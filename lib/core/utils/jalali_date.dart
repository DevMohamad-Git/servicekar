/// Jalali (Persian solar) date conversion and formatting for the UI.
///
/// Storage and picker both deal in Gregorian [DateTime]; this module
/// converts between Gregorian and Jalali, and formats Jalali dates
/// for display in the Persian interface (RTL page).
///
/// The converter uses the exact algorithm from `shamsi_date` / `persian_date`
/// packages without pulling either dependency — the arithmetic is stable,
/// pure-Dart, and well-sourced from published references (Kazimierz M.
/// Borkowski, Earth, Moon, and Planets, 1996).
///
/// All date arithmetic is done in UTC-safe [DateTime] instances; the
/// returned string is a readable Persian-formatted Jalali date.
library;

const _persianDigits = '۰۱۲۳۴۵۶۷۸۹';

/// Persian weekday labels for the calendar header (Saturday → Friday).
const persianWeekdays = <String>[
  'ش', // شنبه
  'ی', // یکشنبه
  'د', // دوشنبه
  'س', // سه‌شنبه
  'چ', // چهارشنبه
  'پ', // پنج‌شنبه
  'ج', // جمعه
];

/// Persian month names (1-indexed).
const persianMonthNames = <int, String>{
  1: 'فروردین',
  2: 'اردیبهشت',
  3: 'خرداد',
  4: 'تیر',
  5: 'مرداد',
  6: 'شهریور',
  7: 'مهر',
  8: 'آبان',
  9: 'آذر',
  10: 'دی',
  11: 'بهمن',
  12: 'اسفند',
};

