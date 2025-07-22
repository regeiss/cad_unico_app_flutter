import 'package:flutter/material.dart';

class StatusChipWidget extends StatelessWidget {
  final String status;
  final String? label;
  final bool showIcon;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusChipWidget({
    Key? key,
    required this.status,
    this.label,
    this.showIcon = true,
    this.fontSize,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(status);
    
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo['backgroundColor'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusInfo['borderColor'],
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              statusInfo['icon'],
              size: fontSize != null ? fontSize! + 2 : 14,
              color: statusInfo['textColor'],
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label ?? statusInfo['text'],
            style: TextStyle(
              color: statusInfo['textColor'],
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toUpperCase()) {
      case 'A':
      case 'ATIVO':
      case 'ACTIVE':
        return {
          'text': 'Ativo',
          'icon': Icons.check_circle,
          'backgroundColor': Colors.green.withOpacity(0.1),
          'borderColor': Colors.green.withOpacity(0.3),
          'textColor': Colors.green.shade700,
        };

      case 'I':
      case 'INATIVO':
      case 'INACTIVE':
        return {
          'text': 'Inativo',
          'icon': Icons.cancel,
          'backgroundColor': Colors.red.withOpacity(0.1),
          'borderColor': Colors.red.withOpacity(0.3),
          'textColor': Colors.red.shade700,
        };

      case 'P':
      case 'PENDENTE':
      case 'PENDING':
        return {
          'text': 'Pendente',
          'icon': Icons.access_time,
          'backgroundColor': Colors.orange.withOpacity(0.1),
          'borderColor': Colors.orange.withOpacity(0.3),
          'textColor': Colors.orange.shade700,
        };

      case 'B':
      case 'BLOQUEADO':
      case 'BLOCKED':
        return {
          'text': 'Bloqueado',
          'icon': Icons.block,
          'backgroundColor': Colors.red.withOpacity(0.1),
          'borderColor': Colors.red.withOpacity(0.3),
          'textColor': Colors.red.shade700,
        };

      case 'S':
      case 'SUSPENSO':
      case 'SUSPENDED':
        return {
          'text': 'Suspenso',
          'icon': Icons.pause_circle,
          'backgroundColor': Colors.orange.withOpacity(0.1),
          'borderColor': Colors.orange.withOpacity(0.3),
          'textColor': Colors.orange.shade700,
        };

      case 'C':
      case 'CONCLUIDO':
      case 'COMPLETED':
        return {
          'text': 'Concluído',
          'icon': Icons.check_circle_outline,
          'backgroundColor': Colors.blue.withOpacity(0.1),
          'borderColor': Colors.blue.withOpacity(0.3),
          'textColor': Colors.blue.shade700,
        };

      case 'E':
      case 'EM_ANDAMENTO':
      case 'IN_PROGRESS':
        return {
          'text': 'Em Andamento',
          'icon': Icons.sync,
          'backgroundColor': Colors.purple.withOpacity(0.1),
          'borderColor': Colors.purple.withOpacity(0.3),
          'textColor': Colors.purple.shade700,
        };

      case 'N':
      case 'NAO_INICIADO':
      case 'NOT_STARTED':
        return {
          'text': 'Não Iniciado',
          'icon': Icons.radio_button_unchecked,
          'backgroundColor': Colors.grey.withOpacity(0.1),
          'borderColor': Colors.grey.withOpacity(0.3),
          'textColor': Colors.grey.shade700,
        };

      default:
        return {
          'text': status,
          'icon': Icons.help_outline,
          'backgroundColor': Colors.grey.withOpacity(0.1),
          'borderColor': Colors.grey.withOpacity(0.3),
          'textColor': Colors.grey.shade700,
        };
    }
  }
}

// Widget helper para diferentes tipos de status
class StatusChip {
  static Widget ativo({String? label, bool showIcon = true}) {
    return StatusChipWidget(
      status: 'A',
      label: label,
      showIcon: showIcon,
    );
  }

  static Widget inativo({String? label, bool showIcon = true}) {
    return StatusChipWidget(
      status: 'I',
      label: label,
      showIcon: showIcon,
    );
  }

  static Widget pendente({String? label, bool showIcon = true}) {
    return StatusChipWidget(
      status: 'P',
      label: label,
      showIcon: showIcon,
    );
  }

  static Widget bloqueado({String? label, bool showIcon = true}) {
    return StatusChipWidget(
      status: 'B',
      label: label,
      showIcon: showIcon,
    );
  }

  static Widget concluido({String? label, bool showIcon = true}) {
    return StatusChipWidget(
      status: 'C',
      label: label,
      showIcon: showIcon,
    );
  }

  static Widget emAndamento({String? label, bool showIcon = true}) {
    return StatusChipWidget(
      status: 'E',
      label: label,
      showIcon: showIcon,
    );
  }

  static Widget custom({
    required String status,
    String? label,
    bool showIcon = true,
    double? fontSize,
    EdgeInsetsGeometry? padding,
  }) {
    return StatusChipWidget(
      status: status,
      label: label,
      showIcon: showIcon,
      fontSize: fontSize,
      padding: padding,
    );
  }
}

// Extension para facilitar o uso com strings
extension StatusChipExtension on String {
  Widget toStatusChip({
    String? customLabel,
    bool showIcon = true,
    double? fontSize,
    EdgeInsetsGeometry? padding,
  }) {
    return StatusChipWidget(
      status: this,
      label: customLabel,
      showIcon: showIcon,
      fontSize: fontSize,
      padding: padding,
    );
  }
}