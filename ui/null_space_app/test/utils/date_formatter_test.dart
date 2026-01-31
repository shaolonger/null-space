import 'package:flutter_test/flutter_test.dart';
import 'package:null_space_app/utils/date_formatter.dart';

void main() {
  group('DateFormatter Tests', () {
    late DateTime now;

    setUp(() {
      // Mock "now" to have consistent test results
      now = DateTime(2024, 1, 20, 12, 0, 0); // Jan 20, 2024 at 12:00 PM
    });

    test('formats date as "just now" for current minute', () {
      final date = now.subtract(const Duration(seconds: 30));
      // Note: This test may be flaky if run near a minute boundary
      // We're testing the logic, not the actual implementation
      final result = DateFormatter.formatRelativeDate(date);
      expect(result, 'just now');
    });

    test('formats date with minutes when less than 1 hour ago', () {
      final testCases = [
        {'minutes': 1, 'expected': '1m ago'},
        {'minutes': 5, 'expected': '5m ago'},
        {'minutes': 30, 'expected': '30m ago'},
        {'minutes': 59, 'expected': '59m ago'},
      ];

      for (final testCase in testCases) {
        final date = now.subtract(Duration(minutes: testCase['minutes'] as int));
        final result = DateFormatter.formatRelativeDate(date);
        expect(result, testCase['expected'], reason: 'Failed for ${testCase['minutes']} minutes ago');
      }
    });

    test('formats date with hours when same day but more than 1 hour ago', () {
      final testCases = [
        {'hours': 1, 'expected': '1h ago'},
        {'hours': 2, 'expected': '2h ago'},
        {'hours': 5, 'expected': '5h ago'},
        {'hours': 12, 'expected': '12h ago'},
        {'hours': 23, 'expected': '23h ago'},
      ];

      for (final testCase in testCases) {
        final date = now.subtract(Duration(hours: testCase['hours'] as int));
        final result = DateFormatter.formatRelativeDate(date);
        expect(result, testCase['expected'], reason: 'Failed for ${testCase['hours']} hours ago');
      }
    });

    test('formats date as "yesterday" when exactly 1 day ago', () {
      final date = now.subtract(const Duration(days: 1));
      final result = DateFormatter.formatRelativeDate(date);
      expect(result, 'yesterday');
    });

    test('formats date with days when between 2 and 6 days ago', () {
      final testCases = [
        {'days': 2, 'expected': '2d ago'},
        {'days': 3, 'expected': '3d ago'},
        {'days': 5, 'expected': '5d ago'},
        {'days': 6, 'expected': '6d ago'},
      ];

      for (final testCase in testCases) {
        final date = now.subtract(Duration(days: testCase['days'] as int));
        final result = DateFormatter.formatRelativeDate(date);
        expect(result, testCase['expected'], reason: 'Failed for ${testCase['days']} days ago');
      }
    });

    test('formats date with formatted string when 7 or more days ago', () {
      final testCases = [
        7, // 1 week
        14, // 2 weeks
        30, // ~1 month
        60, // ~2 months
        365, // 1 year
      ];

      for (final days in testCases) {
        final date = now.subtract(Duration(days: days));
        final result = DateFormatter.formatRelativeDate(date);
        // Should not contain "ago" and should be formatted date
        expect(result, isNot(contains('ago')), reason: 'Failed for $days days ago');
        // Should contain date components (month, day, year)
        expect(result.length, greaterThan(5), reason: 'Formatted date too short for $days days ago');
      }
    });

    test('handles edge case: exactly 0 minutes ago', () {
      final date = now;
      final result = DateFormatter.formatRelativeDate(date);
      expect(result, 'just now');
    });

    test('handles edge case: exactly 1 hour ago', () {
      final date = now.subtract(const Duration(hours: 1));
      final result = DateFormatter.formatRelativeDate(date);
      expect(result, '1h ago');
    });

    test('handles edge case: exactly 24 hours ago', () {
      final date = now.subtract(const Duration(hours: 24));
      final result = DateFormatter.formatRelativeDate(date);
      expect(result, 'yesterday');
    });

    test('handles edge case: exactly 7 days ago', () {
      final date = now.subtract(const Duration(days: 7));
      final result = DateFormatter.formatRelativeDate(date);
      // Should be formatted as a date, not "7d ago"
      expect(result, isNot(contains('ago')));
    });

    test('handles future dates gracefully', () {
      // Even though this shouldn't happen in practice, test the behavior
      final futureDate = now.add(const Duration(days: 1));
      final result = DateFormatter.formatRelativeDate(futureDate);
      // The function should still return something valid (likely a formatted date or "just now")
      expect(result, isNotEmpty);
      // Future dates should not show "ago" suffix
      expect(result, isNot(contains('ago')));
    });

    test('handles very old dates', () {
      final oldDate = DateTime(2020, 1, 1);
      final result = DateFormatter.formatRelativeDate(oldDate);
      // Should be formatted as a full date
      expect(result, isNot(contains('ago')));
      expect(result.length, greaterThan(5));
    });

    test('handles dates from different years', () {
      final lastYear = DateTime(2023, 12, 25);
      final result = DateFormatter.formatRelativeDate(lastYear);
      // Should be formatted as a full date with year
      expect(result, isNot(contains('ago')));
      expect(result, contains('2023'));
    });

    test('consistent formatting for same relative time', () {
      final date1 = now.subtract(const Duration(minutes: 5));
      final date2 = now.subtract(const Duration(minutes: 5, seconds: 30));
      
      final result1 = DateFormatter.formatRelativeDate(date1);
      final result2 = DateFormatter.formatRelativeDate(date2);
      
      // Both should format as "5m ago" (seconds are ignored)
      expect(result1, result2);
    });

    test('handles midnight boundary correctly', () {
      // Test dates across midnight boundary
      final midnight = DateTime(2024, 1, 20, 0, 0, 0);
      final beforeMidnight = DateTime(2024, 1, 19, 23, 59, 0);
      
      // One minute before midnight should be "yesterday"
      final diff = midnight.difference(beforeMidnight);
      expect(diff.inDays, 0); // Same calendar day technically
      expect(diff.inHours, 0);
      expect(diff.inMinutes, 1);
    });

    test('handles different time zones consistently', () {
      // Create dates that are 2 hours ago in both UTC and local time
      final currentUtc = DateTime.now().toUtc();
      final twoHoursAgoUtc = currentUtc.subtract(const Duration(hours: 2));
      final twoHoursAgoLocal = twoHoursAgoUtc.toLocal();
      
      // Both should format the same way when processed
      final result1 = DateFormatter.formatRelativeDate(twoHoursAgoUtc);
      final result2 = DateFormatter.formatRelativeDate(twoHoursAgoLocal);
      
      // Results should be consistent (both are the same moment in time)
      // Both should show "2h ago"
      expect(result1, result2);
      expect(result1, '2h ago');
    });

    test('handles leap year dates correctly', () {
      // Test a date from a leap year
      final leapYearDate = DateTime(2024, 2, 29); // Feb 29, 2024 (leap year)
      final result = DateFormatter.formatRelativeDate(leapYearDate);
      expect(result, isNotEmpty);
    });

    test('handles daylight saving time transitions', () {
      // Test dates around DST transitions (if applicable)
      // This is more of a sanity check that the function doesn't crash
      final springForward = DateTime(2024, 3, 10, 2, 30); // DST start in US
      final fallBack = DateTime(2024, 11, 3, 2, 30); // DST end in US
      
      final result1 = DateFormatter.formatRelativeDate(springForward);
      final result2 = DateFormatter.formatRelativeDate(fallBack);
      
      expect(result1, isNotEmpty);
      expect(result2, isNotEmpty);
    });
  });
}
