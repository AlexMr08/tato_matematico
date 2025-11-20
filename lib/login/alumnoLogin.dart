import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/alumno.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/gamesMenu.dart';
import 'dart:io';
import 'package:tato_matematico/holders/alumnoHolder.dart';

class AlumnoLogIn extends StatefulWidget {
  const AlumnoLogIn({super.key});
  @override
  State<AlumnoLogIn> createState() => _AlumnoLogInState();
}

class _AlumnoLogInState extends State<AlumnoLogIn> {
  late Alumno alumno;
  final TextEditingController passwordController = TextEditingController();

  // Función para autenticar al profesor en la base de datos
  void autenticacionAlumno(String id, String password) async {
    // Validar que los campos no estén vacíos
    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ingrese contraseña")));
      return;
    }

    // Buscar el alumno en la base de datos por su id
    var dbref = FirebaseDatabase.instance
        .ref()
        .child("tato")
        .child("alumnos")
        .child(id);

    DatabaseEvent event = await dbref.once();

    if (event.snapshot.exists) {
      var data = event.snapshot.value;
      print("Alumno encontrado: $data");
    } else {
      print("No existe un alumno con ese id");
    }

    Map alumnoData = event.snapshot.value as Map;

    // Verificar la contraseña
    if (alumnoData["pass"] == password) {
      print("Ha iniciado sesion correctamente");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Ha iniciado sesion correctamente ${alumnoData['nombre']}",
          ),
          backgroundColor: Colors.green,
        ),
      );
      navegar(GamesMenu(), context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Contraseña incorrecta")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final alumnoHolder = context.watch<AlumnoHolder>();
    final navigator = Navigator.of(context);

    //Seccion hecha con chatgpt
    if (alumnoHolder.alumno == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigator.canPop()) navigator.pop();
      });
      return const SizedBox.shrink();
    }
    //Fin seccion hecha con chatgpt
    alumno = alumnoHolder.alumno!;

    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? InkWell(
                child: const Icon(Icons.arrow_back),
                onTap: () => {Navigator.pop(context)},
              )
            : const Icon(Icons.menu),
        title: const Text(
          'Inicio de sesion de Alumno',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        actions: [Padding(padding: const EdgeInsets.only(right: 16))],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    alumno.nombre,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double size = 150; // Tamaño fijo del avatar en login
                      ImageProvider? imageProvider;
                      if (alumno.imagenLocal.isNotEmpty) {
                        imageProvider = FileImage(File(alumno.imagenLocal));
                      }
                      return SizedBox(
                        width: size,
                        height: size,
                        child: CircleAvatar(
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? Text(
                                  alumno.nombre.isNotEmpty
                                      ? alumno.nombre[0]
                                      : '?',
                                  style: TextStyle(fontSize: size * 0.4),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer,
                      ),
                      onPressed: () {
                        String password = passwordController.text.trim();
                        autenticacionAlumno(alumno.id, password);
                      },
                      child: const Text('Entrar'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
