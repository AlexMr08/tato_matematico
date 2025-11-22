import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tato_matematico/ScaffoldComun.dart';
import 'package:cryptography/cryptography.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ese nombre de usuario ya existe")),
      );
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
    return ScaffoldComun(
      titulo: "Añadir profesor",
      funcionSalir: () => {Navigator.pop(context)},
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: agregarProfesor,
                child: const Text(
                  "Añadir Profesor",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
