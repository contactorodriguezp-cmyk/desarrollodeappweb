import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'ing_shell.dart';
import 'nueva_solicitud_page.dart';
import 'solicitudes_page.dart';

void abrirCliente(BuildContext context, String nombre) => Navigator.of(context)
    .push(MaterialPageRoute(builder: (_) => DetalleClientePage(app.cliente(nombre))));

class ClientesPage extends StatelessWidget {
  const ClientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final clientes = app.clientes;
    int proyectos(Cliente c) => app.proyectos.where((p) => p.cliente == c.nombre).length;
    String ultimaVisita(Cliente c) {
      final fechas = app.solicitudes
          .where((s) => s.cliente == c.nombre && s.relevamiento?.enviado != null)
          .map((s) => s.relevamiento!.enviado!)
          .toList()
        ..sort();
      return fechas.isEmpty ? '—' : fmt(fechas.last);
    }

    return ListView(padding: margenPagina(context), children: [
      PageHeader('Clientes', subtitle: 'Empresas donde se hacen los relevamientos', actions: [
        FilledButton.icon(
          onPressed: () => avisar(context, 'El alta de clientes llega en la próxima versión.'),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo cliente'),
        ),
      ]),
      const SizedBox(height: 20),
      if (esAncho(context))
        Tabla(
          columnas: const [('Cliente', 5), ('Rubro', 3), ('Ubicación', 3), ('Proyectos', 2), ('Última visita', 3)],
          filas: [
            for (final c in clientes)
              [
                Row(children: [
                  Avatar(c.iniciales, size: 30),
                  const SizedBox(width: 10),
                  Expanded(child: celda(c.nombre, fuerte: true)),
                ]),
                celda(c.rubro),
                celda(c.ubicacion),
                celda('${proyectos(c)}'),
                celda(ultimaVisita(c)),
              ],
          ],
          onTap: (i) => abrirCliente(context, clientes[i].nombre),
        )
      else
        for (final c in clientes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Panel(
              onTap: () => abrirCliente(context, c.nombre),
              child: Row(children: [
                Avatar(c.iniciales, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.nombre, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    Text('${c.rubro} · ${c.ubicacion}', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                  ]),
                ),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ]),
            ),
          ),
    ]);
  }
}

class DetalleClientePage extends StatelessWidget {
  const DetalleClientePage(this.c, {super.key});

  final Cliente c;

  @override
  Widget build(BuildContext context) {
    return IngScaffold(
      tab: 2,
      title: c.nombre,
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final proyectos = app.proyectos.where((p) => p.cliente == c.nombre).toList();
          final solicitudes = app.solicitudes.where((s) => s.cliente == c.nombre).toList();
          return ListView(padding: margenPagina(context), children: [
            PageHeader(c.nombre, subtitle: '${c.rubro} · ${c.ubicacion}, Mendoza', actions: [
              FilledButton.icon(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => NuevaSolicitudPage(cliente: c.nombre))),
                icon: const Icon(Icons.add),
                label: const Text('Nueva solicitud'),
              ),
            ]),
            const SizedBox(height: 20),
            DosColumnas(
              izquierda: Column(children: [
                Panel(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Column(children: [
                    SectionTitle('Proyectos (${proyectos.length})'),
                    const SizedBox(height: 8),
                    for (var i = 0; i < proyectos.length; i++)
                      FilaLista(
                        primera: i == 0,
                        titulo: proyectos[i].nombre,
                        subtitulo:
                            '${app.solicitudes.where((s) => s.proyecto == proyectos[i].nombre).length} solicitudes',
                        trailing: EstadoBadge(proyectos[i].estado),
                        onTap: () => IngScaffold.irA(context, 3),
                      ),
                  ]),
                ),
                const SizedBox(height: 16),
                Panel(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Column(children: [
                    const SectionTitle('Solicitudes y visitas'),
                    const SizedBox(height: 8),
                    if (solicitudes.isEmpty)
                      const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Todavía no hay solicitudes.')),
                    for (var i = 0; i < solicitudes.length; i++)
                      FilaLista(
                        primera: i == 0,
                        titulo: '${solicitudes[i].codigo} · ${solicitudes[i].titulo}',
                        subtitulo: solicitudes[i].estado == Estado.completada
                            ? 'Visitado el ${solicitudes[i].relevamiento!.fecha} · ${solicitudes[i].comercial}'
                            : 'Visitar antes del ${fmt(solicitudes[i].limite)} · ${solicitudes[i].comercial}',
                        trailing: EstadoBadge(solicitudes[i].estado),
                        onTap: () => abrirDetalle(context, solicitudes[i]),
                      ),
                  ]),
                ),
              ]),
              derecha: Panel(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(children: [
                  const SectionTitle('Datos del cliente'),
                  const SizedBox(height: 8),
                  KvRow('Contacto', c.contacto, first: true),
                  KvRow('Cargo', c.cargo),
                  KvRow('Teléfono', c.telefono),
                  KvRow('Email', c.email),
                  KvRow('Comercial asignado', c.comercial),
                ]),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class ProyectosPage extends StatefulWidget {
  const ProyectosPage({super.key});

  @override
  State<ProyectosPage> createState() => _ProyectosPageState();
}

class _ProyectosPageState extends State<ProyectosPage> {
  Estado? filtro;

  @override
  Widget build(BuildContext context) {
    final lista = app.proyectos.where((p) => filtro == null || p.estado == filtro).toList();
    return ListView(padding: margenPagina(context), children: [
      PageHeader('Proyectos', subtitle: 'Cada proyecto agrupa los relevamientos de un cliente', actions: [
        FilledButton.icon(
          onPressed: () => avisar(context, 'El alta de proyectos llega en la próxima versión.'),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo proyecto'),
        ),
      ]),
      const SizedBox(height: 20),
      Wrap(spacing: 8, runSpacing: 8, children: [
        ChoiceChip(
          label: Text('Todos (${app.proyectos.length})'),
          selected: filtro == null,
          onSelected: (_) => setState(() => filtro = null),
        ),
        for (final e in Estado.values)
          ChoiceChip(label: Text(e.label), selected: filtro == e, onSelected: (_) => setState(() => filtro = e)),
      ]),
      const SizedBox(height: 16),
      ResponsiveGrid(minItemWidth: 280, children: [
        for (final p in lista)
          Panel(
            padding: const EdgeInsets.all(20),
            onTap: () => abrirCliente(context, p.cliente),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              EstadoBadge(p.estado),
              const SizedBox(height: 10),
              Text(p.nombre, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(p.cliente, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
              const Divider(height: 24),
              Text(
                '${app.solicitudes.where((s) => s.proyecto == p.nombre && s.estado == Estado.completada).length} relevamientos enviados',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ]),
          ),
      ]),
    ]);
  }
}
