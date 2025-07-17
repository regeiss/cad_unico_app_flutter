// lib/screens/demandas_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/demanda_provider.dart';
import '../../widgets/dashboard_card.dart';

class DemandasScreen extends StatefulWidget {
  const DemandasScreen({super.key});

  @override
  State<DemandasScreen> createState() => _DemandasScreenState();
}

class _DemandasScreenState extends State<DemandasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DemandaProvider>().loadAllDemandas();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Demandas'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DemandaProvider>().loadAllDemandas();
            },
          ),
        ],
      ),
      body: Consumer<DemandaProvider>(
        builder: (context, demandaProvider, child) {
          if (demandaProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (demandaProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar demandas',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    demandaProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      demandaProvider.loadAllDemandas();
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cards de estatísticas
                Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: 'Demandas de Saúde',
                        value: demandaProvider.totalDemandasSaude.toString(),
                        icon: Icons.local_hospital,
                        color: Colors.red,
                        onTap: () => _showDemandasSaude(context, demandaProvider),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DashboardCard(
                        title: 'Demandas de Educação',
                        value: demandaProvider.totalDemandasEducacao.toString(),
                        icon: Icons.school,
                        color: Colors.blue,
                        onTap: () => _showDemandasEducacao(context, demandaProvider),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: 'Demandas de Ambiente',
                        value: demandaProvider.totalDemandasAmbiente.toString(),
                        icon: Icons.pets,
                        color: Colors.green,
                        onTap: () => _showDemandasAmbiente(context, demandaProvider),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DashboardCard(
                        title: 'Grupos Prioritários',
                        value: demandaProvider.totalGruposPrioritarios.toString(),
                        icon: Icons.priority_high,
                        color: Colors.orange,
                        onTap: () => _showGruposPrioritarios(context, demandaProvider),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Lista de demandas prioritárias
                if (demandaProvider.gruposPrioritarios.isNotEmpty) ...[
                  Text(
                    'Grupos Prioritários',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ...demandaProvider.gruposPrioritarios.take(5).map(
                    (demanda) => Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.priority_high,
                          color: Colors.orange,
                        ),
                        title: Text('CPF: ${demanda.cpf}'),
                        subtitle: Text(demanda.statusSaude),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navegar para detalhes da demanda
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );

  void _showDemandasSaude(BuildContext context, DemandaProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Demandas de Saúde',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: provider.demandasSaude.length,
                  itemBuilder: (context, index) {
                    final demanda = provider.demandasSaude[index];
                    return ListTile(
                      leading: Icon(
                        demanda.isGrupoPrioritario 
                            ? Icons.priority_high 
                            : Icons.person,
                        color: demanda.isGrupoPrioritario 
                            ? Colors.orange 
                            : Colors.blue,
                      ),
                      title: Text('CPF: ${demanda.cpf}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (demanda.saudeCid != null)
                            Text('CID: ${demanda.saudeCid}'),
                          Text('Status: ${demanda.statusSaude}'),
                        ],
                      ),
                      isThreeLine: demanda.saudeCid != null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDemandasEducacao(BuildContext context, DemandaProvider provider) {
    // Similar ao _showDemandasSaude, mas para educação
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Demandas de Educação',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: provider.demandasEducacao.length,
                  itemBuilder: (context, index) {
                    final demanda = provider.demandasEducacao[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.school,
                        color: Colors.blue,
                      ),
                      title: Text(demanda.nome),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CPF: ${demanda.cpf}'),
                          Text('Faixa Etária: ${demanda.faixaEtaria}'),
                          if (demanda.turno != null)
                            Text('Turno: ${demanda.turno}'),
                        ],
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDemandasAmbiente(BuildContext context, DemandaProvider provider) {
    // Similar para ambiente
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Demandas de Ambiente',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: provider.demandasAmbiente.length,
                  itemBuilder: (context, index) {
                    final demanda = provider.demandasAmbiente[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.pets,
                        color: Colors.green,
                      ),
                      title: Text('CPF: ${demanda.cpf}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (demanda.especie != null)
                            Text('Espécie: ${demanda.especie}'),
                          if (demanda.quantidade != null)
                            Text('Quantidade: ${demanda.quantidade}'),
                          Text('Situação: ${demanda.situacaoAnimal}'),
                        ],
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGruposPrioritarios(BuildContext context, DemandaProvider provider) {
    // Mostrar apenas grupos prioritários
    _showDemandasSaude(context, provider);
  }
}