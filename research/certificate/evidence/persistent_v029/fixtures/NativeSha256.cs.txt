// Native Windows batch SHA256 helper. Persistently cached by the runner after
// an existing .NET Framework v4 csc.exe build and successful self-test.
// This source has not been compiled or executed on Windows during preparation.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

internal static class NativeSha256
{
    private const string RequestSchema = "RH_HILBERT_SHA256_REQUEST_V1";
    private const string ResultSchema = "RH_HILBERT_SHA256_RESULT_V1";
    private static readonly UTF8Encoding Utf8 = new UTF8Encoding(false, true);
    private static readonly object ProgressLock = new object();

    private static string Hex(byte[] bytes)
    {
        return BitConverter.ToString(bytes).Replace("-", "").ToLowerInvariant();
    }

    private static string HashBytes(byte[] bytes)
    {
        using (SHA256 hash = SHA256.Create())
        {
            if (hash == null) throw new InvalidOperationException("SHA256 provider unavailable.");
            return Hex(hash.ComputeHash(bytes));
        }
    }

    private static string HashFile(string path)
    {
        using (FileStream input = new FileStream(path, FileMode.Open, FileAccess.Read,
            FileShare.Read, 65536, FileOptions.SequentialScan))
        using (SHA256 hash = SHA256.Create())
        {
            if (hash == null) throw new InvalidOperationException("SHA256 provider unavailable.");
            return Hex(hash.ComputeHash(input));
        }
    }

