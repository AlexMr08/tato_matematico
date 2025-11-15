import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/alumno.dart';
import 'package:tato_matematico/clase.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart';

class EditarClase extends StatefulWidget {
  final Clase clase;
  final VoidCallback salirDeEdicion;
  final List<Alumno> allAlumnos;

  const EditarClase({
    super.key,
    required this.clase,
    required this.allAlumnos,
    required this.salirDeEdicion,
  });
  @override
  State<EditarClase> createState() => _EditarClaseState();
}

class _EditarClaseState extends State<EditarClase> {
  late TextEditingController _nombreController;
  final DatabaseReference dbref = FirebaseDatabase.instance.ref();
  late List<Alumno> alumnos;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.clase.nombre);
    alumnos = alumnosDeClase(widget.clase, widget.allAlumnos);
  }

  List<Alumno> alumnosDeClase(Clase clase, List<Alumno> allAlumnos) {
    return allAlumnos.where((alumno) => clase.alumnos.contains(alumno.id)).toList();
  }

  Future<bool?> mostrarModalAlumnos(BuildContext context, List<Alumno> alumnos, List<String>alumnosClaseIds){
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
                      itemCount: alumnos.length,
                      itemBuilder: (context, index) {
                        final alumno = alumnos[index];
                        final yaEnClase = alumnosClaseIds.contains(alumno.id);
                        final isDisabled = yaEnClase;
                         if(isDisabled){
                          return SizedBox.shrink(); // No mostrar el alumno si ya está en la clase
                         }

                        return alumnos[index].widgetProfesor(context, () {
                          List<String> alumnosActualizados = List.from(widget.clase.alumnos);
                          if (!alumnosActualizados.contains(alumno.id)) {
                            alumnosActualizados.add(alumno.id);
                            dbref.child('tato').child('clases').child(widget.clase.id).update({
                              'alumnos': alumnosActualizados,
                            }).then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Alumno añadido a la clase'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
                              );
                              setState(() {
                                widget.clase.alumnos.add(alumno.id);
                                alumnos = alumnosDeClase(widget.clase, widget.allAlumnos);

                              });
                               Navigator.of(context).pop(true); 
                            }).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al añadir el alumno: $error')),
                              );
                            });

                          }
                        }, Icon(Icons.add));
                      },
                    ),
                  )
                  
                ),
                const SizedBox(height: 16),

                Center(
                  child:
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: const Color.fromARGB(255, 106, 18, 213),
                        foregroundColor: const Color.fromARGB(255, 255, 255, 255)
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
    return Column(
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
                  backgroundColor: const Color.fromARGB(255, 106, 18, 213),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  String nuevoNombre = _nombreController.text.trim();
                  if (nuevoNombre.isNotEmpty) {
                    dbref.child('tato').child('clases').child(widget.clase.id).update({
                      'nombre': nuevoNombre,
                    }).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Clase actualizada correctamente'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
                      );
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al actualizar la clase: $error')),
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
                'Número de alumnos en la clase: ${alumnos.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 106, 18, 213),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  bool? resultado = await mostrarModalAlumnos(context, widget.allAlumnos, widget.clase.alumnos);
                  if (resultado == true) {
                    setState(() {
                      alumnos = alumnosDeClase(widget.clase, widget.allAlumnos);
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
              child:
              Padding(
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
                          alumnos = alumnosDeClase(widget.clase, widget.allAlumnos);
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
        
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: widget.salirDeEdicion, 
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: const Color.fromARGB(255, 106, 18, 213),
            foregroundColor: const Color.fromARGB(255, 255, 255, 255)
          ),
          child: Text("Volver a Clases")),
        const SizedBox(height: 20),
      ],
      
    );
  }
}
