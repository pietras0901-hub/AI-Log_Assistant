import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/log_entry.dart';

/// Karta prezentująca pojedynczy wpis logu na liście.
///
/// Lewa krawędź oraz „chip” poziomu są kolorowane zgodnie z ważnością
/// (czerwony = CRITICAL, pomarańczowy = ERROR).
class LogCard extends StatelessWidget {
  final LogEntry log;
  final VoidCallback? onTap;

  const LogCard({super.key, required this.log, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kolor = log.poziomWaznosci.kolor;
    final formatDaty = DateFormat('dd.MM.yyyy HH:mm');

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kolorowy pasek sygnalizujący poziom ważności.
              Container(width: 6, color: kolor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _PoziomChip(poziom: log.poziomWaznosci),
                          const Spacer(),
                          Icon(Icons.dns_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              log.maszynaNazwa,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        log.opisBledu,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            formatDaty.format(log.dataWpisu),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right,
                              color: theme.colorScheme.onSurfaceVariant),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mały „chip” z etykietą i ikoną poziomu ważności.
class _PoziomChip extends StatelessWidget {
  final PoziomWaznosci poziom;

  const _PoziomChip({required this.poziom});

  @override
  Widget build(BuildContext context) {
    final kolor = poziom.kolor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kolor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kolor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(poziom.ikona, size: 14, color: kolor),
          const SizedBox(width: 4),
          Text(
            poziom.etykieta,
            style: TextStyle(
              color: kolor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
