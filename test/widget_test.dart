import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relevo/data/app_state.dart';
import 'package:relevo/data/models.dart';
import 'package:relevo/screens/ingreso_screen.dart';

void main() {
  testWidgets('Muestra la pantalla de ingreso', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: IngresoScreen()));
    expect(find.text('Ingresá a tu cuenta'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
  });

  test('Una solicitud nueva le llega al comercial y se puede enviar', () {
    final antes = app.noLeidas;
    final s = app.crearSolicitud(
      titulo: 'Prueba',
      cliente: 'Metalúrgica Andina',
      proyecto: 'Ampliación nave 2',
      comercial: app.usuarioComercial,
      limite: DateTime(2026, 12, 1),
      prioridad: 'Media',
      indicaciones: '',
      datos: [DatoRelevar(nombre: 'Largo', tipo: TipoDato.medicion, unidad: 'm')],
    );
    expect(s.codigo, 'SOL-0143');
    expect(app.noLeidas, antes + 1);
    expect(s.faltantes, ['Largo']);

    app.iniciarVisita(s);
    s.relevamiento!.valores['Largo'] = '12,00';
    expect(s.faltantes, isEmpty);

    app.enviar(s);
    expect(s.estado, Estado.completada);
  });
}
