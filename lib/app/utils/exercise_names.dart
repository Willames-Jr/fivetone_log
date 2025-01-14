import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Map<String, String> exerciseNamesEnToPt = {
  'Deadlift': 'Levantamento terra',
  'Squat': 'Agachamento',
  'Bench Press': 'Supino',
  'Military Press': 'Militar press',
  // Add other exercises here
};

Map<String, String> exerciseNamesPtToEn = {
  'Levantamento terra': 'Deadlift',
  'Agachamento': 'Squat',
  'Supino': 'Bench Press',
  'Militar press': 'Military Press',
  // Add other exercises here
};

String getTranslatedExerciseName(String exercise, AppLocalizations localizations) {
  if (localizations.localeName == 'pt_BR') {
    return exerciseNamesEnToPt[exercise] ?? exercise;
  } else {
    return exerciseNamesPtToEn[exercise] ?? exercise;
  }
}
