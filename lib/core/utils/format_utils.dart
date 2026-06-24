class FormatUtils {
  static String formatListeners(int count) {
    if (count >= 1000000) {
      final val = count / 1000000;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}M';
    } else if (count >= 1000) {
      final val = count / 1000;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}K';
    }
    return count.toString();
  }
}
