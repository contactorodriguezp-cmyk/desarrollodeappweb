import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'resumen_screen.dart';

/// Registro de la visita en 4 pasos: Datos, Mediciones, Fotos y Necesidades.
class VisitaScreen extends StatefulWidget {
  const VisitaScreen(this.s, {super.key, this.pasoInicial = 0});

  final Solicitud s;
  final int pasoInicial;

  @override
  State<VisitaScreen> createState() => _VisitaScreenState();
}

class _VisitaScreenState extends State<VisitaScreen> {
  static const pasos = ['Datos', 'Mediciones', 'Fotos', 'Necesidades'];
  late int paso = widget.pasoInicial;

  late final Relevamiento r;
  late final TextEditingController fecha, hora, contacto, cargo, ubicacion;
  final valores = <String, TextEditingController>{};
  final necesidad = TextEditingController();

  Solicitud get s => widget.s;

  @override
  void initState() {
    super.initState();
    r = s.relevamiento ??= Relevamiento(fecha: fmt(DateTime.now()));
    fecha = TextEditingController(text: r.fecha);
    hora = TextEditingController(text: r.hora);
    contacto = TextEditingController(text: r.contacto.isEmpty ? app.cliente(s.cliente).contacto : r.contacto);
    cargo = TextEditingController(text: r.cargo.isEmpty ? app.cliente(s.cliente).cargo : r.cargo);
    ubicacion = TextEditingController(text: r.ubicacion);
    for (final d in s.datos.where((d) => d.tipo == TipoDato.medicion || d.tipo == TipoDato.texto)) {
      valores[d.nombre] = TextEditingController(text: r.valores[d.nombre] ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in [fecha, hora, contacto, cargo, ubicacion, necesidad, ...valores.values]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Pasa lo escrito en los campos al relevamiento.
  void _guardar() {
    r
      ..fecha = fecha.text.trim()
      ..hora = hora.text.trim()
      ..contacto = contacto.text.trim()
      ..cargo = cargo.text.trim()
      ..ubicacion = ubicacion.text.trim();
    valores.forEach((k, c) => r.valores[k] = c.text.trim());
    app.guardar();
  }

  void _borrador() {
    _guardar();
    avisar(context, 'Borrador guardado. Podés seguir después.');
    Navigator.of(context).pop();
  }

  Future<void> _siguiente() async {
    _guardar();
    if (paso < pasos.length - 1) {
      setState(() => paso++);
      return;
    }
    final editar = await Navigator.of(context)
        .push<int>(MaterialPageRoute(builder: (_) => ResumenScreen(s, editable: true)));
    if (editar != null && mounted) setState(() => paso = editar);
  }

  void _atras() {
    _guardar();
    if (paso > 0) {
      setState(() => paso--);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<String?> _pedirTexto(String titulo, String etiqueta, {String inicial = ''}) {
    final c = TextEditingController(text: inicial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: TextField(controller: c, autofocus: true, decoration: InputDecoration(labelText: etiqueta)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Agregar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _atras),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Registrar visita', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          Text('${s.codigo} · ${s.cliente}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: MobileStepper(
            labels: pasos,
            active: paso,
            onTap: (i) {
              _guardar();
              setState(() => paso = i);
            },
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: switch (paso) {
              0 => _pasoDatos(),
              1 => _pasoMediciones(),
              2 => _pasoFotos(),
              _ => _pasoNecesidades(),
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(children: [
            Expanded(child: OutlinedButton(onPressed: _borrador, child: const Text('Guardar borrador'))),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _siguiente,
                child: Text(paso < pasos.length - 1 ? 'Siguiente' : 'Revisar'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  List<Widget> _pasoDatos() => [
        const SectionTitle('Datos de la visita'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: LabeledField('Fecha', controller: fecha, hint: 'dd/mm/aaaa')),
          const SizedBox(width: 12),
          Expanded(child: LabeledField('Hora de llegada', controller: hora, hint: '10:30')),
        ]),
        const SizedBox(height: 14),
        LabeledField('Contacto en planta', controller: contacto),
        const SizedBox(height: 14),
        LabeledField('Cargo', controller: cargo),
        const SizedBox(height: 14),
        LabeledField('Ubicación', controller: ubicacion, hint: 'Dirección de la planta'),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => ubicacion.text = '${app.cliente(s.cliente).ubicacion}, Mendoza (GPS)'),
            icon: const Icon(Icons.my_location, size: 18),
            label: const Text('Usar mi ubicación actual'),
          ),
        ),
      ];

  List<Widget> _pasoMediciones() {
    final mediciones = s.datos.where((d) => d.tipo == TipoDato.medicion).toList();
    return [
      if (s.indicaciones.isNotEmpty) ...[
        InfoBox(title: 'Ingeniería pide relevar', text: s.indicaciones),
        const SizedBox(height: 16),
      ],
      const SectionTitle('Mediciones'),
      const SizedBox(height: 12),
      for (final d in mediciones) ...[
        LabeledField(
          '${d.nombre}${d.unidad.isEmpty ? '' : ' (${d.unidad})'}${d.obligatorio ? ' *' : ''}',
          controller: valores[d.nombre],
          hint: '0,00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 14),
      ],
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () async {
            final nombre = await _pedirTexto('Nueva medición', 'Qué mediste (en metros)');
            if (nombre == null || nombre.isEmpty || valores.containsKey(nombre)) return;
            setState(() {
              s.datos.add(DatoRelevar(nombre: nombre, tipo: TipoDato.medicion, unidad: 'm', obligatorio: false));
              valores[nombre] = TextEditingController();
            });
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Agregar otra medición'),
        ),
      ),
    ];
  }

  List<Widget> _pasoFotos() {
    final pedidas = s.datos.where((d) => d.tipo == TipoDato.foto).map((d) => d.nombre).toList();
    return [
      if (pedidas.isNotEmpty) ...[
        InfoBox(icon: Icons.photo_camera_outlined, text: 'Ingeniería pidió fotos de: ${pedidas.join(', ')}.'),
        const SizedBox(height: 16),
      ],
      SectionTitle('Fotos (${r.fotos.length})'),
      const SizedBox(height: 10),
      if (r.fotos.isNotEmpty)
        ResponsiveGrid(minItemWidth: 150, spacing: 10, children: [
          for (final f in r.fotos)
            Stack(children: [
              Miniatura(f, height: 104),
              Positioned(
                right: 4,
                top: 4,
                child: IconButton.filledTonal(
                  iconSize: 16,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Quitar',
                  onPressed: () => setState(() => r.fotos.remove(f)),
                  icon: const Icon(Icons.close),
                ),
              ),
            ]),
        ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final nombre = await _pedirTexto('Tomar foto', 'Qué muestra la foto',
                  inicial: pedidas.isNotEmpty && r.fotos.isEmpty ? pedidas.first : 'Foto ${r.fotos.length + 1}');
              if (nombre != null && nombre.isNotEmpty) setState(() => r.fotos.add(nombre));
            },
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Tomar foto'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => setState(() => r.documentos.add('Plano_${r.documentos.length + 1}.pdf')),
            icon: const Icon(Icons.upload_file),
            label: const Text('Subir plano'),
          ),
        ),
      ]),
      const SizedBox(height: 20),
      SectionTitle('Planos y documentos (${r.documentos.length})'),
      const SizedBox(height: 10),
      for (final d in r.documentos)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Panel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(children: [
              const Icon(Icons.description_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(d, style: const TextStyle(fontWeight: FontWeight.w600))),
              IconButton(onPressed: () => setState(() => r.documentos.remove(d)), icon: const Icon(Icons.delete_outline)),
            ]),
          ),
        ),
      const Text('En esta versión de prueba las fotos y los planos se simulan; la app final usa la cámara del celular.',
          style: TextStyle(fontSize: 12, color: AppColors.muted)),
    ];
  }

  List<Widget> _pasoNecesidades() {
    final textos = s.datos.where((d) => d.tipo == TipoDato.texto).toList();
    return [
      const SectionTitle('Necesidades detectadas'),
      const SizedBox(height: 10),
      for (final n in r.necesidades)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Panel(
            padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
            child: Row(children: [
              const Icon(Icons.check_box_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(n)),
              IconButton(onPressed: () => setState(() => r.necesidades.remove(n)), icon: const Icon(Icons.close, size: 18)),
            ]),
          ),
        ),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: LabeledField('Agregar necesidad', controller: necesidad, hint: 'Escribí lo que pidió el cliente')),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: () {
            final t = necesidad.text.trim();
            if (t.isEmpty) return;
            setState(() {
              r.necesidades.add(t);
              necesidad.clear();
            });
          },
          icon: const Icon(Icons.add),
        ),
      ]),
      const SizedBox(height: 20),
      const SectionTitle('Materiales y actividades'),
      const SizedBox(height: 10),
      if (r.materiales.isNotEmpty)
        Panel(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Column(children: [
            for (var i = 0; i < r.materiales.length; i++)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: i == 0
                    ? null
                    : const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
                child: Row(children: [
                  Expanded(child: Text(r.materiales[i].nombre)),
                  TagChip(r.materiales[i].estado),
                  IconButton(
                    onPressed: () => setState(() => r.materiales.removeAt(i)),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ]),
              ),
          ]),
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _agregarMaterial,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Agregar material o actividad'),
        ),
      ),
      for (final d in textos) ...[
        const SizedBox(height: 12),
        LabeledField('${d.nombre}${d.obligatorio ? ' *' : ''}', controller: valores[d.nombre], maxLines: 3),
      ],
    ];
  }

  Future<void> _agregarMaterial() async {
    final nombre = TextEditingController();
    var estado = 'Requerido';
    final item = await showDialog<ItemMaterial>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Material o actividad'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nombre, autofocus: true, decoration: const InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: estado,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: const [
                DropdownMenuItem(value: 'Existente', child: Text('Existente')),
                DropdownMenuItem(value: 'Requerido', child: Text('Requerido')),
                DropdownMenuItem(value: 'Desmontar', child: Text('Desmontar')),
              ],
              onChanged: (v) => setD(() => estado = v ?? estado),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, nombre.text.trim().isEmpty ? null : ItemMaterial(nombre.text.trim(), estado)),
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
    if (item != null) setState(() => r.materiales.add(item));
  }
}
