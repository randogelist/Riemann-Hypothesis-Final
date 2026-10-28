// Optional native Windows read-only mapped-file cache warmer.
// Source-only candidate: not compiled or executed during preparation.
// It neither validates proof artifacts nor constructs/shares a Lean environment.
// The operating system may trim every mapped page; residency is NOT guaranteed.
// Build separately from NativeSha256.cs with existing .NET Framework v4 csc.exe,
// /platform:x64, and references to System.dll and System.Core.dll.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.IO.MemoryMappedFiles;
using System.Runtime.InteropServices;
using System.Security;
using System.Security.Cryptography;
using System.Text;
using System.Threading;

internal static class NativeRamWarm
{
    private const string RequestSchema = "RH_HILBERT_RAM_REQUEST_V1";
    private const string StatusSchema = "RH_HILBERT_RAM_STATUS_V1";
    private const int MaxFiles = 4096;
    private const int MaxRequestBytes = 4 * 1024 * 1024;
    private const long MiB = 1024L * 1024L;
    private const long MaxBudgetMiB = 65536;
    private const long LeaseMilliseconds = 6L * 60L * 60L * 1000L;
    private const long EpochTicks = 621355968000000000L;
    private static readonly UTF8Encoding Utf8 = new UTF8Encoding(false, true);
    private static volatile int TouchSink;

    [StructLayout(LayoutKind.Sequential)]
    private struct MemoryStatus
    {
        internal uint Length;
        internal uint MemoryLoad;
        internal ulong TotalPhysical;
        internal ulong AvailablePhysical;
        internal ulong TotalPageFile;
        internal ulong AvailablePageFile;
        internal ulong TotalVirtual;
        internal ulong AvailableVirtual;
        internal ulong AvailableExtendedVirtual;
    }

    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool GlobalMemoryStatusEx(ref MemoryStatus status);

    private sealed class Request
    {
        internal string[] Paths;
        internal string Sha256;
    }

    private sealed class HeldView : IDisposable
    {
        internal FileStream Stream;
        internal MemoryMappedFile Mapping;
        internal MemoryMappedViewAccessor View;
        internal long Length;

        public void Dispose()
        {
            // Every handle is read-only. Still close the remaining handles if
            // disposal of one object unexpectedly reports an error.
            try { if (View != null) View.Dispose(); } catch { }
            try { if (Mapping != null) Mapping.Dispose(); } catch { }
            try { if (Stream != null) Stream.Dispose(); } catch { }
            View = null;
            Mapping = null;
            Stream = null;
        }
    }

    private sealed class StatusPublicationException : Exception
    {
        internal StatusPublicationException(Exception cause)
            : base("Atomic RAM status publication failed.", cause) { }
    }

    private static string Decimal(long value)
    {
        return value.ToString(CultureInfo.InvariantCulture);
    }

    private static long CanonicalDecimal(string text, string field)
    {
        long value;
        if (!Int64.TryParse(text, NumberStyles.None, CultureInfo.InvariantCulture, out value) ||
            value < 0 || Decimal(value) != text)
            throw new InvalidDataException("Invalid canonical decimal " + field + ".");
        return value;
    }

    private static bool ValidToken(string token)
    {
        if (token == null || token.Length == 0 || token.Length > 128) return false;
        foreach (char c in token)
            if (!((c >= '0' && c <= '9') || (c >= 'A' && c <= 'Z') ||
                (c >= 'a' && c <= 'z') || c == '-' || c == '_')) return false;
        return true;
    }

    private static string HashBytes(byte[] bytes)
    {
        using (SHA256 hash = SHA256.Create())
        {
            if (hash == null) throw new InvalidOperationException("SHA256 provider unavailable.");
            return BitConverter.ToString(hash.ComputeHash(bytes)).Replace("-", "").ToLowerInvariant();
        }
    }

    private static long UnixMilliseconds(DateTime time)
    {
        return (time.ToUniversalTime().Ticks - EpochTicks) / TimeSpan.TicksPerMillisecond;
    }

    private static bool OwnerStartMatches(long expected, long actual)
    {
        // Both values are floored UTC Unix milliseconds. Do not accept a nearby
        // process creation time or repeatedly reopen a potentially reused PID.
        return expected >= 0 && expected == actual;
    }

