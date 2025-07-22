import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../providers/auth_provider.dart';
import '../utils/responsive.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key, required int selectedIndex, required void Function(int index) onItemTapped, required List<dynamic> navigationItems});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int _selectedIndex = 0;
  bool _isExpanded = true;

  final List<SideBarItem> _menuItems = [
    SideBarItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      title: 'Dashboard',
      route: '/home',
    ),
    SideBarItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      title: 'Responsáveis',
      route: '/responsaveis',
    ),
    SideBarItem(
      icon: Icons.family_restroom_outlined,
      selectedIcon: Icons.family_restroom,
      title: 'Membros',
      route: '/membros',
    ),
    SideBarItem(
      icon: Icons.health_and_safety_outlined,
      selectedIcon: Icons.health_and_safety,
      title: 'Demandas Saúde',
      route: '/demandas-saude',
    ),
    SideBarItem(
      icon: Icons.school_outlined,
      selectedIcon: Icons.school,
      title: 'Demandas Educação',
      route: '/demandas-educacao',
    ),
    SideBarItem(
      icon: Icons.home_work_outlined,
      selectedIcon: Icons.home_work,
      title: 'Demandas Habitação',
      route: '/demandas-habitacao',
    ),
    SideBarItem(
      icon: Icons.pets_outlined,
      selectedIcon: Icons.pets,
      title: 'Demandas Ambiente',
      route: '/demandas-ambiente',
    ),
    SideBarItem(
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment,
      title: 'Demandas Internas',
      route: '/demandas-internas',
    ),
    SideBarItem(
      icon: Icons.search_outlined,
      selectedIcon: Icons.search,
      title: 'Desaparecidos',
      route: '/desaparecidos',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    // CORREÇÃO LINHA 42: Verificar se é mobile antes de mostrar sidebar
    if (Responsive.isMobile(context)) {
      return _buildMobileSidebar(context, user);
    }
    
    return _buildDesktopSidebar(context, user);
  }

  Widget _buildDesktopSidebar(BuildContext context, user) => Container(
      width: _isExpanded ? 280 : 70,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context, user),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _menuItems.length,
              itemBuilder: _buildMenuItem,
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );

  Widget _buildMobileSidebar(BuildContext context, user) => Drawer(
      child: Column(
        children: [
          _buildHeader(context, user),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _menuItems.length,
              itemBuilder: _buildMenuItem,
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );

  Widget _buildHeader(BuildContext context, user) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          if (!Responsive.isMobile(context))
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_isExpanded) ...[
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                IconButton(
                  onPressed: () {
                    if (mounted) {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    }
                  },
                  icon: Icon(
                    _isExpanded ? Icons.chevron_left : Icons.chevron_right,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_isExpanded || Responsive.isMobile(context)) ...[
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.username ?? 'Usuário',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );

  Widget _buildMenuItem(BuildContext context, int index) {
    final item = _menuItems[index];
    final isSelected = _selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected 
            ? AppConstants.primaryColor.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? item.selectedIcon : item.icon,
          color: isSelected 
              ? AppConstants.primaryColor 
              : Theme.of(context).iconTheme.color,
          size: 24,
        ),
        title: _isExpanded || Responsive.isMobile(context)
            ? Text(
                item.title,
                style: TextStyle(
                  color: isSelected 
                      ? AppConstants.primaryColor 
                      : Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: isSelected 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                ),
              )
            : null,
        onTap: () {
          if (mounted) {
            setState(() {
              _selectedIndex = index;
            });
          }
          
          // Navegação
          Navigator.of(context).pushNamed(item.route);
          
          // Fechar drawer no mobile
          if (Responsive.isMobile(context)) {
            Navigator.of(context).pop();
          }
        },
        dense: !_isExpanded && !Responsive.isMobile(context),
        visualDensity: _isExpanded || Responsive.isMobile(context)
            ? VisualDensity.standard
            : VisualDensity.compact,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          if (_isExpanded || Responsive.isMobile(context)) ...[
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Configurações'),
              onTap: () {
                // Navegar para configurações
              },
              dense: true,
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Ajuda'),
              onTap: () {
                // Abrir ajuda
              },
              dense: true,
            ),
          ],
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: _isExpanded || Responsive.isMobile(context)
                ? const Text(
                    'Sair',
                    style: TextStyle(color: Colors.red),
                  )
                : null,
            onTap: () async {
              // Confirmar logout
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar Saída'),
                  content: const Text('Deseja realmente sair do sistema?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Sair',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && mounted) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              }
            },
            dense: true,
          ),
          if (_isExpanded || Responsive.isMobile(context)) ...[
            const SizedBox(height: 16),
            Text(
              'Versão ${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
}

class SideBarItem {
  final IconData icon;
  final IconData selectedIcon;
  final String title;
  final String route;

  const SideBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.title,
    required this.route,
  });
}