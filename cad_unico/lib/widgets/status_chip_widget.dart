import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final String? label;
  final bool compact;

  const StatusChip({
    Key? key,
    required this.status,
    this.label,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    
    if (compact) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: config.color,
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.color.withOpacity(0.3)),
      ),
      child: Text(
        label ?? config.label,
        style: TextStyle(
          color: config.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status.toUpperCase()) {
      case 'A':
      case 'ATIVO':
        return _StatusConfig(Colors.green, 'Ativo');
      case 'I':
      case 'INATIVO':
        return _StatusConfig(Colors.red, 'Inativo');
      case 'P':
      case 'PENDENTE':
        return _StatusConfig(Colors.orange, 'Pendente');
      case 'B':
      case 'BLOQUEADO':
        return _StatusConfig(Colors.red[800]!, 'Bloqueado');
      default:
        return _StatusConfig(Colors.grey, status);
    }
  }
}

class _StatusConfig {
  final Color color;
  final String label;

  _StatusConfig(this.color, this.label);
}
