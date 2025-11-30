import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/configColorProfesor.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/edicion/configAlfanumerica.dart';
import 'package:tato_matematico/edicion/configImagenUnica.dart';
import 'package:tato_matematico/edicion/configSecuencia.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';

/// **Nombre de la Clase: `EditarAlumno`**
///
/// **Descripción:** clase que permite editar los datos de un alumno.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Joaquin Salas Castillo / Gonzalo Alganza Luque
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///

class EditarAlumno extends StatefulWidget {
  const EditarAlumno({super.key});

  @override
  State<EditarAlumno> createState() => _EditarAlumnoState();
}

/*
  Se han hecho pruebas unitarias para asegurar que funciona correctamente:
  - Se ha cambiado el nombre sin problema, actualizandose en la base de datos
  - Si no se edita el nombre, no se actualiza
  - El cambio de contrasena alfanumerica funciona correctamente
  - Se han probado todas las posiciones de la barra, y funcionan correctamente
  - Se ha probado el cambio de color de un alumno en concreto y
    se ha guardado y reflejeado correctamente.
  - Se ha cambiado la imagen de perfil.

  Queda pendiente:
  - Probar configurar contrasenas imagen y secuencia imagen
   */

class _EditarAlumnoState extends State<EditarAlumno> {
  String tipoPassword = "alfanumerica";
  int posicionBarra = 0;
  late final TextEditingController _nombreController;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Estado para controlar el modo de edicion
  bool _isEditingName = false;
  bool _isControllerInitialized = false;

