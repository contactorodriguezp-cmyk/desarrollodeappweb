import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'ing_shell.dart';
import 'nueva_solicitud_page.dart';
import 'solicitudes_page.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final recibidos = app.porEstado(Estado.completada)
          ..sort((a, b) => b.relevamiento!.enviado!.compareTo(a.relevamiento!.enviado!));
        final abiertas = app.solicitudes.where((s) => s.estado != Estado.completada).toList()
          ..sort((a, b) => a.limite.compareTo(b.limite));

        return ListView(padding: margenPagina(context), children: [
          PageHeader(
            'Buen día, ${app.usuarioIngenieria.split(' ').first}',
            subtitle: 'Así viene el relevamiento técnico',
            actions: [
              FilledButton.icon(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const NuevaSolicitudPage())),
                icon: const Icon(Icons.add),
                label: const Text('Nueva solicitud'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ResponsiveGrid(minItemWidth: 200, children: [
            _Kpi('Pendientes', '${app.porEstado(Estado.pendiente).length}', 'Esperan visita'),
            _Kpi('En curso', '${app.porEstado(Estado.enCurso).length}', 'Visitas en marcha'),
            _Kpi('Completadas', '${recibidos.length}', 'Listas para presupuestar'),
            _Kpi('Clientes', '${app.clientes.length}', 'Con relevamientos'),
          ]),
          const SizedBox(height: 24),
          DosColumnas(
            izquierda: Panel(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(children: [
                SectionTitle('Últimos relevamientos recibidos',
                    trailing: TextButton(onPressed: () => IngScaffold.irA(context, 1), child: const Text('Ver todas'))),
                for (var i = 0; i < recibidos.length && i < 4; i++)
                  FilaLista(
                    primera: i == 0,
                    titulo: recibidos[i].titulo,
                    subtitulo: '${recibidos[i].codigo} · ${recibidos[i].cliente} · ${recibidos[i].comercial}',
                    trailing: EstadoBadge(recibidos[i].estado),
                    onTap: () => abrirDetalle(context, recibidos[i]),
                  ),
              ]),
            ),
            derecha: Panel(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(children: [
                const SectionTitle('Vencen pronto'),
                const SizedBox(height: 8),
                for (var i = 0; i < abiertas.length && i < 4; i++)
                  FilaLista(
                    primera: i == 0,
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: i == 0 ? AppColors.pendingBg : AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(fmt(abiertas[i].limite).substring(0, 5),
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: i == 0 ? AppColors.pending : AppColors.primary)),
                    ),
                    titulo: abiertas[i].titulo,
                    subtitulo: abiertas[i].comercial,
                    onTap: () => abrirDetalle(context, abiertas[i]),
                  ),
              ]),
            ),
          ),
        ]);
      },
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi(this.titulo, this.valor, this.detalle);

  final String titulo;
  final String valor;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.muted)),
        const SizedBox(height: 6),
        Text(valor, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(detalle, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      ]),
    );
  }
}