/// One Gregorian [DateTime] converted to its Jalali (Shamsi) components.
class JalaliDate {
  const JalaliDate({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month;
  final int day;

  /// Maps month number (1-indexed) to its Persian name.
  static const Map<int, String> _monthNames = persianMonthNames;

  /// Human-readable Persian date string, e.g. "۲۱ مرداد ۱۴۰۵".
  String format() {
    final dayStr = _toPersianDigits(day);
    final monthName = _monthNames[month] ?? '';
    final yearStr = _toPersianDigits(year);
    return '$dayStr $monthName $yearStr';
  }

  /// Short numeric format, e.g. "۱۴۰۵/۰۵/۲۱".
  String formatNumeric() {
    final y = _toPersianDigits(year);
    final m = _toPersianDigits(month).padLeft(2, _toPersianDigits(0));
    final d = _toPersianDigits(day).padLeft(2, _toPersianDigits(0));
    return '$y/$m/$d';
  }

  @override
  String toString() => format();
}

/// Convert a Gregorian [DateTime] to its Jalali equivalent.
///
/// Algorithm: based on Jalaali calendar conversion originally published by
/// Kazimierz M. Borkowski (Earth, Moon, and Planets, 1996) and widely used
/// in the Persian developer community (Roozbeh Pournader, et al.).
JalaliDate toJalali(DateTime gregorian) {
  // Work in UTC to avoid DST / timezone offsets.
  final date = DateTime.utc(gregorian.year, gregorian.month, gregorian.day);

  final gy = date.year;
  final gm = date.month;
  final gd = date.day;

  // Cumulative days before each Gregorian month (Jan = index 0).
  const gMonthDays = <int>[
    0,
    31,
    59,
    90,
    120,
    151,
    181,
    212,
    243,
    273,
    304,
    334,
  ];

  var gDayNo =
      365 * (gy - 1600) +
      ((gy - 1600 + 3) ~/ 4) -
      ((gy - 1600 + 99) ~/ 100) +
      ((gy - 1600 + 399) ~/ 400);
  gDayNo += gMonthDays[gm - 1] + (gd - 1);
  if (gm > 2 && ((gy % 4 == 0 && gy % 100 != 0) || (gy % 400 == 0))) {
    // Leap day after Feb.
    gDayNo += 1;
  }

  // Days since the epoch of the Jalaali calendar (1 Farvardin 1).
  var jDayNo = gDayNo - 79;

  // Each 33-year Jalaali cycle has 12053 days.
  final jNp = jDayNo ~/ 12053;
  jDayNo %= 12053;

  // 1461 days per 4-year block; carry the block count into the year.
  var jYear = 979 + 33 * jNp + 4 * (jDayNo ~/ 1461);
  jDayNo %= 1461;

  // Handle the 366-day leap year inside the 4-year block.
  if (jDayNo >= 366) {
    jYear += (jDayNo - 1) ~/ 365;
    jDayNo = (jDayNo - 1) % 365;
  }

  // Split the 365-day year into the six 31-day months, then the rest.
  final int jMonth;
  final int jDay;
  if (jDayNo < 186) {
    jMonth = 1 + jDayNo ~/ 31;
    jDay = 1 + jDayNo % 31;
  } else {
    jMonth = 7 + (jDayNo - 186) ~/ 30;
    jDay = 1 + (jDayNo - 186) % 30;
  }

  return JalaliDate(year: jYear, month: jMonth, day: jDay);
}

/// Convert a Jalali date to its Gregorian [DateTime] equivalent.
///
/// This is the mathematical inverse of [toJalali]. The algorithm
/// computes the same `jDayNo` that the forward conversion produces,
/// then converts it to a Gregorian date.
DateTime jalaliToGregorian(int year, int month, int day) {
  // Compute jDayNo the same way the forward conversion does.
  final jDayNo = _jalaliToJDayNo(year, month, day);

  // Convert back to Gregorian: gDayNo = jDayNo + 79, then decompose.
  final gDayNo = jDayNo + 79;

  return _gDayNoToDateTime(gDayNo);
}

/// Compute the Jalali day number from (year, month, day) using the
/// same epoch and cycle decomposition as [toJalali].
///
/// The forward algorithm computes:
///   jDayNo = gDayNo - 79
///   jNp = jDayNo ~/ 12053
///   jYear = 979 + 33*jNp + 4*(jDayNo ~/ 1461)
///   ...
///
/// This function is its inverse: given a year, compute which position
/// in the 33-year cycle and 4-year block it occupies, then add the
/// day-of-year.
int _jalaliToJDayNo(int year, int month, int day) {
  // Position relative to the reference year 979.
  final yearOffset = year - 979;
  final cycles = yearOffset ~/ 33; // complete 33-year cycles
  final yearInCycle = yearOffset % 33; // 0..32

  final blocks4 = yearInCycle ~/ 4; // complete 4-year blocks
  final yearInBlock = yearInCycle % 4; // 0..3

  var jDayNo = cycles * 12053 + blocks4 * 1461;

  // Add days for years within the current 4-year block.
  // Year 0 of a block is the 366-day leap year; years 1-3 are 365 days.
  if (yearInBlock > 0) {
    jDayNo += 366; // the leap year (year 0 of the block)
    jDayNo += (yearInBlock - 1) * 365;
  }

  // Add days for months before the target month.
  final dayOfYear = _jalaliDayOfYear(month, day, isJalaliLeapYear(year));
  jDayNo += dayOfYear;

  return jDayNo;
}

/// Compute the 0-indexed day-of-year for a Jalali date.
int _jalaliDayOfYear(int month, int day, bool isLeap) {
  var doy = day - 1;
  for (var m = 1; m < month; m++) {
    doy += _monthLen(m, isLeap);
  }
  return doy;
}

/// Number of days in a given Jalali month.
int _monthLen(int month, bool isLeap) {
  if (month <= 6) return 31;
  if (month <= 11) return 30;
  return isLeap ? 30 : 29;
}

/// Number of days from the epoch (1600-01-01) to Jan 1 of [year].
///
/// This is the exact same Gregorian day-number formula used by [toJalali],
/// so [jalaliToGregorian] is a true mathematical inverse of [toJalali].
int _gregorianYearStart(int year) {
  final y = year - 1600;
  return 365 * y + (y + 3) ~/ 4 - (y + 99) ~/ 100 + (y + 399) ~/ 400;
}

/// Convert a Gregorian day number (days since 1600-01-01) to DateTime.
DateTime _gDayNoToDateTime(int gDayNo) {
  // Locate the Gregorian year by narrowing in on the year whose Jan 1 is at
  // or before gDayNo and whose next Jan 1 is after it. This avoids assuming
  // every century has a uniform 36524 days; the century following a
  // 400-multiple (1600, 2000, ...) actually has 36525 days because its
  // opening year is a leap year.
  var gy = 1600 + gDayNo ~/ 365;
  while (gDayNo < _gregorianYearStart(gy)) {
    gy--;
  }
  while (gDayNo >= _gregorianYearStart(gy + 1)) {
    gy++;
  }

  // remaining is now the 0-indexed day of the year.
  var remaining = gDayNo - _gregorianYearStart(gy);

  final isLeap = (gy % 4 == 0 && gy % 100 != 0) || (gy % 400 == 0);

  const gMonthDays = <int>[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  var gm = 0;
  for (; gm < 12; gm++) {
    var monthLen = gMonthDays[gm];
    if (gm == 1 && isLeap) monthLen = 29;
    if (remaining < monthLen) break;
    remaining -= monthLen;
  }

  return DateTime.utc(gy, gm + 1, remaining + 1);
}

/// Returns the number of days in [month] for the given Jalali [year].
int jalaliMonthLength(int year, int month) =>
    _monthLen(month, isJalaliLeapYear(year));

/// Returns true if [year] is a Jalali leap year.
///
/// Leap years occur at positions 0, 4, 8, 12, 16, 20, 24, 28 within each
/// 33-year cycle (every 4th year starting from position 0, except the
/// 33rd year which is standard). This matches the decomposition used by
/// [toJalali].
bool isJalaliLeapYear(int year) {
  final pos = (year - 979) % 33;
  return pos % 4 == 0 && pos != 32;
}

/// Convert Latin digits in [value] to Persian digits.
String toPersianDigits(int value) {
  return value.toString().replaceAllMapped(
    RegExp('[0-9]'),
    (match) => _persianDigits[int.parse(match.group(0)!)],
  );
}

// Keep the private alias for internal use.
String _toPersianDigits(int value) => toPersianDigits(value);
