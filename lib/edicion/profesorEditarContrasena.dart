import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../ScaffoldComun.dart';
import '../holders/profesorHolder.dart';
import 'package:tato_matematico/datos/profesor.dart';
import '../mainMenuProfe.dart';

class ProfesorEditarContrasena extends StatefulWidget {
  final Profesor profesor;
  const ProfesorEditarContrasena({super.key, required this.profesor});
  @override
  State<ProfesorEditarContrasena> createState() => _ProfesorEditarContrasenaState();
}

class _ProfesorEditarContrasenaState extends State<ProfesorEditarContrasena> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _logo = const AssetImage("assets/images/logo.webp");

  // Función para autenticar al profesor en la base de datos
  void actualizarContrasena(String password1, String password2, String id) async {
    // Validar que los campos no estén vacíos
    if (password1.isEmpty || password2.isEmpty || password1 != password2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    // Buscar el profesor en la base de datos por su id
    var dbref = FirebaseDatabase.instance
        .ref()
        .child("tato")
        .child("profesorado").child(widget.profesor.id);
    DatabaseEvent event = await dbref.once();

    Map data = event.snapshot.value as Map;

    var hashHex = await _generarHash(data["salt"], password1);

    await dbref.update({
      "pass": hashHex,
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldComun(
      titulo: 'Inicio de sesion del profesor',
      funcionSalir: Navigator.canPop(context)
          ? () => Navigator.pop(context)
          : null,
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

                const SizedBox(height: 20),

                Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        String username = usernameController.text.trim();
                        String password = passwordController.text.trim();
                        actualizarContrasena(username, password, widget.profesor.id);
                      },
                      child: const Text('Cambiar contraseña'),
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

    final nonce = await SecretKey(saltBytes);

    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: await nonce.extractBytes(),
    );

    final hashBytes = await secretKey.extractBytes();

    final hashHex = hashBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    return hashHex;
  }

}
