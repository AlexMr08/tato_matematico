import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/clase.dart'; // Asegúrate de importar tu modelo Alumno

class AlumnosHolder extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  List<Alumno> _alumnos = [];
  bool _isLoading = true;

  // Suscripciones
  StreamSubscription<DatabaseEvent>? _subAdded;
  StreamSubscription<DatabaseEvent>? _subChanged;
  StreamSubscription<DatabaseEvent>? _subRemoved;

  // Getters
  List<Alumno> get alumnos => _alumnos;
  bool get isLoading => _isLoading;

  AlumnosHolder() {
    _init();
  }

  void _init() {
    _loadAlumnosIniciales().then((_) {
      _attachListeners();
    });
  }

  // 1. Carga inicial masiva
  Future<void> _loadAlumnosIniciales() async {
    try {
      final snapshot = await _dbRef.child("tato").child("alumnos").get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _alumnos.clear();
        for (final entry in data.entries) {
          final alumnoData = Map<dynamic, dynamic>.from(entry.value as Map);
          // IMPORTANTE: Aquí solo creamos el objeto con datos de texto.
          // NO llamamos a descargarImagen() para no bloquear el inicio.
          _alumnos.add(Alumno.fromMap(entry.key, alumnoData));
        }
      }
    } catch (e) {
      print("Error cargando alumnos: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Listeners en tiempo real
  void _attachListeners() {
    final alumnosRef = _dbRef.child('tato').child('alumnos');

    _subAdded = alumnosRef.onChildAdded.listen(_onChildAdded);
    _subChanged = alumnosRef.onChildChanged.listen(_onChildChanged);
    _subRemoved = alumnosRef.onChildRemoved.listen(_onChildRemoved);
  }

  void _onChildAdded(DatabaseEvent event) {
    if (event.snapshot.value == null) return;
    final key = event.snapshot.key!;

    if (_alumnos.any((a) => a.id == key)) return;

    final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
    _alumnos.add(Alumno.fromMap(key, data));
    notifyListeners();
  }

  void _onChildChanged(DatabaseEvent event) {
    if (event.snapshot.value == null) return;
    final key = event.snapshot.key!;
    final index = _alumnos.indexWhere((a) => a.id == key);
    final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

    final alumnoActualizado = Alumno.fromMap(key, data);

    if (index != -1) {
      final alumnoViejo = _alumnos[index];

      if (alumnoViejo.imagen == alumnoActualizado.imagen) {
        alumnoActualizado.foto = alumnoViejo.foto;
        alumnoActualizado.imagenLocal = alumnoViejo.imagenLocal;
      }

      _alumnos[index] = alumnoActualizado;
      notifyListeners();
    }
  }


  void _onChildRemoved(DatabaseEvent event) {
    if (event.snapshot.value == null) return;
    final key = event.snapshot.key!;
    _alumnos.removeWhere((a) => a.id == key);
    notifyListeners();
  }

  // === MÉTODOS DE UTILIDAD ===

  // Obtener alumnos filtrados por el ID de su clase
  List<Alumno> obtenerAlumnosPorClase(Clase clase) {
    return _alumnos.where((a) =>  clase.alumnos.contains(a.id)).toList();
  }
  
  // Obtener un alumno específico (útil si lo necesitas buscar por ID)
  Alumno? obtenerAlumnoPorId(String id) {
    try {
      return _alumnos.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _subAdded?.cancel();
    _subChanged?.cancel();
    _subRemoved?.cancel();
    super.dispose();
  }
}
