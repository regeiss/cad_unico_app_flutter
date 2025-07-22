import 'package:flutter/material.dart';

class PriorityBadge extends StatelessWidget {
  final bool isPriority;
  final String? reason;
  final bool compact;

  const PriorityBadge({
    super.key,
    required this.isPriority,
    this.reason,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPriority) return const SizedBox.shrink();

    if (compact) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.priority_high,
          size: 16,
          color: Colors.red[700],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.priority_high,
            size: 16,
            color: Colors.red[700],
          ),
          const SizedBox(width: 4),
          Text(
            reason ?? 'Prioritário',
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
