import 'package:flutter/material.dart';
import '../card_container.dart';

class InputCard extends StatelessWidget {
  const InputCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CardContainer(child: Column(children: children));
  }
}
