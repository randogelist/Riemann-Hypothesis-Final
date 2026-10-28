'use strict';
// Test-host support only. This module never starts a native process.
// Extend the existing text-stream mock with the binary Size/EOS observations
// needed to test an independently verified empty-file recovery.
function installBinaryHost(h) {
  const c = h.context, previousActiveX = c.ActiveXObject, previousGetFile = c.fso.GetFile;
  const state = {binaryLoads: [], binarySizes: [], binaryEOS: [], binaryCloses: [], fileSizeReads: [],
    beforeBinaryLoad: null, afterBinaryLoad: null, binarySizeOverride: undefined,
    binaryEOSOverride: undefined, binaryPositionOverride: undefined, beforeGetFile: null, afterGetFile: null};
  c.ActiveXObject = function (name) {
    const stream = new previousActiveX(name);
    if (name !== 'ADODB.Stream') return stream;
    let bytes = null, position = 0, filename = null;
    const load = stream.LoadFromFile;
    const close = stream.Close;
    stream.Close = function () { if (stream.Type === 1) state.binaryCloses.push(filename); return close.call(stream); };
    stream.LoadFromFile = function (p) {
      if (stream.Type !== 1) return load.call(stream, p);
      filename = String(p); state.binaryLoads.push(filename);
      if (state.beforeBinaryLoad) state.beforeBinaryLoad(filename);
      bytes = h.memory.read(filename); position = 0;
      if (state.afterBinaryLoad) state.afterBinaryLoad(filename);
    };
    Object.defineProperty(stream, 'Size', {get() {
      if (stream.Type !== 1) throw new Error('Binary review does not emulate text-stream Size');
      state.binarySizes.push(filename);
      return state.binarySizeOverride === undefined ? (bytes ? bytes.length : 0) : state.binarySizeOverride;
    }});
    Object.defineProperty(stream, 'EOS', {get() {
      if (stream.Type !== 1) throw new Error('Binary review does not emulate text-stream EOS');
      state.binaryEOS.push(filename);
      return state.binaryEOSOverride === undefined ? position >= (bytes ? bytes.length : 0) : state.binaryEOSOverride;
    }});
    Object.defineProperty(stream, 'Position', {get() { return state.binaryPositionOverride === undefined ? position : state.binaryPositionOverride; }, set(value) { position = Number(value); }});
    return stream;
  };
  c.fso.GetFile = function (p) {
    const ordinal = state.fileSizeReads.length;
    if (state.beforeGetFile) state.beforeGetFile(String(p), ordinal);
    const file = previousGetFile(p);
    state.fileSizeReads.push({path: String(p), size: file.Size});
    if (state.afterGetFile) state.afterGetFile(String(p), ordinal, file);
    return file;
  };
  h.binary = state; return state;
}
module.exports = {installBinaryHost};
