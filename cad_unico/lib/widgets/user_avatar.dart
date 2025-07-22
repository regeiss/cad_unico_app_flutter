import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_extensions.dart';
import '../providers/auth_provider.dart';

class UserAvatar extends StatelessWidget {
  final double radius;
  final VoidCallback? onTap;
  final bool showOnlineStatus;

  const UserAvatar({
    super.key,
    this.radius = 20,
    this.onTap,
    this.showOnlineStatus = false,
  });

  @override
  Widget build(BuildContext context) => Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey[300],
            child: Icon(
              Icons.person,
              size: radius * 0.8,
              color: Colors.grey[600],
            ),
          );
        }

        return GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              CircleAvatar(
                radius: radius,
                backgroundColor: Colors.blue,
                child: Text(
                  authProvider.userInitials,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: radius * 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (showOnlineStatus)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: radius * 0.4,
                    height: radius * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
}