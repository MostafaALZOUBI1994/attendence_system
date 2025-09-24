class EmployeeMood {
  final int moodId;
  final String mood;
  final String? note;
  final DateTime date;

  EmployeeMood({
    required this.moodId,
    required this.mood,
    this.note,
    required this.date,
  });
}
