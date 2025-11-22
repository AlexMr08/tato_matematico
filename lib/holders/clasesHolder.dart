import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:tato_matematico/clase.dart'; // Asegúrate que la ruta sea correcta

class ClasesHolder extends ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  List<Clase> _clases = [];
  bool _isLoading = true;
  Clase? claseSeleccionada;

  // Suscripciones para escuchar cambios en tiempo real
  StreamSubscription<DatabaseEvent>? _subAdded;
  StreamSubscription<DatabaseEvent>? _subChanged;
  StreamSubscription<DatabaseEvent>? _subRemoved;

  // Getters públicos
  List<Clase> get clases => _clases;
  bool get isLoading => _isLoading;

  // Constructor: Inicia la carga inmediatamente
  ClasesHolder() {
    _init();
  }

  void _init() {
    _loadClasesIniciales().then((_) {
      _attachListeners();
    });
  }

  // 1. Carga inicial masiva (más eficiente que escuchar de uno en uno al principio)
  Future<void> _loadClasesIniciales() async {
    try {
      final snapshot = await _dbRef.child("tato").child("clases").get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _clases.clear();
        for (final entry in data.entries) {
          final claseData = Map<String, dynamic>.from(entry.value as Map);
          _clases.add(Clase.fromMap(entry.key, claseData));
        }
        _ordenarClases();
      }
    } catch (e) {
      print("Error cargando clases: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Avisamos a la app que ya tenemos datos
    }
  }

  // 2. Escuchar cambios en tiempo real
  void _attachListeners() {
    final clasesRef = _dbRef.child('tato').child('clases');

    _subAdded = clasesRef.onChildAdded.listen(_onClaseAgregada);
    _subChanged = clasesRef.onChildChanged.listen(_onClaseCambiada);
    _subRemoved = clasesRef.onChildRemoved.listen(_onClaseEliminada);
  }

  void _onClaseAgregada(DatabaseEvent event) {
    if (event.snapshot.value == null) return;
    final key = event.snapshot.key!;

    // Evitamos duplicados si la carga inicial ya lo trajo
    if (_clases.any((c) => c.id == key)) return;

    final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
    _clases.add(Clase.fromMap(key, data));
    _ordenarClases();
    notifyListeners();
  }

  void _onClaseCambiada(DatabaseEvent event) {
    if (event.snapshot.value == null) return;
    final key = event.snapshot.key!;
    final index = _clases.indexWhere((c) => c.id == key);
    final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
    final claseActualizada = Clase.fromMap(key, data);

    if (index != -1) {
      _clases[index] = claseActualizada;
      _ordenarClases();
      notifyListeners();
    }
  }

  void _onClaseEliminada(DatabaseEvent event) {
    if (event.snapshot.value == null) return;
    final key = event.snapshot.key!;
    _clases.removeWhere((c) => c.id == key);
    notifyListeners();
  }

  // Ordenar: Más recientes primero (puedes cambiar la lógica aquí)
  void _ordenarClases() {
    _clases.sort((a, b) => b.ano.compareTo(a.ano));
  }

  // Método útil para obtener una clase específica por ID
  Clase? obtenerClasePorId(String id) {
    try {
      return _clases.firstWhere((c) => c.id == id);
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
