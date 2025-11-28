import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:crypto/crypto.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'dart:convert';

import 'package:tato_matematico/widgetsAuxiliares/botones.dart';

class AgregarAlumno extends StatefulWidget {
  const AgregarAlumno({super.key});

  @override
  State<AgregarAlumno> createState() => _AgregarAlumnoState();
}

class _AgregarAlumnoState extends State<AgregarAlumno> {
  final _nombreController = TextEditingController();

  /*
  Se han hecho pruebas unitarias para asegurar que funciona correctamente:
  - Si no se pone un nombre, avisará de que se debe introducir un nombre
  - Al crearlo, se anade correctamente a la base de datos

  - Una vez creado, se prueba a iniciar sesion con la contrasena por defecto,
    la cual estara documentada en su lugar correspondiente, y funciona bien.
  - Se puede editar sin problema el usuario creado para personalizarlo
   */
  Future<void> agregarAlumno() async {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty) {
      snackBarAviso(context, "Por favor, introduce el nombre");
      return;
    }

    //En esta parte se establece una contrasena por defecto de "0000"
    String contrasena_defecto = "0000";

    //Se hace cifrado de la contrasena por Hash
    var bytes = utf8.encode(contrasena_defecto);
    var digest = sha256.convert(bytes);

    String passwordHash = digest.toString();

    //Se crea el alumno

    final dbRef = FirebaseDatabase.instance
        .ref()
        .child("tato")
        .child("alumnos");

    final newAlumnoRef = dbRef.push();
    await newAlumnoRef.set({"nombre": nombre});

    //Se crea la contrasena del alumno que por defecto es
    // "0000" cifrada en Hash.

    String id = newAlumnoRef.key!;

    final dbRefpass = FirebaseDatabase.instance
        .ref()
        .child("tato")
        .child("login");

    await dbRefpass.child(id).set({
      "alfanumerica": {"hash": passwordHash},
      "tipoLogin": "alfanumerica",
    });

    snackBarExito(context, "Alumno añadido correctamente");

    _nombreController.clear();

    Navigator.of(context).pop(true);
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
                onPressed: agregarAlumno,
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
