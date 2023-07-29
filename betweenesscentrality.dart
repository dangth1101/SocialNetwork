import 'dart:collection';

class Mentor {
  String id = '';
  List<String> skills = [];
}

Map<String, double> calculateBetweeness(List<Mentor> mentors) {
  Map<String, double> centrality = {};
  Map<String, int> numPaths = {};
  Map<String, double> fractionPaths = {};
  for (var source in mentors) {
    Map<Mentor, int> distances = {};
    Map<Mentor, List<Mentor>> predecessors = {};
    for (var mentor in mentors) {
      distances[mentor] = -1;
      predecessors[mentor] = [];
    }

    distances[source] = 0;
    Queue<Mentor> queue = Queue<Mentor>();
    queue.add(source);

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
          distances[neighbor] = distances[current]! + 1;
          queue.add(neighbor);
        }

        if (distances[neighbor] == distances[current]! + 1) {
          predecessors[neighbor]?.add(current);
        }
      }
    }

    Map<Mentor, int> localNumPaths = {};
    for (var mentor in mentors) {
      localNumPaths[mentor] = 0;
    }

    localNumPaths[source] = 1;
    for (var mentor in predecessors.keys) {
      for (var pred in predecessors[mentor]!) {
        localNumPaths[pred] = localNumPaths[pred]! + localNumPaths[mentor]!;
      }
    }

    for (var mentor in localNumPaths.keys) {
      if (!numPaths.containsKey(mentor.id)) {
        numPaths[mentor.id] = 0;
      }
      numPaths[mentor.id] = numPaths[mentor.id]! + localNumPaths[mentor]!;
    }

    Map<Mentor, double> localFractionPaths = {};
    for (var mentor in mentors) {
      localFractionPaths[mentor] = 0.0;
    }

    for (var mentor in predecessors.keys) {
      if (predecessors[mentor]!.isEmpty) {
        continue;
      }

      for (var pred in predecessors[mentor]!) {
        localFractionPaths[pred] = localFractionPaths[pred]! +
            localNumPaths[pred]! /
                localNumPaths[mentor]! *
                (1.0 + fractionPaths[mentor.id]!);
      }
    }

    for (var mentor in localFractionPaths.keys) {
      if (!fractionPaths.containsKey(mentor.id)) {
        fractionPaths[mentor.id] = 0.0;
      }

      fractionPaths[mentor.id] =
          fractionPaths[mentor.id]! + localFractionPaths[mentor]!;
    }
  }

  for (var mentor in mentors) {
    if (!numPaths.containsKey(mentor.id)) {
      centrality[mentor.id] = 0.0;
    } else {
      centrality[mentor.id] = fractionPaths[mentor.id]! /
          (numPaths[mentor.id]! - 1) *
          (mentors.length - numPaths[mentor.id]!);
    }
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

  Map<String, double> centralityScores = calculateBetweeness(mentors);

  print(centralityScores);
}
