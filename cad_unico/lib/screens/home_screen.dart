import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
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
    final responsavelProvider =
        Provider.of<ResponsavelProvider>(context, listen: false);
    final membroProvider = Provider.of<MembroProvider>(context, listen: false);
    final demandaProvider =
        Provider.of<DemandaProvider>(context, listen: false);

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
                        authProvider.userName ?? 'Usuário',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        authProvider.userEmail ?? '',
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
                        'Bem-vindo, ${authProvider.userName ?? 'Usuário'}!',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Aqui está um resumo das informações do sistema',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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

  Widget _buildStatsCards() =>
      Consumer3<ResponsavelProvider, MembroProvider, DemandaProvider>(
        builder: (context, responsavelProvider, membroProvider, demandaProvider,
            child) {
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
            children: stats
                .map((stat) => DashboardCard(
                      title: stat['title'] as String,
                      value: stat['value'] as String,
                      icon: stat['icon'] as IconData,
                      color: stat['color'] as Color,
                      isLoading: stat['isLoading'] as bool,
                      onTap: () => context.go(stat['route'] as String),
                    ))
                .toList(),
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
        'onTap': _showSearchDialog,
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
          children: actions
              .map((action) => _buildActionCard(
                    title: action['title'] as String,
                    subtitle: action['subtitle'] as String,
                    icon: action['icon'] as IconData,
                    color: action['color'] as Color,
                    onTap: action['onTap'] as VoidCallback,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
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
  }) =>
      ListTile(
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