class Alumno{
  int id;
  String nombre;
  String imagen;

  Alumno({required this.id, required this.nombre, required this.imagen});

  @override
  String toString() {
    return 'Alumno{nombre: $nombre, imagen: $imagen}';
  }
}