import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../constants/constants.dart';
import '../../providers/demanda_provider.dart';
import '../../utils/responsive.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/sidebar.dart';

class DemandasScreen extends StatefulWidget {
  const DemandasScreen({super.key});

  @override
  State<DemandasScreen> createState() => _DemandasScreenState();
}

class _DemandasScreenState extends State<DemandasScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _currentFilter = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Carregar dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final demandaProvider = Provider.of<DemandaProvider>(context, listen: false);
    // Assumindo que existem estes métodos no provider
    demandaProvider.loadDemandasSaude();
    demandaProvider.loadDemandasEducacao();
    demandaProvider.loadDemandasAmbiente();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentFilter = query;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentFilter = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usar o widget Responsive existente
    return Responsive.isMobile(context) 
        ? _buildMobileLayout() 
        : _buildDesktopLayout();
  }

  Widget _buildMobileLayout() => Scaffold(
      appBar: AppBar(
        title: const Text('Demandas'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildTabBar(),
            ],
          ),
        ),
      ),
      body: _buildTabBarView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/demandas/nova'),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );

  Widget _buildDesktopLayout() => Scaffold(
      body: Row(
        children: [
          // Usar o SideBar existente
          const SideBar(),
          Expanded(
            child: Column(
              children: [
                _buildDesktopHeader(),
                Expanded(child: _buildTabBarView()),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildDesktopHeader() => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.clipboardTextMultiple,
                size: 32,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(width: 16),
              Text(
                'Gerenciamento de Demandas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => context.go('/demandas/nova'),
                icon: const Icon(Icons.add),
                label: const Text('Nova Demanda'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildTabBar(),
        ],
      ),
    );

  Widget _buildSearchBar() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar demandas por nome, CPF ou descrição...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _currentFilter.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppConstants.primaryColor),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );

  Widget _buildTabBar() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppConstants.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade700,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(
            icon: Icon(Icons.local_hospital),
            text: 'Saúde',
          ),
          Tab(
            icon: Icon(Icons.school),
            text: 'Educação',
          ),
          Tab(
            icon: Icon(Icons.pets),
            text: 'Ambiente',
          ),
        ],
      ),
    );

  Widget _buildTabBarView() => TabBarView(
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
          return const Center(
            child: SpinKitFadingCircle(
              color: AppConstants.primaryColor,
              size: 50.0,
            ),
          );
        }

        // Assumindo que existe uma lista demandasSaude no provider
        final demandas = provider.demandasSaude ?? [];
        final filteredDemandas = _filterDemandas(demandas);
        
        // Calcular prioritários baseado nos dados
        final prioritarios = filteredDemandas.where(_isPrioritario
        ).toList();

        return Column(
          children: [
            if (prioritarios.isNotEmpty) ...[
              _buildPriorityAlert(prioritarios.length),
              const SizedBox(height: 16),
            ],
            _buildStatsCards([
              _StatsCardData(
                title: 'Total',
                value: filteredDemandas.length.toString(),
                icon: Icons.local_hospital,
                color: Colors.blue,
              ),
              _StatsCardData(
                title: 'Prioritários',
                value: prioritarios.length.toString(),
                icon: Icons.priority_high,
                color: Colors.red,
              ),
              _StatsCardData(
                title: 'Com CID',
                value: filteredDemandas.where((d) => _getCid(d)?.isNotEmpty == true).length.toString(),
                icon: Icons.medical_services,
                color: Colors.orange,
              ),
            ]),
            const SizedBox(height: 16),
            Expanded(
              child: filteredDemandas.isEmpty
                  ? _buildEmptyState('Nenhuma demanda de saúde encontrada')
                  : _buildDemandaList(filteredDemandas, _buildSaudeCard),
            ),
          ],
        );
      },
    );

  Widget _buildEducacaoTab() => Consumer<DemandaProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: SpinKitFadingCircle(
              color: AppConstants.primaryColor,
              size: 50.0,
            ),
          );
        }

        final demandas = provider.demandasEducacao ?? [];
        final filteredDemandas = _filterDemandas(demandas);

        return Column(
          children: [
            _buildStatsCards([
              _StatsCardData(
                title: 'Total',
                value: filteredDemandas.length.toString(),
                icon: Icons.school,
                color: Colors.green,
              ),
              _StatsCardData(
                title: 'Manhã',
                value: filteredDemandas.where((d) => _getTurno(d) == 'M').length.toString(),
                icon: Icons.wb_sunny,
                color: Colors.amber,
              ),
              _StatsCardData(
                title: 'Tarde',
                value: filteredDemandas.where((d) => _getTurno(d) == 'T').length.toString(),
                icon: Icons.wb_twilight,
                color: Colors.deepOrange,
              ),
            ]),
            const SizedBox(height: 16),
            Expanded(
              child: filteredDemandas.isEmpty
                  ? _buildEmptyState('Nenhuma demanda de educação encontrada')
                  : _buildDemandaList(filteredDemandas, _buildEducacaoCard),
            ),
          ],
        );
      },
    );

  Widget _buildAmbienteTab() => Consumer<DemandaProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: SpinKitFadingCircle(
              color: AppConstants.primaryColor,
              size: 50.0,
            ),
          );
        }

        final demandas = provider.demandasAmbiente ?? [];
        final filteredDemandas = _filterDemandas(demandas);

        return Column(
          children: [
            _buildStatsCards([
              _StatsCardData(
                title: 'Total',
                value: filteredDemandas.length.toString(),
                icon: Icons.pets,
                color: Colors.teal,
              ),
              _StatsCardData(
                title: 'Cães',
                value: filteredDemandas.where((d) => _getEspecie(d)?.toLowerCase().contains('cão') == true).length.toString(),
                icon: MdiIcons.dog,
                color: Colors.brown,
              ),
              _StatsCardData(
                title: 'Gatos',
                value: filteredDemandas.where((d) => _getEspecie(d)?.toLowerCase().contains('gato') == true).length.toString(),
                icon: MdiIcons.cat,
                color: Colors.purple,
              ),
            ]),
            const SizedBox(height: 16),
            Expanded(
              child: filteredDemandas.isEmpty
                  ? _buildEmptyState('Nenhuma demanda de ambiente encontrada')
                  : _buildDemandaList(filteredDemandas, _buildAmbienteCard),
            ),
          ],
        );
      },
    );

  Widget _buildPriorityAlert(int count) => Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.priority_high, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grupos Prioritários',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                Text(
                  '$count pessoas em grupos prioritários precisam de atenção especial',
                  style: TextStyle(color: Colors.red.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildStatsCards(List<_StatsCardData> stats) => Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: stats.map((stat) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: DashboardCard(
              title: stat.title,
              value: stat.value,
              icon: stat.icon,
              color: stat.color,
              isCompact: true, subtitle: '',
            ),
          ),
        )).toList(),
      ),
    );

  Widget _buildDemandaList<T>(List<T> demandas, Widget Function(T) cardBuilder) => ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: demandas.length,
      itemBuilder: (context, index) => cardBuilder(demandas[index]),
    );

  Widget _buildSaudeCard(dynamic demanda) {
    final isPrioritario = _isPrioritario(demanda);
    final cpf = _getCpf(demanda);
    final cid = _getCid(demanda);
    final genero = _getGenero(demanda);
    final localRef = _getLocalRef(demanda);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPrioritario
              ? Colors.red.shade100
              : Colors.blue.shade100,
          child: Icon(
            Icons.local_hospital,
            color: isPrioritario
                ? Colors.red.shade700
                : Colors.blue.shade700,
          ),
        ),
        title: Text(
          'CPF: $cpf',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cid?.isNotEmpty == true)
              Text('CID: $cid'),
            if (genero?.isNotEmpty == true)
              Text('Gênero: $genero'),
            if (localRef?.isNotEmpty == true)
              Text('Local Ref.: $localRef'),
          ],
        ),
        trailing: isPrioritario
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Prioritário',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () => _showDemandaDetails(demanda),
      ),
    );
  }

  Widget _buildEducacaoCard(dynamic demanda) {
    final nome = _getNome(demanda);
    final cpf = _getCpf(demanda);
    final turno = _getTurno(demanda);
    final demandaTexto = _getDemandaTexto(demanda);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.school, color: Colors.green.shade700),
        ),
        title: Text(
          nome ?? 'Nome não informado',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CPF: $cpf'),
            if (turno?.isNotEmpty == true)
              Text('Turno: ${_getTurnoText(turno)}'),
            if (demandaTexto?.isNotEmpty == true)
              Text('Demanda: $demandaTexto'),
          ],
        ),
        trailing: turno?.isNotEmpty == true
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTurnoColor(turno).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTurnoText(turno),
                  style: TextStyle(
                    color: _getTurnoColor(turno),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () => _showDemandaDetails(demanda),
      ),
    );
  }

  Widget _buildAmbienteCard(dynamic demanda) {
    final cpf = _getCpf(demanda);
    final especie = _getEspecie(demanda);
    final quantidade = _getQuantidade(demanda);
    final porte = _getPorte(demanda);
    final vacinado = _getVacinado(demanda);
    final castrado = _getCastrado(demanda);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: Icon(Icons.pets, color: Colors.teal.shade700),
        ),
        title: Text(
          'CPF: $cpf',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (especie?.isNotEmpty == true)
              Text('Espécie: $especie'),
            if (quantidade != null)
              Text('Quantidade: $quantidade'),
            if (porte?.isNotEmpty == true)
              Text('Porte: $porte'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (vacinado == 'S')
              Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.vaccines,
                  size: 16,
                  color: Colors.green.shade700,
                ),
              ),
            if (castrado == 'S')
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.health_and_safety,
                  size: 16,
                  color: Colors.blue.shade700,
                ),
              ),
          ],
        ),
        onTap: () => _showDemandaDetails(demanda),
      ),
    );
  }

  Widget _buildEmptyState(String message) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadInitialData,
            icon: const Icon(Icons.refresh),
            label: const Text('Recarregar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

  List<T> _filterDemandas<T>(List<T> demandas) {
    if (_currentFilter.isEmpty) return demandas;
    
    return demandas.where((demanda) {
      final searchLower = _currentFilter.toLowerCase();
      
      // Busca genérica usando toString
      final demandaString = demanda.toString().toLowerCase();
      if (demandaString.contains(searchLower)) {
        return true;
      }
      
      // Busca específica por campos comuns
      try {
        final cpf = _getCpf(demanda);
        final nome = _getNome(demanda);
        final demandaTexto = _getDemandaTexto(demanda);
        final especie = _getEspecie(demanda);
        final cid = _getCid(demanda);
        
        return (cpf?.contains(_currentFilter) == true) ||
               (nome?.toLowerCase().contains(searchLower) == true) ||
               (demandaTexto?.toLowerCase().contains(searchLower) == true) ||
               (especie?.toLowerCase().contains(searchLower) == true) ||
               (cid?.toLowerCase().contains(searchLower) == true);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Métodos auxiliares para extrair dados dos objetos de forma segura
  String? _getCpf(dynamic obj) {
    try {
      return obj?.cpf?.toString();
    } catch (e) {
      return null;
    }
  }

  String? _getNome(dynamic obj) {
    try {
      return obj?.nome?.toString();
    } catch (e) {
      return null;
    }
  }

  String? _getCid(dynamic obj) {
    try {
      return obj?.saudeCid?.toString();
    } catch (e) {
      return null;
    }
  }

  String? _getGenero(dynamic obj) {
    try {
      return obj?.genero?.toString();
    } catch (e) {
      return null;
    }
  }

  String? _getLocalRef(dynamic obj) {
    try {
      return obj?.localRef?.toString();
    } catch (e) {
      return null;
    }
  }

  String? _getTurno(dynamic obj) {
    try {
      return obj?.turno?.toString();
    } catch (e) {
      return null;
    }
  }

  String? _getDemandaTexto(dynamic obj) {
    try {
      return obj?.demanda?.toString();
    } catch (e) {
      return null;
    }
  }

  String? _getEspecie(dynamic obj) {
    try {
      return obj?.especie?.toString();
    } catch (e) {
      return null;
    }
  }

  int? _getQuantidade(dynamic obj) {
    try {
      return obj?.quantidade;
    } catch (e) {
      return null;
    }
  }

  String? _getPorte(dynamic obj) {
    try {
      return obj?.porte?.toString();
    } catch (e) {
      return null;
    }
  }

  String? _getVacinado(dynamic obj) {
    try {
      return obj?.vacinado?.toString();
    } catch (e) {
      return null;
    }
  }

  String? _getCastrado(dynamic obj) {
    try {
      return obj?.castrado?.toString();
    } catch (e) {
      return null;
    }
  }

  bool _isPrioritario(dynamic obj) {
    try {
      return obj?.gestPuerNutriz == 'S' || 
             obj?.mobReduzida == 'S' || 
             obj?.pcdOuMental == 'S';
    } catch (e) {
      return false;
    }
  }

  String _getTurnoText(String? turno) {
    switch (turno) {
      case 'M':
        return 'Manhã';
      case 'T':
        return 'Tarde';
      case 'N':
        return 'Noite';
      default:
        return turno ?? '';
    }
  }

  Color _getTurnoColor(String? turno) {
    switch (turno) {
      case 'M':
        return Colors.amber;
      case 'T':
        return Colors.deepOrange;
      case 'N':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  void _showDemandaDetails(dynamic demanda) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes da Demanda'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('CPF', _getCpf(demanda)),
              if (_getNome(demanda) != null)
                _buildDetailRow('Nome', _getNome(demanda)),
              if (_getGenero(demanda) != null)
                _buildDetailRow('Gênero', _getGenero(demanda)),
              if (_getCid(demanda) != null)
                _buildDetailRow('CID', _getCid(demanda)),
              if (_getEspecie(demanda) != null)
                _buildDetailRow('Espécie', _getEspecie(demanda)),
              if (_getQuantidade(demanda) != null)
                _buildDetailRow('Quantidade', _getQuantidade(demanda).toString()),
              // Adicione mais campos conforme necessário
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implementar edição
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _StatsCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatsCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}