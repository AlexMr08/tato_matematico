import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/datos/clase.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tato_matematico/datos/profesor.dart';
import 'package:tato_matematico/holders/profesoresHolder.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';

import '../auxFunc.dart';

/// **Nombre de la Clase: `EditarClase`**
///
/// **Descripción:** Clase que permite editar los datos de una clase existente en la aplicación.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Andrés Ignacio Mardones Domcke
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 08/12/2025
/// * **Último cambio:** Se ha mejorado la responsividad
///

class EditarClase extends StatefulWidget {
  final Clase clase;
  final List<Alumno> allAlumnos;

  const EditarClase({super.key, required this.clase, required this.allAlumnos});
  @override
  State<EditarClase> createState() => _EditarClaseState();
}

/*
  Se han hecho pruebas unitarias para asegurar que funciona correctamente:
  - Se ha cambiado el nombre de la clase correctamente
  - No se puede guardar si el campo del nombre de la clase esta vacio
  - Al retroceder no se guardan los cambios
  - Se puede cambiar la fecha correctamente, y cambia el orden del listado
    de clases en base a ello
  - Se puede cambiar el tutor sin problemas
  - Se pueden anadir alumnos sin problemas
  - Se pueden eliminar alumnos sin problemas
   */

class _EditarClaseState extends State<EditarClase> {
  late TextEditingController _nombreController;
  final DatabaseReference dbref = FirebaseDatabase.instance.ref();
  late List<Alumno> alumnos;
  String? profesorTutor;
  String? anoSeleccionado;
  List<Profesor> _profesores = [];
  final List<String> _anos = generarListaAnos();
  late double size;
  bool em = false;
  bool notInit = true;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.clase.nombre);
    anoSeleccionado = widget.clase.ano;
    if (!_anos.contains(anoSeleccionado)) {
      _anos.add(anoSeleccionado!);
      _anos.sort();
    }
    alumnos = alumnosDeClase(widget.clase, widget.allAlumnos);
    profesorTutor = widget.clase.idTutor.isNotEmpty
        ? widget.clase.idTutor
        : null;
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

                        return TeacherViewCard(
                          alumno: alumnos[index],
                          onTap: () {
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
                                    setState(() {
                                      widget.clase.alumnos.add(alumno.id);
                                      alumnos = alumnosDeClase(
                                        widget.clase,
                                        widget.allAlumnos,
                                      );
                                      Navigator.of(context).pop(true);
                                    });
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
                          },
                          icono: Icon(Icons.add),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: BotonSinIcono(
                    texto: "Cancelar",
                    vertPadding: 12,
                    horiPadding: 24,
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
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

    if (notInit) {
      size = MediaQuery.sizeOf(context).width;
      em = size < 600;
      notInit = false;
    }

    return ScaffoldComunV2(
      titulo: "Editar Clase",
      cuerpo: !em
          ? Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 500,
                        child: TextField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nombre de la clase',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      BotonConIcono(
                        icono: Icons.save,
                        radio: 16,
                        texto: "Guardar nombre",
                        onPressed: guardarNombre,
                      ),

                      SizedBox(width: 24),

                      Text(
                        'Año: ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: anoSeleccionado,
                        underline: Container(
                          height: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        hint: const Text("Selecciona año"),
                        items: _anos.map((ano) {
                          return DropdownMenuItem(value: ano, child: Text(ano));
                        }).toList(),
                        onChanged: (nuevoId) async {
                          setState(() => anoSeleccionado = nuevoId);
                        },
                      ),
                      const SizedBox(width: 20),
                      BotonConIcono(
                        icono: Icons.save,
                        radio: 16,
                        texto: "Guardar año",
                        onPressed: guardarAno,
                      ),
                      const SizedBox(width: 20),
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
                      const SizedBox(width: 12),
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
                      const SizedBox(width: 12),
                      BotonConIcono(
                        icono: Icons.save,
                        radio: 16,
                        texto: "Guardar tutor",
                        onPressed: guardarTutor,
                      ),
                      const SizedBox(width: 24),

                      Text(
                        'Número de alumnos: ${alumnos.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      BotonConIcono(
                        icono: Icons.add,
                        radio: 16,
                        texto: "Añadir alumno",
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
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.builder(
                        reverse: false,
                        itemCount: alumnos.length,
                        itemBuilder: (BuildContext context, int index) {
                          return TeacherViewCard(
                            alumno: alumnos[index],
                            onTap: () {
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
                                    setState(() {
                                      widget.clase.alumnos.remove(
                                        alumnos[index].id,
                                      );
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
                            },
                            icono: Icon(Icons.remove_circle),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                const SizedBox(height: 20),

                // 1. ZONA SUPERIOR FIJA (Formularios)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- CAMPO NOMBRE + BOTÓN ---
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nombreController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Nombre de la clase',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          BotonConIcono(
                            icono: Icons.save,
                            radio: 12,
                            texto: "Guardar", // Texto corto para que quepa
                            onPressed: guardarNombre,
                          ),
                        ],
                      ),

                      const Divider(height: 24),

                      // --- CAMPO AÑO + BOTÓN ---
                      Row(
                        children: [
                          const Text(
                            "Año: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: anoSeleccionado,
                              items: _anos
                                  .map(
                                    (ano) => DropdownMenuItem(
                                      value: ano,
                                      child: Text(ano),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => anoSeleccionado = v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          BotonConIcono(
                            icono: Icons.save,
                            radio: 12,
                            texto: "Guardar",
                            onPressed: guardarAno,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // --- CAMPO TUTOR + BOTÓN ---
                      Row(
                        children: [
                          const Text(
                            "Tutor: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: profesorTutor,
                              hint: const Text("Seleccionar"),
                              items: _profesores
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p.id,
                                      child: Text(
                                        p.nombre,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => profesorTutor = v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          BotonConIcono(
                            icono: Icons.save,
                            radio: 12,
                            texto: "Guardar",
                            onPressed: guardarTutor,
                          ),
                        ],
                      ),

                      const Divider(),

                      // Cabecera Alumnos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Alumnos (${alumnos.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          BotonConIcono(
                            icono: Icons.add,
                            radio: 16,
                            texto: "Añadir",
                            onPressed: () async {
                              bool? res = await mostrarModalAlumnos(
                                context,
                                widget.allAlumnos,
                                widget.clase.alumnos,
                              );
                              if (res == true) {
                                setState(
                                  () => alumnos = alumnosDeClase(
                                    widget.clase,
                                    widget.allAlumnos,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 2. ZONA INFERIOR CON SCROLL (Lista de alumnos)
                Expanded(
                  child: alumnos.isEmpty
                      ? const Center(child: Text("No hay alumnos"))
                      : Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: alumnos.length,
                            itemBuilder: (context, index) {
                              return TeacherViewCard(
                                alumno: alumnos[index],
                                onTap: () {
                                  // Lógica de borrado
                                  List<String> updated = List.from(
                                    widget.clase.alumnos,
                                  );
                                  updated.remove(alumnos[index].id);
                                  dbref
                                      .child('tato')
                                      .child('clases')
                                      .child(widget.clase.id)
                                      .update({'alumnos': updated})
                                      .then((_) {
                                        setState(() {
                                          widget.clase.alumnos.remove(
                                            alumnos[index].id,
                                          );
                                          alumnos = alumnosDeClase(
                                            widget.clase,
                                            widget.allAlumnos,
                                          );
                                        });
                                      });
                                },
                                icono: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Future<void> guardarNombre() async {
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
                content: Text('Clase actualizada correctamente'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          })
          .catchError((error) {
            if (mounted) {
              snackBarError(context, 'Error al actualizar la clase: $error');
            }
          });
    }
  }

  Future<void> guardarAno() async {
    if (anoSeleccionado != null && anoSeleccionado != widget.clase.ano) {
      dbref
          .child('tato')
          .child('clases')
          .child(widget.clase.id)
          .update({'ano': anoSeleccionado})
          .then((_) {
            setState(() {
              widget.clase.ano = anoSeleccionado!;
              snackBarExito(context, 'Año actualizado correctamente');
            });
          })
          .catchError((error) {
            setState(() {
              snackBarError(context, 'Error al actualizar el año: $error');
            });
          });
    }
  }

  Future<void> guardarTutor() async {
    if (profesorTutor != null) {
      dbref
          .child('tato')
          .child('clases')
          .child(widget.clase.id)
          .update({'id_tutor': profesorTutor})
          .then((_) {
            if (mounted) {
              snackBarExito(context, 'Tutor actualizado correctamente');
              widget.clase.idTutor = profesorTutor!;
            }
          })
          .catchError((error) {
            if (mounted) {
              snackBarError(context, 'Error al actualizar el tutor: $error');
            }
          });
    }
  }
}
