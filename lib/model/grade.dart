class Grade {
  int? gradeId;
  String gradeName;
  List<Student>? gradeStudents;

  Grade(
      {required this.gradeId,
      required this.gradeName,
      required this.gradeStudents});
}

class Student {
  int? studentId;
  String? studentName;
  int? gradeId;
  bool didAttend;

  Student(
      {required this.studentId,
      required this.studentName,
      required this.gradeId,
      this.didAttend = true});

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'didAttend': didAttend,
    };
  }
}
