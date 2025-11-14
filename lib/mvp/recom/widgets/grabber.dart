/// The grabber used in modal sheets.
import "package:flutter/material.dart";

class Grabber extends StatelessWidget {
  const Grabber();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