    private static string NormalizedLocalPath(string path)
    {
        if (String.IsNullOrEmpty(path) || path.Length >= 260 || path.Length < 3 ||
            !((path[0] >= 'A' && path[0] <= 'Z') || (path[0] >= 'a' && path[0] <= 'z')) ||
            path[1] != ':' || path[2] != '\\')
            throw new InvalidDataException("Expected a short absolute local-drive path.");
        foreach (char c in path)
            if (c < 32 || c == '|') throw new InvalidDataException("Invalid character in requested path.");
        if (!String.Equals(Path.GetFullPath(path), path, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("Requested path is not normalized.");
        return path;
    }

    private static bool IsCompiledDataPath(string path)
    {
        string name = Path.GetFileName(path);
        return name.EndsWith(".olean", StringComparison.OrdinalIgnoreCase) ||
            name.IndexOf(".olean.", StringComparison.OrdinalIgnoreCase) >= 0 ||
            name.EndsWith(".ir", StringComparison.OrdinalIgnoreCase) ||
            name.EndsWith(".ir.sig", StringComparison.OrdinalIgnoreCase);
    }

    private static Request ParseRequest(byte[] bytes, string token)
    {
        if (!ValidToken(token)) throw new InvalidDataException("Invalid request token.");
        if (bytes.Length > MaxRequestBytes) throw new InvalidDataException("Request manifest is too large.");
        string text = Utf8.GetString(bytes);
        if (text.Length != 0 && text[0] == '\uFEFF') text = text.Substring(1);
        string[] lines = text.Split(new char[] { '\n' });
        int countLines = lines.Length;
        if (countLines != 0 && lines[countLines - 1] == "") countLines--;
        for (int i = 0; i < countLines; i++)
            if (lines[i].EndsWith("\r", StringComparison.Ordinal))
                lines[i] = lines[i].Substring(0, lines[i].Length - 1);
        if (countLines == 0) throw new InvalidDataException("Empty request manifest.");
        string[] header = lines[0].Split('|');
        if (header.Length != 3 || header[0] != RequestSchema || header[1] != token)
            throw new InvalidDataException("Request schema or token mismatch.");
        long parsedCount = CanonicalDecimal(header[2], "request count");
        if (parsedCount > MaxFiles || parsedCount != countLines - 1)
            throw new InvalidDataException("Request row count is invalid or exceeds 4096.");
        int count = (int)parsedCount;
        string[] paths = new string[count];
        Dictionary<string, bool> seen = new Dictionary<string, bool>(StringComparer.OrdinalIgnoreCase);
        for (int i = 0; i < count; i++)
        {
            string[] row = lines[i + 1].Split('|');
            if (row.Length != 2 || row[0] != Decimal(i))
                throw new InvalidDataException("Missing, duplicate, unordered or invalid request ID.");
            string path = NormalizedLocalPath(row[1]);
            if (!IsCompiledDataPath(path))
                throw new InvalidDataException("Only compiled Lean data files may be warmed.");
            if (seen.ContainsKey(path)) throw new InvalidDataException("Duplicate requested file path.");
            seen.Add(path, true);
            paths[i] = path;
        }
        return new Request { Paths = paths, Sha256 = HashBytes(bytes) };
    }

    private static Request ReadRequest(string path, string token)
    {
        byte[] bytes;
        using (FileStream file = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read))
        {
            long size = file.Length;
            if (size < 0 || size > MaxRequestBytes) throw new InvalidDataException("Request manifest is too large.");
            bytes = new byte[(int)size];
            int done = 0;
            while (done < bytes.Length)
            {
                int n = file.Read(bytes, done, bytes.Length - done);
                if (n == 0) throw new InvalidDataException("Request changed while being read.");
                done += n;
            }
            if (file.ReadByte() != -1) throw new InvalidDataException("Request grew while being read.");
        }
        return ParseRequest(bytes, token);
    }

    private static long BudgetBytes(long requestedBytes, ulong available, int pageSize)
    {
        if (requestedBytes < 0 || pageSize <= 0) throw new ArgumentOutOfRangeException("budget");
        long quarter = (long)(available / 4UL);
        long bounded = Math.Min(requestedBytes, quarter);
        return bounded - bounded % pageSize;
    }

    private static long PageCharge(long length, int pageSize)
    {
        if (length <= 0 || pageSize <= 0 || length > Int64.MaxValue - (pageSize - 1L))
            throw new ArgumentOutOfRangeException("mapped length");
        return ((length + pageSize - 1L) / pageSize) * pageSize;
    }

    private static string LifecycleReason(bool ownerExited, bool stopRequested, long elapsed)
    {
        if (elapsed >= LeaseMilliseconds) return "LEASE_EXPIRED";
        if (ownerExited) return "OWNER_EXITED";
        if (stopRequested) return "STOP_REQUESTED";
        return null;
    }

    private static string SafeMessage(string text)
    {
        string clean = (text ?? "").Replace('\r', ' ').Replace('\n', ' ');
        return clean.Length > 240 ? clean.Substring(0, 240) : clean;
    }

    private sealed class Session : IDisposable
    {
        internal string RequestPath;
        internal string StatusPath;
        internal string StopPath;
        internal string Token;
        internal int OwnerPid;
        internal long OwnerStart;
        internal long RequestedBytes;
        internal Request Request;
        internal Process Owner;
        internal int Pid;
        internal int PageSize;
        internal ulong AvailablePhysical;
        internal long Budget;
        internal long Charged;
        internal long MappedBytes;
        internal long TouchedPages;
        internal int Processed;
        internal int Mapped;
        internal int Warmed;
        internal int Skipped;
        internal int SkippedBudget;
        internal int SkippedEmpty;
        internal int SkippedUnavailable;
        internal string State = "INITIALIZING";
        internal string Reason = "STARTING";
        internal string LastError = "";
        internal bool Terminal;
        private bool published;
        private long sequence;
        private long lastCheck = -250;
        private long lastPublish = -1000;
        private Timer leaseTimer;
        private readonly Stopwatch watch = Stopwatch.StartNew();
        private readonly List<HeldView> held = new List<HeldView>();

        internal void ValidateControlPaths()
        {
            NormalizedLocalPath(RequestPath);
            NormalizedLocalPath(StatusPath);
            NormalizedLocalPath(StopPath);
            string folder = Path.GetDirectoryName(RequestPath);
            if (!folder.StartsWith("E:\\RH-FAST\\workspaces\\", StringComparison.OrdinalIgnoreCase) ||
                !String.Equals(folder, Path.GetDirectoryName(StatusPath), StringComparison.OrdinalIgnoreCase) ||
                !String.Equals(folder, Path.GetDirectoryName(StopPath), StringComparison.OrdinalIgnoreCase) ||
                String.Equals(RequestPath, StatusPath, StringComparison.OrdinalIgnoreCase) ||
                String.Equals(RequestPath, StopPath, StringComparison.OrdinalIgnoreCase) ||
                String.Equals(StatusPath, StopPath, StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("Control paths must be distinct siblings under E:\\RH-FAST\\workspaces.");
            if (!Directory.Exists(folder)) throw new DirectoryNotFoundException("The control directory must already exist.");
            if (File.Exists(StatusPath)) throw new IOException("RAM status path is already in use.");
        }

        internal void Initialize()
        {
            if (IntPtr.Size != 8) throw new PlatformNotSupportedException("The RAM helper requires a 64-bit process.");
            Pid = Process.GetCurrentProcess().Id;
            // No I/O in this callback. If a synchronous mapping/page fault
            // stalls cooperative cleanup, process teardown releases its maps.
            // The parent must treat a stale status plus exit code 3 as a lease
            // timeout, not as a fresh terminal status or a proof result.
            leaseTimer = new Timer(delegate(object ignored) { Environment.Exit(3); },
                null, (int)LeaseMilliseconds, Timeout.Infinite);
            Owner = Process.GetProcessById(OwnerPid);
            // Force acquisition and retain this exact process handle. Subsequent
            // HasExited checks cannot silently follow a reused numeric PID.
            IntPtr ownerHandle = Owner.Handle;
            if (ownerHandle == IntPtr.Zero ||
                !OwnerStartMatches(OwnerStart, UnixMilliseconds(Owner.StartTime)))
                throw new InvalidOperationException("Parent process creation identity mismatch.");
            Request = ReadRequest(RequestPath, Token);
            PageSize = Environment.SystemPageSize;
            MemoryStatus memory = new MemoryStatus();
            memory.Length = (uint)Marshal.SizeOf(typeof(MemoryStatus));
            if (!GlobalMemoryStatusEx(ref memory))
                throw new InvalidOperationException("GlobalMemoryStatusEx failed: " + Marshal.GetLastWin32Error());
            AvailablePhysical = memory.AvailablePhysical;
            Budget = BudgetBytes(RequestedBytes, AvailablePhysical, PageSize);
            Reason = "WARMING";
            Publish();
        }

        private long HeldBytes()
        {
            long result = 0;
            foreach (HeldView item in held) result += item.Length;
            return result;
        }

        internal void Publish()
        {
            sequence++;
            string pending = StatusPath + ".p" + Decimal(Pid) + "." + Decimal(sequence);
            bool created = false;
            try
            {
                if (pending.Length >= 260) throw new PathTooLongException("RAM status temporary path is too long.");
                StringBuilder b = new StringBuilder();
                b.AppendLine("SCHEMA=" + StatusSchema);
                b.AppendLine("TOKEN=" + Token);
                b.AppendLine("REQUEST_SHA256=" + (Request == null ? "UNAVAILABLE" : Request.Sha256));
                b.AppendLine("STATE=" + State);
                b.AppendLine("TERMINAL=" + (Terminal ? "1" : "0"));
                b.AppendLine("OWNER_PID=" + Decimal(OwnerPid));
                b.AppendLine("OWNER_START_UNIX_MS=" + Decimal(OwnerStart));
                b.AppendLine("PID=" + Decimal(Pid));
                b.AppendLine("SEQUENCE=" + Decimal(sequence));
                b.AppendLine("HEARTBEAT_UNIX_MS=" + Decimal(UnixMilliseconds(DateTime.UtcNow)));
                b.AppendLine("ELAPSED_MS=" + Decimal(watch.ElapsedMilliseconds));
                b.AppendLine("REQUEST_FILES=" + Decimal(Request == null ? 0 : Request.Paths.Length));
                b.AppendLine("PROCESSED_FILES=" + Decimal(Processed));
                b.AppendLine("MAPPED_FILES=" + Decimal(Mapped));
                b.AppendLine("WARMED_FILES=" + Decimal(Warmed));
                b.AppendLine("SKIPPED_FILES=" + Decimal(Skipped));
                b.AppendLine("HELD_FILES=" + Decimal(held.Count));
                b.AppendLine("MAPPED_BYTES=" + Decimal(MappedBytes));
                b.AppendLine("HELD_BYTES=" + Decimal(HeldBytes()));
                b.AppendLine("CHARGED_BYTES=" + Decimal(Charged));
                b.AppendLine("BUDGET_BYTES=" + Decimal(Budget));
                b.AppendLine("AVAILABLE_PHYSICAL_BYTES=" + AvailablePhysical.ToString(CultureInfo.InvariantCulture));
                b.AppendLine("TOUCHED_PAGES=" + Decimal(TouchedPages));
                b.AppendLine("SKIP_BUDGET=" + Decimal(SkippedBudget));
                b.AppendLine("SKIP_EMPTY=" + Decimal(SkippedEmpty));
                b.AppendLine("SKIP_UNAVAILABLE=" + Decimal(SkippedUnavailable));
                b.AppendLine("REASON=" + SafeMessage(Reason));
                b.AppendLine("LAST_ERROR=" + SafeMessage(LastError));
                b.AppendLine("MODE=WARM_MAPPED_FILE_CACHE");
                b.AppendLine("RESIDENCY=NOT_GUARANTEED");
                b.AppendLine("LEAN_ENVIRONMENT=NOT_SHARED");
                using (FileStream output = new FileStream(pending, FileMode.CreateNew, FileAccess.Write, FileShare.None))
                {
                    created = true;
                    byte[] bytes = Utf8.GetBytes(b.ToString());
                    output.Write(bytes, 0, bytes.Length);
                }
                if (published) File.Replace(pending, StatusPath, null);
                else File.Move(pending, StatusPath);
                published = true;
                lastPublish = watch.ElapsedMilliseconds;
            }
            catch (Exception e)
            {
                if (created) { try { File.Delete(pending); } catch { } }
                throw new StatusPublicationException(e);
            }
        }

        private bool StopFileMatches()
        {
            if (!File.Exists(StopPath)) return false;
            try
            {
                using (FileStream input = new FileStream(StopPath, FileMode.Open, FileAccess.Read,
                    FileShare.ReadWrite | FileShare.Delete))
                {
                    if (input.Length > 512) return false;
                    using (StreamReader reader = new StreamReader(input, Utf8, true))
                        return String.Equals(reader.ReadToEnd().Trim(), Token, StringComparison.Ordinal);
                }
            }
            catch (IOException) { return false; }
            catch (UnauthorizedAccessException) { return false; }
        }

        internal bool CheckLifecycle(bool force)
        {
            long elapsed = watch.ElapsedMilliseconds;
            if (!force && elapsed - lastCheck < 200) return false;
            lastCheck = elapsed;
            bool exited;
            try { exited = Owner == null || Owner.HasExited; }
            catch { exited = true; }
            string reason = LifecycleReason(exited, StopFileMatches(), elapsed);
            if (reason != null) { Reason = reason; return true; }
            if (elapsed - lastPublish >= 1000) Publish();
            return false;
        }

        private bool Touch(HeldView item)
        {
            int sink = 0;
            for (long offset = 0; offset < item.Length; offset += PageSize)
            {
                if (CheckLifecycle(false)) return false;
                sink ^= item.View.ReadByte(offset);
                TouchedPages++;
            }
            TouchSink = sink;
            return true;
        }

        private static bool SkippableFileError(Exception e)
        {
            return e is IOException || e is UnauthorizedAccessException || e is SecurityException ||
                e is ArgumentException;
        }

        private bool WarmOne(string path)
        {
            HeldView item = new HeldView();
            bool retained = false;
            try
            {
                item.Stream = new FileStream(path, FileMode.Open, FileAccess.Read,
                    FileShare.ReadWrite | FileShare.Delete, 4096, FileOptions.RandomAccess);
                item.Length = item.Stream.Length;
                if (item.Length == 0)
                {
                    Skipped++; SkippedEmpty++; Processed++;
                    return true;
                }
                long charge = PageCharge(item.Length, PageSize);
                if (charge > Budget - Charged)
                {
                    Skipped++; SkippedBudget++; Processed++;
                    return true;
                }
                // Charge once even if a later operation fails. This bounds the
                // page spans attempted, rather than recycling a budget through
                // an unbounded series of failed partial warmings.
                Charged += charge;
                item.Mapping = MemoryMappedFile.CreateFromFile(item.Stream, null, 0,
                    MemoryMappedFileAccess.Read, null, HandleInheritability.None, true);
                item.View = item.Mapping.CreateViewAccessor(0, item.Length, MemoryMappedFileAccess.Read);
                held.Add(item);
                retained = true;
                Mapped++;
                MappedBytes += item.Length;
                if (!Touch(item)) return false;
                Warmed++;
                Processed++;
                return true;
            }
            catch (Exception e)
            {
                if (!SkippableFileError(e)) throw;
                if (retained) { held.Remove(item); retained = false; }
                Skipped++; SkippedUnavailable++; Processed++;
                LastError = e.GetType().Name + ": " + e.Message;
                return true;
            }
            finally
            {
                if (!retained) item.Dispose();
            }
        }

        internal void CloseViews()
        {
            foreach (HeldView item in held) item.Dispose();
            held.Clear();
        }

        private void Stop()
        {
            CloseViews();
            State = "STOPPED";
            Terminal = true;
            Publish();
        }

        internal int Run()
        {
            if (CheckLifecycle(true)) { Stop(); return 0; }
            if (Budget == 0)
            {
                Skipped = Request.Paths.Length;
                SkippedBudget = Skipped;
                Processed = Skipped;
                State = "PARTIAL";
                Reason = "BUDGET_ZERO";
                Terminal = true;
                Publish();
                return 0;
            }
            foreach (string path in Request.Paths)
            {
                if (CheckLifecycle(true) || !WarmOne(path)) { Stop(); return 0; }
            }
            State = Skipped == 0 ? "READY" : "PARTIAL";
            Reason = Request.Paths.Length == 0 ? "EMPTY_MANIFEST" :
                (Skipped == 0 ? "TARGETS_WARMED" : "TARGETS_PARTIALLY_WARMED");
            Terminal = held.Count == 0;
            Publish();
            if (Terminal) return 0;
            while (!CheckLifecycle(true)) Thread.Sleep(200);
            Stop();
            return 0;
        }

        public void Dispose()
        {
            CloseViews();
            if (Owner != null) { Owner.Dispose(); Owner = null; }
            if (leaseTimer != null) { leaseTimer.Dispose(); leaseTimer = null; }
        }
    }

    private static void ExpectRejected(string text, string token)
    {
        bool rejected = false;
        try { ParseRequest(Utf8.GetBytes(text), token); }
        catch (InvalidDataException) { rejected = true; }
        if (!rejected) throw new InvalidOperationException("Parser rejection self-test failed.");
    }

    private static void SelfTest()
    {
        // Pure parsing/arithmetic/lifecycle checks only: no file access, process
        // inventory, mapping, RAM probing, compiler or external executable.
        const string token = "selftest_01";
        string header = RequestSchema + "|" + token + "|";
        Request one = ParseRequest(Utf8.GetBytes("\uFEFF" + header + "1\r\n0|C:\\Cache\\Basic.olean\r\n"), token);
        if (one.Paths.Length != 1 || one.Paths[0] != "C:\\Cache\\Basic.olean" || one.Sha256.Length != 64)
            throw new InvalidOperationException("Parser acceptance self-test failed.");
        if (ParseRequest(Utf8.GetBytes(header + "0\n"), token).Paths.Length != 0)
            throw new InvalidOperationException("Empty parser self-test failed.");
        ExpectRejected(header + "1\n1|C:\\Cache\\Basic.olean\n", token);
        ExpectRejected(header + "2\n0|C:\\Cache\\Basic.olean\n1|c:\\cache\\basic.olean\n", token);
        ExpectRejected(header + "1\n0|C:\\Cache\\Source.lean\n", token);
        ExpectRejected(header + "1\n0|C:\\Cache\\Basic.olean\n", "wrong_token");
        ExpectRejected(header + "01\n0|C:\\Cache\\Basic.olean\n", token);
        if (BudgetBytes(8 * MiB, (ulong)(16 * MiB), 4096) != 4 * MiB ||
            BudgetBytes(0, (ulong)(16 * MiB), 4096) != 0 ||
            PageCharge(1, 4096) != 4096 || PageCharge(4097, 4096) != 8192 ||
            !OwnerStartMatches(1234, 1234) || OwnerStartMatches(1234, 1235) ||
            LifecycleReason(false, false, 0) != null ||
            LifecycleReason(true, false, 0) != "OWNER_EXITED" ||
            LifecycleReason(false, true, 0) != "STOP_REQUESTED" ||
            LifecycleReason(false, false, LeaseMilliseconds) != "LEASE_EXPIRED")
            throw new InvalidOperationException("Budget/lifecycle self-test failed.");
        if (HashBytes(new byte[0]) != "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
            throw new InvalidOperationException("Manifest digest self-test failed.");
    }

    private static int Main(string[] args)
    {
        Session session = null;
        bool controlPathsValidated = false;
        try
        {
            if (args.Length == 1 && args[0] == "--self-test")
            {
                SelfTest();
                Console.WriteLine("RAM_WARM_SELF_TEST=PASS");
                return 0;
            }
            if (args.Length != 8 || args[0] != "--warm")
                throw new ArgumentException("Expected --warm REQUEST STATUS STOP OWNER_PID OWNER_START_UNIX_MS TOKEN BUDGET_MB.");
            if (!ValidToken(args[6])) throw new ArgumentException("Invalid session token.");
            long pid = CanonicalDecimal(args[4], "owner PID");
            long start = CanonicalDecimal(args[5], "owner creation milliseconds");
            long budgetMiB = CanonicalDecimal(args[7], "budget MB");
            if (pid <= 0 || pid > Int32.MaxValue || budgetMiB > MaxBudgetMiB)
                throw new ArgumentOutOfRangeException("PID or budget MB exceeds the supported bound.");
            session = new Session {
                RequestPath = args[1], StatusPath = args[2], StopPath = args[3],
                OwnerPid = (int)pid, OwnerStart = start, Token = args[6], RequestedBytes = budgetMiB * MiB
            };
            session.ValidateControlPaths();
            controlPathsValidated = true;
            session.Initialize();
            Console.WriteLine("RAM_WARM_MODE=WARM_MAPPED_FILE_CACHE");
            return session.Run();
        }
        catch (Exception e)
        {
            if (session != null)
            {
                session.CloseViews();
                if (controlPathsValidated)
                {
                    session.State = "PARTIAL";
                    session.Reason = "HELPER_ERROR";
                    session.LastError = e.GetType().Name + ": " + e.Message;
                    session.Terminal = true;
                    try { session.Publish(); } catch { }
                }
            }
            Console.Error.WriteLine("RAM_WARM_ERROR=" + e.GetType().Name + ": " + SafeMessage(e.Message));
            return 1;
        }
        finally
        {
            if (session != null) session.Dispose();
        }
    }
}
