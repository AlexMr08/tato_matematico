import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/login/loginImagenService.dart';
import 'package:tato_matematico/datos/pictograma.dart';
import 'package:tato_matematico/edicion/imagenStorage.dart';
import 'package:tato_matematico/gamesMenu.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldComunV2.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/widgetsAuxiliares/loginStatusCard.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';

/// **Metadatos de Control:**
/// * **Autor Original:** Joaquin Salas Castillo / Gonzalo Alganza Luque
/// * **Última modificación por:** Gonzalo Alganza Luque
/// * **Fecha de modificación:** 13/12/2025
/// * **Último cambio:** Cambios de Calidad
///
/// Pantalla de inicio de sesión mediante la selección de una imagen.
///
/// En esta pantalla se muestra un grid de imágenes y el alumno debe pulsar
/// la imagen correcta para acceder a los juegos.
///
/// Se utiliza [LoginImagenService] para generar el grid de imágenes.
class alumnoLoginImagen extends StatefulWidget {
  final String alumnoId;

  const alumnoLoginImagen({super.key, required this.alumnoId});

  @override
  State<alumnoLoginImagen> createState() => _alumnoLoginImagenState();
}

class _alumnoLoginImagenState extends State<alumnoLoginImagen> {
  final _service = LoginImagenService();
  final db = FirebaseDatabase.instance.ref();

  bool cargando = true;
  List<Pictograma> imagenesMostradas = [];

  String? _idCorrecta;
  String? _idSeleccionada;

  EstadoLogin _estado = EstadoLogin.normal;

  @override
  void initState() {
    super.initState();
    _iniciarLogin();
  }

  /// Carga la configuración de login de seleccion de imagen desde Firebase.
  ///
  /// Recupera:
  /// 1. La imagen correcta.
  /// 2. Configuración del grid (total de imágenes, modo aleatorio).
  /// 3. Distractores manuales (si existen).
  ///
  /// Se delega la generación del grid a [_service].
  Future<void> _iniciarLogin() async {
    try {
      final snap = await db
          .child("tato/login/${widget.alumnoId}/seleccionImagen")
          .get();

      if (!snap.exists) {
        setState(() => cargando = false);
        return;
      }

      final data = Map<String, dynamic>.from(snap.value as Map);

      // Obtenemos la correcta, el total de imágenes y aleatorio
      _idCorrecta = data["idImagenCorrecta"]?.toString();
      int total = int.tryParse("${data["totalImagenes"]}") ?? 6;
      bool aleatorio = data["distractorasAleatorias"]?.toString().toLowerCase() == 'true';

      List<String> manuales = [];
      if (data["imagenesDistractoras"] is Map) {
        manuales = (data["imagenesDistractoras"] as Map).keys.map((k) => k.toString()).toList();
      }

      // Delegar la generación del grid al servicio
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

  /// Manejo de interacción al tocar una imagen.
  ///
  /// Se resetea al estado normal [EstadoLogin.normal] si había error.
  /// Se realiza un toggle para la selección de la imagen.
  void _onImagenTap(String id) {
    if (_estado != EstadoLogin.normal) {
      setState(() => _estado = EstadoLogin.normal);
    }

    setState(() {
      if (_idSeleccionada == id) {
        _idSeleccionada = null;
      } else {
        _idSeleccionada = id;   // Seleccionar nueva
      }
    });
  }

  /// Compara la imagen seleccionada con la correcta
  ///
  /// Si se selecciona correcta, se navega al menú de juegos y se muestra feedback.
  /// Si se selecciona incorrecta, se deselecciona la imagen y se muestra feedback.
  void _intentarLogin() {
    if (_idSeleccionada != null) {
      if (_idSeleccionada == _idCorrecta) {
        // ÉXITO
        setState(() => _estado = EstadoLogin.exito);

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GamesMenu()),
            );
          }
        });
      }
      else {
        // ERROR
        setState(() {
          _estado = EstadoLogin.error;
          _idSeleccionada = null;
        });
      }
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

                  const SizedBox(height: 10),

                  // TARJETA DE ESTADO DEL LOGIN
                  LoginStatusCard(
                    estado: _estado,
                    mensajeNormal: "Elige la imagen correcta.",
                    mensajeError: "Intentalo de nuevo.",
                  ),

                  const SizedBox(height: 30),

                  // GRID DE IMÁGENES
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
                            _onImagenTap(picto.id);
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
                                  color: colorScheme.primary.withValues(alpha: 0.3),
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

                  // BOTÓN ENTRAR
                  SizedBox(
                    height: 50,
                    width: 350,
                    child: BotonConIcono(
                        icono: Icons.login_rounded,
                        texto: "ENTRAR",
                        fontSize: 20,
                        radio: 27,
                        onPressed: _idSeleccionada == null ? null : _intentarLogin,
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