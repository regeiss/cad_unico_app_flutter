import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class LogoutButton extends StatelessWidget {
  final bool showConfirmDialog;
  final IconData? icon;
  final String? text;
  final bool isIconButton;

  const LogoutButton({
    super.key,
    this.showConfirmDialog = true,
    this.icon,
    this.text,
    this.isIconButton = false,
  });

  Future<void> _handleLogout(BuildContext context) async {
    bool shouldLogout = true;

    if (showConfirmDialog) {
      shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar Logout'),
          content: const Text('Tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sair'),
            ),
          ],
        ),
      ) ?? false;
    }

    if (shouldLogout && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (isIconButton) {
          return IconButton(
            onPressed: authProvider.isLoggingOut 
              ? null 
              : () => _handleLogout(context),
            icon: authProvider.isLoggingOut
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon ?? Icons.exit_to_app),
            tooltip: 'Sair',
          );
        }

        return ListTile(
          leading: authProvider.isLoggingOut
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon ?? Icons.exit_to_app),
          title: Text(text ?? 'Sair'),
          onTap: authProvider.isLoggingOut 
            ? null 
            : () => _handleLogout(context),
          enabled: !authProvider.isLoggingOut,
        );
      },
    );
}