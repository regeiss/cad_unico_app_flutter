import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/demanda_ambiente.model.dart';
import '../../models/demanda_educacao_model.dart';
import '../../models/demanda_saude_model.dart';
import '../../providers/demanda_provider.dart';
import '../../utils/responsive.dart';
import '../../widgets/dashboard_card.dart';

class DemandasScreen extends StatefulWidget {
  const DemandasScreen({super.key});

  @override
  State<DemandasScreen> createState() => _DemandasScreenState();
}

class _DemandasScreenState extends State<DemandasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Carregar dados ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DemandaProvider>().loadAllDemandas();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DemandaProvider>(
        builder: (context, demandaProvider, child) {
          return RefreshIndicator(
            onRefresh: () => demandaProvider.loadAllDemandas(),
            child: Column(
              children: [
                // Header com estatísticas
                _buildHeader(demandaProvider),
                
                // Barra de pesquisa
                _buildSearchBar(),
                
                // Tabs
                _buildTabBar(),
                
                // Conteúdo das tabs
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(demandaProvider),
                      _buildSaudeTab(demandaProvider),
                      _buildEducacaoTab(demandaProvider),
                      _buildAmbienteTab(demandaProvider),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(DemandaProvider provider) => Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Demandas',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Cards de estatísticas
          if (Responsive.isDesktop)
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: 'Total Saúde',
                    value: provider.totalDemandasSaude.toString(),
                    icon: Icons.health_and_safety,
                    color: Colors.red,
                    //isCompact: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardCard(
                    title: 'Total Educação',
                    value: provider.totalDemandasEducacao.toString(),
                    icon: Icons.school,
                    color: Colors.blue,
                    //isCompact: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardCard(
                    title: 'Total Ambiente',
                    value: provider.totalDemandasAmbiente.toString(),
                    icon: Icons.pets,
                    color: Colors.green,
                    //isCompact: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardCard(
                    title: 'Grupos Prioritários',
                    value: provider.totalGruposPrioritarios.toString(),
                    icon: Icons.priority_high,
                    color: Colors.orange,
                    //isCompact: true,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: 'Saúde',
                        value: provider.totalDemandasSaude.toString(),
                        icon: Icons.health_and_safety,
                        color: Colors.red,
                        //isCompact: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DashboardCard(
                        title: 'Educação',
                        value: provider.totalDemandasEducacao.toString(),
                        icon: Icons.school,
                        color: Colors.blue,
                        //isCompact: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: 'Ambiente',
                        value: provider.totalDemandasAmbiente.toString(),
                        icon: Icons.pets,
                        color: Colors.green,
                        //isCompact: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DashboardCard(
                        title: 'Prioritários',
                        value: provider.totalGruposPrioritarios.toString(),
                        icon: Icons.priority_high,
                        color: Colors.orange,
                        // isCompact: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Pesquisar por CPF, nome ou código...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).primaryColor,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(text: 'Visão Geral'),
          Tab(text: 'Saúde'),
          Tab(text: 'Educação'),
          Tab(text: 'Ambiente'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(DemandaProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grupos Prioritários',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          if (provider.gruposPrioritarios.isEmpty)
            const Center(
              child: Text('Nenhum grupo prioritário encontrado'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.gruposPrioritarios.length,
              itemBuilder: (context, index) {
                final demanda = provider.gruposPrioritarios[index];
                return _buildSaudeCard(demanda);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSaudeTab(DemandaProvider provider) {
    if (provider.isLoadingSaude) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredDemandas = provider.filterDemandasSaude(search: _searchQuery);

    return Column(
      children: [
        // Filtros
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por Gênero',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Todos')),
                    DropdownMenuItem(value: 'M', child: Text('Masculino')),
                    DropdownMenuItem(value: 'F', child: Text('Feminino')),
                  ],
                  onChanged: (value) {
                    // Implementar filtro
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Lista
        Expanded(
          child: filteredDemandas.isEmpty
              ? const Center(child: Text('Nenhuma demanda de saúde encontrada'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredDemandas.length,
                  itemBuilder: (context, index) {
                    final demanda = filteredDemandas[index];
                    return _buildSaudeCard(demanda);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEducacaoTab(DemandaProvider provider) {
    if (provider.isLoadingEducacao) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredDemandas = provider.filterDemandasEducacao(search: _searchQuery);

    return Column(
      children: [
        // Filtros
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por Turno',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Todos')),
                    DropdownMenuItem(value: 'matutino', child: Text('Matutino')),
                    DropdownMenuItem(value: 'vespertino', child: Text('Vespertino')),
                    DropdownMenuItem(value: 'noturno', child: Text('Noturno')),
                  ],
                  onChanged: (value) {
                    // Implementar filtro
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Lista
        Expanded(
          child: filteredDemandas.isEmpty
              ? const Center(child: Text('Nenhuma demanda de educação encontrada'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredDemandas.length,
                  itemBuilder: (context, index) {
                    final demanda = filteredDemandas[index];
                    return _buildEducacaoCard(demanda);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAmbienteTab(DemandaProvider provider) {
    if (provider.isLoadingAmbiente) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredDemandas = provider.filterDemandasAmbiente(search: _searchQuery);

    return Column(
      children: [
        // Filtros
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por Espécie',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Todas')),
                    DropdownMenuItem(value: 'cao', child: Text('Cão')),
                    DropdownMenuItem(value: 'gato', child: Text('Gato')),
                    DropdownMenuItem(value: 'ave', child: Text('Ave')),
                    DropdownMenuItem(value: 'outro', child: Text('Outro')),
                  ],
                  onChanged: (value) {
                    // Implementar filtro
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Lista
        Expanded(
          child: filteredDemandas.isEmpty
              ? const Center(child: Text('Nenhuma demanda de ambiente encontrada'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredDemandas.length,
                  itemBuilder: (context, index) {
                    final demanda = filteredDemandas[index];
                    return _buildAmbienteCard(demanda);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSaudeCard(DemandaSaude demanda) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: demanda.isPrioritario ? Colors.orange : Colors.red,
          child: Icon(
            demanda.isPrioritario ? Icons.priority_high : Icons.health_and_safety,
            color: Colors.white,
          ),
        ),
        title: Text('CPF: ${demanda.cpf}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (demanda.saudeCid != null)
              Text('CID: ${demanda.saudeCid}'),
            Text('Gênero: ${demanda.genero ?? "Não informado"}'),
            if (demanda.isPrioritario)
              Text(
                'Prioritário: ${demanda.statusPrioridade}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: demanda.isPrioritario
            ? const Icon(Icons.star, color: Colors.orange)
            : null,
        onTap: () {
          // Navegar para detalhes
        },
      ),
    );
  }

  Widget _buildEducacaoCard(DemandaEducacao demanda) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.school, color: Colors.white),
        ),
        title: Text(demanda.nome),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CPF: ${demanda.cpf}'),
            Text('Idade: ${demanda.idade} anos'),
            Text('Turno: ${demanda.turnoFormatado}'),
            if (demanda.demanda != null)
              Text('Demanda: ${demanda.demanda}'),
          ],
        ),
        onTap: () {
          // Navegar para detalhes
        },
      ),
    );
  }

  Widget _buildAmbienteCard(DemandaAmbiente demanda) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.pets, color: Colors.white),
        ),
        title: Text('CPF: ${demanda.cpf}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Espécie: ${demanda.especieFormatada}'),
            if (demanda.quantidade != null)
              Text('Quantidade: ${demanda.quantidade}'),
            Text('Porte: ${demanda.porteFormatado}'),
            Text('Status: ${demanda.statusSaude}'),
            if (demanda.necessidades != 'Nenhuma')
              Text(
                'Necessidades: ${demanda.necessidades}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: demanda.necessidades != 'Nenhuma'
            ? const Icon(Icons.warning, color: Colors.red)
            : const Icon(Icons.check, color: Colors.green),
        onTap: () {
          // Navegar para detalhes
        },
      ),
    );
  }
}