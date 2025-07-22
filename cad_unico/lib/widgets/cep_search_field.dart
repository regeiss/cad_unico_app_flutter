import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../services/cep_service.dart';
import '../utils/app_utils.dart';

class CepSearchField extends StatefulWidget {
  final TextEditingController controller;
  final Function(CepModel)? onCepFound;
  final Function(String)? onError;
  final String? label;
  final String? hint;
  final bool required;

  const CepSearchField({
    super.key,
    required this.controller,
    this.onCepFound,
    this.onError,
    this.label,
    this.hint,
    this.required = false,
  });

  @override
  State<CepSearchField> createState() => _CepSearchFieldState();
}

class _CepSearchFieldState extends State<CepSearchField> {
  bool _isSearching = false;
  final _cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {'#': RegExp(r'[0-9]')},
  );

  Future<void> _buscarCep() async {
    final cep = AppUtils.cleanCep(widget.controller.text);

    if (!CepService.isValidCepFormat(cep)) {
      widget.onError?.call('CEP deve ter 8 dígitos');
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final cepData = await CepService.buscarCep(cep);

      if (cepData != null) {
        widget.onCepFound?.call(cepData);

        // Mostrar snackbar de sucesso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'CEP encontrado: ${cepData.logradouro}, ${cepData.bairro}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        widget.onError?.call('CEP não encontrado');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CEP não encontrado'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      widget.onError?.call(e.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar CEP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: widget.controller,
        inputFormatters: [_cepFormatter],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: widget.label ?? 'CEP${widget.required ? ' *' : ''}',
          hintText: widget.hint ?? '00000-000',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                IconButton(
                  onPressed: _buscarCep,
                  icon: const Icon(Icons.search),
                  tooltip: 'Buscar CEP',
                ),
            ],
          ),
          border: const OutlineInputBorder(),
        ),
        validator: widget.required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'CEP é obrigatório';
                }
                if (!CepService.isValidCepFormat(value)) {
                  return 'CEP deve ter 8 dígitos';
                }
                return null;
              }
            : null,
        onChanged: (value) {
          // Auto-busca quando CEP estiver completo
          if (AppUtils.cleanCep(value).length == 8 && !_isSearching) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted &&
                  AppUtils.cleanCep(widget.controller.text).length == 8) {
                _buscarCep();
              }
            });
          }
        },
      );
}