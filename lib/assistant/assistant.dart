
import 'dart:math';


String formatBytes(int bytes, {int decimals = 2}) {
  if (bytes <= 0) return "0 B";
  const List<String> sizes = [
    "B",
    "KB",
    "MB",
    "GB",
    "TB",
    "PB",
    "EB",
    "ZB",
    "YB",
  ];
  final int i = (log(bytes) / log(1024)).floor();
  final double adjustedSize = bytes / pow(1024, i);
  return "${adjustedSize.toStringAsFixed(decimals)} ${sizes[i]}";
}
