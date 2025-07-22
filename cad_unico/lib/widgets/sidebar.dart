// lib/widgets/sidebar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../providers/auth_provider.dart';
import '../utils/responsive.dart';

class NavigationItem {
  final String title;
  final String route;
  final IconData icon;
  final List<NavigationItem>? children;

  NavigationItem({
    required this.title,
    required this.route,
    required this.icon,
    this.children,
  });
}

class SideBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<NavigationItem> navigationItems;

  const SideBar({
    super.key,
    this.selectedIndex = 0,
    required this.onItemTapped,
    required this.navigationItems,
  });

  // Construtor padrão para uso sem parâmetros obrigatórios
  const SideBar.defaultItems({
    super.key,
  }) : selectedIndex = 0,
        onItemTapped = _defaultOnItemTapped,
        navigationItems = _defaultNavigationItems;

  static void _defaultOnItemTapped(int index) {
    // Implementação padrão vazia
  }

  static final List<NavigationItem> _defaultNavigationItems = [
    NavigationItem(
      title: 'Dashboard',
      route: '/home',
      icon: Icons.dashboard,
    ),
    NavigationItem(
      title: 'Responsáveis',
      route: '/responsaveis',
      icon: Icons.person,
    ),
    NavigationItem(
      title: 'Membros',
      route: '/membros',
      icon: Icons.group,
    ),
    NavigationItem(
      title: 'Demandas',
      route: '/demandas',
      icon: Icons.assignment,
    ),
  ];

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int _selectedIndex = 0;
  String _currentRoute = '/home';

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _currentRoute = GoRouter.of(context).routeInformationProvider.value.uri.path;
  }

  List<NavigationItem> get _navigationItems => widget.navigationItems.isNotEmpty 
        ? widget.navigationItems 
        : _getDefaultNavigationItems();

  List<NavigationItem> _getDefaultNavigationItems() => [
      NavigationItem(
        title: 'Dashboard',
        route: '/home',
        icon: Icons.dashboard,
      ),
      NavigationItem(
        title: 'Responsáveis',
        route: '/responsaveis',
        icon: Icons.person,
        children: [
          NavigationItem(
            title: 'Lista',
            route: '/responsaveis',
            icon: Icons.list,
          ),
          NavigationItem(
            title: 'Novo',
            route: '/responsaveis/novo',
            icon: Icons.person_add,
          ),
        ],
      ),
      NavigationItem(
        title: 'Membros',
        route: '/membros',
        icon: Icons.group,
        children: [
          NavigationItem(
            title: 'Lista',
            route: '/membros',
            icon: Icons.list,
          ),
          NavigationItem(
            title: 'Novo',
            route: '/membros/novo',
            icon: Icons.group_add,
          ),
        ],
      ),
      NavigationItem(
        title: 'Demandas',
        route: '/demandas',
        icon: Icons.assignment,
        children: [
          NavigationItem(
            title: 'Saúde',
            route: '/demandas/saude',
            icon: Icons.health_and_safety,
          ),
          NavigationItem(
            title: 'Educação',
            route: '/demandas/educacao',
            icon: Icons.school,
          ),
          NavigationItem(
            title: 'Ambiente',
            route: '/demandas/ambiente',
            icon: Icons.pets,
          ),
        ],
      ),
      NavigationItem(
        title: 'Relatórios',
        route: '/relatorios',
        icon: Icons.analytics,
      ),
      NavigationItem(
        title: 'Configurações',
        route: '/configuracoes',
        icon: Icons.settings,
      ),
    ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final theme = Theme.of(context);

    return Container(
      width: isDesktop ? 260 : 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
        boxShadow: isDesktop
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ..._navigationItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildNavigationItem(item, index);
                }),
              ],
            ),
          ),

          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo e nome do app
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'v${AppConstants.appVersion}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Informações do usuário
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              final user = auth.user;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        user?.username?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Usuário',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user?.email ?? '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

  Widget _buildNavigationItem(NavigationItem item, int index) {
    final isSelected = _currentRoute == item.route || _selectedIndex == index;
    final hasChildren = item.children != null && item.children!.isNotEmpty;

    if (hasChildren) {
      return ExpansionTile(
        leading: Icon(
          item.icon,
          color: isSelected 
              ? Theme.of(context).primaryColor
              : Colors.grey[600],
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        children: item.children!.map((child) {
          final isChildSelected = _currentRoute == child.route;
          return ListTile(
            contentPadding: const EdgeInsets.only(left: 56, right: 16),
            leading: Icon(
              child.icon,
              size: 20,
              color: isChildSelected 
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            title: Text(
              child.title,
              style: TextStyle(
                color: isChildSelected 
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isChildSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            onTap: () {
              _onItemTap(child.route, index);
            },
          );
        }).toList(),
      );
    }

    return ListTile(
      leading: Icon(
        item.icon,
        color: isSelected 
            ? Theme.of(context).primaryColor
            : Colors.grey[600],
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: isSelected 
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        _onItemTap(item.route, index);
      },
    );
  }

  Widget _buildFooter() => Container(
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
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.help_outline),
            title: const Text('Ajuda'),
            onTap: () {
              // TODO: Implementar página de ajuda
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre'),
            onTap: () {
              _showAboutDialog();
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              _logout();
            },
          ),
        ],
      ),
    );

  void _onItemTap(String route, int index) {
    setState(() {
      _selectedIndex = index;
      _currentRoute = route;
    });

    widget.onItemTapped(index);
    context.go(route);

    // Fechar drawer no mobile
    if (!Responsive.isDesktop(context)) {
      Navigator.of(context).pop();
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Tem certeza que deseja sair do sistema?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.account_balance,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text('Sistema de gestão de cadastros e demandas sociais.'),
        const SizedBox(height: 8),
        const Text('Desenvolvido para auxiliar no controle e acompanhamento de responsáveis, membros e suas demandas.'),
      ],
    );
  }
}