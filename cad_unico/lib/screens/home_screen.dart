import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/demanda_provider.dart';
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
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    try {
      await Future.wait([
        context.read<ResponsavelProvider>().loadResponsaveis(),
        context.read<MembroProvider>().loadMembros(),
        context.read<DemandaProvider>().loadAllDemandas(),
      ]);
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    }
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<NavigationItem> _getNavigationItems() => [
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
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    
    return Scaffold(
      drawer: isDesktop ? null : SideBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavigationItemTapped,
        navigationItems: _getNavigationItems(),
      ),
      body: Row(
        children: [
          // Sidebar para desktop
          if (isDesktop) 
            SideBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onNavigationItemTapped,
              navigationItems: _getNavigationItems(),
            ),
          
          // Conteúdo principal
          Expanded(
            child: Column(
              children: [
                // AppBar customizada
                _buildAppBar(),
                
                // Conteúdo
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header de boas-vindas
                          _buildWelcomeHeader(),
                          
                          const SizedBox(height: 24),
                          
                          // Cards de estatísticas
                          _buildStatsCards(),
                          
                          const SizedBox(height: 24),
                          
                          // Gráficos e informações
                          if (isDesktop) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildDemandasChart(),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildRecentActivities(),
                                ),
                              ],
                            ),
                          ] else ...[
                            _buildDemandasChart(),
                            const SizedBox(height: 16),
                            _buildRecentActivities(),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          // Ações rápidas
                          _buildQuickActions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() => Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!Responsive.isDesktop(context))
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Text(
              'Dashboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Ações da AppBar
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implementar notificações
            },
          ),
          
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          
          const SizedBox(width: 8),
          
          // Avatar do usuário
          Consumer<AuthProvider>(
            builder: (context, auth, child) => PopupMenuButton<String>(
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    auth.user?.username.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'perfil',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Perfil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'configuracoes',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('Configurações'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'sair',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Sair', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (String value) {
                  switch (value) {
                    case 'perfil':
                      // TODO: Navegar para perfil
                      break;
                    case 'configuracoes':
                      // TODO: Navegar para configurações
                      break;
                    case 'sair':
                      context.read<AuthProvider>().logout();
                      context.go('/login');
                      break;
                  }
                },
              ),
          ),
          
          const SizedBox(width: 16),
        ],
      ),
    );

  Widget _buildWelcomeHeader() => Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final now = DateTime.now();
        final hour = now.hour;
        String greeting;
        
        if (hour < 12) {
          greeting = 'Bom dia';
        } else if (hour < 18) {
          greeting = 'Boa tarde';
        } else {
          greeting = 'Boa noite';
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, ${auth.user?.username ?? 'Usuário'}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Aqui está o resumo das atividades do sistema',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      },
    );

  Widget _buildStatsCards() => Consumer3<ResponsavelProvider, MembroProvider, DemandaProvider>(
      builder: (context, responsavelProvider, membroProvider, demandaProvider, child) {
        final isDesktop = Responsive.isDesktop(context);
        
        final cards = [
          DashboardCard(
            title: 'Responsáveis',
            value: responsavelProvider.totalResponsaveis.toString(),
            subtitle: 'Cadastrados',
            icon: Icons.person,
            color: Colors.blue,
            onTap: () => context.go('/responsaveis'),
            isCompact: !isDesktop,
          ),
          DashboardCard(
            title: 'Membros',
            value: membroProvider.totalMembros.toString(),
            subtitle: 'Registrados',
            icon: Icons.group,
            color: Colors.green,
            onTap: () => context.go('/membros'),
            isCompact: !isDesktop,
          ),
          DashboardCard(
            title: 'Demandas Saúde',
            value: demandaProvider.totalDemandasSaude.toString(),
            subtitle: 'Ativas',
            icon: Icons.health_and_safety,
            color: Colors.red,
            onTap: () => context.go('/demandas'),
            isCompact: !isDesktop,
          ),
          DashboardCard(
            title: 'Demandas Educação',
            value: demandaProvider.totalDemandasEducacao.toString(),
            subtitle: 'Pendentes',
            icon: Icons.school,
            color: Colors.orange,
            onTap: () => context.go('/demandas'),
            isCompact: !isDesktop,
          ),
        ];
        
        if (isDesktop) {
          return Row(
            children: cards
                .map((card) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: card,
                      ),
                    ))
                .toList(),
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 8),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: cards[2]),
                  const SizedBox(width: 8),
                  Expanded(child: cards[3]),
                ],
              ),
            ],
          );
        }
      },
    );

  Widget _buildDemandasChart() => Consumer<DemandaProvider>(
      builder: (context, demandaProvider, child) {
        final totalDemandas = demandaProvider.totalDemandasSaude + 
                             demandaProvider.totalDemandasEducacao + 
                             demandaProvider.totalDemandasAmbiente;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Distribuição de Demandas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => context.go('/demandas'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (totalDemandas == 0)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Nenhuma demanda encontrada',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      _buildDemandaItem(
                        'Saúde',
                        demandaProvider.totalDemandasSaude,
                        totalDemandas,
                        Colors.red,
                        Icons.health_and_safety,
                      ),
                      _buildDemandaItem(
                        'Educação',
                        demandaProvider.totalDemandasEducacao,
                        totalDemandas,
                        Colors.blue,
                        Icons.school,
                      ),
                      _buildDemandaItem(
                        'Ambiente',
                        demandaProvider.totalDemandasAmbiente,
                        totalDemandas,
                        Colors.green,
                        Icons.pets,
                      ),
                      _buildDemandaItem(
                        'Grupos Prioritários',
                        demandaProvider.totalGruposPrioritarios,
                        totalDemandas,
                        Colors.orange,
                        Icons.priority_high,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );

  Widget _buildDemandaItem(
    String label,
    int value,
    int total,
    Color color,
    IconData icon,
  ) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Atividades Recentes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Ver todas as atividades
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Lista de atividades
            Column(
              children: [
                _buildActivityItem(
                  'Novo responsável cadastrado',
                  '2 horas atrás',
                  Icons.person_add,
                  Colors.green,
                ),
                _buildActivityItem(
                  'Demanda de saúde atualizada',
                  '4 horas atrás',
                  Icons.health_and_safety,
                  Colors.blue,
                ),
                _buildActivityItem(
                  'Relatório gerado',
                  '1 dia atrás',
                  Icons.description,
                  Colors.orange,
                ),
                _buildActivityItem(
                  'Backup realizado',
                  '2 dias atrás',
                  Icons.backup,
                  Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) => Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'Novo Responsável',
        'icon': Icons.person_add,
        'color': Colors.blue,
        'route': '/responsaveis/novo',
      },
      {
        'title': 'Novo Membro',
        'icon': Icons.group_add,
        'color': Colors.green,
        'route': '/membros/novo',
      },
      {
        'title': 'Relatórios',
        'icon': Icons.analytics,
        'color': Colors.purple,
        'route': '/relatorios',
      },
      {
        'title': 'Configurações',
        'icon': Icons.settings,
        'color': Colors.grey,
        'route': '/configuracoes',
      },
    ];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações Rápidas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (Responsive.isDesktop(context))
              Row(
                children: actions
                    .map((action) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildActionButton(action),
                          ),
                        ))
                    .toList(),
              )
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.5,
                children: actions
                    .map(_buildActionButton)
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> action) => ElevatedButton.icon(
      onPressed: () {
        context.go(action['route']);
      },
      icon: Icon(
        action['icon'],
        color: action['color'],
        size: 20,
      ),
      label: Text(
        action['title'],
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: (action['color'] as Color).withValues(alpha: 0.1),
        foregroundColor: action['color'],
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
}