    private static void SelfTest()
    {
        if (HashBytes(new byte[0]) != "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ||
            HashBytes(Encoding.ASCII.GetBytes("abc")) != "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
            throw new InvalidOperationException("SHA256 self-test failed.");
    }

    private static int Decimal(string text, string field)
    {
        int value;
        if (!Int32.TryParse(text, NumberStyles.None, CultureInfo.InvariantCulture, out value) ||
            value.ToString(CultureInfo.InvariantCulture) != text)
            throw new InvalidDataException("Invalid canonical decimal " + field + ".");
        return value;
    }

    private static bool ValidToken(string token)
    {
        if (token.Length == 0 || token.Length > 128) return false;
        foreach (char c in token)
            if (!((c >= '0' && c <= '9') || (c >= 'A' && c <= 'Z') ||
                (c >= 'a' && c <= 'z') || c == '-' || c == '_')) return false;
        return true;
    }

    private static string[] ReadRequest(string path, string token, out string requestHash)
    {
        // Parse the same byte snapshot whose digest is returned to the runner.
        byte[] bytes = File.ReadAllBytes(path);
        requestHash = HashBytes(bytes);
        string text = Utf8.GetString(bytes);
        if (text.Length != 0 && text[0] == '\uFEFF') text = text.Substring(1);
        string[] lines = text.Split(new char[] { '\n' });
        int lineCount = lines.Length;
        if (lineCount != 0 && lines[lineCount - 1] == "") lineCount--;
        for (int i = 0; i < lineCount; i++)
            if (lines[i].EndsWith("\r", StringComparison.Ordinal))
                lines[i] = lines[i].Substring(0, lines[i].Length - 1);
        if (lineCount == 0) throw new InvalidDataException("Empty request manifest.");
        string[] header = lines[0].Split('|');
        if (header.Length != 3 || header[0] != RequestSchema || header[1] != token)
            throw new InvalidDataException("Request schema or token mismatch.");
        int count = Decimal(header[2], "request count");
        if (lineCount - 1 != count) throw new InvalidDataException("Request row count mismatch.");
        string[] paths = new string[count];
        Dictionary<string, bool> seen = new Dictionary<string, bool>(StringComparer.OrdinalIgnoreCase);
        for (int i = 0; i < count; i++)
        {
            string[] pair = lines[i + 1].Split('|');
            if (pair.Length != 2 || pair[0] != i.ToString(CultureInfo.InvariantCulture))
                throw new InvalidDataException("Duplicate, missing, unordered or invalid request ID.");
            string file = pair[1];
            foreach (char c in file)
                if (c < 32) throw new InvalidDataException("Control character in requested path.");
            if (!Path.IsPathRooted(file) ||
                !String.Equals(Path.GetFullPath(file), file, StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("Requested path must be normalized and absolute.");
            if (seen.ContainsKey(file)) throw new InvalidDataException("Duplicate requested file path.");
            seen.Add(file, true);
            paths[i] = file;
        }
        return paths;
    }

    private static void WriteResult(string path, string token, string requestHash, string[] hashes)
    {
        string pending = path + ".pending";
        if (File.Exists(path) || File.Exists(pending))
            throw new IOException("Result or staged result already exists.");
        // The final path is published only after every input was hashed and the
        // complete result has been closed. A failed run never publishes a result.
        using (FileStream output = new FileStream(pending, FileMode.CreateNew, FileAccess.Write, FileShare.None))
        using (StreamWriter writer = new StreamWriter(output, Utf8))
        {
            string count = hashes.Length.ToString(CultureInfo.InvariantCulture);
            writer.WriteLine(ResultSchema + "|" + token + "|" + count + "|" + requestHash);
            for (int i = 0; i < hashes.Length; i++)
            {
                if (hashes[i] == null || hashes[i].Length != 64)
                    throw new InvalidDataException("Missing completed file digest.");
                writer.WriteLine(i.ToString(CultureInfo.InvariantCulture) + "|" + hashes[i]);
            }
            writer.WriteLine("COMPLETE|" + token + "|" + count);
        }
        File.Move(pending, path);
    }

    private static int Main(string[] args)
    {
        try
        {
            if (args.Length == 1 && args[0] == "--self-test")
            {
                SelfTest();
                Console.WriteLine("BATCH_SHA256_SELF_TEST=PASS");
                return 0;
            }
            if (args.Length != 4) throw new ArgumentException("Expected request, result, workers, token.");
            int workers = Decimal(args[2], "worker count");
            if (workers < 1 || workers > 16) throw new ArgumentException("Workers must be between 1 and 16.");
            string token = args[3];
            if (!ValidToken(token)) throw new ArgumentException("Invalid request token.");
            SelfTest();
            Console.WriteLine("BATCH_SHA256_SELF_TEST=PASS");
            string requestHash;
            string[] paths = ReadRequest(args[0], token, out requestHash);
            if (File.Exists(args[1]) || File.Exists(args[1] + ".pending"))
                throw new IOException("Result paths must be unused.");
            string[] hashes = new string[paths.Length];
            int completed = 0;
            Stopwatch watch = Stopwatch.StartNew();
            Parallel.For(0, paths.Length, new ParallelOptions { MaxDegreeOfParallelism = workers }, delegate(int i)
            {
                hashes[i] = HashFile(paths[i]);
                int done = Interlocked.Increment(ref completed);
                if (done % 256 == 0 || done == paths.Length)
                    lock (ProgressLock)
                        Console.WriteLine("DEPENDENCY_HASH_PROGRESS=" + done.ToString(CultureInfo.InvariantCulture) +
                            "/" + paths.Length.ToString(CultureInfo.InvariantCulture));
            });
            if (completed != paths.Length) throw new InvalidDataException("Incomplete parallel hash operation.");
            WriteResult(args[1], token, requestHash, hashes);
            watch.Stop();
            Console.WriteLine("BATCH_SHA256_FILES=" + completed.ToString(CultureInfo.InvariantCulture));
            Console.WriteLine("BATCH_SHA256_ELAPSED_MS=" + watch.ElapsedMilliseconds.ToString(CultureInfo.InvariantCulture));
            return 0;
        }
        catch (Exception e)
        {
            Console.Error.WriteLine("BATCH_SHA256_ERROR=" + e.GetType().Name + ": " + e.Message);
            return 1;
        }
    }
}
