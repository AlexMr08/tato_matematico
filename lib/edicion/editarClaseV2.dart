import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/clase.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tato_matematico/datos/profesor.dart';
import 'package:tato_matematico/holders/profesoresHolder.dart';

class EditarClaseV2 extends StatefulWidget {
  final Clase clase;
  final List<Alumno> allAlumnos;

  const EditarClaseV2({
    super.key,
    required this.clase,
    required this.allAlumnos
  });
  @override
  State<EditarClaseV2> createState() => _EditarClaseV2State();
}

class _EditarClaseV2State extends State<EditarClaseV2> {
  late TextEditingController _nombreController;
  final DatabaseReference dbref = FirebaseDatabase.instance.ref();
  late List<Alumno> alumnos;
  String? profesorTutor;
  List<Profesor> _profesores = [];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.clase.nombre);
    alumnos = alumnosDeClase(widget.clase, widget.allAlumnos);
    profesorTutor = widget.clase.idTutor.isNotEmpty ? widget.clase.idTutor : null;
  }


  List<Alumno> alumnosDeClase(Clase clase, List<Alumno> allAlumnos) {
    return allAlumnos
        .where((alumno) => clase.alumnos.contains(alumno.id))
        .toList();
  }

  Future<bool?> mostrarModalAlumnos(
    BuildContext context,
    List<Alumno> alumnos,
    List<String> alumnosClaseIds,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 500, // ancho fijo
            height: 600, // alto fijo
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Todos los alumnos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      itemCount: alumnos.length,
                      itemBuilder: (context, index) {
                        final alumno = alumnos[index];
                        final yaEnClase = alumnosClaseIds.contains(alumno.id);
                        final isDisabled = yaEnClase;
                        if (isDisabled) {
                          return SizedBox.shrink(); // No mostrar el alumno si ya está en la clase
                        }

                        return alumnos[index].widgetProfesor(context, () {
                          List<String> alumnosActualizados = List.from(
                            widget.clase.alumnos,
                          );
                          if (!alumnosActualizados.contains(alumno.id)) {
                            alumnosActualizados.add(alumno.id);
                            dbref
                                .child('tato')
                                .child('clases')
                                .child(widget.clase.id)
                                .update({'alumnos': alumnosActualizados})
                                .then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Alumno añadido a la clase',
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  setState(() {
                                    widget.clase.alumnos.add(alumno.id);
                                    alumnos = alumnosDeClase(
                                      widget.clase,
                                      widget.allAlumnos,
                                    );
                                  });
                                  Navigator.of(context).pop(true);
                                })
                                .catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error al añadir el alumno: $error',
                                      ),
                                    ),
                                  );
                                });
                          }
                        }, Icon(Icons.add));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer,
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _profesores = context.read<ProfesoresHolder>().profesores;
    //profesorTutor = widget.clase.idTutor.isNotEmpty ? widget.clase.idTutor : null;

    return ScaffoldComunV2(
      titulo: "Editar Clase",
      cuerpo: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 800,
                  child: TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nombre de la clase',
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    String nuevoNombre = _nombreController.text.trim();
                    if (nuevoNombre.isNotEmpty) {
                      dbref
                          .child('tato')
                          .child('clases')
                          .child(widget.clase.id)
                          .update({'nombre': nuevoNombre})
                          .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Clase actualizada correctamente',
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          })
                          .catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error al actualizar la clase: $error',
                                ),
                              ),
                            );
                          });
                    }
                  },
                  label: Text("Guardar"),
                  icon: const Icon(Icons.save),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tutor: ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),
                _profesores.isEmpty
                    ? const CircularProgressIndicator()
                    : DropdownButton<String>(
                        value: profesorTutor,
                        underline: Container(
                          height: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        hint: const Text("Selecciona tutor"),
                        items: _profesores.map((prof) {
                          return DropdownMenuItem(
                            value: prof.id,
                            child: Text(prof.nombre),
                          );
                        }).toList(),
                        onChanged: (nuevoId) async {
                          setState(() => profesorTutor = nuevoId);
                        },
                      ),
                const SizedBox(width: 20),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (profesorTutor != null) {
                      dbref
                          .child('tato')
                          .child('clases')
                          .child(widget.clase.id)
                          .update({'id_tutor': profesorTutor})
                          .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Tutor actualizado correctamente',
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            setState(() {
                              widget.clase.idTutor = profesorTutor!;
                            });
                          })
                          .catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error al actualizar el tutor: $error',
                                ),
                              ),
                            );
                          });
                    }
                  },
                  label: Text("Guardar Tutor"),
                  icon: const Icon(Icons.save),
                ),

                const SizedBox(width: 80),
                Text(
                  'Número de alumnos en la clase: ${alumnos.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    bool? resultado = await mostrarModalAlumnos(
                      context,
                      widget.allAlumnos,
                      widget.clase.alumnos,
                    );
                    if (resultado == true) {
                      setState(() {
                        alumnos = alumnosDeClase(
                          widget.clase,
                          widget.allAlumnos,
                        );
                      });
                    }
                  },
                  label: Text("Añadir Alumno"),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  reverse: false,
                  itemCount: alumnos.length,
                  itemBuilder: (BuildContext context, int index) {
                    return alumnos[index].widgetProfesor(context, () {
                      List<String> alumnosActualizados = List.from(
                        widget.clase.alumnos,
                      );
                      alumnosActualizados.remove(alumnos[index].id);

                      dbref
                          .child('tato')
                          .child('clases')
                          .child(widget.clase.id)
                          .update({'alumnos': alumnosActualizados})
                          .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Alumno eliminado de la clase'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            setState(() {
                              widget.clase.alumnos.remove(alumnos[index].id);
                            });
                            alumnos = alumnosDeClase(
                              widget.clase,
                              widget.allAlumnos,
                            );
                          })
                          .catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error al eliminar el alumno: $error',
                                ),
                              ),
                            );
                          });
                    }, Icon(Icons.remove_circle));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
