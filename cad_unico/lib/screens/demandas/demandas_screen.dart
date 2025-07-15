import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/demanda_educacao_model.dart';
import '../../models/demanda_saude_model.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../providers/demanda_provider.dart';
import '../../utils/app_utils.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/filter_chip_widget.dart';
import '../../widgets/loading_widget.dart';

class DemandasScreen extends StatefulWidget {
  const DemandasScreen({super.key});

  @override
  State<DemandasScreen> createState() => _DemandasScreenState();
}

class _DemandasScreenState extends State<DemandasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDemandas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDemandas() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DemandaProvider>(context, listen: false).loadAllDemandas();
    });
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        // Usando sua classe Responsive
        if (Responsive.isDesktop(width)) {
          return _buildDesktopLayout();
        } else if (Responsive.isTablet(width)) {
          return _buildTabletLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );

  Widget _buildMobileLayout() => Scaffold(
      appBar: AppBar(
        title: const Text('Demandas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Saúde', icon: Icon(Icons.favorite)),
            Tab(text: 'Educação', icon: Icon(Icons.school)),
            Tab(text: 'Ambiente', icon: Icon(Icons.pets)),
          ],
        ),
      ),
      body: _buildTabView(),
    );

  Widget _buildTabletLayout() => Scaffold(
      appBar: AppBar(
        title: const Text('Demandas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Saúde', icon: Icon(Icons.favorite)),
            Tab(text: 'Educação', icon: Icon(Icons.school)),
            Tab(text: 'Ambiente', icon: Icon(Icons.pets)),
          ],
        ),
      ),
      body: _buildTabView(),
    );

  Widget _buildDesktopLayout() => Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          Expanded(child: _buildTabView()),
        ],
      ),
    );

  Widget _buildHeader() => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demandas',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Visualize e gerencie as demandas cadastradas',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Saúde', icon: Icon(Icons.favorite)),
              Tab(text: 'Educação', icon: Icon(Icons.school)),
              Tab(text: 'Ambiente', icon: Icon(Icons.pets)),
            ],
          ),
        ],
      ),
    );

  Widget _buildFilters() => Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Filtros:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                FilterChipWidget(
                  label: 'Todos',
                  isSelected: _selectedFilter == 'all',
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'all';
                    });
                  },
                ),
                FilterChipWidget(
                  label: 'Prioritários',
                  isSelected: _selectedFilter == 'priority',
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'priority';
                    });
                  },
                ),
                FilterChipWidget(
                  label: 'Recentes',
                  isSelected: _selectedFilter == 'recent',
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'recent';
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildTabView() => TabBarView(
      controller: _tabController,
      children: [
        _buildSaudeTab(),
        _buildEducacaoTab(),
        _buildAmbienteTab(),
      ],
    );

  Widget _buildSaudeTab() => Consumer<DemandaProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingWidget(message: 'Carregando demandas de saúde...');
        }
        
        if (provider.error != null) {
          return ErrorDisplayWidget(
            message: provider.error!,
            onRetry: _loadDemandas,
          );
        }
        
        if (provider.demandasSaude.isEmpty) {
          return const EmptyStateWidget(
            title: 'Nenhuma demanda de saúde',
            subtitle: 'Não há demandas de saúde cadastradas',
            icon: Icons.favorite_border,
          );
        }
        
        return _buildSaudeList(provider.demandasSaude);
      },
    );

  Widget _buildEducacaoTab() => Consumer<DemandaProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingWidget(message: 'Carregando demandas de educação...');
        }
        
        if (provider.error != null) {
          return ErrorDisplayWidget(
            message: provider.error!,
            onRetry: _loadDemandas,
          );
        }
        
        if (provider.demandasEducacao.isEmpty) {
          return const EmptyStateWidget(
            title: 'Nenhuma demanda de educação',
            subtitle: 'Não há demandas de educação cadastradas',
            icon: Icons.school_outlined,
          );
        }
        
        return _buildEducacaoList(provider.demandasEducacao);
      },
    );

  Widget _buildAmbienteTab() => const EmptyStateWidget(
      title: 'Demandas de Ambiente',
      subtitle: 'Funcionalidade em desenvolvimento',
      icon: Icons.pets_outlined,
    );

  Widget _buildSaudeList(List<DemandaSaudeModel> demandas) => RefreshIndicator(
      onRefresh: () => Provider.of<DemandaProvider>(context, listen: false)
          .loadDemandasSaude(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: demandas.length,
        itemBuilder: (context, index) {
          final demanda = demandas[index];
          return _buildDemandaSaudeCard(demanda);
        },
      ),
    );

  Widget _buildEducacaoList(List<DemandaEducacaoModel> demandas) => RefreshIndicator(
      onRefresh: () => Provider.of<DemandaProvider>(context, listen: false)
          .loadDemandasEducacao(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: demandas.length,
        itemBuilder: (context, index) {
          final demanda = demandas[index];
          return _buildDemandaEducacaoCard(demanda);
        },
      ),
    );

  Widget _buildDemandaSaudeCard(DemandaSaudeModel demanda) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: demanda.isGrupoPrioritario ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'CPF: ${AppUtils.formatCpf(demanda.cpf)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (demanda.isGrupoPrioritario)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Prioritário',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            if (demanda.saudeCid != null)
              Text('CID: ${demanda.saudeCid}'),
            
            if (demanda.genero != null)
              Text('Gênero: ${AppConstants.generoOptions[demanda.genero] ?? demanda.genero}'),
            
            if (demanda.idade != null)
              Text('Idade: ${demanda.idade} anos'),
            
            if (demanda.alergiaIntol != null && demanda.alergiaIntol!.isNotEmpty)
              Text('Alergias: ${demanda.alergiaIntol}'),
          ],
        ),
      ),
    );

  Widget _buildDemandaEducacaoCard(DemandaEducacaoModel demanda) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    demanda.nome,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text('CPF: ${AppUtils.formatCpf(demanda.cpf)}'),
            
            if (demanda.genero != null)
              Text('Gênero: ${AppConstants.generoOptions[demanda.genero] ?? demanda.genero}'),
            
            if (demanda.idade != null)
              Text('Idade: ${demanda.idade} anos'),
            
            if (demanda.turno != null)
              Text('Turno: ${AppConstants.turnoOptions[demanda.turno] ?? demanda.turno}'),
            
            if (demanda.demanda != null && demanda.demanda!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Demanda: ${demanda.demanda}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
}