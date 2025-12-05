import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database_mocks/firebase_database_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tato_matematico/agregar/agregarAlumno.dart';
import 'package:tato_matematico/datos/juego.dart';
// Asegúrate de importar tu botón correcto
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';

class TestAlumnoLogic with AlumnoLogic {}

void main() {
  late FirebaseDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockFirebaseDatabase.instance;
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      // Ahora esto funcionará porque actualizaste el paso 1
      home: AgregarAlumno(database: mockDatabase),
    );
  }

  group('Pruebas del método agregarAlumno', () {
    test(
      'Unit Test: procesarAgregarAlumno debe devolver 1 si el nombre no está vacío',
      () async {
        final logic = TestAlumnoLogic();

        // 1. Llamamos a la función DIRECTAMENTE pasando un string vacío
        int resultado = await logic.procesarAgregarAlumno("Juan", mockDatabase);

        // 2. Verificamos el retorno exacto
        expect(resultado, 1);
      },
    );

    test(
      'Unit Test: procesarAgregarAlumno debe devolver -1 si el nombre está vacío',
      () async {
        final logic = TestAlumnoLogic();

        // 1. Llamamos a la función DIRECTAMENTE pasando un string vacío
        int resultado = await logic.procesarAgregarAlumno("", mockDatabase);

        // 2. Verificamos el retorno exacto
        expect(resultado, -1);
      },
    );

    testWidgets(
      'Debe permitir iniciar sesión con la contraseña por defecto (0000)',
      (WidgetTester tester) async {
        // 2. Recuperar el ID del alumno creado de la DB simulada
        final alumnosSnapshot = await mockDatabase
            .ref()
            .child("tato/alumnos")
            .get();
        final alumnosMap = alumnosSnapshot.value as Map;
        // Buscamos el ID del alumno que acabamos de crear
        final alumnoId = alumnosMap.entries
            .firstWhere((e) => e.value['nombre'] == "Juan")
            .key;

        // 3. Simular la entrada de contraseña del usuario ("0000")
        String inputUsuario = "0000";

        // 4. Buscar los datos de login en la DB simulada para ese ID
        final loginSnapshot = await mockDatabase
            .ref()
            .child("tato/login/$alumnoId")
            .get();

        expect(
          loginSnapshot.exists,
          true,
          reason: "El usuario no tiene datos de login",
        );

        final loginData = loginSnapshot.value as Map;
        String hashGuardado = loginData['alfanumerica']['hash'];

        // 5. LÓGICA DE VERIFICACIÓN (Lo que haría tu app real)
        var bytes = utf8.encode(inputUsuario);
        var digest = sha256.convert(bytes);
        String hashInput = digest.toString();

        // 6. Aserción: El hash generado por "0000" debe coincidir con el guardado
        expect(
          hashInput,
          hashGuardado,
          reason: "La contraseña por defecto no coincide con el hash guardado",
        );

        // Prueba negativa: Intentar con contraseña incorrecta
        var bytesMal = utf8.encode("1234");
        var digestMal = sha256.convert(bytesMal);
        expect(
          digestMal.toString(),
          isNot(hashGuardado),
          reason: "Una contraseña incorrecta no debería coincidir",
        );
      },
    );
  });
}
