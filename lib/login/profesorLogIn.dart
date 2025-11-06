import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../ScaffoldComun.dart';
import '../holders/profesorHolder.dart';
import '../profesor.dart';
import '../mainMenuProfe.dart';

class ProfesorLogIn extends StatefulWidget {
  const ProfesorLogIn({super.key});
  @override
  State<ProfesorLogIn> createState() => _ProfesorLogInState();
}

class _ProfesorLogInState extends State<ProfesorLogIn> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _logo = const AssetImage("assets/images/logo.webp");

  // Función para autenticar al profesor en la base de datos
  void autenticacionProfesor(String username, String password) async {
    // Validar que los campos no estén vacíos
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingrese nombre de usuario y contraseña")),
      );
      return;
    }

    // Buscar el profesor en la base de datos por nombre de usuario
    var dbref = FirebaseDatabase.instance
        .ref()
        .child("tato")
        .child("profesorado");
    DatabaseEvent event = await dbref
        .orderByChild("username")
        .equalTo(username)
        .once();

    // Si el profesor no existe, mostrar mensaje de error
    if (event.snapshot.value == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Usuario no registrado")));
      return;
    }

    Map data = event.snapshot.value as Map;
    var profesorId = data.keys.first;
    var profesorData = data[profesorId];

    // Verificar la contraseña
    if (profesorData["pass"] == password) {
      print("Ha iniciado sesion correctamente");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            profesorData["director"]
                ? "Ha iniciado sesion correctamente, rol: Director"
                : "Ha iniciado sesion correctamente, rol: Profesor",
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.read<ProfesorHolder>().setProfesor(
        Profesor.fromMap(profesorId, Map<dynamic, dynamic>.from(profesorData)),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainMenuProfe()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Contraseña incorrecta")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldComun(
      titulo: 'Inicio de sesion del profesor',
      funcionSalir: Navigator.canPop(context) ? () => Navigator.pop(context) : null,
      fab: null,
      navBar: null,
      cuerpo: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),

                Center(
                  child: Container(
                    height: 350,
                    width: 350,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/logo.webp"),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

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
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        String username = usernameController.text.trim();
                        String password = passwordController.text.trim();
                        autenticacionProfesor(username, password);
                      },
                      child: const Text('Iniciar sesión'),
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
