import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/holders/alumnosHolder.dart';
import 'package:tato_matematico/holders/clasesHolder.dart';
import 'package:tato_matematico/login/seleccionClase.dart';

/// **Nombre de la Clase: `SplashScreen`**
///
/// **Descripción:** Clase que se encarga de mostrar una pantalla de bienvenida mientras se cargan los datos iniciales de la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Pequeños cambios en como se maneja la carga
///

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Escuchamos el estado de carga de los holders
    final clasesHolder = context.watch<ClasesHolder>();
    final alumnosHolder = context.watch<AlumnosHolder>();

    // 2. Verificamos si siguen cargando
    bool cargando = clasesHolder.isLoading || alumnosHolder.isLoading;

    // 3. Si ya terminaron, navegamos a la pantalla principal
    if (!cargando) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => SeleccionClase()));
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
            Image.asset('assets/images/logo2.png', width: 200, height: 200),
            const SizedBox(height: 30),
            // Indicador de carga
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              "Cargando contenido...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
