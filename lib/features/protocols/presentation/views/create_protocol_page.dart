import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/theme/app_colors.dart';

import '../viewmodels/protocol_view_model.dart';

class CreateProtocolPage extends StatefulWidget {
  final ProtocolViewModel viewModel;

  const CreateProtocolPage({super.key, required this.viewModel});

  @override
  State<CreateProtocolPage> createState() => _CreateProtocolPageState();
}

class _CreateProtocolPageState extends State<CreateProtocolPage> {
  final _titleController = TextEditingController();
  final List<TextEditingController> _stepControllers = [
    TextEditingController(),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    for (final controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addStep() {
    setState(() => _stepControllers.add(TextEditingController()));
  }

  void _removeStep(int index) {
    if (_stepControllers.length == 1) return;
    setState(() {
      _stepControllers.removeAt(index).dispose();
    });
  }

  bool get _isValid {
    if (_titleController.text.trim().isEmpty) return false;
    return _stepControllers.any((c) => c.text.trim().isNotEmpty);
  }

  Future<void> _save() async {
    final pasos = _stepControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final created = await widget.viewModel.createProtocol(
      titulo: _titleController.text,
      pasos: pasos,
    );

    if (!mounted) return;

    if (created) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            widget.viewModel.message ?? 'No se pudo crear el protocolo.',
            style: GoogleFonts.livvic(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        backgroundColor: AppColors.ivory,
        foregroundColor: AppColors.coffe,
        title: Text(
          'Nuevo protocolo',
          style: GoogleFonts.shortStack(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    children: [
                      Text(
                        'Dale un nombre',
                        style: GoogleFonts.shortStack(
                          fontSize: 16,
                          color: AppColors.coffe,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTitleField(),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pasos',
                            style: GoogleFonts.shortStack(
                              fontSize: 16,
                              color: AppColors.coffe,
                            ),
                          ),
                          Text(
                            '${_stepControllers.length}',
                            style: GoogleFonts.livvic(
                              fontSize: 14,
                              color: AppColors.coffe,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (var i = 0; i < _stepControllers.length; i++) ...[
                        _buildStepField(i),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 4),
                      _buildAddStepButton(),
                    ],
                  ),
                ),
                _buildSaveButton(),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      onChanged: (_) => setState(() {}),
      style: GoogleFonts.livvic(fontSize: 16, color: AppColors.coffe),
      decoration: _inputDecoration('Ej. Crisis de ansiedad'),
    );
  }

  Widget _buildStepField(int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.peach.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.clay.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 32,
            width: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.clay,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: GoogleFonts.shortStack(
                fontSize: 14,
                color: AppColors.coffe,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _stepControllers[index],
              onChanged: (_) => setState(() {}),
              minLines: 1,
              maxLines: 3,
              style: GoogleFonts.livvic(fontSize: 15, color: AppColors.coffe),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Describe el paso',
                hintStyle: GoogleFonts.livvic(
                  fontSize: 15,
                  color: AppColors.coffe.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _stepControllers.length == 1
                ? null
                : () => _removeStep(index),
            icon: Icon(
              Icons.close_rounded,
              color: _stepControllers.length == 1
                  ? AppColors.coffe.withValues(alpha: 0.3)
                  : AppColors.coffe,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddStepButton() {
    return OutlinedButton.icon(
      onPressed: _addStep,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.coffe,
        side: const BorderSide(color: AppColors.coffe),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(double.infinity, 48),
      ),
      icon: const Icon(Icons.add),
      label: Text('Añadir paso', style: GoogleFonts.shortStack(fontSize: 15)),
    );
  }

  Widget _buildSaveButton() {
    final isSaving = widget.viewModel.isSaving;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isValid && !isSaving ? _save : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.clay,
            foregroundColor: AppColors.coffe,
            disabledBackgroundColor: AppColors.clay.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isSaving
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.coffe,
                  ),
                )
              : Text(
                  'Crear protocolo',
                  style: GoogleFonts.shortStack(fontSize: 18),
                ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.livvic(
        fontSize: 16,
        color: AppColors.coffe.withValues(alpha: 0.5),
      ),
      filled: true,
      fillColor: AppColors.peach.withValues(alpha: 0.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.clay.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.clay),
      ),
    );
  }
}
