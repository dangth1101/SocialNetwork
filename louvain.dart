import 'package:crosstech_mtmt_pj/models/mentor.dart';
import 'package:crosstech_mtmt_pj/models/skill.dart';
import 'package:crosstech_mtmt_pj/models/user.dart';

import '../models/course.dart';
import 'common_funcs.dart';

class Louvain {
  int m = 0;
  List<Node> nodes = [];
  List<Community> communities = [];

  void exec(int times) {
    for (int i = 0; i < times; i++) {
      modularityOptimization();
      communityAggregation();
    }
  }

  void init() {
    List<Mentor> mentors = CommonFuncs.initSampleMentors();
    int index = mentors[0].id!;

    for (Mentor mentor in mentors) {
      nodes.add(Node(mentor.id! - index, 0));
      communities.add(Community(nodes[mentor.id! - index]));
    }

    for (Mentor mentor1 in mentors) {
      for (Mentor mentor2 in mentors) {
        if (mentor1.id != mentor2.id) {
          for (int i = 0; i < mentor1.skills!.length; i++) {
            for (int j = 0; j < mentor2.skills!.length; j++) {
              if (mentor1.skills![i].id == mentor2.skills![j].id) {
                m++;
                nodes[mentor1.id! - index].add(nodes[mentor2.id! - index], 1);
                nodes[mentor2.id! - index].add(nodes[mentor1.id! - index], 1);
              }
            }
          }
        }
      }
    }
  }

  void modularityOptimization() {
    bool move;
    do {
      move = false;
      for (Node node in nodes) {
        Node? tempNode;
        double max_delta = 0;

        for (Node adj in node.next) {
          if (node.community.id != adj.community.id) {
            double takeOut = node.community.modularityOut(node, m);
            double putIn = adj.community.modularityIn(node, m);
            double delta = takeOut + putIn;

            if (delta > max_delta) {
              tempNode = adj;
              max_delta = delta;
            }
          }
        }

        if (tempNode != null) {
          move = true;
          tempNode.community.nodes.add(node);
          node.community.nodes.remove(node);
          node.community = tempNode.community;
        }
      }
    } while (move);
  }

  void communityAggregation() {
    Map<int, int> index = <int, int>{};
    List<Node> new_nodes = [];
    List<Community> new_communities = [];
    int id = 0;

    for (Node node in nodes) {
      if (!index.containsKey(node.community.id)) {
        index[node.community.id] = id;
        new_nodes.add(Node(id, node.community.sumIn() + node.self_weight));
        id++;
      } else {
        new_nodes[index[node.community.id]!].self_weight += node.self_weight;
      }
    }

    for (Node node in nodes) {
      for (Node adj in node.next) {
        if (node.community.id != adj.community.id) {
          Node curr = new_nodes[index[node.community.id]!];
          Node next = new_nodes[index[adj.community.id]!];

          if (!curr.weight.containsKey(next)) {
            curr.add(next, node.weight[adj]!);
          } else {
            curr.weight[next] = curr.weight[next]! + node.weight[adj]!;
          }
        }
      }
    }

    for (Node node in new_nodes) {
      new_communities.add(node.community);
    }

    nodes = new_nodes;
    communities = new_communities;
  }

  Louvain();
}

class Node {
  int id;
  int self_weight;
  List<Node> next = [];
  Map<Node, int> weight = <Node, int>{};
  late Community community;

  Node(this.id, this.self_weight) {
    community = Community(this);
  }

  void add(Node node, int value) {
    next.add(node);
    weight[node] = value;
  }

  int kin(Community community) {
    int result = 0;

    for (Node node in community.nodes) {
      if (next.contains(node)) {
        result += weight[node]!;
      }
    }

    return result * 2;
  }

  int ki() {
    int result = 0;

    for (Node node in next) {
      result += weight[node]!;
    }

    return result;
  }

  double modularity(int m) {
    return (self_weight / 2 * m) - (ki() / (2 * m)) * (ki() / (2 * m));
  }

  int getSumWeight() {
    int result = 0;
    for (Node node in next) {
      result += weight[node]!;
    }

    return result;
  }
}

class Community {
  late int id;
  List<Node> nodes = [];

  Community(Node node) {
    id = node.id;
    nodes.add(node);
  }

  void add(Node node) {
    node.community = this;

    nodes.add(node);
  }

  int sumIn() {
    int result = 0;

    for (Node node in nodes) {
      for (Node adj in node.next) {
        if (nodes.contains(adj)) {
          result += node.weight[adj]!;
        }
      }
    }

    return result;
  }

  int sumTot() {
    int result = 0;

    for (Node node in nodes) {
      result += node.getSumWeight();
    }

    return result;
  }

  double modularity(int m) {
    return (sumIn() / (2 * m)) - (sumTot() / (2 * m)) * (sumTot() / (2 * m));
  }

  double modularityIn(Node node, int m) {
    double before = modularity(m) + node.modularity(m);
    double after = ((sumIn() + node.kin(this)) / (2 * m)) -
        ((sumTot() + node.ki()) / (2 * m)) * ((sumTot() + node.ki()) / (2 * m));
    return after - before;
  }

  double modularityOut(Node node, int m) {
    nodes.remove(node);
    double after = modularity(m) + node.modularity(m);
    double before = ((sumIn() + node.kin(this)) / (2 * m)) -
        ((sumTot() + node.ki()) / (2 * m)) * ((sumTot() + node.ki()) / (2 * m));
    nodes.add(node);
    return after - before;
  }
}
