part of globalauth.common;

/**
 * This class splits [String] values into individual lines based on a
 * carriage-return line-feed.
 */
class CRLFLineSplitter extends Converter<String, List<String>> {

  const CRLFLineSplitter();

  @override
  List<String> convert(String data) {
    var lines = new List<String>();
    _CRLFLineSplitterSink._addSlice(data, 0, data.length, true, lines.add);
    return lines;
  }

  @override
  StringConversionSink startChunkedConversion(Sink<String> sink) {
    if (sink is! StringConversionSink) {
      sink = new StringConversionSink.from(sink);
    }
    return new _CRLFLineSplitterSink(sink);
  }
}

class _CRLFLineSplitterSink extends StringConversionSinkBase {
  static const int _LF = 10;
  static const int _CR = 13;

  final StringConversionSink _sink;

  String _carry;

  _CRLFLineSplitterSink(this._sink);

  @override
  void addSlice(String chunk, int start, int end, bool isLast) {
    if (_carry != null) {
      chunk = _carry + chunk.substring(start, end);
      start = 0;
      end = chunk.length;
      _carry = null;
    }
    _carry = _addSlice(chunk, start, end, isLast, _sink.add);
    if (isLast) _sink.close();
  }

  @override
  void close() {
    addSlice('', 0, 0, true);
  }

  static String _addSlice(String chunk, int start, int end, bool isLast,
                          void adder(String val)) {

    int pos = start;
    while (pos < end) {
      int skip = 0;
      int char = chunk.codeUnitAt(pos);
      if (char == _CR) {
        if (pos + 1 < end) {
          if (chunk.codeUnitAt(pos + 1) == _LF) {
            skip = 2;
          }
        } else if (!isLast) {
          return chunk.substring(start, end);
        }
      }
      if (skip > 0) {
        adder(chunk.substring(start, pos));
        start = pos = pos + skip;
      } else {
        pos++;
      }
    }
    if (pos != start) {
      var carry = chunk.substring(start, pos);
      if (isLast) {
        // Add remaining
        adder(carry);
      } else {
        return carry;
      }
    }
    return null;
  }
}