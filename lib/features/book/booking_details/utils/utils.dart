import 'package:welcome_port/core/helpers/singletons.dart';

String _getLocalizedYears() {
  final locale = Singletons.sharedPref.getString('locale') ?? 'en';
  return locale == 'ar' ? 'سنوات' : 'years';
}

List<String> getInfantPossibleAges() {
  final years = _getLocalizedYears();
  return List.generate(3, (index) => '$index $years');
}

List<String> getChildPossibleAges() {
  final years = _getLocalizedYears();
  return List.generate(13, (index) => '${index + 3} $years');
}
