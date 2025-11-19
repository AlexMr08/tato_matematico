import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tato_matematico/ScaffoldComun.dart';
import 'package:tato_matematico/alumno.dart';

class ConfigAlfanumericaScreen extends StatefulWidget {
  final Alumno alumno;

  const ConfigAlfanumericaScreen({super.key, required this.alumno});

  @override
  State<ConfigAlfanumericaScreen> createState() =>
      _ConfigAlfanumericaScreenState();
}

class _ConfigAlfanumericaScreenState extends State<ConfigAlfanumericaScreen> {
  // Controladores para el formulario de contraseña
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Referencia a firebase
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Ocultar contraseña
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Metodo para encriptar la contraseña con SHA256
  String _generarHash(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Metodo para guardar la nueva contraseña haciendo validaciones
  Future<void> _guardarConfiguracion() async {
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Hacemos validaciones de los campos
    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña no puede estar vacía')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Generamos el hash de la contraseña
      String passwordHash = _generarHash(password);

      // Preparamos los datos a guardar en firebase
      Map<String, dynamic> loginConfig = {
        "tipoLogin": "alfanumerica",
        "alfanumerica": {"hash": passwordHash},
        // Desabilitamos los otros tipos de contraseñas
        "seleccionImagenes": null,
        "secuenciaImagenes": null,
      };

      // Guardamos la configuracion en firebase
      await _dbRef
          .child('tato')
          .child('login')
          .child(widget.alumno.id)
          .set(loginConfig); // Con set sobreescribimos login previo

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Configuracion guardada')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaffoldComun(
      titulo: widget.alumno.nombre,
      subtitulo: "Contraseña Alfanumérica",
      funcionSalir: () => Navigator.pop(context),
      cuerpo: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar del alumno
                CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: widget.alumno.cachedImage,
                  child: widget.alumno.cachedImage == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                const SizedBox(height: 40),

                // Campo Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Nueva Contraseña",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo Repetir Contraseña
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  decoration: const InputDecoration(
                    labelText: "Repetir Contraseña",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_reset),
                  ),
                ),
                const SizedBox(height: 40),

                // Botón Guardar
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _guardarConfiguracion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("GUARDAR CAMBIOS"),
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
