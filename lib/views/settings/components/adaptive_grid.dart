import 'package:flutter/material.dart';

class AdaptiveGrid extends StatelessWidget {
  final bool isTablet;
  final List<Widget> children;

  const AdaptiveGrid({
    super.key,
    required this.isTablet,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTablet) {
      return Column(
        children: children
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: c),
            )
            .toList(),
      );
    }
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      mainAxisExtent: 80,
      children: children,
    );
  }
}
