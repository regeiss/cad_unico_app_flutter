import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../contants/constants.dart';
import '../../models/responsavel_model.dart';
import '../../providers/responsavel_provider.dart';

import '../../utils/app_utils.dart';
import '../../utils/responsive.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/filter_chip_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/search_bar_widget.dart';

class ResponsaveisScreen extends StatefulWidget {
  const ResponsaveisScreen({super.key});

  @override
  State<ResponsaveisScreen> createState() => _ResponsaveisScreenState();
}

class _ResponsaveisScreenState extends State<ResponsaveisScreen> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String? _statusFilter;
  String? _bairroFilter;
  String? selectedStatus = 'A';
  List<String> filterStatuses = ['A']; // Filtros ativos por padrão


  @override
  void initState() {
    super.initState();
    _loadResponsaveis();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadResponsaveis() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ResponsavelProvider>(context, listen: false)
          .loadResponsaveis(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<ResponsavelProvider>(context, listen: false)
          .loadResponsaveis();
    }
  }

  void _applyFilters() {
    final provider = Provider.of<ResponsavelProvider>(context, listen: false);
    final filters = <String, dynamic>{};
    
    if (_searchQuery.isNotEmpty) {
      filters['search'] = _searchQuery;
    }
    if (_statusFilter != null) {
      filters['status'] = _statusFilter;
    }
    if (_bairroFilter != null) {
      filters['bairro'] = _bairroFilter;
    }
    
    provider.setFilters(filters);
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _statusFilter = null;
      _bairroFilter = null;
    });
    Provider.of<ResponsavelProvider>(context, listen: false).clearFilters();
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
        title: const Text('Responsáveis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/responsaveis/novo'),
        child: const Icon(Icons.add),
      ),
    );

  Widget _buildTabletLayout() => Scaffold(
      appBar: AppBar(
        title: const Text('Responsáveis'),
      ),
      body: Row(
        children: [
          SizedBox(
            width: 300,
            child: _buildFilterSidebar(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/responsaveis/novo'),
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );

  Widget _buildDesktopLayout() => Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 320,
                  child: _buildFilterSidebar(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
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
                  'Responsáveis',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gerencie as pessoas responsáveis do sistema',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => context.go('/responsaveis/novo'),
            icon: const Icon(Icons.add),
            label: const Text('Novo Responsável'),
          ),
        ],
      ),
    );

  Widget _buildFilterSidebar() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Busca
          SearchBarWidget(
            hintText: 'Buscar por nome, CPF...',
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _applyFilters();
            },
            onClear: () {
              setState(() {
                _searchQuery = '';
              });
              _applyFilters();
            },
          ),
          
          const SizedBox(height: 16),
          
          // Filtro por Status
          Text(
            'Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChipWidget(
                label: 'Todos',
                isSelected: _statusFilter == null,
                onPressed: () {
                  setState(() {
                    _statusFilter = null;
                  });
                  _applyFilters();
                },
              ),
              ...AppConstants.statusOptions['general']!.entries.map(
                  (entry) => FilterChip(
                    selected: filterStatuses.contains(entry.key),
                    label: Text(entry.value['label'] as String),
                    avatar: Icon(
                      entry.value['icon'] as IconData,
                      size: 16,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          filterStatuses.add(entry.key);
                        } else {
                          filterStatuses.remove(entry.key);
                        }
                      });
                    },
                  ),
                ), // <
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Ações
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Limpar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Estatísticas
          Consumer<ResponsavelProvider>(
            builder: (context, provider, child) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estatísticas',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Total: ${provider.responsaveis.length}'),
                      Text(
                        'Ativos: ${provider.responsaveis.where((r) => r.isAtivo).length}',
                      ),
                    ],
                  ),
                ),
              ),
          ),
        ],
      ),
    );

  Widget _buildBody() => Consumer<ResponsavelProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.responsaveis.isEmpty) {
          return const LoadingWidget(message: 'Carregando responsáveis...');
        }
        
        if (provider.error != null && provider.responsaveis.isEmpty) {
          return CustomErrorWidget(
            message: provider.error!,
            onRetry: _loadResponsaveis,
          );
        }
        
        if (provider.responsaveis.isEmpty) {
          return EmptyStateWidget(
            title: 'Nenhum responsável encontrado',
            subtitle: 'Comece cadastrando um novo responsável no sistema',
            icon: Icons.people_outline,
            actionText: 'Novo Responsável',
            onAction: () => context.go('/responsaveis/novo'),
          );
        }
        
        return _buildList(provider);
      },
    );

  Widget _buildList(ResponsavelProvider provider) => RefreshIndicator(
      onRefresh: () => provider.loadResponsaveis(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.responsaveis.length + (provider.hasNextPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= provider.responsaveis.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SpinKitThreeBounce(
                  color: Colors.blue,
                  size: 20,
                ),
              ),
            );
          }
          
          final responsavel = provider.responsaveis[index];
          return _buildResponsavelCard(responsavel);
        },
      ),
    );

  Widget _buildResponsavelCard(ResponsavelModel responsavel) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.go('/responsaveis/${responsavel.cpf}'),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          responsavel.nome,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'CPF: ${AppUtils.formatCpf(responsavel.cpf)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: responsavel.isAtivo ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      responsavel.isAtivo ? 'Ativo' : 'Inativo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (responsavel.telefone != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      AppUtils.formatTelefone(responsavel.telefone.toString()),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      responsavel.enderecoCompleto,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (responsavel.timestamp != null)
                    Text(
                      'Cadastrado em ${responsavel.timestamp!.day}/${responsavel.timestamp!.month}/${responsavel.timestamp!.year}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => context.go('/responsaveis/${responsavel.cpf}/editar'),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 20),
                        onPressed: () => context.go('/responsaveis/${responsavel.cpf}'),
                        tooltip: 'Visualizar',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtros',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Status Filter
              Text('Status:', style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children: [
                  FilterChipWidget(
                    label: 'Todos',
                    isSelected: _statusFilter == null,
                    onPressed: () {
                      setState(() {
                        _statusFilter = null;
                      });
                    },
                  ),
                  ...AppConstants.statusOptions['general']!.entries.map(
                  (entry) => FilterChip(
                    selected: filterStatuses.contains(entry.key),
                    label: Text(entry.value['label'] as String),
                    avatar: Icon(
                      entry.value['icon'] as IconData,
                      size: 16,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          filterStatuses.add(entry.key);
                        } else {
                          filterStatuses.remove(entry.key);
                        }
                      });
                    },
                  ),
                ), // <- .toList() é OBRIGATÓRIO
                ],
              ),
              
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Limpar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}