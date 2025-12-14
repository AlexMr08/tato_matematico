import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';
import 'package:tato_matematico/datos/profesor.dart';

/// **Nombre de la Clase: `ProfesorEditarContrasena`**
///
/// **Descripción:** clase que permite cambiar la contraseña de un profesor.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Gonzalo Alganza Luque
/// * **Fecha de modificación:** 13/12/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///

class ProfesorEditarContrasena extends StatefulWidget {
  final Profesor profesor;
  const ProfesorEditarContrasena({super.key, required this.profesor});
  @override
  State<ProfesorEditarContrasena> createState() =>
      _ProfesorEditarContrasenaState();
}

/*
  Se han hecho pruebas unitarias para asegurar que funciona correctamente:
  - Si no se introduce contrasena ni confirmar, no se cambia
  - Si se introduce contrasena pero no confirmar, no se cambia
  - Si se introduce confirmar pero no contrasena, no se cambia
  - Si se introducen contrasena y confirmar diferentes, no se cambia
  - Si se introducen contrasena y confirmar iguales, se cambia
   */

class _ProfesorEditarContrasenaState extends State<ProfesorEditarContrasena> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Función para autenticar al profesor en la base de datos
  void actualizarContrasena(
    String password1,
    String password2,
    String id,
  ) async {
    // Validar que los campos no estén vacíos
    if (password1.isEmpty) {
      snackBarAviso(context, "La contraseña no puede estar vacia");
    } else if (password1 != password2) {
      snackBarAviso(context, "Las contraseñas no coinciden");
    } else {
      // Buscar el profesor en la base de datos por su id
      var dbref = FirebaseDatabase.instance
          .ref()
          .child("tato")
          .child("profesorado")
          .child(widget.profesor.id);
      DatabaseEvent event = await dbref.once();

      Map data = event.snapshot.value as Map;

      var hashHex = await _generarHash(data["salt"], password1);

      await dbref
          .update({"pass": hashHex})
          .then((_) {
        setState(() {
          snackBarExito(context, "Contraseña actualizada correctamente");
          Navigator.pop(context);
        });
      })
          .catchError((error) {
        setState(() {
          snackBarError(context, "Error al actualizar la contraseña: $error");
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldComunV2(
      titulo: 'Cambiar contraseña',
      subtitulo: widget.profesor.username,
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

                const SizedBox(height: 32),

                Center(
                  child: SizedBox(
                    width: 500,
                    child: TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Nueva contraseña',
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
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Repetir nueva contraseña',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: BotonSinIcono(
                    texto: "Cambiar contraseña",
                    onPressed: () {
                      String username = usernameController.text.trim();
                      String password = passwordController.text.trim();
                      actualizarContrasena(
                        username,
                        password,
                        widget.profesor.id,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _generarHash(salt, password) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 10000, // Estándar recomendado mínimo hoy en día
      bits: 256, // 32 bytes de salida
    );

    String saltHex = salt;
    List<int> saltBytes = [];
    for (int i = 0; i < saltHex.length; i += 2) {
      String hexByte = saltHex.substring(i, i + 2);
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
