import 'package:intl/intl.dart';

/// Utility class for date formatting operations
class DateFormatter {
  DateFormatter._();

  /// Formats an ISO 8601 date string to display format (MMM d, yyyy)
  ///
  /// Example: "2001-08-09T00:00:00.000Z" -> "Aug 9, 2001"
  ///
  /// Returns the original string if parsing fails
  static String formatToDisplay(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('MMM d, yyyy').format(dateTime);
    } catch (e) {
      return isoDate; // Return original if parsing fails
    }
  }

  /// Formats a DateTime object to display format (MMM d, yyyy)
  ///
  /// Example: DateTime(2025, 12, 1) -> "Dec 1, 2025"
  static String formatDateTimeToDisplay(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  /// Formats an ISO 8601 date string to day and month only (MMM d)
  ///
  /// Example: "2001-08-09T00:00:00.000Z" -> "Aug 9"
  ///
  /// Returns the original string if parsing fails
  static String formatToDayMonth(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('MMM d').format(dateTime);
    } catch (e) {
      return isoDate;
    }
  }

  /// Parses an ISO 8601 date string to DateTime
  ///
  /// Returns null if parsing fails
  static DateTime? parseIsoDate(String isoDate) {
    try {
      return DateTime.parse(isoDate);
    } catch (e) {
      return null;
    }
  }

  /// Formats an ISO 8601 date string to time format (hh:mm a)
  ///
  /// Example: "2025-12-01T10:10:35.002Z" -> "10:10 AM"
  /// Example: "2025-12-01T23:30:35.002Z" -> "11:30 PM"
  ///
  /// Returns the original string if parsing fails
  static String formatToTime(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return isoDate; // Return original if parsing fails
    }
  }

  static String formatSyncTime(DateTime? syncTime) {
    if (syncTime == null) return 'Unknown';

    // Always convert to local time for display
    final localSyncTime = syncTime.toLocal();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final syncDate = DateTime(
      localSyncTime.year,
      localSyncTime.month,
      localSyncTime.day,
    );

    final timeFormat = DateFormat('h:mm a'); // 9:45 AM format

    if (syncDate == today) {
      // Today
      return 'Today ${timeFormat.format(localSyncTime)}';
    } else if (syncDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday ${timeFormat.format(localSyncTime)}';
    } else {
      // Other dates
      final dateFormat = DateFormat('MMM dd, h:mm a'); // Jan 20, 9:45 AM
      return dateFormat.format(localSyncTime);
    }
  }

  /// Formats a DateTime object to time format (hh:mm a)
  ///
  /// Example: DateTime(2025, 12, 1, 10, 30) -> "10:30 AM"
  static String formatDateTimeToTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }
}
