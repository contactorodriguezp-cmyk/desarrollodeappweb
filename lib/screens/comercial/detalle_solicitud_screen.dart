import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'visita_screen.dart';

class DetalleSolicitudScreen extends StatelessWidget {
  const DetalleSolicitudScreen(this.s, {super.key});

  final Solicitud s;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.codigo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const Text('Solicitud de Ingeniería', style: TextStyle(fontSize: 12, color: AppColors.muted)),
        ]),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Align(alignment: Alignment.centerLeft, child: EstadoBadge(s.estado)),
            const SizedBox(height: 8),
            Text(s.titulo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Panel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(children: [
                KvRow('Cliente', s.cliente, first: true),
                KvRow('Proyecto', s.proyecto),
                KvRow('Pidió', '${s.pidio} · Ingeniería'),
                KvRow('Prioridad', s.prioridad),
                KvRow('Visitar antes del', fmt(s.limite)),
              ]),
            ),
            if (s.indicaciones.isNotEmpty) ...[
              const SizedBox(height: 12),
              InfoBox(title: 'Indicaciones de Ingeniería', text: s.indicaciones),
            ],
            const SizedBox(height: 16),
            const SectionTitle('Qué hay que relevar'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final d in s.datos)
                Chip(
                  avatar: Icon(_icono(d.tipo), size: 16, color: AppColors.primary),
                  label: Text('${d.nombre}${d.obligatorio ? ' *' : ''}'),
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.border),
                ),
            ]),
            const SizedBox(height: 8),
            const Text('* obligatorio', style: TextStyle(fontSize: 12, color: AppColors.muted)),
          ]),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () {
              app.iniciarVisita(s);
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => VisitaScreen(s)));
            },
            child: Text(s.estado == Estado.pendiente ? 'Iniciar visita' : 'Continuar visita'),
          ),
        ),
      ),
    );
  }
}

IconData _icono(TipoDato t) => switch (t) {
      TipoDato.medicion => Icons.straighten,
      TipoDato.foto => Icons.photo_camera_outlined,
      TipoDato.documento => Icons.description_outlined,
      TipoDato.texto => Icons.notes,
    };
