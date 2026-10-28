import 'package:flutter/foundation.dart';

import 'models.dart';

/// Estado en memoria de la app (datos de ejemplo, sin backend).
/// Lo que crea Ingeniería le aparece al comercial y lo que envía el
/// comercial le aparece a Ingeniería, mientras la app esté abierta.
class AppState extends ChangeNotifier {
  final String usuarioComercial = 'Martina López';
  final String usuarioIngenieria = 'Juan Pérez';

  final List<Comercial> comerciales = const [
    Comercial('Martina López', 'Zona Gran Mendoza · Luján de Cuyo'),
    Comercial('Diego Funes', 'Zona Este · San Martín'),
    Comercial('Lucía Herrera', 'Zona Sur · San Rafael'),
  ];

  final List<Cliente> clientes = const [
    Cliente(nombre: 'Metalúrgica Andina', rubro: 'Metalurgia', ubicacion: 'Luján de Cuyo', contacto: 'Carlos Gómez', cargo: 'Jefe de mantenimiento', telefono: '+54 261 555-0101', email: 'mantenimiento@ejemplo.com', comercial: 'Martina López'),
    Cliente(nombre: 'Bodega Los Álamos', rubro: 'Vitivinícola', ubicacion: 'Maipú', contacto: 'Paula Ríos', cargo: 'Jefa de planta', telefono: '+54 261 555-0102', email: 'planta@ejemplo.com', comercial: 'Martina López'),
    Cliente(nombre: 'Agroindustrias Cuyo', rubro: 'Agroindustria', ubicacion: 'San Martín', contacto: 'Raúl Sosa', cargo: 'Gerente de operaciones', telefono: '+54 263 555-0103', email: 'operaciones@ejemplo.com', comercial: 'Diego Funes'),
    Cliente(nombre: 'Frigorífico del Sur', rubro: 'Alimentos', ubicacion: 'Godoy Cruz', contacto: 'Ana Molina', cargo: 'Responsable de mantenimiento', telefono: '+54 261 555-0104', email: 'frio@ejemplo.com', comercial: 'Martina López'),
    Cliente(nombre: 'Cementos del Oeste', rubro: 'Construcción', ubicacion: 'Las Heras', contacto: 'Jorge Videla', cargo: 'Jefe de planta', telefono: '+54 261 555-0105', email: 'planta.oeste@ejemplo.com', comercial: 'Diego Funes'),
    Cliente(nombre: 'Lácteos San Rafael', rubro: 'Alimentos', ubicacion: 'San Rafael', contacto: 'Sofía Ortiz', cargo: 'Jefa de mantenimiento', telefono: '+54 260 555-0106', email: 'lacteos@ejemplo.com', comercial: 'Diego Funes'),
  ];

  final List<Proyecto> proyectos = const [
    Proyecto('Ampliación nave 2', 'Metalúrgica Andina', Estado.enCurso),
    Proyecto('Puente grúa: mantenimiento', 'Metalúrgica Andina', Estado.completada),
    Proyecto('Línea de envasado nueva', 'Bodega Los Álamos', Estado.pendiente),
    Proyecto('Galpón de acopio', 'Agroindustrias Cuyo', Estado.pendiente),
    Proyecto('Tablero eléctrico planta 1', 'Frigorífico del Sur', Estado.enCurso),
    Proyecto('Cámara de frío 2', 'Frigorífico del Sur', Estado.completada),
    Proyecto('Pasarelas de mantenimiento', 'Cementos del Oeste', Estado.completada),
    Proyecto('Red de vapor', 'Lácteos San Rafael', Estado.completada),
  ];

  late final List<Solicitud> solicitudes = _seed();

  final List<Notificacion> notificaciones = [
    Notificacion('Nueva solicitud de Ingeniería', 'SOL-0142 · Relevamiento de nave para estructura metálica', 'Hace 10 min', codigo: 'SOL-0142'),
    Notificacion('Nueva solicitud de Ingeniería', 'SOL-0139 · Medición de línea de envasado', 'Hace 2 h', codigo: 'SOL-0139'),
    Notificacion('Fecha límite cercana', 'SOL-0131 vence el 30/10. Te faltan las fotos.', 'Ayer', codigo: 'SOL-0131', leida: true),
    Notificacion('Ingeniería comentó tu relevamiento', 'SOL-0119 · "Con esto alcanza para cotizar, gracias."', 'Ayer', codigo: 'SOL-0119', leida: true),
  ];

  int get noLeidas => notificaciones.where((n) => !n.leida).length;

  List<Solicitud> delComercial(String nombre) =>
      solicitudes.where((s) => s.comercial == nombre).toList();

  List<Solicitud> porEstado(Estado e) => solicitudes.where((s) => s.estado == e).toList();

  Solicitud? buscar(String codigo) {
    for (final s in solicitudes) {
      if (s.codigo == codigo) return s;
    }
    return null;
  }

  Cliente cliente(String nombre) => clientes.firstWhere((c) => c.nombre == nombre);

