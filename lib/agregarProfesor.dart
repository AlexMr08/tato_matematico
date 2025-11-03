import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
    final snapshot = await dbRef.orderByChild("username").equalTo(username).once();
    if (snapshot.snapshot.value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ese nombre de usuario ya existe")),
      );
      return;
    }

    await dbRef.push().set({
      "nombre": nombre,
      "username": username,
      "pass": password,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Añadir Profesor"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: "Nombre completo"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Nombre de usuario"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _esDirector,
                  onChanged: (v) => setState(() => _esDirector = v ?? false),
                ),
                const Text("¿Es director?"),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: agregarProfesor,
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}