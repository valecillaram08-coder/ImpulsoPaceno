class Servicio {
  final int? id;
  final String nombrePrestador;
  final String oficioCategoria;
  final String descripcion;
  final String telefono;
  final String? whatsapp;
  final String? email;
  final String zona;
  final double? precioAprox;
  final String? disponibilidad;
  final String? fotoPath;
  final DateTime fechaRegistro;

  const Servicio({
    this.id,
    required this.nombrePrestador,
    required this.oficioCategoria,
    required this.descripcion,
    required this.telefono,
    this.whatsapp,
    this.email,
    required this.zona,
    this.precioAprox,
    this.disponibilidad,
    this.fotoPath,
    required this.fechaRegistro,
  });

  Servicio copyWith({
    int? id,
    String? nombrePrestador,
    String? oficioCategoria,
    String? descripcion,
    String? telefono,
    String? whatsapp,
    String? email,
    String? zona,
    double? precioAprox,
    String? disponibilidad,
    String? fotoPath,
    DateTime? fechaRegistro,
  }) {
    return Servicio(
      id: id ?? this.id,
      nombrePrestador: nombrePrestador ?? this.nombrePrestador,
      oficioCategoria: oficioCategoria ?? this.oficioCategoria,
      descripcion: descripcion ?? this.descripcion,
      telefono: telefono ?? this.telefono,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      zona: zona ?? this.zona,
      precioAprox: precioAprox ?? this.precioAprox,
      disponibilidad: disponibilidad ?? this.disponibilidad,
      fotoPath: fotoPath ?? this.fotoPath,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nombrePrestador': nombrePrestador,
      'oficioCategoria': oficioCategoria,
      'descripcion': descripcion,
      'telefono': telefono,
      'whatsapp': whatsapp,
      'email': email,
      'zona': zona,
      'precioAprox': precioAprox,
      'disponibilidad': disponibilidad,
      'fotoPath': fotoPath,
      'fechaRegistro': fechaRegistro.millisecondsSinceEpoch,
    };
  }

  factory Servicio.fromMap(Map<String, Object?> map) {
    return Servicio(
      id: map['id'] as int?,
      nombrePrestador: (map['nombrePrestador'] as String?) ?? '',
      oficioCategoria: (map['oficioCategoria'] as String?) ?? '',
      descripcion: (map['descripcion'] as String?) ?? '',
      telefono: (map['telefono'] as String?) ?? '',
      whatsapp: map['whatsapp'] as String?,
      email: map['email'] as String?,
      zona: (map['zona'] as String?) ?? '',
      precioAprox: (map['precioAprox'] as num?)?.toDouble(),
      disponibilidad: map['disponibilidad'] as String?,
      fotoPath: map['fotoPath'] as String?,
      fechaRegistro: DateTime.fromMillisecondsSinceEpoch(
        (map['fechaRegistro'] as int?) ?? 0,
      ),
    );
  }
}
