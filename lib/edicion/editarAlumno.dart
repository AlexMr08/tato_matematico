import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/edicion/ajustesSonidoProfe.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldComunV2.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/ajustes/configColorProfesor.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/edicion/configAlfanumerica.dart';
import 'package:tato_matematico/edicion/configImagenUnica.dart';
import 'package:tato_matematico/edicion/configSecuencia.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tato_matematico/juegos/juego2/juego2AjustesProfe.dart';
import 'package:tato_matematico/juegos/juego2/juego2ScreenProfe.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';
import 'package:tato_matematico/juegos/juego3/juego3AjustesProfe.dart';
import '../juegos/juego3/juego3ScreenProfe.dart';

/// **Nombre de la Clase: `EditarAlumno`**
///
/// **Descripción:** clase que permite editar los datos de un alumno.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Joaquin Salas Castillo / Gonzalo Alganza Luque
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Se han añadido los ajustes de color y sonido de una mejor forma
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
    } else if (nuevoNombre == alumno.nombre) {
      // Si no hay cambios, simplemente salimos del modo edición.
      setState(() => _isEditingName = false);
    } else {
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

  Widget _buildBloqueJuego({
    required String titulo,
    required bool permisoValor,
    required Function(bool) onPermisoChanged,
    required VoidCallback onConfigurar,
    required VoidCallback onProbar,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.extension),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Permitir ajustes'),
              value: permisoValor,
              onChanged: onPermisoChanged,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                Expanded(
                  child: BotonSinIcono(
                    texto: "Configurar",
                    onPressed: onConfigurar,
                  ),
                ),
                Expanded(
                  child: BotonSinIcono(texto: "Probar", onPressed: onProbar),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloqueGeneral({
    required String titulo,
    required bool permisoSonido,
    required bool permisoColor,
    required Function(bool) onColoresChanged,
    required Function(bool) onSonidosChanged,
    required VoidCallback onConfigurar,
    required VoidCallback onProbar,
    required Alumno alumno,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings_accessibility),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: posicionBarra,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text("Arriba")),
                      DropdownMenuItem(value: 1, child: Text("Abajo")),
                      DropdownMenuItem(value: 2, child: Text("Izquierda")),
                      DropdownMenuItem(value: 3, child: Text("Derecha")),
                    ],
                    onChanged: (value) =>
                        setState(() => posicionBarra = value!),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Posición botones principales",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                BotonIcono(
                  icono: Icons.save_alt_outlined,
                  onPressed: () => _guardarBarra(alumno),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text('Permitir cambios de color'),
              value: permisoColor,
              onChanged: onColoresChanged,
            ),
            SwitchListTile(
              title: const Text('Permitir ajustes de sonido'),
              value: permisoSonido,
              onChanged: onSonidosChanged,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                Expanded(
                  child: BotonConIcono(
                    texto: "Colores",
                    onPressed: onConfigurar,
                    icono: Icons.palette,
                  ),
                ),
                Expanded(
                  child: BotonConIcono(
                    texto: "Sonido",
                    onPressed: onProbar,
                    icono: Icons.volume_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _guardarPermiso(Alumno alumno, String permiso, bool valor) async {
    try {
      await _dbRef.child('tato/alumnos/${alumno.id}').update({permiso: valor});
    } catch (e) {
      if (mounted) {
        snackBarError(context, 'Error al guardar el permiso');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final alumno = Provider.of<AlumnoHolder>(context).alumno;
    final listaJuegos = context.read<AlumnoHolder>().listaJuegos;

    if (alumno == null) {
      // Si el alumno es nulo, mostramos un loader o un mensaje y evitamos errores.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    var onPressed = _isUploadingImage
        ? null
        : () => _mostrarMenuOrigen(context, alumno);

    // -------------------------------------------------------------------------
    // BLOQUE 1: PERFIL (Avatar, Nombre, Botón Imagen)
    // -------------------------------------------------------------------------
    Widget bloquePerfil = Column(
      children: [
        // AVATAR
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: alumno.cachedImage,
              child: alumno.cachedImage == null
                  ? Text(
                      alumno.nombre.isNotEmpty
                          ? alumno.nombre[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
            if (_isUploadingImage) const CircularProgressIndicator(),
          ],
        ),
        const SizedBox(height: 16),
        // NOMBRE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
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
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (_) => _guardarNombre(alumno),
                      )
                    : Text(
                        _nombreController.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
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
                      setState(() => _isEditingName = true);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // BOTÓN CAMBIAR IMAGEN
        BotonConIcono(
          icono: Icons.cameraswitch_outlined,
          texto: "Cambiar Imagen",
          onPressed: onPressed,
        ),
      ],
    );

    Widget bloqueGeneral = _buildBloqueGeneral(
      titulo: "Ajustes Accesibilidad",
      permisoSonido: alumno.permisoSonido,
      permisoColor: alumno.permisoColor,
      onColoresChanged: (val) => _guardarPermiso(alumno, 'permisoColor', val),
      onSonidosChanged: (val) => _guardarPermiso(alumno, 'permisoSonido', val),
      onConfigurar: () => navegar(ConfigColorProfesor(alum: alumno), context),
      onProbar: () => navegar(AjustesSonidosProfesor(), context),
      alumno: alumno,
    );

    Widget bloqueJuego1 = _buildBloqueJuego(
      titulo: "Juego 1",
      permisoValor: alumno.permisoAjustesJuego1,
      onPermisoChanged: (val) =>
          _guardarPermiso(alumno, 'permisoAjustesJuego1', val),
      onConfigurar: () =>
          navegar(Juego2AjustesProfe(juego: listaJuegos["juego2"]!), context),
      onProbar: () => navegar(
        Juego2ScreenProfe(juego: listaJuegos["juego2"]!, alumno: alumno),
        context,
      ),
    );

    Widget bloqueJuego2 = _buildBloqueJuego(
      titulo: "Juego 2",
      permisoValor: alumno.permisoAjustesJuego2,
      onPermisoChanged: (val) =>
          _guardarPermiso(alumno, 'permisoAjustesJuego2', val),
      onConfigurar: () =>
          navegar(Juego2AjustesProfe(juego: listaJuegos["juego2"]!), context),
      onProbar: () => navegar(
        Juego2ScreenProfe(juego: listaJuegos["juego2"]!, alumno: alumno),
        context,
      ),
    );

    Widget bloqueJuego3 = _buildBloqueJuego(
      titulo: "Juego 3",
      permisoValor: alumno.permisoAjustesJuego3,
      onPermisoChanged: (val) =>
          _guardarPermiso(alumno, 'permisoAjustesJuego3', val),
      onConfigurar: () =>
          navegar(Juego3AjustesProfe(juego: listaJuegos["juego3"]!), context),
      onProbar: () => navegar(
        Juego3ScreenProfe(juego: listaJuegos["juego3"]!, alumno: alumno),
        context,
      ),
    );

    Widget bloqueJuego4 = _buildBloqueJuego(
      titulo: "Juego 4",
      permisoValor: alumno.permisoAjustesJuego4,
      onPermisoChanged: (val) =>
          _guardarPermiso(alumno, 'permisoAjustesJuego4', val),
      onConfigurar: () =>
          navegar(Juego2AjustesProfe(juego: listaJuegos["juego2"]!), context),
      onProbar: () => navegar(
        Juego2ScreenProfe(juego: listaJuegos["juego2"]!, alumno: alumno),
        context,
      ),
    );

    // -------------------------------------------------------------------------
    // BLOQUE 2: CONTRASEÑA (Dropdown, Botón Configurar)
    // -------------------------------------------------------------------------
    Widget bloquePassword = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Tipo de Contraseña",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            value: tipoPassword,
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
            onChanged: (value) => setState(() => tipoPassword = value!),
            decoration: const InputDecoration(
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
    );

    // -------------------------------------------------------------------------
    // BLOQUE 3: ACCESIBILIDAD (Barra, Colores, Juego1)
    // -------------------------------------------------------------------------
    Widget bloqueAccesibilidad = Column(
      children: [
        const Text(
          "Ajustes Accesibilidad",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Selector Posición Barra
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: posicionBarra,
                items: const [
                  DropdownMenuItem(value: 0, child: Text("Arriba")),
                  DropdownMenuItem(value: 1, child: Text("Abajo")),
                  DropdownMenuItem(value: 2, child: Text("Izquierda")),
                  DropdownMenuItem(value: 3, child: Text("Derecha")),
                ],
                onChanged: (value) => setState(() => posicionBarra = value!),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Posición botones principales",
                ),
              ),
            ),
            const SizedBox(width: 8),
            BotonIcono(
              icono: Icons.save_alt_outlined,
              onPressed: () => _guardarBarra(alumno),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Botón Colores
        bloqueGeneral,
        const SizedBox(height: 16),

        // Ajustes Juego 1
        /*
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                const Row(
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
                const Divider(),
                SwitchListTile(
                  title: const Text('Permitir ajustes'),
                  value: alumno.permisoAjustesJuego1,
                  onChanged: (bool value) {
                    _guardarPermisoJuego1(
                      alumno,
                      'permisoAjustesJuego1',
                      value,
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Permitir estadísticas'),
                  value: alumno.permisoEstadisticasJuego1,
                  onChanged: (bool value) {
                    _guardarPermisoJuego1(
                      alumno,
                      'permisoEstadisticasJuego1',
                      value,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
         */
      ],
    );

    // -------------------------------------------------------------------------
    // LAYOUT RESPONSIVO (LayoutBuilder)
    // -------------------------------------------------------------------------
    return ScaffoldComunV2(
      titulo: 'Editar Alumno',
      subtitulo: alumno.nombre,
      cuerpo: LayoutBuilder(
        builder: (context, constraints) {
          // Si el ancho es menor a 1000px, diseño vertical (MÓVIL)
          if (constraints.maxWidth < 1000) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  bloquePerfil,
                  const SizedBox(height: 16),
                  const Divider(thickness: 2),
                  const SizedBox(height: 16),
                  bloquePassword,
                  const SizedBox(height: 16),
                  const Divider(thickness: 2),
                  const SizedBox(height: 16),
                  bloqueGeneral,
                  const SizedBox(height: 16),
                  bloqueJuego1,
                  const SizedBox(width: 16),
                  bloqueJuego2,
                  const SizedBox(width: 16),
                  bloqueJuego3,
                  const SizedBox(width: 16),
                  bloqueJuego4,
                ],
              ),
            );
          } else {
            // Diseño horizontal de 3 columnas (ESCRITORIO/TABLET)
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 8,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 1, child: bloquePerfil),
                      const SizedBox(width: 16),
                      Expanded(flex: 1, child: bloquePassword),
                      const SizedBox(width: 16),
                      Expanded(flex: 1, child: bloqueGeneral),
                    ],
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(flex: 1, child: bloqueJuego1),
                      Expanded(flex: 1, child: bloqueJuego2),
                      Expanded(flex: 1, child: bloqueJuego3),
                      Expanded(flex: 1, child: bloqueJuego4),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
