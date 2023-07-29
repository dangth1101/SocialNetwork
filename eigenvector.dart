import 'dart:math';

class Mentor {
  String id = '';
  List<String> skills = [];
}

Map<String, double> calculateEigenvector(List<Mentor> mentors) {
  Map<String, double> centrality = {};

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

  List<double> eigenvector =
      List.filled(mentors.length, 1 / sqrt(mentors.length));

  for (var i = 0; i < 10; i++) {
    var newEigenvector = List.filled(mentors.length, 0.0);

    for (var j = 0; j < mentors.length; j++) {
      for (var k = 0; k < mentors.length; k++) {
        newEigenvector[j] += skillMatrix[j][k] * eigenvector[k];
      }
    }

    double norm = 0.0;
    for (var value in newEigenvector) {
      norm += pow(value, 2);
    }
    norm = sqrt(norm);

    for (var j = 0; j < mentors.length; j++) {
      newEigenvector[j] /= norm;
    }

    eigenvector = newEigenvector;
  }

  for (var i = 0; i < mentors.length; i++) {
    centrality[mentors[i].id] = eigenvector[i];
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

  Map<String, double> centralityScores = calculateEigenvector(mentors);

  print(centralityScores);
}
