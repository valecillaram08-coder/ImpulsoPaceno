import 'package:flutter_test/flutter_test.dart';
import 'package:impulso_paceno/models/servicio.dart';

void main() {
  group('Servicio', () {
    test('serializa y deserializa correctamente', () {
      final fecha = DateTime(2026, 1, 15, 10, 30);
      final original = Servicio(
        id: 7,
        nombrePrestador: 'Juan Pérez',
        oficioCategoria: 'Electricidad',
        descripcion: 'Instalaciones y reparaciones eléctricas.',
        telefono: '+591 70000000',
        whatsapp: '+591 70000000',
        email: 'juan@example.com',
        zona: 'Zona Sur',
        precioAprox: 150,
        disponibilidad: 'Lun a Sáb',
        fotoPath: null,
        fechaRegistro: fecha,
      );

      final reconstruido = Servicio.fromMap(original.toMap());

      expect(reconstruido.id, original.id);
      expect(reconstruido.nombrePrestador, original.nombrePrestador);
      expect(reconstruido.oficioCategoria, original.oficioCategoria);
      expect(reconstruido.descripcion, original.descripcion);
      expect(reconstruido.telefono, original.telefono);
      expect(reconstruido.whatsapp, original.whatsapp);
      expect(reconstruido.email, original.email);
      expect(reconstruido.zona, original.zona);
      expect(reconstruido.precioAprox, original.precioAprox);
      expect(reconstruido.disponibilidad, original.disponibilidad);
      expect(reconstruido.fechaRegistro, original.fechaRegistro);
    });

    test('campos opcionales nulos se leen por defecto', () {
      final reconstruido = Servicio.fromMap({
        'id': 1,
        'nombrePrestador': 'Ana',
        'oficioCategoria': 'Limpieza',
        'descripcion': 'Limpieza de casas',
        'telefono': '1234567',
        'zona': 'Centro',
        'fechaRegistro': DateTime(2026, 1, 1).millisecondsSinceEpoch,
      });

      expect(reconstruido.whatsapp, isNull);
      expect(reconstruido.email, isNull);
      expect(reconstruido.precioAprox, isNull);
      expect(reconstruido.disponibilidad, isNull);
      expect(reconstruido.fotoPath, isNull);
    });
  });
}
