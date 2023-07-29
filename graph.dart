// ignore_for_file: non_constant_identifier_names

import 'dart:math';
import 'package:crosstech_mtmt_pj/utils/common_funcs.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';

class Edges {
  List<String> u = [];
  List<String> v = [];
  List<String> tags = CommonFuncs.initSampleTags();

  void createEdges(List<Course> courses) {
    for (String tag in tags) {
      for (Course course in courses) {
        if (course.tags.contains(tag)) {
          u.add(tag);
          v.add(course.id.toString());
        }
      }
    }

    for (Course course in courses) {
      for (String tag in tags) {
        if (course.tags.contains(tag)) {
          u.add(course.id.toString());
          v.add(tag);
        }
      }
    }
  }

  String getRandomCourse(String tag) {
    int firstIndex = u.indexWhere((element) => element == tag);
    if (firstIndex == -1) debugPrint(tag);
    int lastIndex = u.lastIndexWhere((element) => element == tag);

    return v[firstIndex + Random().nextInt(lastIndex - firstIndex + 1)];
  }

  Future<String> getRandomTag(String course) async {
    int firstIndex = u.indexWhere((element) => element == course);
    int lastIndex = u.lastIndexWhere((element) => element == course);
    SharedPreferences shared = await SharedPreferences.getInstance();
    List<String> times = shared.getStringList("time")!;
    List<String> counts = shared.getStringList("count")!;

    List<DateTime> convert_date = [];
    List<int> covert_count = [];

    for (String time in times) {
      convert_date.add(DateTime.parse(time));
    }

    for (String count in counts) {
      covert_count.add(int.parse(count));
    }

    int total = 0;
    for (int i = firstIndex; i <=  lastIndex; i++) {
      for (int j = 0; j < tags.length; j++) {
        if (tags[j] == v[i]) {
          total += (isExpired(convert_date[j]) ? 0 : covert_count[j]);
          break;
        }
      }
    }

    int rand = Random().nextInt(total);
    for (int i = firstIndex; i <= lastIndex; i++) {
      for (int j = 0; j < tags.length; j++) {
        if (tags[j] == v[i]) {
          if (!isExpired(convert_date[j])) {
            if (rand - covert_count[j] <= 0) return v[i];

            rand -= covert_count[j];
          }
          break;
        }
      }
    }

    return "NOT FOUND";
  }

  bool isExpired(DateTime date) {
    Duration duration = DateTime.now().difference(date);

    return duration.inDays > 3;
  }
}
