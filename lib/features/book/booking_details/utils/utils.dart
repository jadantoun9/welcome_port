List<String> getInfantPossibleAges() {
  return List.generate(3, (index) => '$index years');
}

List<String> getChildPossibleAges() {
  return List.generate(13, (index) => '${index + 3} years');
}
