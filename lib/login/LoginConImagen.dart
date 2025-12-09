import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/login/loginImagenService.dart';
import 'package:tato_matematico/pictograma.dart';
import 'package:tato_matematico/edicion/imagenStorage.dart';
import 'package:tato_matematico/gamesMenu.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/datos/alumno.dart';

//Parte del codigo se ha hecho con asistencia de IA

class LoginConImagen extends StatefulWidget {
  final String alumnoId;

  const LoginConImagen({super.key, required this.alumnoId});

  @override
  State<LoginConImagen> createState() => _LoginConImagenState();
}

class _LoginConImagenState extends State<LoginConImagen> {
  final _service = LoginImagenService();
  final db = FirebaseDatabase.instance.ref();

  bool cargando = true;
  List<Pictograma> imagenesMostradas = [];

  String? _idCorrecta;
  String? _idSeleccionada;

  @override
  void initState() {
    super.initState();
    _iniciarLogin();
  }

  Future<void> _iniciarLogin() async {
    try {
      // 1. LEER CONFIGURACIÓN (Esto es específico de cada tipo de login)
      final snap = await db
          .child("tato/login/${widget.alumnoId}/seleccionImagen")
          .get();

      if (!snap.exists) {
        setState(() => cargando = false);
        return;
      }

      final data = Map<String, dynamic>.from(snap.value as Map);

      _idCorrecta = data["idImagenCorrecta"]?.toString();
      int total = int.tryParse("${data["totalImagenes"]}") ?? 6;
      bool aleatorio = data["distractorasAleatorias"]?.toString().toLowerCase() == 'true';

      List<String> manuales = [];
      if (data["imagenesDistractoras"] is Map) {
        manuales = (data["imagenesDistractoras"] as Map).keys.map((k) => k.toString()).toList();
      }

      // 2. PEDIR GRID AL SERVICIO (Aquí nos ahorramos 80 líneas de código)
      if (_idCorrecta != null) {
        imagenesMostradas = await _service.generarGrid(
            idsCorrectos: [_idCorrecta!], // Lo pasamos como lista
            idsDistractoresManuales: manuales,
            totalImagenes: total,
            esAleatorio: aleatorio
        );
      }

    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void _intentarLogin() {
    if (_idSeleccionada == null) return;

    // Recuperamos el nombre del alumno para el mensaje
    final alumnoHolder = context.read<AlumnoHolder>();
    String nombreAlumno = alumnoHolder.alumno?.nombre ?? "Alumno";

    if (_idSeleccionada == _idCorrecta) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("¡Bienvenido $nombreAlumno!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GamesMenu()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Contraseña incorrecta, inténtalo de nuevo"),
          backgroundColor: Colors.red,
        ),
      );
      // Opcional: Quitar selección tras error
      setState(() => _idSeleccionada = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alumnoHolder = context.watch<AlumnoHolder>();
    final Alumno? alumno = alumnoHolder.alumno;
    final colorScheme = Theme.of(context).colorScheme;

    if (alumno == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // --- LÓGICA DEL GRID 2xN ---
    // Calculamos las columnas para que siempre sean 2 filas aprox.
    int columnas = 3; // Valor por defecto (2x3)
    if (imagenesMostradas.length == 4) columnas = 2; // (2x2)
    if (imagenesMostradas.length == 8) columnas = 4; // (2x4)
    if (imagenesMostradas.length > 8) columnas = 4;  // Fallback para más grandes

    // Ajustamos el ancho máximo de la caja según las columnas para que no queden huecos gigantes
    double maxWidth = columnas * 180.0;

    return ScaffoldComunV2(
      titulo: "Incio de sesión por Imagen",
      cuerpo: cargando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const SizedBox(height: 20),

                  // 1. INSTRUCCIÓN (Ahora es lo primero)
                  Text(
                    "Elige la imagen que es tu contraseña",
                    style: TextStyle(
                      fontSize: 24, // Un poco más grande para destacar
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // 2. GRID DE IMÁGENES
                  if (imagenesMostradas.isEmpty)
                    const Text("No se pudieron cargar las imágenes")
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnas,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: imagenesMostradas.length,
                      itemBuilder: (context, index) {
                        final picto = imagenesMostradas[index];
                        final bool isSelected = _idSeleccionada == picto.id;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_idSeleccionada == picto.id) {
                                _idSeleccionada = null;
                              } else {
                                _idSeleccionada = picto.id;
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? colorScheme.primary : Colors.grey.shade300,
                                width: isSelected ? 5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                                  : [],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ImagenStorage(
                                  rutaGs: picto.url,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 40),

                  // 3. BOTÓN ENTRAR
                  SizedBox(
                    width: 300,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _idSeleccionada == null ? null : _intentarLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text("Entrar"),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}