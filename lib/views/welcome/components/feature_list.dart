import 'package:flutter/material.dart';

class FeatureList extends StatelessWidget {
  final bool large;
  const FeatureList({super.key, required this.large});

  @override
  Widget build(BuildContext context) {
    final features = [
      (
        Icons.auto_awesome_rounded,
        'Extraction automatique',
        'Analyse de vos factures instantanément',
      ),
      (
        Icons.verified_rounded,
        'Certification conforme DGI',
        'Génération de FNE signées électroniquement',
      ),
      (
        Icons.share_rounded,
        'Import depuis toutes vos apps',
        'WhatsApp, Gmail, Fichiers et plus encore',
      ),
    ];

    return Column(
      children: features
          .map((f) => Padding(
                padding: EdgeInsets.only(bottom: large ? 20 : 16),
                child: FeatureTile(
                  icon: f.$1,
                  title: f.$2,
                  subtitle: f.$3,
                  large: large,
                ),
              ))
          .toList(),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool large;

  const FeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.large,
  });

  @override
  Widget build(BuildContext context) {
    final boxSize = large ? 46.0 : 40.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          decoration: BoxDecoration(
            color: const Color(0xFF1A6B3C).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: large ? 22 : 19,
            color: const Color(0xFF1A6B3C),
          ),
        ),
        SizedBox(width: large ? 16 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: large ? 16 : 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A3828),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: large ? 14 : 12.5,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
