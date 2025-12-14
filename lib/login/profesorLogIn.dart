import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';
import '../holders/profesorHolder.dart';
import 'package:tato_matematico/datos/profesor.dart';
import '../mainMenuProfe.dart';

/// **Nombre de la Clase: `ProfesorLogIn`**
///
/// **Descripción:** Clase que permite iniciar sesion a los profesores.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** ?
/// * **Última modificación por:** Gonzalo Alganza Luque
/// * **Fecha de modificación:** 13/12/2025
/// * **Último cambio:** Se ha mejorado la navegacion por el formulario
///

class ProfesorLogIn extends StatefulWidget {
  const ProfesorLogIn({super.key});
  @override
  State<ProfesorLogIn> createState() => _ProfesorLogInState();
}

class _ProfesorLogInState extends State<ProfesorLogIn> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /*
  Se han hecho pruebas unitarias para asegurar que funciona correctamente:
  - Si no se introduce usuario ni contrasena, no inicia sesion
  - Si no se introduce contrasena y el usuario no es correcto, no inicia sesion
  - Si no se introduce contrasena y el usuario es correcto, no inicia sesion
  - Si se introduce contrasena y no usuario, no se inicia sesion
  - Si se introducen usuario y contrasena incorrectas, no se inicia sesion
  - Si se introducen usuario correcto y contrasena incorrecta, avisa de que
    la contrasena no es correcta y no se inica sesion
  - Si se introduce usuario incorrecto y una contrasena, se avisa de que el
    usuario no existe y no se inicia sesion
  - Si se introducen usuario y contrasena correctos, se inicia sesion
    correctamente
   */

  // Función para autenticar al profesor en la base de datos
  void autenticacionProfesor(String username, String password) async {
    // Validar que los campos no estén vacíos
    if (username.isEmpty || password.isEmpty) {
      snackBarAviso(context, "Ingrese nombre de usuario y contraseña");
    } else {
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
        if (mounted) {
          snackBarAviso(context, "Usuario no registrado");
        }
      } else {
        Map data = event.snapshot.value as Map;
        var profesorId = data.keys.first;
        var profesorData = data[profesorId];

        var hashHex = await _generarHash(profesorData["salt"], password);
        // Verificar la contraseña
        if (profesorData["pass"] == hashHex) {
          if (mounted) {
            snackBarExito(
              context,
              profesorData["director"]
                  ? "Ha iniciado sesion correctamente, rol: Director"
                  : "Ha iniciado sesion correctamente, rol: Profesor",
            );
            context.read<ProfesorHolder>().setProfesor(
              Profesor.fromMap(
                profesorId,
                Map<dynamic, dynamic>.from(profesorData),
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainMenuProfe()),
            );
          }
        } else {
          if (mounted) {
            snackBarAviso(context, "Contraseña incorrecta");
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final FocusNode passFocus = FocusNode();
    return ScaffoldComunV2(
      titulo: 'Inicio de sesion del profesor',
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

                Center(
                  child: SizedBox(
                    width: 500,
                    child: TextField(
                      controller: usernameController,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) {
                        FocusScope.of(context).requestFocus(passFocus);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Nombre de usuario',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: SizedBox(
                    width: 500,
                    child: TextField(
                      controller: passwordController,
                      focusNode: passFocus,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        String username = usernameController.text.trim();
                        String password = passwordController.text.trim();
                        autenticacionProfesor(username, password);
                      },
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: SizedBox(
                    width: 150,
                    child: BotonSinIcono(
                      texto: "Iniciar sesión",
                      onPressed: () {
                        String username = usernameController.text.trim();
                        String password = passwordController.text.trim();
                        autenticacionProfesor(username, password);
                      },
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

  Future<String?> _generarHash(String salt, String password) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 10000, // Estándar recomendado mínimo hoy en día
      bits: 256, // 32 bytes de salida
    );

    List<int> saltBytes = [];
    for (int i = 0; i < salt.length; i += 2) {
      String hexByte = salt.substring(i, i + 2);
      saltBytes.add(int.parse(hexByte, radix: 16));
    }

    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: await SecretKey(saltBytes).extractBytes(),
    );

    final hashBytes = await secretKey.extractBytes();

    final hashHex = hashBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    return hashHex;
  }
}
