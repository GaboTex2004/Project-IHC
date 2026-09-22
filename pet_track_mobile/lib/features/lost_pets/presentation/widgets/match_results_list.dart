import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';

class MatchResultsList extends StatelessWidget {
  final Map<String, dynamic> result;
  final ValueChanged<int> onOpenDetails;

  const MatchResultsList({
    super.key,
    required this.result,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    final rawMatches = result['matches'];
    if (rawMatches is! List) {
      return const Text('El servidor devolvió coincidencias inválidas.');
    }

    final matches = rawMatches.whereType<Map>().where(
      (item) => item['report_id'] is int && item['score'] is num,
    ).toList();

    if (matches.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(Icons.search_off_rounded, size: 38, color: AppColors.textMuted),
            SizedBox(height: 10),
            Text(
              'Sin coincidencias por ahora',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 6),
            Text(
              'No encontramos reportes analizados con suficientes rasgos en común.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Posibles coincidencias',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${matches.length}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'La puntuación compara rasgos visibles y no confirma la identidad de la mascota.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        ...matches.map(
          (item) => _MatchCard(item: item, onOpenDetails: onOpenDetails),
        ),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Map<dynamic, dynamic> item;
  final ValueChanged<int> onOpenDetails;

  const _MatchCard({required this.item, required this.onOpenDetails});

  @override
  Widget build(BuildContext context) {
    final reportId = item['report_id'] as int;
    final score = (item['score'] as num).clamp(0, 100).toInt();
    final name = item['name']?.toString().trim() ?? '';
    final reportType = item['report_type']?.toString() ?? '';
    final typeLabel = reportType == 'HOMELESS'
        ? 'Sin hogar'
        : reportType == 'FOUND'
        ? 'Encontrado'
        : reportType;
    void openDetails() => onOpenDetails(reportId);

    return Card(
      key: ValueKey('match-$reportId'),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: openDetails,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.pets_rounded, color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? 'Animal encontrado' : name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (typeLabel.isNotEmpty) _MatchLabel(text: typeLabel),
                            Text(
                              'Reporte #$reportId',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Similitud orientativa',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '$score/100',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 7,
                  backgroundColor: AppColors.border,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: openDetails,
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Ver detalles'),
                ),
              ),
              const Text(
                'Podrás contactar al responsable desde los detalles.',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchLabel extends StatelessWidget {
  final String text;
  const _MatchLabel({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.warningSurface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.secondary,
      ),
    ),
  );
}
