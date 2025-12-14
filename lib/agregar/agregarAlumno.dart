import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:crypto/crypto.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'dart:convert';

import 'package:tato_matematico/widgetsAuxiliares/botones.dart';

/// **Nombre de la Clase: `AgregarAlumno`**
///
/// **Descripción:** clase que permite agregar un nuevo alumno al sistema.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Joaquin Salas Castillo / Gonzalo Alganza Luque
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///

class AgregarAlumno extends StatefulWidget {
  FirebaseDatabase? database;
  AgregarAlumno({super.key, this.database});

  @override
  State<AgregarAlumno> createState() => _AgregarAlumnoState();
}

class _AgregarAlumnoState extends State<AgregarAlumno> with AlumnoLogic {
  final _nombreController = TextEditingController();
  late FirebaseDatabase _db;

  @override
  void initState() {
    super.initState();
    _db = widget.database ?? FirebaseDatabase.instance;
  }

  /*
  Se han hecho pruebas unitarias para asegurar que funciona correctamente:
  - Si no se pone un nombre, avisará de que se debe introducir un nombre
  - Al crearlo, se anade correctamente a la base de datos

  - Una vez creado, se prueba a iniciar sesion con la contrasena por defecto,
    la cual estara documentada en su lugar correspondiente, y funciona bien.
  - Se puede editar sin problema el usuario creado para personalizarlo
   */

  Future<void> agregarAlumno(String nom) async {
    int resultado = await procesarAgregarAlumno(nom, _db);

    if (resultado == -1) {
      if (mounted) snackBarAviso(context, "El nombre no puede estar vacío");
    } else {
      if (mounted) {
        snackBarExito(context, "Alumno creado con exito");
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Añadir alumno"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Introducir Nombre Completo
            const Text(
              "Nombre Completo",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nombre del alumno',
              ),
            ),
            const SizedBox(height: 10),

            // Boton para añadir al alumno
            SizedBox(
              width: double.infinity,
              child: BotonSinIcono(
                texto: "Añadir alumno",
                onPressed: () => agregarAlumno(_nombreController.text),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                vertPadding: 14,
                radius: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Agrega esto al final o principio de agregarAlumno.dart

mixin AlumnoLogic {
  // Esta función ahora es pura y testeable.
  // Recibe la DB como argumento en lugar de depender del estado.
  Future<int> procesarAgregarAlumno(String nom, FirebaseDatabase db) async {
    final nombre = nom.trim();

    // 1. Validación: Si está vacío devuelve -1
    if (nombre.isEmpty) {
      return -1;
    }

    String contrasenaDefecto = "0000";
    var bytes = utf8.encode(contrasenaDefecto);
    var digest = sha256.convert(bytes);
    String passwordHash = digest.toString();

    final dbRef = db.ref().child("tato").child("alumnos");
    final newAlumnoRef = dbRef.push();
    await newAlumnoRef.set({"nombre": nombre});

    String id = newAlumnoRef.key!;

    final dbRefpass = db.ref().child("tato").child("login");
    await dbRefpass.child(id).set({
      "alfanumerica": {"hash": passwordHash},
      "tipoLogin": "alfanumerica",
    });

    return 1; // Éxito
  }
}