  // Mostrar carga si se esta cargando la imagen de perfil
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isControllerInitialized) {
      final alumno = Provider.of<AlumnoHolder>(context, listen: false).alumno;
      _nombreController = TextEditingController(text: alumno?.nombre ?? '');
      if (alumno != null) {
        posicionBarra = alumno.posicionBarra ?? 0;
      }
      _isControllerInitialized = true;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _irAConfiguracion(BuildContext context, Alumno alumno) {
    Widget pantallaDestino;

    switch (tipoPassword) {
      case "alfanumerica":
        pantallaDestino = ConfigAlfanumericaScreen(alumno: alumno);
        break;
      case "seleccion_imagen":
        pantallaDestino = ConfigImagenUnicaScreen(alumno: alumno);
        break;
      case "secuencia_imagen":
        pantallaDestino = ConfigSecuenciaScreen(alumno: alumno);
        break;
      default:
        return;
    }
    navegar(pantallaDestino, context);
  }

  void _guardarNombre(Alumno alumno) async {
    final nuevoNombre = _nombreController.text.trim();
    if (nuevoNombre.isEmpty) {
      snackBarAviso(context, 'El nombre no puede estar vacío.');
      return;
    }
    if (nuevoNombre == alumno.nombre) {
      // Si no hay cambios, simplemente salimos del modo edición.
      setState(() => _isEditingName = false);
      return;
    }
    try {
      // Actualizamos la base de datos
      await _dbRef.child('tato/alumnos/${alumno.id}').update({
        'nombre': nuevoNombre,
      });

      // Actualizamos el estado local
      alumno.nombre = nuevoNombre;
      context.read<AlumnoHolder>().setAlumno(alumno);

      snackBarExito(context, 'Nombre actualizado correctamente.');
    } catch (e) {
      snackBarError(context, 'Error al actualizar el nombre: $e');
    } finally {
      // Salimos del modo edición
      setState(() => _isEditingName = false);
    }
  }

  Future<void> _cambiarImagen(ImageSource source, Alumno alumno) async {
    try {
      final ImagePicker picker = ImagePicker();

      // Abrimos camara o galeria con optimizacion
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800, // Redimensionar 800px de ancho
        maxHeight: 800,
        imageQuality: 80, // Calidad JPEG al 80%
      );

      if (pickedFile == null) {
        return; // Si no se selecciono ninguna imagen, salimos
      }

      setState(() {
        _isUploadingImage = true;
      });

      File imageFile = File(pickedFile.path);

      // ---------------------------------------------------------
      // 1. Borrar imagen anterior si existe para no acumular basura
      // ---------------------------------------------------------
      if (alumno.imagen != null && alumno.imagen!.isNotEmpty) {
        try {
          // Intentamos borrar la imagen antigua del Storage.
          // refFromURL funciona con URLs gs:// y https://
          await FirebaseStorage.instance.refFromURL(alumno.imagen!).delete();
        } catch (e) {
          // Si falla (ej. no existe el archivo o no tiene permisos), solo logueamos y seguimos
          print(
            "No se pudo borrar la imagen anterior (quizás ya no existe): $e",
          );
        }
      }

      // ---------------------------------------------------------
      // 2. Subir nueva imagen
      // ---------------------------------------------------------
      // Usamos timestamp para que el nombre sea único y evitar problemas de caché en la nube y local
      String fileName =
          '${alumno.id}_${DateTime.now().millisecondsSinceEpoch}_perfil.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('alumnos/$fileName');

      await ref.putFile(imageFile);

      // Obtener ruta gs://
      String bucketName = FirebaseStorage.instance.bucket;
      String gsUrl = "gs://$bucketName/alumnos/$fileName";

      // 3. Actualizar Realtime Database
      await _dbRef.child('tato/alumnos/${alumno.id}').update({'imagen': gsUrl});

      // 4. Actualizar el objeto alumno
      alumno.imagen = gsUrl;
      alumno.imagenLocal = imageFile.path;

      // Limpiar cache (aunque el setter de imagen ya lo hace, no está de más si no se usó el setter)
      alumno.invalidarCachedImage();

      // 5. Notificar cambios
      if (mounted) {
        context.read<AlumnoHolder>().setAlumno(alumno);
        snackBarExito(context, 'Imagen actualizada correctamente.');
      }
    } catch (e) {
      print("Error subiendo imagen: $e");
      if (mounted) {
        snackBarError(context, "Error al subir imagen: $e");
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _mostrarMenuOrigen(BuildContext context, Alumno alumno) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Galería'),
                  onTap: () {
                    Navigator.of(context).pop(); // Cerrar menú
                    _cambiarImagen(ImageSource.gallery, alumno);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: colorScheme.primary),
                  title: const Text('Cámara'),
                  onTap: () {
                    Navigator.of(context).pop(); // Cerrar menú
                    _cambiarImagen(ImageSource.camera, alumno);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _guardarBarra(Alumno alumno) async {
    final nuevoValor = posicionBarra;

    // if (nuevoNombre == alumno.nombre) {
    //   // Si no hay cambios, simplemente salimos del modo edición.
    //   return;
    // }
    try {
      // Actualizamos la base de datos
      await _dbRef.child('tato/alumnos/${alumno.id}').update({
        'posicionBarra': nuevoValor,
      });

      // Actualizamos el estado local
      alumno.posicionBarra = nuevoValor;
      if (mounted) {
        context.read<AlumnoHolder>().setAlumno(alumno);
        snackBarExito(
          context,
          "Posicion de la barra actualizada correctamente.",
        );
      }
    } catch (e) {
      if (mounted) {
        snackBarError(
          context,
          "Error al actualizar la posicion de la barra: $e",
        );
      }
    }
  }

  // --- NUEVA FUNCIÓN PARA GUARDAR PERMISOS DEL JUEGO ---
  void _guardarPermisoJuego1(Alumno alumno, String permiso, bool valor) async {
    try {
      await _dbRef.child('tato/alumnos/${alumno.id}').update({permiso: valor});

      if (mounted) {
        // Actualizamos el estado local
        if (permiso == 'permisoAjustesJuego1') {
          alumno.permisoAjustesJuego1 = valor;
        } else if (permiso == 'permisoEstadisticasJuego1') {
          alumno.permisoEstadisticasJuego1 = valor;
        }
        context.read<AlumnoHolder>().setAlumno(alumno);
        snackBarExito(context, "Permiso actualizado.");
      }
    } catch (e) {
      if (mounted) {
        snackBarError(context, 'Error al guardar el permiso: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<AlumnoHolder>(
      builder: (context, alumnoHolder, child) {
        final Alumno? alumno = alumnoHolder.alumno;
        if (alumno == null) {
          // Si el alumno es nulo, mostramos un loader o un mensaje y evitamos errores.
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        var onPressed = _isUploadingImage
            ? null
            : () => _mostrarMenuOrigen(context, alumno);

        return ScaffoldComunV2(
          titulo: 'Editar Alumno',
          subtitulo: alumno.nombre,
          cuerpo: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------
                  //     BLOQUE IZQUIERDO
                  // ------------------------------
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        //AVATAR
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 80,
                              backgroundColor: colorScheme.primaryContainer,
                              // Usamos la imagen cacheada que definimos en alumno.dart
                              backgroundImage: alumno.cachedImage,
                              child: alumno.cachedImage == null
                                  ? Text(
                                      // Lógica para obtener inicial: Si no está vacío, coge la primera letra
                                      alumno.nombre.isNotEmpty
                                          ? alumno.nombre[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontSize: 64, // Tamaño grande
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    )
                                  : null,
                            ),
                            // Si se está subiendo la foto, mostramos el spinner encima
                            if (_isUploadingImage)
                              const CircularProgressIndicator(),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // NOMBRE
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40.0,
                                ),
                                child: Center(
                                  child: _isEditingName
                                      ? TextFormField(
                                          controller: _nombreController,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  vertical: 8,
                                                  horizontal: 4,
                                                ),
                                            border: OutlineInputBorder(),
                                          ),
                                          onFieldSubmitted: (_) =>
                                              _guardarNombre(alumno),
                                        )
                                      : Text(
                                          // Usamos el controlador para mostrar el nombre, asegurando consistencia
                                          _nombreController.text,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: BotonIcono(
                                  icono: _isEditingName
                                      ? Icons.save_alt_outlined
                                      : Icons.edit_outlined,
                                  onPressed: () {
                                    if (_isEditingName) {
                                      _guardarNombre(alumno);
                                    } else {
                                      setState(() {
                                        _isEditingName = true;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // BOTON CAMBIAR IMAGEN
                        BotonConIcono(
                          icono: Icons.cameraswitch_outlined,
                          texto: "Cambiar Imagen",
                          onPressed: onPressed,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  // ------------------------------
                  //       BLOQUE CENTRAL
                  // ------------------------------
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Tipo de Contraseña",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: DropdownButtonFormField<String>(
                            initialValue: tipoPassword,
                            items: const [
                              DropdownMenuItem(
                                value: "alfanumerica",
                                child: Text("Contraseña Alfanumérica"),
                              ),
                              DropdownMenuItem(
                                value: "seleccion_imagen",
                                child: Text("Selección de imagen"),
                              ),
                              DropdownMenuItem(
                                value: "secuencia_imagen",
                                child: Text("Secuencia de imágenes"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => tipoPassword = value!);
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Tipo de contraseña",
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: BotonConIcono(
                            icono: Icons.arrow_forward_ios,
                            radio: 16,
                            iconAlignment: IconAlignment.end,
                            fontSize: 18,
                            texto: "Configurar contraseña",
                            onPressed: () => _irAConfiguracion(context, alumno),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  // ------------------------------
                  //     BLOQUE DERECHO
                  // ------------------------------
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        const Text(
                          "Ajustes Accesibilidad",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: posicionBarra,
                                items: const [
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Text("Arriba"),
                                  ),
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text("Abajo"),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text("Izquierda"),
                                  ),
                                  DropdownMenuItem(
                                    value: 3,
                                    child: Text("Derecha"),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => posicionBarra = value!);
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Posicion botones principales",
                                ),
                              ),
                            ),
                            BotonIcono(
                              icono: Icons.save_alt_outlined,
                              onPressed: () {
                                _guardarBarra(alumno);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        BotonConIcono(
                          icono: Icons.palette,
                          radio: 16,
                          texto: "Colores",
                          onPressed: () {
                            navegar(ConfigColorProfesor(alum: alumno), context);
                          },
                        ),
                        const SizedBox(height: 16),
                        // --- NUEVO WIDGET PARA AJUSTES DEL JUEGO 1 ---
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.extension),
                                    SizedBox(width: 8),
                                    Text(
                                      "Juego 1",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                                SwitchListTile(
                                  title: Text('Permitir ajustes'),
                                  value: alumno.permisoAjustesJuego1,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _guardarPermisoJuego1(
                                        alumno,
                                        'permisoAjustesJuego1',
                                        value,
                                      );
                                    });
                                  },
                                ),
                                SwitchListTile(
                                  title: Text('Permitir estadísticas'),
                                  value: alumno.permisoEstadisticasJuego1,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _guardarPermisoJuego1(
                                        alumno,
                                        'permisoEstadisticasJuego1',
                                        value,
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

//// PANTALLAS PARA DISTINTOS TIPOS DE CONTRASEÑAS ////
