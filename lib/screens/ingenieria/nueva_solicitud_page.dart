import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'ing_shell.dart';

/// Ingeniería arma la solicitud en 3 pasos:
/// datos generales → datos a relevar → asignar ejecutivo comercial.
class NuevaSolicitudPage extends StatefulWidget {
  const NuevaSolicitudPage({super.key, this.cliente});

  final String? cliente;

  @override
  State<NuevaSolicitudPage> createState() => _NuevaSolicitudPageState();
}

class _DatoEdit {
  _DatoEdit(this.tipo, {String nombre = '', String unidad = ''})
      : nombre = TextEditingController(text: nombre),
        unidad = TextEditingController(text: unidad);

  TipoDato tipo;
  final TextEditingController nombre;
  final TextEditingController unidad;
  bool obligatorio = true;
}

class _NuevaSolicitudPageState extends State<NuevaSolicitudPage> {
  static const pasos = ['Datos generales', 'Datos a relevar', 'Asignar comercial'];
  int paso = 0;

  late String cliente = widget.cliente ?? app.clientes.first.nombre;
  final proyecto = TextEditingController();
  final titulo = TextEditingController();
  final indicaciones = TextEditingController();
  String prioridad = 'Media';

  final datos = <_DatoEdit>[
    _DatoEdit(TipoDato.medicion, nombre: 'Medida principal', unidad: 'm'),
    _DatoEdit(TipoDato.foto, nombre: 'Vista general'),
  ];

