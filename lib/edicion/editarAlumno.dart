import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tato_matematico/ScaffoldComun.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/colorPicker.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/alumno.dart';
import 'package:tato_matematico/edicion/configAlfanumerica.dart';
import 'package:tato_matematico/edicion/configImagenUnica.dart';
import 'package:tato_matematico/edicion/configSecuencia.dart';

class EditarAlumno extends StatefulWidget{
  @override
  State<EditarAlumno> createState() => _EditarAlumnoState();
}

class _EditarAlumnoState extends State<EditarAlumno> {
  String tipoPassword = "alfanumerica";
  int posicionBarra = 0;
  late final TextEditingController _nombreController;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Estado para controlar el modo de edicion
  bool _isEditingName = false;
  bool _isControllerInitialized = false;

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

    switch(tipoPassword) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío.')),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre actualizado correctamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el nombre: $e')),
      );
    } finally {
      // Salimos del modo edición
      setState(() => _isEditingName = false);
    }
  }

  void _guardarBarra(Alumno alumno) async {
    final nuevoNombre = posicionBarra;

    if (nuevoNombre == alumno.nombre) {
      // Si no hay cambios, simplemente salimos del modo edición.
      return;
    }
    try {
      // Actualizamos la base de datos
      await _dbRef.child('tato/alumnos/${alumno.id}').update({
        'posicionBarra': nuevoNombre,
      });

      // Actualizamos el estado local
      alumno.posicionBarra = nuevoNombre;
      context.read<AlumnoHolder>().setAlumno(alumno);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posicion de la barra actualizada correctamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la posicion de la barra: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<AlumnoHolder>(
        builder: (context, alumnoHolder, child) {
          final Alumno? alumno = alumnoHolder.alumno;
          return ScaffoldComun(
            titulo: alumno!.nombre,
            subtitulo: 'Editar Alumno',
            funcionSalir: () {
              Navigator.pop(context);
            },
            cuerpo: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [

                  // ------------------------------
                  //     BLOQUE IZQUIERDO
                  // ------------------------------
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: colorScheme.primaryContainer,
                          backgroundImage: alumno.cachedImage,
                          child: alumno.cachedImage == null
                              ? Icon(
                                Icons.person,
                                size: 80,
                                color: colorScheme.onPrimaryContainer,
                              )
                              : null,
                        ),

                        const SizedBox(height: 15),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                                  child: Center(
                                    child: _isEditingName
                                        ? TextFormField(
                                      controller: _nombreController,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 20, fontWeight: FontWeight.bold
                                      ),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 4
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      onFieldSubmitted: (_) => _guardarNombre(alumno),
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
                                  child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        _isEditingName ? Icons.save_alt_outlined : Icons.edit_outlined,
                                        color: colorScheme.primary,
                                      ),
                                      onPressed: () {
                                        if (_isEditingName) {
                                          _guardarNombre(alumno);
                                        } else {
                                          setState(() {
                                            _isEditingName = true;
                                          });
                                        }
                                      }
                                  ),
                                )
                              ]
                          ),
                        ),


                        const SizedBox(height: 16),

                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.edit),
                          label: Text("Cambiar Imagen"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primaryContainer,
                            foregroundColor: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),

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
                              fontWeight: FontWeight.bold
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
                          child: ElevatedButton(
                            onPressed: () => _irAConfiguracion(context, alumno),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primaryContainer,
                              foregroundColor: colorScheme.onPrimaryContainer,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 4,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("CONFIGURAR CONTRASEÑA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward_ios)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                              fontWeight: FontWeight.bold
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
                            IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.save_alt_outlined,
                                  color: colorScheme.primary,
                                ),
                                onPressed: () {
                                  _guardarBarra(alumno);
                                }
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<AlumnoHolder>().setAlumno(alumno);
                            navegar(ConfigColor(), context);
                          },
                          icon: Icon(Icons.palette),
                          label: Text("Colores"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primaryContainer,
                            foregroundColor: colorScheme.onPrimaryContainer,
                            minimumSize: Size(120, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.extension),
                          label: Text("Juego 1"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primaryContainer,
                            foregroundColor: colorScheme.onPrimaryContainer,
                            minimumSize: Size(120, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          );
        }
    );
  }
}

//// PANTALLAS PARA DISTINTOS TIPOS DE CONTRASEÑAS ////
