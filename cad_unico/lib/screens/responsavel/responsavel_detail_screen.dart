import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/responsavel_model.dart';
import '../../providers/responsavel_provider.dart';
// import '../../models/user_model.dart';
import '../../utils/app_utils.dart';
import '../../utils/responsive.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';


class ResponsavelDetailScreen extends StatefulWidget {
  final String cpf;

  const ResponsavelDetailScreen({
    super.key,
    required this.cpf,
  });

  @override
  State<ResponsavelDetailScreen> createState() => _ResponsavelDetailScreenState();
}

class _ResponsavelDetailScreenState extends State<ResponsavelDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadResponsavel();
  }

  void _loadResponsavel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ResponsavelProvider>(context, listen: false)
          .getResponsavel(widget.cpf);
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
        title: const Text('Detalhes do Responsável'),
        actions: [
          Consumer<ResponsavelProvider>(
            builder: (context, provider, child) {
              if (provider.selectedResponsavel != null) {
                return PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'members',
                      child: Row(
                        children: [
                          Icon(Icons.family_restroom),
                          SizedBox(width: 8),
                          Text('Ver Membros'),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: Consumer<ResponsavelProvider>(
        builder: (context, provider, child) {
          if (provider.selectedResponsavel != null) {
            return FloatingActionButton(
              onPressed: () => context.go('/responsaveis/${widget.cpf}/editar'),
              child: const Icon(Icons.edit),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );

  Widget _buildTabletLayout() => Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Responsável'),
        actions: _buildActions(),
      ),
      body: _buildBody(),
    );

  Widget _buildDesktopLayout() => Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );

  Widget _buildHeader() => Consumer<ResponsavelProvider>(
      builder: (context, provider, child) {
        final responsavel = provider.selectedResponsavel;
        
        return Container(
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
              IconButton(
                onPressed: () => context.go('/responsaveis'),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      responsavel?.nome ?? 'Carregando...',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (responsavel != null)
                      Text(
                        'CPF: ${AppUtils.formatCpf(responsavel.cpf)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                  ],
                ),
              ),
              ..._buildActions(),
            ],
          ),
        );
      },
    );

  List<Widget> _buildActions() => [
      ElevatedButton.icon(
        onPressed: () => context.go('/responsaveis/${widget.cpf}/editar'),
        icon: const Icon(Icons.edit),
        label: const Text('Editar'),
      ),
      const SizedBox(width: 8),
      OutlinedButton.icon(
        onPressed: () => _handleMenuAction('members'),
        icon: const Icon(Icons.family_restroom),
        label: const Text('Membros'),
      ),
    ];

  Widget _buildBody() => Consumer<ResponsavelProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingWidget(message: 'Carregando dados...');
        }
        
        if (provider.error != null) {
          return CustomErrorWidget(
            message: provider.error!,
            onRetry: _loadResponsavel,
          );
        }
        
        if (provider.selectedResponsavel == null) {
          return const CustomErrorWidget(
            message: 'Responsável não encontrado',
          );
        }
        
        return _buildContent(provider.selectedResponsavel!);
      },
    );

  Widget _buildContent(ResponsavelModel responsavel) => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          _buildStatusCard(responsavel),
          
          const SizedBox(height: 16),
          
          // Informações Pessoais
          _buildInfoCard(
            title: 'Informações Pessoais',
            icon: Icons.person,
            children: [
              _buildInfoRow('Nome Completo', responsavel.nome),
              _buildInfoRow('CPF', AppUtils.formatCpf(responsavel.cpf)),
              if (responsavel.nomeMae != null)
                _buildInfoRow('Nome da Mãe', responsavel.nomeMae!),
              if (responsavel.dataNasc != null)
                _buildInfoRow(
                  'Data de Nascimento',
                  '${responsavel.dataNasc!.day}/${responsavel.dataNasc!.month}/${responsavel.dataNasc!.year}',
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Informações de Contato
          _buildInfoCard(
            title: 'Contato',
            icon: Icons.contact_phone,
            children: [
              if (responsavel.telefone != null)
                _buildInfoRow(
                  'Telefone',
                  AppUtils.formatTelefone(responsavel.telefone.toString()),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Endereço
          _buildInfoCard(
            title: 'Endereço',
            icon: Icons.location_on,
            children: [
              _buildInfoRow('CEP', AppUtils.formatCep(responsavel.cep)),
              if (responsavel.logradouro != null)
                _buildInfoRow('Logradouro', responsavel.logradouro!),
              _buildInfoRow('Número', responsavel.numero.toString()),
              if (responsavel.complemento != null && responsavel.complemento!.isNotEmpty)
                _buildInfoRow('Complemento', responsavel.complemento!),
              if (responsavel.bairro != null)
                _buildInfoRow('Bairro', responsavel.bairro!),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Informações do Sistema
          _buildInfoCard(
            title: 'Informações do Sistema',
            icon: MdiIcons.cog,
            children: [
              _buildInfoRow(
                'Status',
                responsavel.isAtivo ? 'Ativo' : 'Inativo',
                valueColor: responsavel.isAtivo ? Colors.green : Colors.red,
              ),
              if (responsavel.timestamp != null)
                _buildInfoRow(
                  'Data de Cadastro',
                  '${responsavel.timestamp!.day}/${responsavel.timestamp!.month}/${responsavel.timestamp!.year} às ${responsavel.timestamp!.hour}:${responsavel.timestamp!.minute.toString().padLeft(2, '0')}',
                ),
              if (responsavel.codRge != null)
                _buildInfoRow('Código RGE', responsavel.codRge.toString()),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Ações
          _buildActionButtons(responsavel),
        ],
      ),
    );

  Widget _buildStatusCard(ResponsavelModel responsavel) => Card(
      color: responsavel.isAtivo 
          ? Colors.green.withOpacity(0.1) 
          : Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              responsavel.isAtivo ? Icons.check_circle : Icons.cancel,
              color: responsavel.isAtivo ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    responsavel.isAtivo ? 'Responsável Ativo' : 'Responsável Inativo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: responsavel.isAtivo ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    responsavel.isAtivo 
                        ? 'Este responsável está ativo no sistema'
                        : 'Este responsável está inativo no sistema',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );

  Widget _buildActionButtons(ResponsavelModel responsavel) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => context.go('/responsaveis/${responsavel.cpf}/editar'),
          icon: const Icon(Icons.edit),
          label: const Text('Editar Responsável'),
        ),
        
        const SizedBox(height: 8),
        
        OutlinedButton.icon(
          onPressed: () => _handleMenuAction('members'),
          icon: const Icon(Icons.family_restroom),
          label: const Text('Ver Membros da Família'),
        ),
        
        const SizedBox(height: 8),
        
        OutlinedButton.icon(
          onPressed: () => _showShareDialog(responsavel),
          icon: const Icon(Icons.share),
          label: const Text('Compartilhar Dados'),
        ),
      ],
    );

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        context.go('/responsaveis/${widget.cpf}/editar');
        break;
      case 'members':
        // TODO: Implementar navegação para membros
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Visualização de membros em desenvolvimento'),
          ),
        );
        break;
    }
  }

  void _showShareDialog(ResponsavelModel responsavel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compartilhar Dados'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Escolha como deseja compartilhar os dados:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copiar informações'),
              onTap: () {
                // TODO: Implementar cópia dos dados
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Imprimir ficha'),
              onTap: () {
                // TODO: Implementar impressão
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}