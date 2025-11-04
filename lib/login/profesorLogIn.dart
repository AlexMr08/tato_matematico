import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tato_matematico/agregarProfesor.dart';
import 'package:tato_matematico/pruebaProfe.dart';

class ProfesorLogIn extends StatefulWidget {
  const ProfesorLogIn({super.key});
  @override
  State<ProfesorLogIn> createState() => _ProfesorLogInState();
}

class _ProfesorLogInState extends State<ProfesorLogIn> {
  int selectedTab = 0;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
          content: Text(profesorData["director"] ?  "Ha iniciado sesion correctamente, rol: Director" : "Ha iniciado sesion correctamente, rol: Profesor"),
          backgroundColor: Colors.green,
        ),
      );
      if (profesorData["director"]) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PruebaProfe(),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Contraseña incorrecta")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? InkWell(
                child: const Icon(Icons.arrow_back),
                onTap: () => {Navigator.pop(context)},
              )
            : const Icon(Icons.menu),
        title: const Text(
          'Inicio de sesion del profesor',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        actions: [Padding(padding: const EdgeInsets.only(right: 16))],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Log In del profesor',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),

              // Campo de texto para el nombre de usuario
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de texto para la contraseña
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // Botón de "Iniciar sesión"
              ElevatedButton(
                onPressed: () {
                  String username = usernameController.text.trim();
                  String password = passwordController.text.trim();
                  autenticacionProfesor(username, password);
                },
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
