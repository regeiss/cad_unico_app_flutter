import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class LogoutButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isIconButton;
  final bool showConfirmDialog;

  const LogoutButton({
    super.key,
    this.text,
    this.icon,
    this.color,
    this.textColor,
    this.isIconButton = false,
    this.showConfirmDialog = true,
  });

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    // Mostrar diálogo de confirmação se habilitado
    if (widget.showConfirmDialog) {
      final bool? confirm = await _showLogoutConfirmDialog();
      if (confirm != true) return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (mounted) {
        Fluttertoast.showToast(
          msg: "Logout realizado com sucesso",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Navegar para a tela de login
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Erro ao fazer logout: ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  Future<bool?> _showLogoutConfirmDialog() => showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.orange),
              SizedBox(width: 8),
              Text('Confirmar Logout'),
            ],
          ),
          content: const Text(
            'Tem certeza que deseja sair do sistema?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: _isLoggingOut
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: _isLoggingOut ? Colors.grey : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isLoggingOut
                  ? null
                  : () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: _isLoggingOut
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Sair'),
            ),
          ],
        ),
    );

  @override
  Widget build(BuildContext context) => Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (widget.isIconButton) {
          return IconButton(
            onPressed: _isLoggingOut ? null : _handleLogout,
            icon: _isLoggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    widget.icon ?? Icons.logout,
                    color: widget.color ?? Colors.white,
                  ),
            tooltip: _isLoggingOut ? 'Saindo...' : 'Sair do sistema',
          );
        }

        return ElevatedButton.icon(
          onPressed: _isLoggingOut ? null : _handleLogout,
          icon: _isLoggingOut
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  widget.icon ?? Icons.logout,
                  size: 18,
                ),
          label: Text(
            _isLoggingOut 
                ? 'Saindo...' 
                : (widget.text ?? 'Sair'),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color ?? Colors.red,
            foregroundColor: widget.textColor ?? Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
}

// Widget para uso rápido na AppBar
class AppBarLogoutButton extends StatelessWidget {
  const AppBarLogoutButton({super.key});

  @override
  Widget build(BuildContext context) => const LogoutButton(
      isIconButton: true,
      icon: Icons.logout,
      color: Colors.white,
      showConfirmDialog: true,
    );
}

// Widget para uso em menus/sidebar
class MenuLogoutButton extends StatelessWidget {
  final bool showIcon;
  
  const MenuLogoutButton({
    super.key,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) => LogoutButton(
      text: 'Sair do Sistema',
      icon: showIcon ? Icons.logout : null,
      color: Colors.red[600],
      textColor: Colors.white,
      showConfirmDialog: true,
    );
}

// Widget para uso em cards/dashboard
class CardLogoutButton extends StatelessWidget {
  const CardLogoutButton({super.key});

  @override
  Widget build(BuildContext context) => LogoutButton(
      text: 'Logout',
      icon: Icons.exit_to_app,
      color: Colors.orange[600],
      textColor: Colors.white,
      showConfirmDialog: false,
    );
}