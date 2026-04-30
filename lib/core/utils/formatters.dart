/// Formats a listener count into a human-readable string.
/// e.g. 284500 → "284K", 1200000 → "1.2M"
String formatListeners(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}M';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(0)}K';
  }
  return count.toString();
}

/// Formats a [Duration] as MM:SS.
/// e.g. Duration(minutes: 3, seconds: 42) → "03:42"
String formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
