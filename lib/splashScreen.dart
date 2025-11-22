import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/holders/alumnosHolder.dart';
import 'package:tato_matematico/holders/clasesHolder.dart';
import 'package:tato_matematico/login/seleccionClase.dart'; // O tu pantalla principal real

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Opcional: Forzar un tiempo mínimo de splash para que no sea un parpadeo feo
    // si el internet es muy rápido.
  }

  @override
  Widget build(BuildContext context) {
    // 1. Escuchamos el estado de carga de los holders
    final clasesHolder = context.watch<ClasesHolder>();
    final alumnosHolder = context.watch<AlumnosHolder>();

    // final alumnoHolder = context.watch<AlumnoHolder>(); // Descomenta si también quieres esperar a los alumnos

    // 2. Verificamos si siguen cargando
    bool cargando = clasesHolder.isLoading && alumnosHolder.isLoading;
    // bool cargando = clasesHolder.isLoading || alumnoHolder.isLoading;

    // 3. Si ya terminaron, navegamos a la pantalla principal
    // Usamos addPostFrameCallback para evitar navegar durante el build
    if (!cargando) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Navegar reemplazando para que no puedan volver al Splash
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => SeleccionClase()), // Tu pantalla inicial real
        );
      });
    }

    // 4. Diseño de la pantalla de carga
    return Scaffold(
      backgroundColor: Colors.white, // O el color de tu marca
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tu logo
            Image.asset(
              'assets/images/logo.webp', // Asegúrate de tener esta imagen
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 30),
            // Indicador de carga
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              "Cargando contenido...",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey
              ),
            ),
          ],
        ),
      ),
    );
  }
}
