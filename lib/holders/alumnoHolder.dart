import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tato_matematico/datos/estadistica.dart';
import 'package:tato_matematico/juegos/juego1/juego1.dart';

import '../datos/alumno.dart';
import '../datos/juego.dart';
import '../juegos/juego2/juego2.dart';
import '../juegos/juego3/juego3.dart';

/// **Nombre de la Clase: `AlumnoHolder`**
///
/// **Descripción:** Clase que permite gestionar el estado del alumno que ha iniciado sesion en la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Se ha añadido setContenedor
///

class AlumnoHolder extends ChangeNotifier {
  Alumno? alumno;
  Map<String, Juego> listaJuegos = {};

  Map<String, EstadisticaJuego> estadisticas = {};
  StreamSubscription<DatabaseEvent>? _perfilSubscription;
  StreamSubscription<DatabaseEvent>? _juegosSubscription;
  StreamSubscription<DatabaseEvent>? _estadisticasSubscription;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  var areGamesLoaded = false;
  var areStatsLoaded = false;

  AlumnoHolder({this.alumno});

  void setAlumno(
    Alumno newAlumno, {
    bool initStats = true,
    bool initJuegos = true,
  }) {
    alumno = newAlumno;
    if (initJuegos) {
      cargarJuegos();
      _escucharCambiosJuegos(newAlumno.id);
    }
    if (initStats) {
      cargarEstaditicas();
      _escucharCambiosEstadisticas(newAlumno.id);
    }
    _escucharCambiosPerfil(newAlumno.id);
    notifyListeners();
  }

  Future<void> cargarJuegos() async {
    listaJuegos = {
      "juego1": Juego1(cantidad: 3, max: 10, min: 0),
      "juego2": Juego2(cantidad: 3, max: 10, min: 0, ordenDescendente: false),
      "juego3": Juego3(cantidad: 3, max: 10, min: 0, cantContenedores: 2),
      "juego4": Juego(id: "juego4", nombre: "Juego 4")};
    if (alumno != null) {
      // Apuntamos específicamente al nodo del juego 2
      var dbRef = FirebaseDatabase.instance.ref().child(
        "tato/juegos/${alumno!.id}",
      );

      try {
        final snapshot = await dbRef.get();
        if (snapshot.exists && snapshot.value != null) {
          for (var child in snapshot.children) {
            final data = Map<String, dynamic>.from(child.value as Map);

            // Fábrica dinámica:
            // Si tienes clases específicas (Juego2) úsalas, si no, la genérica.
            if (child.key == "juego1") {
              listaJuegos[child.key!] = Juego1.fromMap(data);
            } else if (child.key == "juego2") {
              listaJuegos[child.key!] = Juego2.fromMap(data);
            } else if (child.key == "juego3") {
              listaJuegos[child.key!] = Juego3.fromMap(data);
            } else {
              listaJuegos[child.key!] = Juego.fromMap(data);
            }
          }
          notifyListeners();
          _escucharCambiosJuegos(alumno!.id);
        }
        areGamesLoaded = true;
      } catch (e) {
        print("Error cargando configuración del Juego 2: $e");
      }
    }
  }

  void _escucharCambiosJuegos(String id) {
    _juegosSubscription?.cancel();
    final juegosRef = _dbRef.child('tato/juegos/$id');
    _juegosSubscription = juegosRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          final juegoData = Map<dynamic, dynamic>.from(value as Map);
          if (key == "juego1") {
            listaJuegos[key] = Juego1.fromMap(juegoData);
          } else if (key == 'juego2') {
            listaJuegos[key] = Juego2.fromMap(juegoData);
          } else if (key == 'juego3') {
            listaJuegos[key] = Juego3.fromMap(juegoData);
          } else {
            listaJuegos[key] = Juego.fromMap(juegoData);
          }
        });
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
    listaJuegos.clear();
    estadisticas.clear();
    areGamesLoaded = false;
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

  void setColorContenedor(Color color) {
    if (alumno != null) {
      alumno!.colorContenedor = color;
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
          final rawValue = child.value;
          if (rawValue is Map) {
            final data = Map<dynamic, dynamic>.from(rawValue);
            if (child.key != null) {
              // 2. CREAR EL OBJETO CON DATOS REALES
              var estadisticaJuego = EstadisticaJuego.fromMap(child.key!, data);

              estadisticaJuego.estadisticasSemanales.sort((a, b) {
                return b.fecha.compareTo(a.fecha);
              });

              estadisticas[child.key!] = estadisticaJuego;
            }
          }
        }
      }
      areStatsLoaded = true;
      notifyListeners();
    } catch (e) {
      print("Error general cargando estadisticas: $e");
    }
  }

  bool get hasAlumno => alumno != null;
}
