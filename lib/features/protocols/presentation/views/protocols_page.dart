import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenmind/core/theme/app_colors.dart';
import 'package:zenmind/features/protocols/domain/entities/protocol.dart';

import '../viewmodels/protocol_view_model.dart';
import 'create_protocol_page.dart';
import 'protocol_detail_page.dart';

class ProtocolsPage extends StatefulWidget {
  final ProtocolViewModel viewModel;

  const ProtocolsPage({super.key, required this.viewModel});

  @override
  State<ProtocolsPage> createState() => _ProtocolsPageState();
}

class _ProtocolsPageState extends State<ProtocolsPage> {
  late final ProtocolViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel;
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openDetail(Protocol protocol) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProtocolDetailPage(protocol: protocol)),
    );
  }

  Future<void> _openCreate() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateProtocolPage(viewModel: _viewModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        backgroundColor: AppColors.ivory,
        foregroundColor: AppColors.coffe,
        title: Text('Volver', style: GoogleFonts.shortStack(fontSize: 18)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        backgroundColor: AppColors.clay,
        foregroundColor: AppColors.coffe,
        icon: const Icon(Icons.add),
        label: Text('Crear', style: GoogleFonts.shortStack(fontSize: 16)),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading && _viewModel.protocols.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.clay),
              );
            }

            return Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  'P R O T O C O L O S',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shortStack(
                    fontSize: 18,
                    color: AppColors.coffe,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tus rutinas para momentos difíciles',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.livvic(
                    fontSize: 14,
                    color: AppColors.coffe,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _viewModel.protocols.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: AppColors.clay,
                          onRefresh: _viewModel.loadProtocols,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                            itemCount: _viewModel.protocols.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildProtocolCard(
                                _viewModel.protocols[index],
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.checklist_rounded,
              size: 56,
              color: AppColors.clay,
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no tienes protocolos.\nCrea el primero con el botón de abajo.',
              textAlign: TextAlign.center,
              style: GoogleFonts.livvic(fontSize: 15, color: AppColors.coffe),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolCard(Protocol protocol) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openDetail(protocol),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.peach.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.clay.withValues(alpha: 0.4)),
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: AppColors.clay.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.spa_rounded, color: AppColors.coffe),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    protocol.titulo,
                    style: GoogleFonts.shortStack(
                      fontSize: 17,
                      color: AppColors.coffe,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${protocol.pasos.length} pasos',
                    style: GoogleFonts.livvic(
                      fontSize: 13,
                      color: AppColors.coffe,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.coffe),
          ],
        ),
      ),
    );
  }
}
