import 'dart:collection';

class Mentor {
  String id = '';
  List<String> skills = [];
}

Map<String, double> calculateCloseness(List<Mentor> mentors) {
  Map<String, double> centrality = {};

  for (var mentor in mentors) {
    double shortestPathSum = 0.0;

    Map<Mentor, int> distances = {};
    for (var otherMentor in mentors) {
      distances[otherMentor] = -1;
    }

    distances[mentor] = 0;
    Queue<Mentor> queue = Queue<Mentor>();
    queue.add(mentor);

    while (queue.isNotEmpty) {
      var current = queue.removeFirst();

      for (var neighbor in mentors) {
        if (current == neighbor) {
          continue;
        }

        int weight = 0;
        if (current.skills
                .toSet()
                .intersection(neighbor.skills.toSet())
                .length >
            0) {
          weight = 1;
        }

        if (distances[neighbor] == -1) {
          distances[neighbor] = distances[current]! + weight;
          queue.add(neighbor);
        }
      }
    }

    for (var distance in distances.values) {
      if (distance == -1) {
        continue;
      }
      shortestPathSum += distance;
    }

    double closenessCentrality = (mentors.length - 1) / shortestPathSum;

    centrality[mentor.id] = closenessCentrality;
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

  Map<String, double> centralityScores = calculateCloseness(mentors);

  print(centralityScores);
}
