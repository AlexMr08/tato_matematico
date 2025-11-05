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
        title: const Text(
            "Añadir Profesor",
            style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(234, 221, 255, 1),
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
              decoration: InputDecoration(
                hintText: "Nombre",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                )
              ),
            ),
            const SizedBox(height: 10,),

            // Introducir Nombre de Usuario
            const Text(
              "Nombre de Usuario",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: "Nombre de Usuario",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                )
              )
            ),
            const SizedBox(height: 10),

            // Introducir Contraseña
            const Text(
              "Contraseña",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Introduce contraseña segura",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20,),

            // Checkbox para director
            Row(
              children: [
                Checkbox(
                    value: _esDirector,
                    onChanged: (v) => setState(() => _esDirector = v ?? false),
                ),
                const Text(
                  "¿Es Director?",
                  style: TextStyle(fontSize: 16),
                )
              ]
            ),
            const SizedBox(height: 100,),

            // Boton para añadir al profesor
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: agregarProfesor,
                child: const Text(
                  "Añadir Profesor",
                  style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(121, 100, 174, 1)
                  )
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}