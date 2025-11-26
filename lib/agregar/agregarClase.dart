import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tato_matematico/datos/profesor.dart';
import 'package:tato_matematico/holders/profesoresHolder.dart';

/*
  Se han hecho pruebas unitarias para asegurar que funciona correctamente:
  - No se puede crear una clase sin nombre
  - Se puede crear una clase introduciendo como minimo el nombre.
  - Se puede crear una clase con nombre y con tutor, pero sin alumnos
  - Se puede crear una clase con nombre, tutor y alumnos.
   */

class AgregarClase extends StatefulWidget {
  final List<Alumno> allAlumnos;

  const AgregarClase({super.key, required this.allAlumnos});
  @override
  State<AgregarClase> createState() => _AgregarClaseState();
}

class _AgregarClaseState extends State<AgregarClase> {
  late TextEditingController _nombreController;
  final DatabaseReference dbref = FirebaseDatabase.instance.ref();
  late List<Alumno> alumnos;
  String? profesorTutor;
  List<Profesor> _profesores = [];
  List<String> seleccionados = [];

  late String anoSeleccionado;
  late List<String> listaAnos;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    alumnos = alumnosDeClase(seleccionados, widget.allAlumnos);
    profesorTutor = null;

    // Inicializar año y lista
    anoSeleccionado = obtenerAnoAcademico();
    listaAnos = generarListaAnos();
    if (!listaAnos.contains(anoSeleccionado)) {
      listaAnos.add(anoSeleccionado);
      listaAnos.sort();
    }
  }

  List<Alumno> alumnosDeClase(
    List<String> seleccionados,
    List<Alumno> allAlumnos,
  ) {
    return allAlumnos
        .where((alumno) => seleccionados.contains(alumno.id))
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
                            seleccionados,
                          );
                          if (!alumnosActualizados.contains(alumno.id)) {
                            alumnosActualizados.add(alumno.id);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Alumno añadido a la clase'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            seleccionados.add(alumno.id);
                            alumnos = alumnosDeClase(
                              seleccionados,
                              widget.allAlumnos,
                            );
                            Navigator.of(context).pop(true);
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

    return ScaffoldComunV2(
      titulo: "Crear Clase",
      cuerpo: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 800,
              child: TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nombre de la clase',
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Selector de Año
                Row(
                  children: [
                    Text(
                      'Año: ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: anoSeleccionado,
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      items: listaAnos.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            anoSeleccionado = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
                // Selector de Tutor
                Row(
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
                  ],
                ),
                // Botón Añadir Alumnos
                Row(
                  children: [
                    Text(
                      'Alumnos: ${alumnos.length}',
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
                          seleccionados,
                        );
                        if (resultado == true) {
                          setState(() {
                            alumnos = alumnosDeClase(
                              seleccionados,
                              widget.allAlumnos,
                            );
                          });
                        }
                      },
                      label: Text("Añadir"),
                      icon: const Icon(Icons.add),
                    ),
                  ],
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
                      seleccionados.remove(alumnos[index].id);
                      setState(() {
                        alumnos = alumnosDeClase(
                          seleccionados,
                          widget.allAlumnos,
                        );
                      });
                    }, Icon(Icons.remove_circle));
                  },
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              if (_nombreController.text != "") {
                try {
                  final snapshot = await dbref
                      .child("tato")
                      .child("clases")
                      .orderByChild("ano")
                      .equalTo(anoSeleccionado)
                      .get();

                  if (snapshot.exists) {
                    final data = Map<String, dynamic>.from(
                      snapshot.value as Map,
                    );

                    for (final entry in data.entries) {
                      final classData = Map<dynamic, dynamic>.from(
                        entry.value as Map,
                      );
                      if (classData["ano"] == anoSeleccionado &&
                          classData["nombre"] == _nombreController.text) {
                        setState(() {
                          snackBarError(context, "La clase ya existe");
                        });
                        return;
                      }
                    }
                  }
                } catch (e) {
                  print("Error comprobando clase: $e");
                }

                String? id = dbref.child('tato').child('clases').push().key;
                dbref
                    .child('tato')
                    .child('clases')
                    .child(id!)
                    .set({
                      "nombre": _nombreController.text,
                      "ano": anoSeleccionado,
                      "id_tutor": profesorTutor,
                      "alumnos": seleccionados,
                      "timestamp": DateTime.now().millisecondsSinceEpoch,
                    })
                    .then((_) {
                      setState(() {
                        snackBarExito(context, "Clase creada correctamente");
                        Navigator.pop(context);
                      });
                    });
              }
            },
            label: Text("Crear clase"),
            icon: const Icon(Icons.add),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
