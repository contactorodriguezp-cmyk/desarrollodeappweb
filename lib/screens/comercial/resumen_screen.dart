import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/relevamiento_view.dart';
import 'comercial_home.dart';

/// "Revisar y enviar" (editable) o el relevamiento ya enviado (solo lectura).
class ResumenScreen extends StatelessWidget {
  const ResumenScreen(this.s, {super.key, this.editable = false});

  final Solicitud s;
  final bool editable;

  Future<void> _enviar(BuildContext context) async {
    final faltan = s.faltantes;
    if (faltan.isNotEmpty) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Faltan datos obligatorios'),
          content: Text('Ingeniería pidió: ${faltan.join(', ')}. ¿Querés enviar igual?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Completar')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Enviar igual')),
          ],
        ),
      );
      if (ok != true) return;
    }
    app.enviar(s);
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => VisitaEnviadaScreen(s)),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final faltan = s.faltantes;
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(editable ? 'Revisar y enviar' : 'Relevamiento ${s.codigo}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          Text(editable ? '${s.codigo} · ${s.cliente}' : s.cliente,
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ]),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            if (!editable) ...[
              Text(s.titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Enviado el ${fmt(s.relevamiento?.enviado ?? s.limite)}',
                  style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 12),
            ],
            if (editable) ...[
              faltan.isEmpty
                  ? const InfoBox(
                      icon: Icons.check_circle_outline,
                      text: 'Completaste todo lo que pidió Ingeniería.',
                      color: AppColors.doneBg,
                      fg: AppColors.done)
                  : InfoBox(
                      icon: Icons.error_outline,
                      text: 'Te falta: ${faltan.join(', ')}.',
                      color: AppColors.pendingBg,
                      fg: AppColors.pending),
              const SizedBox(height: 12),
            ],
            RelevamientoView(s, onEditar: editable ? (paso) => Navigator.of(context).pop(paso) : null),
          ]),
        ),
      ),
      bottomNavigationBar: editable
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(onPressed: () => _enviar(context), child: const Text('Enviar a Ingeniería')),
              ),
            )
          : null,
    );
  }
}

class VisitaEnviadaScreen extends StatelessWidget {
  const VisitaEnviadaScreen(this.s, {super.key});

  final Solicitud s;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.doneBg,
                    child: Icon(Icons.check, size: 48, color: AppColors.done),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('¡Visita enviada!',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  'Ingeniería ya puede ver el relevamiento de ${s.codigo} y avanzar con el presupuesto. Te avisamos si necesita algo más.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: AppColors.muted),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () {
                    comercialTab.value = 0;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Volver a solicitudes'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    comercialTab.value = 1;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ver en el historial'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