  late String comercial = app.cliente(cliente).comercial;
  DateTime limite = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    for (final c in [proyecto, titulo, indicaciones]) {
      c.dispose();
    }
    for (final d in datos) {
      d.nombre.dispose();
      d.unidad.dispose();
    }
    super.dispose();
  }

  void _siguiente() {
    if (paso == 0 && titulo.text.trim().isEmpty) {
      avisar(context, 'Poné un título a la solicitud.');
      return;
    }
    if (paso == 1) {
      if (datos.isEmpty) {
        avisar(context, 'Agregá al menos un dato a relevar.');
        return;
      }
      if (datos.any((d) => d.nombre.text.trim().isEmpty)) {
        avisar(context, 'Hay datos sin nombre.');
        return;
      }
    }
    if (paso < 2) {
      setState(() => paso++);
    } else {
      _generar();
    }
  }

  void _generar() {
    final s = app.crearSolicitud(
      titulo: titulo.text.trim(),
      cliente: cliente,
      proyecto: proyecto.text.trim().isEmpty ? 'Sin proyecto' : proyecto.text.trim(),
      comercial: comercial,
      limite: limite,
      prioridad: prioridad,
      indicaciones: indicaciones.text.trim(),
      datos: [
        for (final d in datos)
          DatoRelevar(
            nombre: d.nombre.text.trim(),
            tipo: d.tipo,
            unidad: d.tipo == TipoDato.medicion ? d.unidad.text.trim() : '',
            obligatorio: d.obligatorio,
          ),
      ],
    );
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.doneBg,
          child: Icon(Icons.check, color: AppColors.done, size: 32),
        ),
        title: const Text('Solicitud enviada'),
        content: Text(
          '$comercial recibió ${s.codigo} en su celular. Te avisamos cuando cargue el relevamiento.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const NuevaSolicitudPage()));
            },
            child: const Text('Crear otra'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              IngScaffold.irA(context, 1);
            },
            child: const Text('Ver solicitudes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titulos = [
      ('Nueva solicitud', 'Definí qué necesita relevar el comercial en la visita'),
      ('Datos a relevar', 'Cargá cada dato que necesitás para presupuestar. El comercial lo completa en la visita.'),
      ('Asignar ejecutivo comercial', 'Elegí quién hace la visita. Le llega la solicitud al celular.'),
    ];
    return IngScaffold(
      tab: 1,
      title: 'Nueva solicitud',
      body: ListView(padding: margenPagina(context), children: [
        PageHeader(titulos[paso].$1, subtitle: titulos[paso].$2, actions: [
          if (paso > 0) OutlinedButton(onPressed: () => setState(() => paso--), child: const Text('Volver')),
          FilledButton(onPressed: _siguiente, child: Text(paso < 2 ? 'Siguiente' : 'Generar solicitud')),
        ]),
        const SizedBox(height: 16),
        _Pasos(
          pasos: pasos,
          activo: paso,
          onTap: (i) {
            if (i < paso) setState(() => paso = i);
          },
        ),
        const SizedBox(height: 20),
        switch (paso) {
          0 => _datosGenerales(),
          1 => _datosARelevar(),
          _ => _asignar(),
        },
      ]),
    );
  }

  Widget _datosGenerales() {
    final ancho = esAncho(context);
    Widget par(Widget a, Widget b) => ancho
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: a),
            const SizedBox(width: 16),
            Expanded(child: b),
          ])
        : Column(children: [a, const SizedBox(height: 14), b]);

    return Panel(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionTitle('Datos generales'),
        const SizedBox(height: 16),
        par(
          _Desplegable(
            'Cliente',
            valor: cliente,
            opciones: [for (final c in app.clientes) c.nombre],
            onChanged: (v) => setState(() {
              cliente = v;
              comercial = app.cliente(v).comercial;
            }),
          ),
          LabeledField('Proyecto', controller: proyecto, hint: 'Ej.: Ampliación nave 2'),
        ),
        const SizedBox(height: 14),
        par(
          LabeledField('Título', controller: titulo, hint: 'Ej.: Relevamiento de nave para estructura metálica'),
          _Desplegable('Prioridad',
              valor: prioridad, opciones: const ['Alta', 'Media', 'Baja'], onChanged: (v) => setState(() => prioridad = v)),
        ),
        const SizedBox(height: 14),
        LabeledField('Indicaciones para el comercial',
            controller: indicaciones, maxLines: 4, hint: 'Qué tiene que mirar, medir o fotografiar en la visita'),
      ]),
    );
  }

  Widget _datosARelevar() {
    final ancho = esAncho(context);
    final lista = Panel(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var i = 0; i < datos.length; i++) ...[
          if (i > 0) const Divider(height: 24),
          _FilaDato(
            dato: datos[i],
            ancho: ancho,
            onChanged: () => setState(() {}),
            onBorrar: () => setState(() {
              final d = datos.removeAt(i);
              // Se liberan después del redibujo, cuando el campo ya no está en pantalla.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                d.nombre.dispose();
                d.unidad.dispose();
              });
            }),
          ),
        ],
        const SizedBox(height: 16),
        const Text('Agregar dato:', style: TextStyle(fontSize: 13, color: AppColors.muted)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in TipoDato.values)
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: Text(t.label),
              onPressed: () => setState(() => datos.add(_DatoEdit(t, unidad: t == TipoDato.medicion ? 'm' : ''))),
            ),
        ]),
      ]),
    );

    final vista = Panel(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionTitle('Así lo ve el comercial'),
        const SizedBox(height: 4),
        const Text('Cada dato se convierte en un campo del formulario de la visita.',
            style: TextStyle(fontSize: 13, color: AppColors.muted)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.ink, width: 6),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final d in datos.where((d) => d.nombre.text.trim().isNotEmpty)) ...[
              Text(
                '${d.nombre.text}${d.tipo == TipoDato.medicion && d.unidad.text.isNotEmpty ? ' (${d.unidad.text})' : ''}${d.obligatorio ? ' *' : ''}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  switch (d.tipo) {
                    TipoDato.medicion => '0,00',
                    TipoDato.foto => 'Tomar foto',
                    TipoDato.documento => 'Subir archivo',
                    TipoDato.texto => 'Escribir…',
                  },
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ]),
        ),
      ]),
    );

    return DosColumnas(izquierda: lista, derecha: vista, anchoDerecha: 380);
  }

  Widget _asignar() {
    final obligatorios = datos.where((d) => d.obligatorio).length;
    final lista = Panel(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionTitle('Ejecutivos comerciales'),
        const SizedBox(height: 12),
        for (final c in app.comerciales)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: c.nombre == comercial ? AppColors.primarySoft : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: c.nombre == comercial ? AppColors.primary : AppColors.border,
                  width: c.nombre == comercial ? 2 : 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => comercial = c.nombre),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(children: [
                    Icon(c.nombre == comercial ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: c.nombre == comercial ? AppColors.primary : AppColors.muted),
                    const SizedBox(width: 12),
                    Avatar(c.iniciales, size: 40, color: c.nombre == comercial ? AppColors.surface : AppColors.primarySoft),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c.nombre, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        Text(c.zona, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                      ]),
                    ),
                    TagChip('${app.pendientesDe(c.nombre)} pendientes', highlight: c.nombre == comercial),
                  ]),
                ),
              ),
            ),
          ),
        const SizedBox(height: 6),
        const Text('Visitar antes del', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            side: const BorderSide(color: AppColors.border),
            alignment: Alignment.centerLeft,
          ),
          onPressed: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: limite,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (d != null) setState(() => limite = d);
          },
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Text(fmt(limite)),
        ),
      ]),
    );

    final resumen = Panel(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionTitle('Resumen de la solicitud'),
        const SizedBox(height: 8),
        KvRow('Cliente', cliente, first: true),
        KvRow('Proyecto', proyecto.text.trim().isEmpty ? '—' : proyecto.text.trim()),
        KvRow('Título', titulo.text.trim()),
        KvRow('Datos a relevar', '${datos.length} ($obligatorios obligatorios)'),
        KvRow('Comercial', comercial),
        KvRow('Visitar antes del', fmt(limite)),
        KvRow('Prioridad', prioridad),
        const SizedBox(height: 8),
        InfoBox(
          icon: Icons.notifications_none,
          text: 'Al generar la solicitud, ${comercial.split(' ').first} recibe un aviso en su celular.',
        ),
      ]),
    );

    return DosColumnas(izquierda: lista, derecha: resumen);
  }
}

