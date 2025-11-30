import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cryptography/cryptography.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';

/// **Nombre de la Clase: `AgregarProfesor`**
///
/// **Descripción:** clase que permite agregar un nuevo profesor al sistema.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Joaquin Salas Castillo / Gonzalo Alganza Luque
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///

class AgregarProfesor extends StatefulWidget {
  const AgregarProfesor({super.key});

  @override
  State<AgregarProfesor> createState() => _AgregarProfesorState();
}

class _AgregarProfesorState extends State<AgregarProfesor> {
  final _nombreController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _esDirector = false;

  /*
  Se han hecho pruebas unitarias para asegurar que funciona correctamente:
  - Si no se introduce ningun campo, se avisara de ello y no se creara
    el profesor nuevo.
  - Si se pone el nombre pero no usuario ni contrasena, no se crea
  - Si se pone el nombre y usuario pero no contrasena, no se crea
  - Si se pone el nombre y contrasena pero no usuario, no se crea
  - Si se pone usuario y contrasena, pero no nombre, no se crea
  - Si se pone usuario, pero no nombre y contrasena, no se crea
  - Si se pone contrasena, pero no nombre y usuario, no se crea
  - Todas estas comprobaciones se han repetido con el check de director
  - Si se introducen todos los campos, se crea correctamente un profesor
  - Si se introducen todos los campos y se marca el check, se crea
    correctamente un administrador/director
  - Si se intenta crear una cuenta con un nombre de usuario ya existente,
    se avisara de ello y no se creara la cuenta nueva
   */

  Future<void> agregarProfesor() async {
    final nombre = _nombreController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (nombre.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    final dbRef = FirebaseDatabase.instance
        .ref()
        .child("tato")
        .child("profesorado");

    // Verificar si ya existe el username
    final snapshot = await dbRef
        .orderByChild("username")
        .equalTo(username)
        .once();
    if (snapshot.snapshot.value != null) {
      if(mounted){
        snackBarAviso(context, "Ese nombre de usuario ya existe");
      }
      return;
    }

    String? key = dbRef.push().key;

    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 10000, // Estándar recomendado mínimo hoy en día
      bits: 256, // 32 bytes de salida
    );

    final rng = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => rng.nextInt(256));

    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: saltBytes,
    );

    final hashBytes = await secretKey.extractBytes();

    final hashHex = hashBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final saltHex = saltBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    await dbRef.child(key!).set({
      "nombre": nombre,
      "username": username,
      "pass": hashHex,
      "salt": saltHex,
      "director": _esDirector,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profesor añadido correctamente")),
    );

    _nombreController.clear();
    _usernameController.clear();
    _passwordController.clear();
    setState(() {
      _esDirector = false;
    });

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldComunV2(
      titulo: "Añadir profesor",
      cuerpo: SingleChildScrollView(
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
              obscureText: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nombre completo',
              ),
            ),
            const SizedBox(height: 10),

            // Introducir Nombre de Usuario
            const Text(
              "Nombre de Usuario",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              obscureText: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nombre de usuario',
              ),
            ),
            const SizedBox(height: 10),

            // Introducir Contraseña
            const Text(
              "Contraseña",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contraseña segura',
              ),
            ),
            const SizedBox(height: 20),

            // Checkbox para director
            Row(
              children: [
                Checkbox(
                  value: _esDirector,
                  onChanged: (v) => setState(() => _esDirector = v ?? false),
                ),
                const Text("¿Es Director?", style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 100),

            // Boton para añadir al profesor
            SizedBox(
              width: double.infinity,
              child: BotonSinIcono(
                texto: "Añadir profesor",
                onPressed: agregarProfesor,
                horiPadding: 24,
                vertPadding: 14,
                fontSize: 18,
                radius: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
