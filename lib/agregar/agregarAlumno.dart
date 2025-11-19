import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AgregarAlumno extends StatefulWidget {
  const AgregarAlumno({super.key});

  @override
  State<AgregarAlumno> createState() => _AgregarAlumnoState();
}

class _AgregarAlumnoState extends State<AgregarAlumno> {
  final _nombreController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> agregarAlumno() async {
    final nombre = _nombreController.text.trim();
    final password = _passwordController.text.trim();

    if (nombre.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    final dbRef = FirebaseDatabase.instance
        .ref()
        .child("tato")
        .child("alumnos");

    await dbRef.push().set({"nombre": nombre, "pass": password});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Alumno añadido correctamente")),
    );

    _nombreController.clear();
    _passwordController.clear();

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Añadir Alumno"),
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
                labelText: 'Introduce contraseña segura',
              ),
            ),
            const SizedBox(height: 20),

            // Boton para añadir al alumno
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
                onPressed: agregarAlumno,
                child: const Text(
                  "Añadir Alumno",
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
