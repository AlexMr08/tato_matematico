import 'package:flutter/material.dart';
import 'package:tato_matematico/alumno.dart';

abstract class LoginData {
  // Clase abstracta para polimorfismo
}

class AlfanumericaData extends LoginData {
  final String hash;

  AlfanumericaData({
    required this.hash,
  });

  factory AlfanumericaData.fromMap(Map<dynamic, dynamic> data) {
    return AlfanumericaData(hash: data['hash']);
  }
}

class SeleccionImagenData extends LoginData {
  final String idImagenCorrecta;
  final int totalImagenes;
  final bool distractorasAleatorias;
  final List<String> imagenesDistractoras;

  SeleccionImagenData({
    required this.idImagenCorrecta,
    required this.totalImagenes,
    required this.distractorasAleatorias,
    required this.imagenesDistractoras,
  });

  factory SeleccionImagenData.fromMap(Map<dynamic, dynamic> data) {
    final Map<dynamic, dynamic> imagenesDistractorasMap = data['imagenesDistractoras'];
    List<String> distractorasList = [];

    if (imagenesDistractorasMap != null) {
      distractorasList = imagenesDistractorasMap.keys.cast<String>().toList();
    }

    return SeleccionImagenData(
      idImagenCorrecta: data['idImagenCorrecta'],
      totalImagenes: data['totalImagenes'],
      distractorasAleatorias: data['distractorasAleatorias'],
      imagenesDistractoras: distractorasList,
    );
  }

  // Devuelve los IDs de todas las imagenes para pintar el grid
  List<String> obtenerIdsGrid() {
    List<String> gridIds = [idImagenCorrecta];
    if (!distractorasAleatorias) {
      gridIds.addAll(imagenesDistractoras);
    }
    return gridIds;
  }
}

class SecuenciaImagenesData extends LoginData {
  final int totalImagenes;
  final bool distractorasAleatorias;
  final Map<String, String> secuenciaCorrecta;
  final List<String> imagenesDistractoras;

  SecuenciaImagenesData({
    required this.totalImagenes,
    required this.distractorasAleatorias,
    required this.secuenciaCorrecta,
    required this.imagenesDistractoras,
  });

  factory SecuenciaImagenesData.fromMap(Map<dynamic, dynamic> data) {
    final Map<String, String> secuenciaCorrectaMap = data['secuenciaCorrecta'];
    final Map<dynamic, dynamic> distractorasMap = data['imagenesDistractoras'];
    List<String> distractorasList = [];
    if (distractorasMap != null) {
      distractorasList = distractorasMap.keys.cast<String>().toList();
    }

    return SecuenciaImagenesData(
      totalImagenes: data['totalImagenes'],
      distractorasAleatorias: data['distractorasAleatorias'],
      secuenciaCorrecta: secuenciaCorrectaMap,
      imagenesDistractoras: distractorasList,
    );
  }

  // Metodo para devolver la lista de imagenes correctas ordenadas
  List<String> obtenerSecuenciaOrdenada() {
    final List<String> pasosOrdenados = secuenciaCorrecta.keys.toList()..sort();
    return pasosOrdenados.map((paso) => secuenciaCorrecta[paso]!).toList();
  }
}

class AlumnoLoginConfig {
  final String idAlumno;
  final String tipoLogin;
  final LoginData datosLogin;

  AlumnoLoginConfig({
    required this.idAlumno,
    required this.tipoLogin,
    required this.datosLogin,
  });

  // Lee de firebase y decide que estructura de login usar
  factory AlumnoLoginConfig.fromMap(String id, Map<dynamic, dynamic> data) {
    final String loginTipo = data['tipoLogin'];

    final Map<dynamic, dynamic> datosEspecificos = data[loginTipo];

    LoginData loginData;

    switch(loginTipo) {
      case 'alfanumerica':
        loginData = AlfanumericaData.fromMap(datosEspecificos);
        break;
      case 'seleccionImagen':
        loginData = SeleccionImagenData.fromMap(datosEspecificos);
        break;
      case 'secuenciaImagenes':
        loginData = SecuenciaImagenesData.fromMap(datosEspecificos);
        break;
      default:
        throw Exception('Tipo de login desconocido: $loginTipo');
    }

    return AlumnoLoginConfig(
        idAlumno: id,
        tipoLogin: loginTipo,
        datosLogin: loginData
    );
  }
}