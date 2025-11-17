import "package:flutter/material.dart";

abstract class RecomView {
  BuildContext get context;

  String get search;
  String get custom;

  List<String> get candidates;
  List<String> get selected;
  int get topK;
  double get cutoff;
  bool get excludeWatched;

  void toggle(String title);
  void addFromSearch();
  Future<void> startRecom();
}
