import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme.dart';
import 'common.dart';

/// Muestra todo lo que cargó el comercial en una visita.
/// Lo usan el resumen del celular y el detalle de Ingeniería.
/// Si [onEditar] no es null, cada sección muestra "Editar" (índice del paso).
class RelevamientoView extends StatelessWidget {
  const RelevamientoView(this.s, {super.key, this.onEditar, this.dosColumnas = false});

  final Solicitud s;
  final ValueChanged<int>? onEditar;
  final bool dosColumnas;

  @override
  Widget build(BuildContext context) {
    final r = s.relevamiento ?? Relevamiento();
    final mediciones = s.datos.where((d) => d.tipo == TipoDato.medicion).toList();
    final textos = s.datos.where((d) => d.tipo == TipoDato.texto).toList();

    Widget seccion(String titulo, int paso, List<Widget> hijos) => Panel(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionTitle(titulo,
                trailing: onEditar == null
                    ? null
                    : TextButton(onPressed: () => onEditar!(paso), child: const Text('Editar'))),
            const SizedBox(height: 4),
            ...hijos,
          ]),
        );

    final datos = seccion('Datos de la visita', 0, [
      KvRow('Fecha', '${r.fecha}${r.hora.isEmpty ? '' : ' · ${r.hora}'}', first: true),
      KvRow('Contacto', r.contacto.isEmpty ? '—' : r.contacto),
      KvRow('Cargo', r.cargo.isEmpty ? '—' : r.cargo),
      KvRow('Ubicación', r.ubicacion.isEmpty ? '—' : r.ubicacion),
    ]);

    final med = seccion('Mediciones', 1, [
      if (mediciones.isEmpty) const Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Sin mediciones pedidas.')),
      for (var i = 0; i < mediciones.length; i++)
        KvRow(
          mediciones[i].nombre,
          (r.valores[mediciones[i].nombre] ?? '').isEmpty
              ? 'Falta'
              : '${r.valores[mediciones[i].nombre]} ${mediciones[i].unidad}'.trim(),
          first: i == 0,
        ),
    ]);

    final fotos = seccion('Fotos y planos (${r.fotos.length + r.documentos.length})', 2, [
      if (r.fotos.isEmpty && r.documentos.isEmpty)
        const Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Todavía no hay adjuntos.')),
      if (r.fotos.isNotEmpty || r.documentos.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 10),
          child: ResponsiveGrid(minItemWidth: 120, spacing: 10, children: [
            for (final f in r.fotos) Miniatura(f, height: 90),
            for (final d in r.documentos) Miniatura(d, documento: true, height: 90),
          ]),
        ),
    ]);

    final nec = seccion('Necesidades y materiales', 3, [
      if (r.necesidades.isEmpty) const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('Sin necesidades cargadas.')),
      for (final n in r.necesidades)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.check_box_outlined, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(n, style: const TextStyle(fontSize: 14))),
          ]),
        ),
      for (var i = 0; i < r.materiales.length; i++)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
          child: Row(children: [
            Expanded(child: Text(r.materiales[i].nombre, style: const TextStyle(fontSize: 14))),
            TagChip(r.materiales[i].estado),
          ]),
        ),
      for (final t in textos)
        KvRow(t.nombre, (r.valores[t.nombre] ?? '').isEmpty ? '—' : r.valores[t.nombre]!),
      const SizedBox(height: 4),
    ]);

    if (!dosColumnas) {
      return Column(children: [
        for (final w in [datos, med, fotos, nec]) Padding(padding: const EdgeInsets.only(bottom: 12), child: w),
      ]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(children: [med, const SizedBox(height: 16), fotos])),
      const SizedBox(width: 24),
      SizedBox(width: 400, child: Column(children: [datos, const SizedBox(height: 16), nec])),
    ]);
  }
}
