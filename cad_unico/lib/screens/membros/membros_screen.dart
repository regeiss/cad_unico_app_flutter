import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_utils.dart';
// import '../../models/user_model.dart';
import '../../utils/responsive.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/search_bar_widget.dart';

class MembrosScreen extends StatefulWidget {
  const MembrosScreen({super.key});

  @override
  State<MembrosScreen> createState() => _MembrosScreenState();
}

class _MembrosScreenState extends State<MembrosScreen> {
  final ScrollController _scrollController = ScrollController();
  // ignore: unused_field
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMembros();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMembros() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MembroProvider>(context, listen: false)
          .loadMembros(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<MembroProvider>(context, listen: false).loadMembros();
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        // Usando sua classe Responsive
        if (Responsive.isDesktop(context)) {
          return _buildDesktopLayout();
        } else if (Responsive.isTablet(context)) {
          return _buildTabletLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );

  Widget _buildMobileLayout() => Scaffold(
      appBar: AppBar(
        title: const Text('Membros'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemberDialog,
        child: const Icon(Icons.add),
      ),
    );

  Widget _buildTabletLayout() => Scaffold(
      appBar: AppBar(
        title: const Text('Membros'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMemberDialog,
        icon: const Icon(Icons.add),
        label: const Text('Novo Membro'),
      ),
    );

  Widget _buildDesktopLayout() => Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );

  Widget _buildHeader() => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: (0.1)),
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
                  'Membros',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gerencie os membros familiares cadastrados',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showAddMemberDialog,
            icon: const Icon(Icons.add),
            label: const Text('Novo Membro'),
          ),
        ],
      ),
    );

  Widget _buildBody() => Column(
      children: [
        // Barra de busca
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchBarWidget(
            hintText: 'Buscar por nome, CPF...',
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              // TODO: Implementar busca
            },
          ),
        ),
        
        // Lista de membros
        Expanded(
          child: Consumer<MembroProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.membros.isEmpty) {
                return const LoadingWidget(message: 'Carregando membros...');
              }
              
              if (provider.error != null && provider.membros.isEmpty) {
                return CustomErrorWidget(
                  message: provider.error!,
                  onRetry: _loadMembros,
                );
              }
              
              if (provider.membros.isEmpty) {
                return EmptyStateWidget(
                  title: 'Nenhum membro encontrado',
                  subtitle: 'Comece adicionando membros familiares',
                  icon: Icons.family_restroom,
                  actionText: 'Novo Membro',
                  onAction: _showAddMemberDialog,
                );
              }
              
              return _buildList(provider);
            },
          ),
        ),
      ],
    );

  Widget _buildList(MembroProvider provider) => RefreshIndicator(
      onRefresh: () => provider.loadMembros(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.membros.length,
        itemBuilder: (context, index) {
          final membro = provider.membros[index];
          return _buildMembroCard(membro);
        },
      ),
    );

  Widget _buildMembroCard(MembroModel membro) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            membro.nome.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          membro.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CPF: ${AppUtils.formatCpf(membro.cpf)}'),
            Text('Responsável: ${membro.cpfResponsavel}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: membro.isAtivo ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            membro.isAtivo ? 'Ativo' : 'Inativo',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () => _showMemberDetails(membro),
      ),
    );

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Membro'),
        content: const Text('Funcionalidade de adicionar membro em desenvolvimento.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showMemberDetails(MembroModel membro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(membro.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CPF: ${AppUtils.formatCpf(membro.cpf)}'),
            Text('Responsável: ${membro.cpfResponsavel}'),
            Text('Status: ${membro.isAtivo ? 'Ativo' : 'Inativo'}'),
            if (membro.timestamp != null)
              Text('Cadastrado em: ${membro.timestamp!.day}/${membro.timestamp!.month}/${membro.timestamp!.year}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
