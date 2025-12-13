import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tato_matematico/datos/estadistica.dart';

import '../datos/alumno.dart';
import '../juegos/juego2/juego2.dart';

/// **Nombre de la Clase: `AlumnoHolder`**
///
/// **Descripción:** Clase que permite gestionar el estado del alumno que ha iniciado sesion en la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 12/12/2025
/// * **Último cambio:** Se ha mejorado como se llama al metodo de carga de juegos
///

class AlumnoHolder extends ChangeNotifier {
  Alumno? alumno;
  Juego2? juego2;
  Map<String, EstadisticaJuego> estadisticas = {};
  StreamSubscription<DatabaseEvent>? _perfilSubscription;
  StreamSubscription<DatabaseEvent>? _juegosSubscription;
  StreamSubscription<DatabaseEvent>? _estadisticasSubscription;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  var isLoaded = false;

  AlumnoHolder({this.alumno});

  void setAlumno(Alumno newAlumno) {
    alumno = newAlumno;
    cargarJuegos();
    cargarEstaditicas();
    _escucharCambiosPerfil(newAlumno.id);
    _escucharCambiosJuegos(newAlumno.id);
    _escucharCambiosEstadisticas(newAlumno.id);
    notifyListeners();
  }

  Future<void> cargarJuegos() async {
    if (alumno == null) return;
    // Apuntamos específicamente al nodo del juego 2
    var dbRef = FirebaseDatabase.instance.ref().child(
      "tato/juegos/${alumno!.id}",
    );

    try {
      final snapshot = await dbRef.get();
      print("SNAPSHOT: ${snapshot.value}");
      if (snapshot.exists && snapshot.value != null) {
        for (var child in snapshot.children) {
          if (child.key == "juego2") {
            // Convertimos los datos de Firebase (que suelen ser dynamic) a Map<String, dynamic>
            final data = Map<String, dynamic>.from(child.value as Map);
            juego2 = Juego2.fromMap(data);
          }
        }
        // Avisamos a las vistas que el juego ya está cargado
        notifyListeners();
        isLoaded = true;
        _escucharCambiosJuegos(alumno!.id);
      } else {
        juego2 = Juego2(
          min: 0,
          max: 10,
          cantidad: 8,
          usaImagenes: false,
          tipoImagenes: "numeros",
          ordenDescendente: false,
        );
        isLoaded = true;
        juego2?.guardarAjustes(
          idAlumno: alumno!.id,
          rango: 10,
          cantidad: 8,
          tema: 'numeros',
          dbRef: FirebaseDatabase.instance.ref(),
          orden: false,
        );
        _escucharCambiosJuegos(alumno!.id);
      }
    } catch (e) {
      print("Error cargando configuración del Juego 2: $e");
    }
  }

  void _escucharCambiosJuegos(String id) {
    _juegosSubscription?.cancel();
    final juegosRef = _dbRef.child('tato/juegos/$id');
    _juegosSubscription = juegosRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        if (data.containsKey('juego2')) {
          final juego2Data = Map<dynamic, dynamic>.from(data['juego2'] as Map);
          juego2 = Juego2.fromMap(juego2Data);
        }
        if (data.containsKey('juego1')) {
          print("TODO");
        }
      }
    });
  }

  void _escucharCambiosPerfil(String id) {
    _perfilSubscription?.cancel();
    final perfilRef = _dbRef.child('tato').child('alumnos').child(id);

    _perfilSubscription = perfilRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

        final alumnoActualizado = Alumno.fromMap(id, data);

        if (alumno != null && alumno!.imagen == alumnoActualizado.imagen) {
          alumnoActualizado.foto = alumno!.foto;
          alumnoActualizado.imagenLocal = alumno!.imagenLocal;
        }

        alumno = alumnoActualizado;
        notifyListeners();
      }
    });
  }

  void _escucharCambiosEstadisticas(String id) {
    _estadisticasSubscription?.cancel();
    final perfilRef = _dbRef.child('tato').child('estadisticas').child(id);
    _estadisticasSubscription = perfilRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);

        for (var entry in data.entries) {
          final key = entry.key;
          final value = Map<dynamic, dynamic>.from(entry.value as Map);

          var estadisticaJuego = EstadisticaJuego.fromMap(key, value);

          estadisticaJuego.estadisticasSemanales.sort((a, b) {
            return b.fecha.compareTo(a.fecha);
          });

          estadisticas[key] = estadisticaJuego;
        }
        notifyListeners();
      }
    });
  }

  void clear() {
    _perfilSubscription?.cancel();
    _perfilSubscription = null;
    _juegosSubscription?.cancel();
    _juegosSubscription = null;
    _estadisticasSubscription?.cancel();
    _estadisticasSubscription = null;
    alumno = null;
    juego2 = null;
    estadisticas.clear();
    isLoaded = false;
    notifyListeners();
  }

  void setColorFondo(Color color) {
    if (alumno != null) {
      alumno!.colorFondo = color;
      notifyListeners();
    }
  }

  void setBarraNav(Color color) {
    if (alumno != null) {
      alumno!.colorBarraNav = color;
      notifyListeners();
    }
  }

  void setColorBotones(Color color) {
    if (alumno != null) {
      alumno!.colorBotones = color;
      notifyListeners();
    }
  }

  void setColorSeleccion(Color color) {
    if (alumno != null) {
      alumno!.colorSeleccion = color;
      notifyListeners();
    }
  }

  Future<void> cargarEstaditicas() async {
    if (alumno == null) return;

    var dbRef = FirebaseDatabase.instance.ref().child(
      "tato/estadisticas/${alumno!.id}",
    );

    try {
      final snapshot = await dbRef.get();

      // 1. LIMPIAR E INICIALIZAR CON JUEGOS POR DEFECTO
      estadisticas.clear();

      // Definimos los IDs de tus 4 juegos
      final juegosIds = ["juego1", "juego2", "juego3", "juego4"];

      // Creamos entradas vacías para todos al principio
      for (var id in juegosIds) {
        estadisticas[id] = EstadisticaJuego(
          juegoId: id,
          estadisticasSemanales: [],
        );
      }

      if (snapshot.exists && snapshot.value != null) {
        for (var child in snapshot.children) {
          try {
            final rawValue = child.value;
            if (rawValue is Map) {
              final data = Map<dynamic, dynamic>.from(rawValue);
              if (child.key != null) {
                // 2. CREAR EL OBJETO CON DATOS REALES
                var estadisticaJuego = EstadisticaJuego.fromMap(
                  child.key!,
                  data,
                );

                // Ordenar por fecha (más reciente primero)
                estadisticaJuego.estadisticasSemanales.sort((a, b) {
                  return b.fecha.compareTo(a.fecha);
                });

                // 3. SOBRESCRIBIR LA ENTRADA VACÍA
                // Si child.key es "juego1", reemplazará al objeto vacío que creamos arriba
                estadisticas[child.key!] = estadisticaJuego;
              }
            }
          } catch (e) {
            print(
              "Error al procesar estadística individual (${child.key}): $e",
            );
          }
        }
      }
      // Notificamos sea cual sea el resultado (incluso si solo hay vacíos)
      notifyListeners();
    } catch (e) {
      print("Error general cargando estadisticas: $e");
    }
  }

  bool get hasAlumno => alumno != null;
}
