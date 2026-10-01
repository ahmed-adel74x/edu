import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

/// Arabic-Indic digits, which Arabic copy in this app counts with ("٤").
const _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';

/// Renders [value] in the digits of the language in force: Arabic-Indic for
/// Arabic, Western for English.
///
/// intl does the grouping (and would do decimals/percentages the same way), but
/// its own `ar` locale data uses Western digits, so the digit set is chosen per
/// language here. One helper owns numbers app-wide, so no screen has to decide
/// which numerals to print.
String formatNumber(BuildContext context, num value) {
  final locale = Localizations.localeOf(context);
  final formatted = NumberFormat.decimalPattern(locale.toLanguageTag())
      .format(value);
  if (locale.languageCode != 'ar') return formatted;
  return formatted.replaceAllMapped(
    RegExp(r'\d'),
    (match) => _arabicIndicDigits[int.parse(match[0]!)],
  );
}
