import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/relevamiento_view.dart';
import 'ing_shell.dart';
import 'nueva_solicitud_page.dart';

void abrirDetalle(BuildContext context, Solicitud s) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetalleRelevamientoPage(s)));

class SolicitudesPage extends StatefulWidget {
  const SolicitudesPage({super.key});

  @override
  State<SolicitudesPage> createState() => _SolicitudesPageState();
}

class _SolicitudesPageState extends State<SolicitudesPage> {
  Estado? filtro;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final lista = app.solicitudes.where((s) => filtro == null || s.estado == filtro).toList();
        return ListView(padding: margenPagina(context), children: [
          PageHeader(
            'Solicitudes de relevamiento',
            subtitle: 'Pedidos de Ingeniería a los ejecutivos comerciales',
            actions: [
              FilledButton.icon(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const NuevaSolicitudPage())),
                icon: const Icon(Icons.add),
                label: const Text('Nueva solicitud'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ChoiceChip(
              label: Text('Todas (${app.solicitudes.length})'),
              selected: filtro == null,
              onSelected: (_) => setState(() => filtro = null),
            ),
            for (final e in Estado.values)
              ChoiceChip(
                label: Text('${e.label} (${app.porEstado(e).length})'),
                selected: filtro == e,
                onSelected: (_) => setState(() => filtro = e),
              ),
          ]),
          const SizedBox(height: 16),
          if (esAncho(context))
            Tabla(
              columnas: const [('Código', 2), ('Solicitud', 6), ('Cliente', 4), ('Comercial', 3), ('Fecha límite', 3), ('Estado', 3)],
              filas: [
                for (final s in lista)
                  [
                    celda(s.codigo, suave: true),
                    celda(s.titulo, fuerte: true),
                    celda(s.cliente),
                    celda(s.comercial),
                    celda(fmt(s.limite)),
                    Align(alignment: Alignment.centerLeft, child: EstadoBadge(s.estado)),
                  ],
              ],
              onTap: (i) => abrirDetalle(context, lista[i]),
            )
          else
            for (final s in lista)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SolicitudCard(s, onTap: () => abrirDetalle(context, s)),
              ),
        ]);
      },
    );
  }
}

/// Lo que ve Ingeniería de una solicitud: el relevamiento si ya se envió,
/// o lo que pidió y el estado de la visita si todavía no.
class DetalleRelevamientoPage extends StatelessWidget {
  const DetalleRelevamientoPage(this.s, {super.key});

  final Solicitud s;

  @override
  Widget build(BuildContext context) {
    return IngScaffold(
      tab: 1,
      title: s.codigo,
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final completa = s.estado == Estado.completada;
          return ListView(padding: margenPagina(context), children: [
            PageHeader(
              s.titulo,
              subtitle: completa
                  ? '${s.codigo} · ${s.cliente} · Visitado por ${s.comercial} el ${s.relevamiento!.fecha}'
                  : '${s.codigo} · ${s.cliente} · Asignada a ${s.comercial}',
              actions: completa
                  ? [
                      OutlinedButton.icon(
                        onPressed: () => avisar(context, 'La descarga en PDF llega en la próxima versión.'),
                        icon: const Icon(Icons.download),
                        label: const Text('Descargar PDF'),
                      ),
                      FilledButton(
                        onPressed: () => avisar(context, '${s.codigo} pasó a Presupuestos.'),
                        child: const Text('Pasar a presupuesto'),
                      ),
                    ]
                  : [],
            ),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: EstadoBadge(s.estado)),
            const SizedBox(height: 16),
            if (completa)
              RelevamientoView(s, dosColumnas: esAncho(context))
            else
              DosColumnas(
                izquierda: Panel(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SectionTitle('Datos pedidos'),
                    const SizedBox(height: 8),
                    for (var i = 0; i < s.datos.length; i++)
                      FilaLista(
                        primera: i == 0,
                        titulo: s.datos[i].nombre,
                        subtitulo: s.datos[i].tipo.label +
                            (s.datos[i].unidad.isEmpty ? '' : ' · ${s.datos[i].unidad}'),
                        trailing: TagChip(s.datos[i].obligatorio ? 'Obligatorio' : 'Opcional',
                            highlight: s.datos[i].obligatorio),
                      ),
                  ]),
                ),
                derecha: Column(children: [
                  InfoBox(
                    icon: s.estado == Estado.pendiente ? Icons.schedule : Icons.directions_walk,
                    text: s.estado == Estado.pendiente
                        ? '${s.comercial} todavía no empezó la visita. Fecha límite: ${fmt(s.limite)}.'
                        : '${s.comercial} está haciendo la visita. Fecha límite: ${fmt(s.limite)}.',
                  ),
                  const SizedBox(height: 16),
                  Panel(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(children: [
                      KvRow('Proyecto', s.proyecto, first: true),
                      KvRow('Prioridad', s.prioridad),
                      KvRow('Pidió', s.pidio),
                    ]),
                  ),
                  if (s.indicaciones.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    InfoBox(title: 'Indicaciones', text: s.indicaciones, color: AppColors.surface),
                  ],
                ]),
              ),
          ]);
        },
      ),
    );
  }
}
