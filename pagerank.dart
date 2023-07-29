class Mentor {
  String id = '';
  List<String> skills = [];
}

Map<String, double> calculatePageRank(List<Mentor> mentors) {
  Map<String, double> pageRank = {};

  List<List<int>> skillMatrix = [];
  for (var mentor1 in mentors) {
    var row = [];
    for (var mentor2 in mentors) {
      if (mentor1.skills.toSet().intersection(mentor2.skills.toSet()).length >
          0) {
        row.add(1);
      } else {
        row.add(0);
      }
    }
    skillMatrix.add(row.cast<int>());
  }

  List<int> outDegree = List.filled(mentors.length, 0);
  for (var i = 0; i < mentors.length; i++) {
    var rowSum = 0;
    for (var j = 0; j < mentors.length; j++) {
      rowSum += skillMatrix[i][j];
    }
    outDegree[i] = rowSum;
  }

  List<double> pageRankVector =
      List.filled(mentors.length, 1 / mentors.length.toDouble());

  for (var i = 0; i < 10; i++) {
    var newPageRankVector = List.filled(mentors.length, 0.0);

    for (var j = 0; j < mentors.length; j++) {
      for (var k = 0; k < mentors.length; k++) {
        if (skillMatrix[k][j] == 1) {
          newPageRankVector[j] += pageRankVector[k] / outDegree[k];
        }
      }
    }

    for (var j = 0; j < mentors.length; j++) {
      pageRank[mentors[j].id] = newPageRankVector[j];
    }

    pageRankVector = newPageRankVector;
  }

  return pageRank;
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

  Map<String, double> pageRankScores = calculatePageRank(mentors);

  print(pageRankScores);
}