  int pendientesDe(String comercial) =>
      solicitudes.where((s) => s.comercial == comercial && s.estado != Estado.completada).length;

  Solicitud crearSolicitud({
    required String titulo,
    required String cliente,
    required String proyecto,
    required String comercial,
    required DateTime limite,
    required String prioridad,
    required String indicaciones,
    required List<DatoRelevar> datos,
  }) {
    final ultimo = solicitudes
        .map((s) => int.parse(s.codigo.substring(4)))
        .reduce((a, b) => a > b ? a : b);
    final s = Solicitud(
      codigo: 'SOL-${(ultimo + 1).toString().padLeft(4, '0')}',
      titulo: titulo,
      cliente: cliente,
      proyecto: proyecto,
      comercial: comercial,
      limite: limite,
      prioridad: prioridad,
      pidio: usuarioIngenieria,
      indicaciones: indicaciones,
      datos: datos,
    );
    solicitudes.insert(0, s);
    if (comercial == usuarioComercial) {
      notificaciones.insert(0, Notificacion('Nueva solicitud de Ingeniería', '${s.codigo} · $titulo', 'Recién', codigo: s.codigo));
    }
    notifyListeners();
    return s;
  }

  void iniciarVisita(Solicitud s) {
    if (s.estado == Estado.pendiente) s.estado = Estado.enCurso;
    s.relevamiento ??= Relevamiento(fecha: fmt(DateTime.now()));
    notifyListeners();
  }

  void guardar() => notifyListeners();

  void enviar(Solicitud s) {
    s.estado = Estado.completada;
    s.relevamiento!.enviado = DateTime.now();
    notifyListeners();
  }

  void marcarLeidas() {
    if (noLeidas == 0) return;
    for (final n in notificaciones) {
      n.leida = true;
    }
    notifyListeners();
  }

