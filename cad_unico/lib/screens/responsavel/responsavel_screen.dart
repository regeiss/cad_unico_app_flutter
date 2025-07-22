import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
// import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../contants/constants.dart';
import '../../models/responsavel_model.dart';
import '../../providers/responsavel_provider.dart';
import '../../utils/app_utils.dart';
import '../../utils/responsive.dart';
// import '../../models/user_model.dart';

class ResponsavelFormScreen extends StatefulWidget {
  final String? cpf;

  const ResponsavelFormScreen({
    super.key,
    this.cpf,
  });

  bool get isEdit => cpf != null;

  @override
  State<ResponsavelFormScreen> createState() => _ResponsavelFormScreenState();
}

class _ResponsavelFormScreenState extends State<ResponsavelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _cpfController = TextEditingController();
  final _nomeController = TextEditingController();
  final _nomeMaeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  
  // Formatters
  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {'#': RegExp(r'[0-9]')},
  );
  
  // Form data
  DateTime? _dataNascimento;
  String _status = 'A';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _loadResponsavel();
    }
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _nomeController.dispose();
    _nomeMaeController.dispose();
    _telefoneController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    super.dispose();
  }

  void _loadResponsavel() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ResponsavelProvider>(context, listen: false);
      final responsavel = await provider.getResponsavel(widget.cpf!);
      
      if (responsavel != null) {
        _fillForm(responsavel);
      }
    });
  }

  void _fillForm(ResponsavelModel responsavel) {
    _cpfController.text = AppUtils.formatCpf(responsavel.cpf);
    _nomeController.text = responsavel.nome;
    _nomeMaeController.text = responsavel.nomeMae ?? '';
    _telefoneController.text = responsavel.telefone != null 
        ? AppUtils.formatTelefone(responsavel.telefone.toString()) 
        : '';
    _cepController.text = AppUtils.formatCep(responsavel.cep);
    _logradouroController.text = responsavel.logradouro ?? '';
    _numeroController.text = responsavel.numero.toString();
    _complementoController.text = responsavel.complemento ?? '';
    _bairroController.text = responsavel.bairro ?? '';
    _dataNascimento = responsavel.dataNasc;
    _status = responsavel.status ?? 'A';
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _dataNascimento = date;
      });
    }
  }

  Future<void> _buscarCep() async {
    final cep = AppUtils.cleanCep(_cepController.text);
    if (cep.length != 8) return;
    
    // TODO: Implementar busca de CEP via API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Busca de CEP em desenvolvimento'),
      ),
    );
  }

  Future<void> _saveResponsavel() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final responsavel = ResponsavelModel(
        cpf: AppUtils.cleanCpf(_cpfController.text),
        nome: _nomeController.text.trim(),
        cep: AppUtils.cleanCep(_cepController.text),
        numero: int.parse(_numeroController.text),
        complemento: _complementoController.text.trim().isEmpty 
            ? null 
            : _complementoController.text.trim(),
        telefone: _telefoneController.text.trim().isEmpty
            ? null
            : int.tryParse(AppUtils.cleanTelefone(_telefoneController.text)),
        bairro: _bairroController.text.trim().isEmpty
            ? null
            : _bairroController.text.trim(),
        logradouro: _logradouroController.text.trim().isEmpty
            ? null
            : _logradouroController.text.trim(),
        nomeMae: _nomeMaeController.text.trim().isEmpty
            ? null
            : _nomeMaeController.text.trim(),
        dataNasc: _dataNascimento,
        status: _status,
      );
      
      final provider = Provider.of<ResponsavelProvider>(context, listen: false);
      bool success;
      
      if (widget.isEdit) {
        success = await provider.updateResponsavel(responsavel);
      } else {
        success = await provider.createResponsavel(responsavel);
      }
      
      if (success) {
        Fluttertoast.showToast(
          msg: widget.isEdit 
              ? AppConstants.successUpdate 
              : AppConstants.successSave,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        
        if (mounted) {
          context.go('/responsaveis');
        }
      } else {
        Fluttertoast.showToast(
          msg: provider.error ?? AppConstants.errorUpdate,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } on Exception   {
      Fluttertoast.showToast(
        msg: 'Erro ao salvar: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        title: Text(widget.isEdit ? 'Editar Responsável' : 'Novo Responsável'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveResponsavel,
              child: const Text('Salvar'),
            ),
        ],
      ),
      body: _buildForm(),
    );

  Widget _buildTabletLayout() => Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Editar Responsável' : 'Novo Responsável'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildForm(),
        ),
      ),
    );

  Widget _buildDesktopLayout() => Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: _buildForm(),
              ),
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
            color: Colors.black.withValues(alpha: (0.1)),
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
                  widget.isEdit ? 'Editar Responsável' : 'Novo Responsável',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.isEdit 
                      ? 'Edite as informações do responsável'
                      : 'Cadastre um novo responsável no sistema',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveResponsavel,
            icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Salvar'),
          ),
        ],
      ),
    );

  Widget _buildForm() => Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de Identificação
            _buildSection(
              title: 'Identificação',
              icon: Icons.person,
              children: [
                TextFormField(
                  controller: _cpfController,
                  decoration: const InputDecoration(
                    labelText: 'CPF *',
                    hintText: '000.000.000-00',
                  ),
                  inputFormatters: [_cpfFormatter],
                  keyboardType: TextInputType.number,
                  enabled: !widget.isEdit, // CPF não pode ser editado
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'CPF é obrigatório';
                    }
                    if (AppUtils.cleanCpf(value).length != 11) {
                      return 'CPF deve ter 11 dígitos';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo *',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    if (value.trim().length < 2) {
                      return 'Nome deve ter pelo menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _nomeMaeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Mãe',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                
                const SizedBox(height: 16),
                
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de Nascimento',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _dataNascimento != null
                          ? '${_dataNascimento!.day}/${_dataNascimento!.month}/${_dataNascimento!.year}'
                          : 'Selecione a data',
                      style: _dataNascimento != null
                          ? null
                          : TextStyle(
                              color: Theme.of(context).hintColor,
                            ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Seção de Contato
            _buildSection(
              title: 'Contato',
              icon: Icons.contact_phone,
              children: [
                TextFormField(
                  controller: _telefoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    hintText: '(00) 00000-0000',
                  ),
                  inputFormatters: [_telefoneFormatter],
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (AppUtils.cleanTelefone(value).length < 10) {
                        return 'Telefone deve ter pelo menos 10 dígitos';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Seção de Endereço
            _buildSection(
              title: 'Endereço',
              icon: Icons.location_on,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cepController,
                        decoration: const InputDecoration(
                          labelText: 'CEP *',
                          hintText: '00000-000',
                        ),
                        inputFormatters: [_cepFormatter],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'CEP é obrigatório';
                          }
                          if (AppUtils.cleanCep(value).length != 8) {
                            return 'CEP deve ter 8 dígitos';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (AppUtils.cleanCep(value).length == 8) {
                            _buscarCep();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _buscarCep,
                      icon: const Icon(Icons.search),
                      tooltip: 'Buscar CEP',
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _logradouroController,
                  decoration: const InputDecoration(
                    labelText: 'Logradouro',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _numeroController,
                        decoration: const InputDecoration(
                          labelText: 'Número *',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Número é obrigatório';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Número inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _complementoController,
                        decoration: const InputDecoration(
                          labelText: 'Complemento',
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _bairroController,
                  decoration: const InputDecoration(
                    labelText: 'Bairro',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Seção de Sistema
            _buildSection(
              title: 'Sistema',
              icon: Icons.settings,
              children: [
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                  ),
                  items: AppConstants.statusOptions.entries.map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value as String),
                    ),
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value ?? 'A';
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Botões de ação (apenas mobile)
            if (MediaQuery.of(context).size.width < AppConstants.tabletBreakpoint)
              _buildActionButtons(),
          ],
        ),
      ),
    );

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) => Column(
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
    );

  Widget _buildActionButtons() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _saveResponsavel,
          child: _isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Salvando...'),
                  ],
                )
              : Text(widget.isEdit ? 'Atualizar' : 'Salvar'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => context.go('/responsaveis'),
          child: const Text('Cancelar'),
        ),
      ],
    );
}