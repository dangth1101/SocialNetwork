class Mentor {
  String id = '';
  List<String> skills = [];
}

Map<String, double> calculateDegree(List<Mentor> mentors) {
  Map<String, double> centrality = {};

  for (var mentor in mentors) {
    double degreeCentrality = 0.0;

    for (var otherMentor in mentors) {
      if (mentor == otherMentor) {
        continue;
      }

      int commonSkills =
          mentor.skills.toSet().intersection(otherMentor.skills.toSet()).length;
      if (commonSkills > 0) {
        degreeCentrality += 1.0;
      }
    }
    centrality[mentor.id] = degreeCentrality;
  }
  return centrality;
}

void main() {
  List<Mentor> mentors = [
    Mentor()
      ..id = '01'
      ..skills = ['Python', 'Java', 'C'],
    Mentor()
      ..id = '02'
      ..skills = ['Python', 'JavaScript', 'SQL'],
    Mentor()
      ..id = '03'
      ..skills = ['Java', 'C++', 'R'],
  ];

  Map<String, double> centralityScores = calculateDegree(mentors);

  print(centralityScores);
}
