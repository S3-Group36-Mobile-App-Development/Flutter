import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/theme/app_colors.dart';
import 'package:zenmind/features/protocols/domain/entities/protocol.dart';

class ProtocolDetailPage extends StatelessWidget {
  final Protocol protocol;

  const ProtocolDetailPage({super.key, required this.protocol});

  @override
  Widget build(BuildContext context) {
    final pasos = [...protocol.pasos]
      ..sort((a, b) => a.ordenPaso.compareTo(b.ordenPaso));

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        backgroundColor: AppColors.ivory,
        foregroundColor: AppColors.coffe,
        title: Text('Volver', style: GoogleFonts.shortStack(fontSize: 18)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Text(
              protocol.titulo,
              textAlign: TextAlign.center,
              style: GoogleFonts.shortStack(fontSize: 24, color: AppColors.coffe),
            ),
            const SizedBox(height: 4),
            Text(
              '${pasos.length} pasos',
              textAlign: TextAlign.center,
              style: GoogleFonts.livvic(fontSize: 14, color: AppColors.coffe),
            ),
            const SizedBox(height: 24),
            for (final paso in pasos) ...[
              _buildStep(paso.ordenPaso, paso.descripcion),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int orden, String descripcion) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.peach.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.clay.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.clay,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$orden',
              style: GoogleFonts.shortStack(
                fontSize: 15,
                color: AppColors.coffe,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                descripcion,
                style: GoogleFonts.livvic(fontSize: 16, color: AppColors.coffe),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
