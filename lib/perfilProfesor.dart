import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tato_matematico/clase.dart';
import 'package:tato_matematico/profesor.dart';

class PerfilProfesor extends StatefulWidget {
  final Profesor profesor;
  final List<Clase> clases;

  const PerfilProfesor({
    super.key,
    required this.profesor,
    required this.clases,
  });

  @override
  State<PerfilProfesor> createState() => _PerfilProfesorState();
}

class _PerfilProfesorState extends State<PerfilProfesor> {
  late TextEditingController _nameController;
  bool _isEditing = false;

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
      // Guardar: actualizar el nombre en el modelo local
      setState(() {
        widget.profesor.actualizarNombre(_nameController.text);
        _isEditing = false;
      });
      FocusScope.of(context).unfocus();

      // Aquí puedes llamar a tu API o provider para persistir el cambio
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (widget.profesor.imagenLocal.isNotEmpty) {
      imageProvider = FileImage(File(widget.profesor.imagenLocal));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(120),
                  clipBehavior: Clip.hardEdge,
                  child: GestureDetector(
                    onTap: () {
                      // acción al tocar el avatar (ej. cambiar imagen)
                    },
                    child: imageProvider != null
                        ? Image(image: imageProvider, fit: BoxFit.cover)
                        : Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Center(
                              child: Text(
                                widget.profesor.nombre.isNotEmpty
                                    ? widget.profesor.nombre[0]
                                    : '?',
                                style: TextStyle(
                                  fontSize: 48,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
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

                        IconButton(
                          icon: Icon(
                            _isEditing ? Icons.check : Icons.edit,
                            size: 20,
                          ),
                          onPressed: _toggleEditing,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // editar contraseña
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 18,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      label: Text(
                        'Editar contraseña',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Text(
            'MIS CLASES',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          // Solo la lista de clases se desplaza
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: widget.clases.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return widget.clases[index].widgetClase(context, () {
                  // Acción al presionar el botón de editar clase
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
