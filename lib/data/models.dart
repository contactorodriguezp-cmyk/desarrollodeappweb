enum Estado { pendiente, enCurso, completada }

extension EstadoLabel on Estado {
  String get label => switch (this) {
        Estado.pendiente => 'Pendiente',
        Estado.enCurso => 'En curso',
        Estado.completada => 'Completada',
      };
}

enum TipoDato { medicion, foto, documento, texto }

extension TipoDatoLabel on TipoDato {
  String get label => switch (this) {
        TipoDato.medicion => 'Medición',
        TipoDato.foto => 'Foto',
        TipoDato.documento => 'Documento',
        TipoDato.texto => 'Texto',
      };
}

/// Un dato que Ingeniería pide relevar en la visita.
class DatoRelevar {
  DatoRelevar({
    required this.nombre,
    required this.tipo,
    this.unidad = '',
    this.obligatorio = true,
  });

  String nombre;
  TipoDato tipo;
  String unidad;
  bool obligatorio;
}

class ItemMaterial {
  ItemMaterial(this.nombre, this.estado);

  final String nombre;
  final String estado; // Existente, Requerido o Desmontar
}

/// Lo que carga el ejecutivo comercial durante la visita.
class Relevamiento {
  Relevamiento({
    this.fecha = '',
    this.hora = '',
    this.contacto = '',
    this.cargo = '',
    this.ubicacion = '',
    Map<String, String>? valores,
    List<String>? fotos,
    List<String>? documentos,
    List<String>? necesidades,
    List<ItemMaterial>? materiales,
    this.enviado,
  })  : valores = valores ?? {},
        fotos = fotos ?? [],
        documentos = documentos ?? [],
        necesidades = necesidades ?? [],
        materiales = materiales ?? [];

  String fecha;
  String hora;
  String contacto;
  String cargo;
  String ubicacion;

  /// Valor de cada dato de medición o texto, por nombre del dato.
  final Map<String, String> valores;
  final List<String> fotos;
  final List<String> documentos;
  final List<String> necesidades;
  final List<ItemMaterial> materiales;
  DateTime? enviado;
}

class Solicitud {
  Solicitud({
    required this.codigo,
    required this.titulo,
    required this.cliente,
    required this.proyecto,
    required this.comercial,
    required this.limite,
    this.estado = Estado.pendiente,
    this.prioridad = 'Media',
    this.pidio = 'Juan Pérez',
    this.indicaciones = '',
    List<DatoRelevar>? datos,
    this.relevamiento,
  }) : datos = datos ?? [];

  final String codigo;
  final String titulo;
  final String cliente;
  final String proyecto;
  final String comercial;
  final DateTime limite;
  Estado estado;
  final String prioridad;
  final String pidio;
  final String indicaciones;
  final List<DatoRelevar> datos;
  Relevamiento? relevamiento;

  /// Datos obligatorios que todavía no se cargaron.
  List<String> get faltantes {
    final r = relevamiento;
    if (r == null) return datos.where((d) => d.obligatorio).map((d) => d.nombre).toList();
    return [
      for (final d in datos.where((d) => d.obligatorio))
        if (switch (d.tipo) {
          TipoDato.medicion || TipoDato.texto => (r.valores[d.nombre] ?? '').trim().isEmpty,
          TipoDato.foto => r.fotos.isEmpty,
          TipoDato.documento => r.documentos.isEmpty,
        })
          d.nombre,
    ];
  }
}

class Cliente {
  const Cliente({
    required this.nombre,
    required this.rubro,
    required this.ubicacion,
    required this.contacto,
    required this.cargo,
    required this.telefono,
    required this.email,
    required this.comercial,
  });

  final String nombre;
  final String rubro;
  final String ubicacion;
  final String contacto;
  final String cargo;
  final String telefono;
  final String email;
  final String comercial;

  String get iniciales => nombre
      .split(' ')
      .where((p) => p.isNotEmpty && p[0] == p[0].toUpperCase())
      .take(2)
      .map((p) => p[0])
      .join();
}

class Proyecto {
  const Proyecto(this.nombre, this.cliente, this.estado);

  final String nombre;
  final String cliente;
  final Estado estado;
}

class Comercial {
  const Comercial(this.nombre, this.zona);

  final String nombre;
  final String zona;

  String get iniciales => nombre.split(' ').map((p) => p[0]).take(2).join();
}

class Notificacion {
  Notificacion(this.titulo, this.detalle, this.cuando, {this.codigo, this.leida = false});

  final String titulo;
  final String detalle;
  final String cuando;
  final String? codigo;
  bool leida;
}

String fmt(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
