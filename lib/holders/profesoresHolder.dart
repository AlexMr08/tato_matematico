import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:tato_matematico/datos/profesor.dart';

class ProfesoresHolder extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  List<Profesor> _profesores = [];
  bool _isLoading = true;
  bool _isInit = false;

  bool get isLoading => _isLoading;
  bool get isInit => _isInit;

  // Suscripciones
  StreamSubscription<DatabaseEvent>? _subAdded;
  StreamSubscription<DatabaseEvent>? _subChanged;
  StreamSubscription<DatabaseEvent>? _subRemoved;
  bool get escuchando => _subAdded != null;
  // Getters
  List<Profesor> get profesores => _profesores;

  void init() {
    if (escuchando) return;

    // 2. RECONEXIÓN RÁPIDA: Si ya tenemos datos en memoria (porque entramos y salimos),
    // solo volvemos a conectar los listeners sin descargar todo de nuevo.
    if (_profesores.isNotEmpty) {
      print("reconecto");
      _attachListeners();
      return;
    }

    // 3. PRIMERA VEZ: Si la lista está vacía, descargamos y conectamos.
    _loadProfesores().then((_) {
      _attachListeners();
    });
  }

  // 1. Carga inicial masiva
  Future<void> _loadProfesores() async {
    try {
      final snapshot = await _dbRef.child("tato").child("profesorado").get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _profesores.clear();
        for (final entry in data.entries) {
          final profesorData = Map<dynamic, dynamic>.from(entry.value as Map);
          // IMPORTANTE: Aquí solo creamos el objeto con datos de texto.
          // NO llamamos a descargarImagen() para no bloquear el inicio.
          _profesores.add(Profesor.fromMap(entry.key, profesorData));
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
    final alumnosRef = _dbRef.child('tato').child('profesorado');

    _subAdded = alumnosRef.onChildAdded.listen(_onChildAdded);
    _subChanged = alumnosRef.onChildChanged.listen(_onChildChanged);
    _subRemoved = alumnosRef.onChildRemoved.listen(_onChildRemoved);
  }

  void _onChildAdded(DatabaseEvent event) {
    if (event.snapshot.value == null) return;
    final key = event.snapshot.key!;

    if (_profesores.any((a) => a.id == key)) {
      //Actualizamos el profesor
      print("actualizooo");
      final key = event.snapshot.key!;
      final index = _profesores.indexWhere((a) => a.id == key);
      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

      final profesorActualizado = Profesor.fromMap(key, data);

      if (index != -1) {
        _profesores[index] = profesorActualizado;
        notifyListeners();
      }
    } else {
      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      _profesores.add(Profesor.fromMap(key, data));
      notifyListeners();
    }
  }

  void _onChildChanged(DatabaseEvent event) {
    if (event.snapshot.value == null) return;
    final key = event.snapshot.key!;
    final index = _profesores.indexWhere((a) => a.id == key);
    final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

    final profesorActualizado = Profesor.fromMap(key, data);

    if (index != -1) {
      _profesores[index] = profesorActualizado;
      notifyListeners();
    }
  }

  void _onChildRemoved(DatabaseEvent event) {
    if (event.snapshot.value == null) return;
    final key = event.snapshot.key!;
    _profesores.removeWhere((a) => a.id == key);
    notifyListeners();
  }

  // === MÉTODOS DE UTILIDAD ===

  // Obtener un profesor específico
  Profesor? obtenerProfesorPorId(String id) {
    try {
      return _profesores.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  void desconectar() {
    _subAdded?.cancel();
    _subChanged?.cancel();
    _subRemoved?.cancel();

    _subAdded = null;
    _subChanged = null;
    _subRemoved = null;
  }

  @override
  void dispose() {
    _subAdded?.cancel();
    _subChanged?.cancel();
    _subRemoved?.cancel();
    super.dispose();
  }
}