class _FilaDato extends StatelessWidget {
  const _FilaDato({required this.dato, required this.ancho, required this.onChanged, required this.onBorrar});

  final _DatoEdit dato;
  final bool ancho;
  final VoidCallback onChanged;
  final VoidCallback onBorrar;

  @override
  Widget build(BuildContext context) {
    final nombre = TextField(
      controller: dato.nombre,
      onChanged: (_) => onChanged(),
      decoration: const InputDecoration(hintText: 'Nombre del dato', isDense: true),
    );
    final tipo = DropdownButtonFormField<TipoDato>(
      initialValue: dato.tipo,
      isDense: true,
      decoration: const InputDecoration(isDense: true),
      items: [for (final t in TipoDato.values) DropdownMenuItem(value: t, child: Text(t.label))],
      onChanged: (t) {
        if (t == null) return;
        dato.tipo = t;
        if (t == TipoDato.medicion && dato.unidad.text.isEmpty) dato.unidad.text = 'm';
        onChanged();
      },
    );
    final unidad = TextField(
      controller: dato.unidad,
      enabled: dato.tipo == TipoDato.medicion,
      onChanged: (_) => onChanged(),
      decoration: const InputDecoration(hintText: 'Unidad', isDense: true),
    );
    final obligatorio = Row(mainAxisSize: MainAxisSize.min, children: [
      Switch(
        value: dato.obligatorio,
        onChanged: (v) {
          dato.obligatorio = v;
          onChanged();
        },
      ),
      const SizedBox(width: 4),
      const Text('Obligatorio', style: TextStyle(fontSize: 13)),
    ]);
    final borrar = IconButton(tooltip: 'Quitar', onPressed: onBorrar, icon: const Icon(Icons.delete_outline));

    if (ancho) {
      return Row(children: [
        Expanded(flex: 5, child: nombre),
        const SizedBox(width: 12),
        Expanded(flex: 3, child: tipo),
        const SizedBox(width: 12),
        SizedBox(width: 90, child: unidad),
        const SizedBox(width: 12),
        obligatorio,
        borrar,
      ]);
    }
    return Column(children: [
      Row(children: [Expanded(child: nombre), borrar]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: tipo),
        const SizedBox(width: 8),
        SizedBox(width: 90, child: unidad),
      ]),
      Align(alignment: Alignment.centerLeft, child: obligatorio),
    ]);
  }
}

class _Desplegable extends StatelessWidget {
  const _Desplegable(this.etiqueta, {required this.valor, required this.opciones, required this.onChanged});

  final String etiqueta;
  final String valor;
  final List<String> opciones;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(etiqueta, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        initialValue: valor,
        items: [for (final o in opciones) DropdownMenuItem(value: o, child: Text(o))],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    ]);
  }
}

class _Pasos extends StatelessWidget {
  const _Pasos({required this.pasos, required this.activo, required this.onTap});

  final List<String> pasos;
  final int activo;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
      for (var i = 0; i < pasos.length; i++)
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onTap(i),
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
            decoration: BoxDecoration(
              color: i == activo ? AppColors.primarySoft : AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: i == activo ? Colors.transparent : AppColors.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: i <= activo ? AppColors.primary : AppColors.bg,
                child: i < activo
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text('${i + 1}',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: i == activo ? Colors.white : AppColors.muted)),
              ),
              const SizedBox(width: 8),
              Text(pasos[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: i == activo ? FontWeight.w600 : FontWeight.w500,
                    color: i <= activo ? AppColors.primary : AppColors.muted,
                  )),
            ]),
          ),
        ),
    ]);
  }
}
