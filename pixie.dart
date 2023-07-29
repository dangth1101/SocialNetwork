import 'dart:math';
import 'package:crosstech_mtmt_pj/utils/common_funcs.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'graph.dart';

class Pixie {
  late Edges edges;
  List<String> tags = CommonFuncs.initSampleTags();

  Pixie() {
    edges = Edges();
    edges.createEdges(CommonFuncs.initSampleCourses());
  }

  Future<Map<String, int>> pixieRandomWalk(String tag, int np, int nv, int maxSteps) async {
    Map<String, int> scores = <String, int>{};
    int nHighVisited = 0;
    int totalSteps = 0;

    while (totalSteps < maxSteps || nHighVisited > np) {
      String currTag = tag;
      int currSteps = Random().nextInt(10);

      for (int i = 0; i < currSteps; i++) {
        String currCourse = edges.getRandomCourse(currTag);
        String newTag = await edges.getRandomTag(currCourse);
        currTag = newTag;

        if (scores.containsKey(currCourse)) {
          scores[currCourse] = scores[currCourse]! + 1;
        } else {
          scores[currCourse] = 1;
        }

        if (scores[currCourse] == nv) {
          nHighVisited++;
        }
        
      }
      totalSteps += currSteps; 
    }

    return scores;
  }

  Future<List<Score>> pixieRandomWalkMultiple()  async{
  
    List<Score> scores = [];
    Map<String, double> aggregation = <String, double>{};
    SharedPreferences shared = await SharedPreferences.getInstance();
    List<String> counts = shared.getStringList("count")!;
    
    for (int i = 0; i < tags.length; i++) {
      if (int.parse(counts[i]) > 0) {
        int np = 10;
        int nv = 10;
        int totalSteps = 100;
        Map<String, int> count = await pixieRandomWalk(tags[i], np, nv, totalSteps);

        count.forEach((key, value) {
          aggregation[key] = aggregation[key] ?? 0 + sqrt(value);
        });
      }
    }
    
    aggregation.forEach((key, value) {
      aggregation[key] = value * value;
      scores.add(Score(key, value));
    });

    scores.sort((a, b) => b.score.compareTo(a.score));
    debugPrint('pixie end');
    return scores;
  }
}

class Score {
  String course_id;
  double score;

  Score(this.course_id, this.score);
}