  List<Solicitud> _seed() {
    DatoRelevar m(String n, {bool o = true}) => DatoRelevar(nombre: n, tipo: TipoDato.medicion, unidad: 'm', obligatorio: o);
    DatoRelevar f(String n) => DatoRelevar(nombre: n, tipo: TipoDato.foto);

    return [
      Solicitud(
        codigo: 'SOL-0142',
        titulo: 'Relevamiento de nave para estructura metálica',
        cliente: 'Metalúrgica Andina',
        proyecto: 'Ampliación nave 2',
        comercial: 'Martina López',
        limite: DateTime(2026, 11, 4),
        prioridad: 'Alta',
        indicaciones: 'Necesitamos la luz libre de la nave, la distancia entre columnas y la altura del portón. Fotografiar uniones y anclajes existentes.',
        datos: [
          m('Luz libre de la nave'),
          m('Distancia entre columnas'),
          m('Altura de portón'),
          f('Uniones y anclajes'),
          DatoRelevar(nombre: 'Plano de la nave', tipo: TipoDato.documento, obligatorio: false),
          DatoRelevar(nombre: 'Uso actual del espacio', tipo: TipoDato.texto, obligatorio: false),
        ],
      ),
      Solicitud(
        codigo: 'SOL-0139',
        titulo: 'Medición de línea de envasado',
        cliente: 'Bodega Los Álamos',
        proyecto: 'Línea de envasado nueva',
        comercial: 'Martina López',
        limite: DateTime(2026, 11, 6),
        indicaciones: 'Medir el largo disponible para la línea nueva y fotografiar el tablero eléctrico de la sala.',
        datos: [m('Largo disponible'), m('Ancho disponible'), f('Tablero eléctrico')],
      ),
      Solicitud(
        codigo: 'SOL-0137',
        titulo: 'Cubierta de galpón de acopio',
        cliente: 'Agroindustrias Cuyo',
        proyecto: 'Galpón de acopio',
        comercial: 'Diego Funes',
        limite: DateTime(2026, 11, 7),
        indicaciones: 'Relevar dimensiones del galpón y estado de la cubierta actual.',
        datos: [m('Largo del galpón'), m('Ancho del galpón'), m('Altura de cumbrera'), f('Estado de la cubierta')],
      ),
      Solicitud(
        codigo: 'SOL-0131',
        titulo: 'Ampliación de tablero eléctrico',
        cliente: 'Frigorífico del Sur',
        proyecto: 'Tablero eléctrico planta 1',
        comercial: 'Martina López',
        limite: DateTime(2026, 10, 30),
        estado: Estado.enCurso,
        indicaciones: 'Necesitamos las dimensiones del tablero y fotos de las borneras.',
        datos: [m('Alto del tablero'), m('Ancho del tablero'), f('Borneras')],
        relevamiento: Relevamiento(fecha: '28/10/2026', hora: '09:30', contacto: 'Ana Molina', cargo: 'Responsable de mantenimiento', ubicacion: 'Godoy Cruz, Mendoza', valores: {'Alto del tablero': '2,10'}),
      ),
      Solicitud(
        codigo: 'SOL-0128',
        titulo: 'Pasarela y escalera de mantenimiento',
        cliente: 'Cementos del Oeste',
        proyecto: 'Pasarelas de mantenimiento',
        comercial: 'Diego Funes',
        limite: DateTime(2026, 10, 28),
        estado: Estado.completada,
        indicaciones: 'Relevar el acceso a la tolva norte para diseñar pasarela y escalera.',
        datos: [m('Altura a salvar'), m('Largo de pasarela'), m('Ancho disponible'), m('Distancia a tolva'), f('Vista general')],
        relevamiento: Relevamiento(
          fecha: '27/10/2026', hora: '10:00', contacto: 'Jorge Videla', cargo: 'Jefe de planta', ubicacion: 'Las Heras, Mendoza',
          valores: {'Altura a salvar': '6,40', 'Largo de pasarela': '12,00', 'Ancho disponible': '1,10', 'Distancia a tolva': '2,35'},
          fotos: ['Vista general', 'Tolva norte', 'Anclajes'],
          documentos: ['Plano_planta.pdf'],
          necesidades: ['Acceso seguro a la tolva para limpieza semanal.', 'Baranda con rodapié según norma.', 'Trabajo en parada de planta (fin de semana).'],
          materiales: [ItemMaterial('Perfil UPN 160', 'Requerido'), ItemMaterial('Rejilla electrosoldada', 'Requerido'), ItemMaterial('Escalera existente', 'Desmontar')],
          enviado: DateTime(2026, 10, 27, 17),
        ),
      ),
      Solicitud(
        codigo: 'SOL-0125',
        titulo: 'Reemplazo de cañería de vapor',
        cliente: 'Lácteos San Rafael',
        proyecto: 'Red de vapor',
        comercial: 'Diego Funes',
        limite: DateTime(2026, 10, 25),
        estado: Estado.completada,
        datos: [m('Largo del tramo'), DatoRelevar(nombre: 'Diámetro', tipo: TipoDato.medicion, unidad: 'pulg.'), f('Recorrido')],
        relevamiento: Relevamiento(
          fecha: '24/10/2026', hora: '08:30', contacto: 'Sofía Ortiz', cargo: 'Jefa de mantenimiento', ubicacion: 'San Rafael, Mendoza',
          valores: {'Largo del tramo': '38,00', 'Diámetro': '2'},
          fotos: ['Recorrido', 'Válvulas', 'Soportes', 'Caldera'],
          necesidades: ['Reemplazar el tramo con pérdidas.', 'Aislar térmicamente la cañería.'],
          materiales: [ItemMaterial('Caño ASTM A106 2"', 'Requerido'), ItemMaterial('Soportes existentes', 'Existente')],
          enviado: DateTime(2026, 10, 24, 16),
        ),
      ),
      Solicitud(
        codigo: 'SOL-0119',
        titulo: 'Relevamiento de cámara de frío',
        cliente: 'Frigorífico del Sur',
        proyecto: 'Cámara de frío 2',
        comercial: 'Martina López',
        limite: DateTime(2026, 10, 18),
        estado: Estado.completada,
        datos: [m('Largo'), m('Ancho'), m('Alto'), f('Paneles')],
        relevamiento: Relevamiento(
          fecha: '17/10/2026', hora: '11:00', contacto: 'Ana Molina', cargo: 'Responsable de mantenimiento', ubicacion: 'Godoy Cruz, Mendoza',
          valores: {'Largo': '9,00', 'Ancho': '6,00', 'Alto': '3,50'},
          fotos: ['Paneles', 'Puerta', 'Evaporador'],
          necesidades: ['Mantener la temperatura durante la obra.'],
          materiales: [ItemMaterial('Panel isotérmico 100 mm', 'Requerido')],
          enviado: DateTime(2026, 10, 17, 15),
        ),
      ),
      Solicitud(
        codigo: 'SOL-0110',
        titulo: 'Puente grúa: inspección de rieles',
        cliente: 'Metalúrgica Andina',
        proyecto: 'Puente grúa: mantenimiento',
        comercial: 'Martina López',
        limite: DateTime(2026, 10, 11),
        estado: Estado.completada,
        datos: [m('Luz del puente'), m('Largo de rieles'), f('Estado de rieles')],
        relevamiento: Relevamiento(
          fecha: '10/10/2026', hora: '14:00', contacto: 'Carlos Gómez', cargo: 'Jefe de mantenimiento', ubicacion: 'Luján de Cuyo, Mendoza',
          valores: {'Luz del puente': '16,00', 'Largo de rieles': '48,00'},
          fotos: ['Riel norte', 'Riel sur', 'Topes'],
          necesidades: ['Alinear rieles y cambiar topes.'],
          materiales: [ItemMaterial('Topes de goma', 'Requerido'), ItemMaterial('Rieles existentes', 'Existente')],
          enviado: DateTime(2026, 10, 10, 18),
        ),
      ),
    ];
  }
}

/// Instancia única que comparten todas las pantallas.
final app = AppState();
