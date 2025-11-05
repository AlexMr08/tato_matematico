import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tato_matematico/agregarProfesor.dart';

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
      context.read<ProfesorHolder>().setProfesor(
        Profesor.fromMap(profesorId, Map<dynamic, dynamic>.from(profesorData)),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PruebaProfe()),
      );
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
                        backgroundColor: const Color(0xFF6750A4),
                        foregroundColor: Colors.white,
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
