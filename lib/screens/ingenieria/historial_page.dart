import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../widgets/common.dart';
import 'ing_shell.dart';
import 'solicitudes_page.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  String busqueda = '';
  String? cliente;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final q = busqueda.toLowerCase();
        final lista = app
            .porEstado(Estado.completada)
            .where((s) => cliente == null || s.cliente == cliente)
            .where((s) => '${s.codigo} ${s.titulo} ${s.cliente} ${s.comercial}'.toLowerCase().contains(q))
            .toList()
          ..sort((a, b) => b.relevamiento!.enviado!.compareTo(a.relevamiento!.enviado!));

        final filtros = [
          SizedBox(
            width: 320,
            child: TextField(
              onChanged: (v) => setState(() => busqueda = v),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar', isDense: true),
            ),
          ),
          SizedBox(
            width: 260,
            child: DropdownButtonFormField<String?>(
              initialValue: cliente,
              isDense: true,
              decoration: const InputDecoration(isDense: true),
              items: [
                const DropdownMenuItem(value: null, child: Text('Cliente: todos')),
                for (final c in app.clientes) DropdownMenuItem(value: c.nombre, child: Text(c.nombre)),
              ],
              onChanged: (v) => setState(() => cliente = v),
            ),
          ),
        ];

        return ListView(padding: margenPagina(context), children: [
          PageHeader('Historial de relevamientos',
              subtitle: 'Todas las visitas técnicas que enviaron los comerciales',
              actions: [
                OutlinedButton.icon(
                  onPressed: () => avisar(context, 'La exportación llega en la próxima versión.'),
                  icon: const Icon(Icons.download),
                  label: const Text('Exportar'),
                ),
              ]),
          const SizedBox(height: 20),
          Wrap(spacing: 12, runSpacing: 12, children: filtros),
          const SizedBox(height: 16),
          if (lista.isEmpty)
            const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No hay relevamientos con ese filtro.')))
          else if (esAncho(context))
            Tabla(
              columnas: const [('Código', 2), ('Relevamiento', 6), ('Cliente', 4), ('Comercial', 3), ('Fecha de visita', 3), ('Adjuntos', 2)],
              filas: [
                for (final s in lista)
                  [
                    celda(s.codigo, suave: true),
                    celda(s.titulo, fuerte: true),
                    celda(s.cliente),
                    celda(s.comercial),
                    celda(s.relevamiento!.fecha),
                    celda('${s.relevamiento!.fotos.length + s.relevamiento!.documentos.length}'),
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
