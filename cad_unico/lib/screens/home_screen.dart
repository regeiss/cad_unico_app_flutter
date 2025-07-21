import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../contants/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/demanda_provider.dart';
import '../providers/membro_provider.dart';
import '../providers/responsavel_provider.dart';
import '../utils/responsive.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _navigationItems = [
    {
      'icon': AppConstants.homeIcon,
      'label': 'Dashboard',
      'route': '/home',
    },
    {
      'icon': AppConstants.responsavelIcon,
      'label': 'Responsáveis',
      'route': '/home/responsaveis',
    },
    {
      'icon': AppConstants.membroIcon,
      'label': 'Membros',
      'route': '/home/membros',
    },
    {
      'icon': AppConstants.demandaIcon,
      'label': 'Demandas',
      'route': '/home/demandas',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final responsavelProvider = Provider.of<ResponsavelProvider>(context, listen: false);
    final membroProvider = Provider.of<MembroProvider>(context, listen: false);
    final demandaProvider = Provider.of<DemandaProvider>(context, listen: false);

    await Future.wait([
      responsavelProvider.loadResponsaveis(),
      membroProvider.loadMembros(),
      demandaProvider.loadDemandas(),
    ]);
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    if (Responsive.isMobile) {
      Navigator.of(context).pop(); // Close drawer
    }
    
    context.go(_navigationItems[index]['route']);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: Responsive.isMobile ? _buildDrawer() : null,
      body: ResponsiveBreakpoints(
        mobile: _buildMobileLayout(),
        desktop: _buildDesktopLayout(),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );

  PreferredSizeWidget _buildAppBar() => AppBar(
      title: Text(AppConstants.appName),
      leading: Responsive.isMobile
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            )
          : null,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadInitialData,
          tooltip: 'Atualizar dados',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Implement notifications
          },
          tooltip: 'Notificações',
        ),
        _buildUserMenu(),
      ],
    );

  Widget _buildUserMenu() => Consumer<AuthProvider>(
      builder: (context, authProvider, child) => PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              authProvider.userInitials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onSelected: (value) async {
            switch (value) {
              case 'profile':
                // TODO: Navigate to profile
                break;
              case 'settings':
                // TODO: Navigate to settings
                break;
              case 'logout':
                await authProvider.logout();
                if (mounted) {
                  context.go('/');
                }
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  const Icon(Icons.person_outline),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        authProvider.userName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        authProvider.user?.email ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined),
                  SizedBox(width: 12),
                  Text('Configurações'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.exit_to_app),
                  SizedBox(width: 12),
                  Text('Sair'),
                ],
              ),
            ),
          ],
        ),
    );

  Widget _buildDrawer() => SideBar(
      selectedIndex: _selectedIndex,
      onItemTapped: _onNavigationItemTapped,
      navigationItems: _navigationItems,
    );

  Widget _buildMobileLayout() => _buildDashboard();

  Widget _buildDesktopLayout() => Row(
      children: [
        SideBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onNavigationItemTapped,
          navigationItems: _navigationItems,
        ),
        Expanded(
          child: _buildDashboard(),
        ),
      ],
    );

  Widget _buildDashboard() => RefreshIndicator(
      onRefresh: _loadInitialData,
      child: SingleChildScrollView(
        padding: Responsive.padding(
          mobile: const EdgeInsets.all(16),
          desktop: const EdgeInsets.all(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );

  Widget _buildWelcomeSection() => Consumer<AuthProvider>(
      builder: (context, authProvider, child) => Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    authProvider.userInitials,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bem-vindo, ${authProvider.userName}!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Aqui está um resumo das informações do sistema',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );

  Widget _buildStatsCards() => Consumer3<ResponsavelProvider, MembroProvider, DemandaProvider>(
      builder: (context, responsavelProvider, membroProvider, demandaProvider, child) {
        final stats = [
          {
            'title': 'Responsáveis',
            'value': responsavelProvider.responsaveis.length.toString(),
            'icon': AppConstants.responsavelIcon,
            'color': Colors.blue,
            'route': '/home/responsaveis',
            'isLoading': responsavelProvider.isLoading,
          },
          {
            'title': 'Membros',
            'value': membroProvider.membros.length.toString(),
            'icon': AppConstants.membroIcon,
            'color': Colors.green,
            'route': '/home/membros',
            'isLoading': membroProvider.isLoading,
          },
          {
            'title': 'Demandas',
            'value': demandaProvider.demandas.length.toString(),
            'icon': AppConstants.demandaIcon,
            'color': Colors.orange,
            'route': '/home/demandas',
            'isLoading': demandaProvider.isLoading,
          },
          {
            'title': 'Pendentes',
            'value': '0', // TODO: Calculate pending items
            'icon': Icons.pending_actions,
            'color': Colors.red,
            'route': '/home/demandas',
            'isLoading': false,
          },
        ];

        return ResponsiveGrid(
          mobileColumns: 2,
          tabletColumns: 4,
          desktopColumns: 4,
          spacing: 16,
          children: stats.map((stat) => DashboardCard(
            title: stat['title'] as String,
            value: stat['value'] as String,
            icon: stat['icon'] as IconData,
            color: stat['color'] as Color,
            isLoading: stat['isLoading'] as bool,
            onTap: () => context.go(stat['route'] as String),
          )).toList(),
        );
      },
    );

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'Novo Responsável',
        'subtitle': 'Cadastrar nova pessoa',
        'icon': Icons.person_add,
        'color': Colors.blue,
        'onTap': () {
          // TODO: Navigate to new responsavel form
          context.go('/home/responsaveis');
        },
      },
      {
        'title': 'Nova Demanda',
        'subtitle': 'Registrar demanda',
        'icon': Icons.assignment_add,
        'color': Colors.green,
        'onTap': () {
          // TODO: Navigate to new demanda form
          context.go('/home/demandas');
        },
      },
      {
        'title': 'Buscar CPF',
        'subtitle': 'Localizar por CPF',
        'icon': Icons.search,
        'color': Colors.orange,
        'onTap': () {
          _showSearchDialog();
        },
      },
      {
        'title': 'Relatórios',
        'subtitle': 'Gerar relatórios',
        'icon': Icons.bar_chart,
        'color': Colors.purple,
        'onTap': () {
          // TODO: Navigate to reports
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ResponsiveGrid(
          mobileColumns: 2,
          tabletColumns: 4,
          desktopColumns: 4,
          spacing: 16,
          children: actions.map((action) => DashboardCard.action(
            title: action['title'] as String,
            subtitle: action['subtitle'] as String,
            icon: action['icon'] as IconData,
            color: action['color'] as Color,
            onTap: action['onTap'] as VoidCallback,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Atividade Recente',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full activity log
              },
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityItem(
                  icon: Icons.person_add,
                  title: 'Novo responsável cadastrado',
                  subtitle: 'João Silva - CPF: 123.456.789-00',
                  time: '2 horas atrás',
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.assignment,
                  title: 'Nova demanda registrada',
                  subtitle: 'Demanda de saúde - Maria Santos',
                  time: '4 horas atrás',
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.edit,
                  title: 'Cadastro atualizado',
                  subtitle: 'Pedro Oliveira - Dados atualizados',
                  time: '6 horas atrás',
                ),
              ],
            ),
          ),
        ),
      ],
    );

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) => ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 4),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
    );

  Widget? _buildFloatingActionButton() {
    if (!Responsive.isMobile) return null;

    return FloatingActionButton(
      onPressed: _showQuickActionDialog,
      child: const Icon(Icons.add),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar por CPF'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'CPF',
            hintText: 'Digite o CPF',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement search
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _showQuickActionDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Novo Responsável'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/home/responsaveis');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_add),
              title: const Text('Nova Demanda'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/home/demandas');
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Buscar CPF'),
              onTap: () {
                Navigator.of(context).pop();
                _showSearchDialog();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:provider/provider.dart';

// import '../contants/constants.dart';
// import '../providers/auth_provider.dart';
// import '../providers/demanda_provider.dart';
// import '../providers/membro_provider.dart';
// import '../providers/responsavel_provider.dart';
// import '../utils/responsive.dart';
// import '../widgets/dashboard_card.dart';
// //import 'package:cadastro_app/widgets/responsive_layout.dart';
// import '../widgets/sidebar.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
  
//   final List<NavigationItem> _navigationItems = [
//     NavigationItem(
//       icon: Icons.dashboard,
//       label: 'Dashboard',
//       route: '/',
//     ),
//     NavigationItem(
//       icon: Icons.people,
//       label: 'Responsáveis',
//       route: '/responsaveis',
//     ),
//     NavigationItem(
//       icon: Icons.family_restroom,
//       label: 'Membros',
//       route: '/membros',
//     ),
//     NavigationItem(
//       icon: MdiIcons.clipboardText,
//       label: 'Demandas',
//       route: '/demandas',
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     final responsavelProvider = Provider.of<ResponsavelProvider>(context, listen: false);
//     final membroProvider = Provider.of<MembroProvider>(context, listen: false);
//     final demandaProvider = Provider.of<DemandaProvider>(context, listen: false);

//     // Carrega dados iniciais para o dashboard
//     try {
//       await Future.wait([
//         responsavelProvider.loadResponsaveis(refresh: true),
//         membroProvider.loadMembros(refresh: true),
//         demandaProvider.loadAllDemandas(),
//       ]);
//     } on Exception catch (e) {
//       debugPrint('Erro ao carregar dados iniciais: $e');
//     }
//   }

//   void _onNavigationItemSelected(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
    
//     final route = _navigationItems[index].route;
//     if (route != '/') {
//       context.go(route);
//     }
//   }

//   @override
//   Widget build(BuildContext context) => LayoutBuilder(
//       builder: (context, constraints) {
//         final width = constraints.maxWidth;
        
//         // Usando sua classe Responsive
//         if (Responsive.isDesktop(width)) {
//           return _buildDesktopLayout();
//         } else if (Responsive.isTablet(width)) {
//           return _buildTabletLayout();
//         } else {
//           return _buildMobileLayout();
//         }
//       },
//     );

//   Widget _buildMobileLayout() => Scaffold(
//       appBar: AppBar(
//         title: Text(_navigationItems[_selectedIndex].label),
//         actions: [
//           _buildProfileMenu(),
//         ],
//       ),
//       body: _buildDashboardContent(),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _selectedIndex,
//         onTap: _onNavigationItemSelected,
//         items: _navigationItems.map((item) => BottomNavigationBarItem(
//           icon: Icon(item.icon),
//           label: item.label,
//         )).toList(),
//       ),
//     );

//   Widget _buildTabletLayout() => Scaffold(
//       appBar: AppBar(
//         title: const Text('Cadastro Unificado'),
//         actions: [
//           _buildProfileMenu(),
//         ],
//       ),
//       body: Row(
//         children: [
//           NavigationRail(
//             selectedIndex: _selectedIndex,
//             onDestinationSelected: _onNavigationItemSelected,
//             labelType: NavigationRailLabelType.all,
//             destinations: _navigationItems.map((item) => NavigationRailDestination(
//               icon: Icon(item.icon),
//               label: Text(item.label),
//             )).toList(),
//           ),
//           const VerticalDivider(thickness: 1, width: 1),
//           Expanded(child: _buildDashboardContent()),
//         ],
//       ),
//     );

//   Widget _buildDesktopLayout() => Scaffold(
//       body: Row(
//         children: [
//           SideBar(
//             selectedIndex: _selectedIndex,
//             items: _navigationItems,
//             onItemSelected: _onNavigationItemSelected,
//           ),
//           Expanded(
//             child: Column(
//               children: [
//                 _buildTopBar(),
//                 Expanded(child: _buildDashboardContent()),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );

//   Widget _buildTopBar() => Container(
//       height: 64,
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         child: Row(
//           children: [
//             Text(
//               _navigationItems[_selectedIndex].label,
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const Spacer(),
//             _buildProfileMenu(),
//           ],
//         ),
//       ),
//     );

//   Widget _buildProfileMenu() => Consumer<AuthProvider>(
//       builder: (context, authProvider, child) {
//         final user = authProvider.user;
        
//         return PopupMenuButton<String>(
//           icon: CircleAvatar(
//             backgroundColor: Theme.of(context).colorScheme.primary,
//             child: Text(
//               user?.username.substring(0, 1).toUpperCase() ?? 'U',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           onSelected: (value) {
//             switch (value) {
//               case 'profile':
//                 _showProfileDialog();
//                 break;
//               case 'logout':
//                 _handleLogout();
//                 break;
//             }
//           },
//           itemBuilder: (context) => [
//             PopupMenuItem(
//               value: 'profile',
//               child: Row(
//                 children: [
//                   const Icon(Icons.person),
//                   const SizedBox(width: 8),
//                   Text('Perfil (${user?.username ?? 'Usuário'})'),
//                 ],
//               ),
//             ),
//             const PopupMenuDivider(),
//             const PopupMenuItem(
//               value: 'logout',
//               child: Row(
//                 children: [
//                   Icon(Icons.logout),
//                   SizedBox(width: 8),
//                   Text('Sair'),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );

//   Widget _buildDashboardContent() => SingleChildScrollView(
//       padding: Responsive.getResponsivePadding(context),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Text(
//             'Dashboard',
//             style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Visão geral do sistema de cadastros',
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//               color: Theme.of(context).textTheme.bodyMedium?.color,
//             ),
//           ),
//           const SizedBox(height: 24),
          
//           // Cards de estatísticas
//           _buildStatsCards(),
          
//           const SizedBox(height: 24),
          
//           // Gráficos e resumos
//           _buildChartsSection(),
          
//           const SizedBox(height: 24),
          
//           // Ações rápidas
//           _buildQuickActions(),
//         ],
//       ),
//     );

//   Widget _buildStatsCards() => Consumer3<ResponsavelProvider, MembroProvider, DemandaProvider>(
//       builder: (context, responsavelProvider, membroProvider, demandaProvider, child) => LayoutBuilder(
//           builder: (context, constraints) {
//             final crossAxisCount = Responsive.getGridColumns(
//               constraints.maxWidth,
//               mobile: 2,
//               tablet: 3,
//               desktop: 4,
//             );
            
//             return GridView.count(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisCount: crossAxisCount,
//               childAspectRatio: 1.5,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//               children: [
//                 DashboardCard(
//                   title: 'Responsáveis',
//                   value: responsavelProvider.responsaveis.length.toString(),
//                   icon: Icons.people,
//                   color: Colors.blue,
//                   subtitle: '${responsavelProvider.responsaveis.where((r) => r.isAtivo).length} ativos',
//                   onTap: () => context.go('/responsaveis'),
//                   isLoading: responsavelProvider.isLoading,
//                 ),
//                 DashboardCard(
//                   title: 'Membros',
//                   value: membroProvider.membros.length.toString(),
//                   icon: Icons.family_restroom,
//                   color: Colors.green,
//                   subtitle: '${membroProvider.membros.where((m) => m.isAtivo).length} ativos',
//                   onTap: () => context.go('/membros'),
//                   isLoading: membroProvider.isLoading,
//                 ),
//                 DashboardCard(
//                   title: 'Demandas Saúde',
//                   value: demandaProvider.demandasSaude.length.toString(),
//                   icon: MdiIcons.heart,
//                   color: Colors.red,
//                   subtitle: '${demandaProvider.demandasSaude.where((d) => d.isGrupoPrioritario).length} prioritárias',
//                   onTap: () => context.go('/demandas'),
//                   isLoading: demandaProvider.isLoading,
//                 ),
//                 DashboardCard(
//                   title: 'Demandas Educação',
//                   value: demandaProvider.demandasEducacao.length.toString(),
//                   icon: MdiIcons.school,
//                   color: Colors.orange,
//                   onTap: () => context.go('/demandas'),
//                   isLoading: demandaProvider.isLoading,
//                 ),
//               ],
//             );
//           },
//         ),
//     );

//   Widget _buildChartsSection() => Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Análises',
//           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 16),
        
//         Consumer<DemandaProvider>(
//           builder: (context, demandaProvider, child) {
//             final gruposPrioritarios = demandaProvider.demandasSaude
//                 .where((d) => d.isGrupoPrioritario)
//                 .length;
            
//             return Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(
//                           MdiIcons.alertCircle,
//                           color: Colors.orange,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Grupos Prioritários',
//                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '$gruposPrioritarios pessoas em grupos prioritários de saúde',
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                     const SizedBox(height: 16),
//                     LinearProgressIndicator(
//                       value: demandaProvider.demandasSaude.isNotEmpty 
//                           ? gruposPrioritarios / demandaProvider.demandasSaude.length 
//                           : 0,
//                       backgroundColor: Colors.grey[300],
//                       valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );

//   Widget _buildQuickActions() {
//     final actions = [
//       QuickAction(
//         title: 'Novo Responsável',
//         subtitle: 'Cadastrar nova pessoa responsável',
//         icon: Icons.person_add,
//         color: Colors.blue,
//         onTap: () => context.go('/responsaveis/novo'),
//       ),
//       QuickAction(
//         title: 'Novo Membro',
//         subtitle: 'Adicionar membro familiar',
//         icon: Icons.group_add,
//         color: Colors.green,
//         onTap: () => context.go('/membros'),
//       ),
//       QuickAction(
//         title: 'Ver Demandas',
//         subtitle: 'Consultar demandas cadastradas',
//         icon: MdiIcons.clipboardText,
//         color: Colors.orange,
//         onTap: () => context.go('/demandas'),
//       ),
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Ações Rápidas',
//           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 16),
        
//         LayoutBuilder(
//           builder: (context, constraints) {
//             final isDesktop = Responsive.isDesktop(constraints.maxWidth);
            
//             if (isDesktop) {
//               return Row(
//                 children: actions.map((action) => Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.only(right: 16),
//                     child: _buildQuickActionCard(action),
//                   ),
//                 )).toList(),
//               );
//             } else {
//               return Column(
//                 children: actions.map((action) => Padding(
//                   padding: const EdgeInsets.only(bottom: 16),
//                   child: _buildQuickActionCard(action),
//                 )).toList(),
//               );
//             }
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildQuickActionCard(QuickAction action) => Card(
//       child: InkWell(
//         onTap: action.onTap,
//         borderRadius: BorderRadius.circular(AppConstants.borderRadius),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: action.color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: Icon(
//                   action.icon,
//                   color: action.color,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       action.title,
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Text(
//                       action.subtitle,
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: Theme.of(context).textTheme.bodySmall?.color,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.chevron_right,
//                 color: Theme.of(context).textTheme.bodySmall?.color,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//   void _showProfileDialog() {
//     final user = Provider.of<AuthProvider>(context, listen: false).user;
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Perfil do Usuário'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Usuário: ${user?.username ?? 'N/A'}'),
//             Text('Email: ${user?.email ?? 'N/A'}'),
//             Text('Nome: ${user?.fullName ?? 'N/A'}'),
//             Text('Ativo: ${user?.isActive == true ? 'Sim' : 'Não'}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Fechar'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleLogout() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirmar Logout'),
//         content: const Text('Tem certeza que deseja sair?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancelar'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               Provider.of<AuthProvider>(context, listen: false).logout();
//               context.go('/login');
//             },
//             child: const Text('Sair'),
//           ),
//         ],
//       ),
//     );
//   }
// }
// // Models de apoio
// class NavigationItem {
//   final IconData icon;
//   final String label;
//   final String route;

//   NavigationItem({
//     required this.icon,
//     required this.label,
//     required this.route,
//   });
// }

// class QuickAction {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;

//   QuickAction({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.color,
//     required this.onTap,
//   });
// }