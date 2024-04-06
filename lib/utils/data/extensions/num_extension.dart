extension NumExt on num {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));

  String fizeSizeString() {
    if (this < 1024) return '${_fileSizePrecision(this)} B';
    final double sizeInMb = this / (1024 * 1024);
    if (sizeInMb < 1) return '${_fileSizePrecision(_sizeInKb(this))} KB';
    return '${_fileSizePrecision(sizeInMb)} MB';
  }

  _sizeInKb(num byteSize) => byteSize / 1024;

  _fileSizePrecision(num byteSize) => byteSize.toPrecision(2);
}

extension IntExt on int?{
  String toDurationString({bool showHour = false}) {
    if(this==null) return '00:00:00';
    // Duration _d = Duration(seconds: this!);
    int h = this!~/3600;
    int n = this!%3600;
    int m = n~/60;
    int s = n%60;
    if(showHour||h>0)
    return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }
}