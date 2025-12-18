import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/clase.dart';
import 'package:tato_matematico/edicion/editarClase.dart';
import 'package:tato_matematico/edicion/profesorEditarContrasena.dart';
import 'package:tato_matematico/datos/profesor.dart';
import 'package:tato_matematico/holders/alumnosHolder.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';
import 'package:tato_matematico/widgetsAuxiliares/fotoPerfil.dart';

/// **Nombre de la Clase: `PerfilProfesor`**
///
/// **Descripción:** Clase que muestra el perfil de un profesor,
/// permitiendo editar su nombre, su foto de perfil y su contraseña.
/// Ademas, permite ver sus clases asociadas.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///

class PerfilProfesor extends StatefulWidget {
  final Profesor profesor;
  final List<Clase> clases;
  final bool propio;

  const PerfilProfesor({
    super.key,
    required this.profesor,
    required this.clases,
    required this.propio,
  });

  @override
  State<PerfilProfesor> createState() => _PerfilProfesorState();
}

class _PerfilProfesorState extends State<PerfilProfesor> {
  late TextEditingController _nameController;
  bool _isEditing = false;
  bool _isUploadingImage = false;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  late FotoPerfil foto;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profesor.nombre);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    if (_isEditing) {
      if (_nameController.text.trim().isNotEmpty) {
        setState(() {
          widget.profesor.actualizarNombre(_nameController.text);
          _isEditing = false;
        });
      } else {
        snackBarError(context, 'El nombre no puede estar vacío.');
        _nameController.text = widget.profesor.nombre;
        _isEditing = false;
      }
      FocusScope.of(context).unfocus();
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  Widget _versionMovil() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BotonConIcono(
          icono: Icons.edit,
          texto: "Cambiar contraseña",
          onPressed: () {
            navegar(
              ProfesorEditarContrasena(profesor: widget.profesor),
              context,
            );
          },
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Text("¿Es Administrador?"),
            const SizedBox(width: 8),
            Switch(
              value: widget.profesor.director,
              onChanged: (value) {
                setState(() {
                  widget.profesor.actualizarDirector(value);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _versionEscritorio() {
    return Row(
      children: [
        BotonConIcono(
          icono: Icons.edit,
          texto: "Cambiar contraseña",
          onPressed: () {
            navegar(
              ProfesorEditarContrasena(profesor: widget.profesor),
              context,
            );
          },
        ),
        const SizedBox(width: 16),
        Text("¿Es administrador?"),
        const SizedBox(width: 8),
        Switch(
          value: widget.profesor.director,
          onChanged: (value) {
            setState(() {
              widget.profesor.actualizarDirector(value);
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var alumnos = context.read<AlumnosHolder>().alumnos;
    var esMovil = MediaQuery.of(context).size.width < 600;
    foto = FotoPerfil(
      key: ValueKey(widget.profesor.imagen),
      nombre: widget.profesor.nombre,
      idUnico: widget.profesor.imagen ?? widget.profesor.id,
      onObtenerImagen: widget.profesor.obtenerImagen,
      radio: 28,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(120),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () {
                          _mostrarMenuOrigen(
                            context,
                            widget.profesor,
                            propio: widget.propio,
                          );
                        },
                        child: foto,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        _mostrarMenuOrigen(
                          context,
                          widget.profesor,
                          propio: widget.propio,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          // Borde blanco para separar visualmente de la foto
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.cameraswitch_outlined, // O Icons.edit
                          size: esMovil ? 16:20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _isEditing
                            ? Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Nombre',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : Text(
                                widget.profesor.nombre,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                        BotonIcono(
                          icono: _isEditing ? Icons.save : Icons.edit,
                          onPressed: _toggleEditing,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    widget.propio
                        ? BotonConIcono(
                            icono: Icons.edit,
                            texto: "Cambiar contraseña",
                            onPressed: () {
                              navegar(
                                ProfesorEditarContrasena(
                                  profesor: widget.profesor,
                                ),
                                context,
                              );
                            },
                          )
                        : esMovil
                        ? _versionMovil()
                        : _versionEscritorio(),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          Text(
            widget.propio
                ? 'MIS CLASES'
                : 'CLASES DE ${widget.profesor.nombre.toUpperCase()}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          // Solo la lista de clases se desplaza
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: widget.clases.length,
              separatorBuilder: (_, _) => const SizedBox(height: 0),
              itemBuilder: (context, index) {
                return ProfesorClaseCard(
                  clase: widget.clases[index],
                  onPressed: () {
                    navegar(
                      EditarClase(
                        clase: widget.clases[index],
                        allAlumnos: alumnos,
                      ),
                      context,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMenuOrigen(
    BuildContext context,
    Profesor alumno, {
    bool propio = true,
  }) {
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
                    _cambiarImagen(ImageSource.gallery, alumno, propio: propio);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: colorScheme.primary),
                  title: const Text('Cámara'),
                  onTap: () {
                    Navigator.of(context).pop(); // Cerrar menú
                    _cambiarImagen(ImageSource.camera, alumno, propio: propio);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _cambiarImagen(
    ImageSource source,
    Profesor prof, {
    bool propio = true,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      print(propio);
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
      if (prof.imagen != null && prof.imagen!.isNotEmpty) {
        try {
          // Intentamos borrar la imagen antigua del Storage.
          // refFromURL funciona con URLs gs:// y https://
          await FirebaseStorage.instance.refFromURL(prof.imagen!).delete();
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
          '${prof.id}_${DateTime.now().millisecondsSinceEpoch}_perfil.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(
        'profesorado/$fileName',
      );

      await ref.putFile(imageFile);

      // Obtener ruta gs://
      String bucketName = FirebaseStorage.instance.bucket;
      String gsUrl = "gs://$bucketName/profesorado/$fileName";

      // 3. Actualizar Realtime Database
      await _dbRef.child('tato/profesorado/${prof.id}').update({
        'imagen': gsUrl,
      });

      // 4. Actualizar el objeto alumno
      prof.imagen = gsUrl;
      prof.imagenLocal = imageFile.path;

      // Limpiar cache (aunque el setter de imagen ya lo hace, no está de más si no se usó el setter)
      prof.invalidarCachedImage();

      // 5. Notificar cambios
      if (mounted) {
        if (propio) {
          //context.read<ProfesorHolder>().setProfesor(prof);
        }
        snackBarExito(context, "Imagen actualizada correctamente.");
      }
    } catch (e) {
      if (mounted) {
        snackBarError(context, "Error al subir imagen: $e");
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }
}
