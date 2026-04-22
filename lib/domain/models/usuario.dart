class Usuario {
  final String uid;
  final String nombre;
  final String correo;
  final String telefono;
  final String rol;

  // Opcionales según rol
  final String? direccion;
  final bool? disponible;

  Usuario({
    required this.uid,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.rol,
    this.direccion,
    this.disponible,
  });

  /// Convertir Firestore → Objeto
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      uid: map['uid'] as String,
      nombre: map['nombre'] as String,
      correo: map['correo'] as String,
      telefono: map['telefono'] as String,
      rol: map['rol'] as String,
      direccion: map['direccion'] as String?,
      disponible: map['disponible'] as bool?,
    );
  }

  /// Convertir Objeto → Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'rol': rol,
      'direccion': direccion,
      'disponible': disponible,
    };
  }

  Usuario copyWith({
    String? uid,
    String? nombre,
    String? correo,
    String? telefono,
    String? direccion,
    String? rol,
    bool? disponible,
  }) {
    return Usuario(
      uid: uid ?? this.uid,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      rol: rol ?? this.rol,
      disponible: disponible ?? this.disponible,
    );
  }
}
