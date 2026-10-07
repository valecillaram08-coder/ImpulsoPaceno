import 'package:sqflite/sqflite.dart';

import '../models/servicio.dart';
import 'database_helper.dart';

class ServicioFiltro {
  final String texto;
  final String? categoria;
  final String? zona;
  final double? precioMax;

  const ServicioFiltro({
    this.texto = '',
    this.categoria,
    this.zona,
    this.precioMax,
  });

  bool get estaVacio =>
      texto.trim().isEmpty &&
      (categoria == null || categoria!.isEmpty) &&
      (zona == null || zona!.isEmpty) &&
      precioMax == null;
}

class ServicioRepository {
  final DatabaseHelper _dbHelper;

  ServicioRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<int> insertar(Servicio servicio) async {
    final db = await _dbHelper.database;
    final mapa = servicio.toMap()..remove('id');
    return db.insert(DatabaseHelper.tablaServicios, mapa);
  }

  Future<int> actualizar(Servicio servicio) async {
    final db = await _dbHelper.database;
    return db.update(
      DatabaseHelper.tablaServicios,
      servicio.toMap(),
      where: 'id = ?',
      whereArgs: [servicio.id],
    );
  }

  Future<int> eliminar(int id) async {
    final db = await _dbHelper.database;
    return db.delete(
      DatabaseHelper.tablaServicios,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Servicio>> obtenerTodos() async {
    final db = await _dbHelper.database;
    final filas = await db.query(
      DatabaseHelper.tablaServicios,
      orderBy: 'fechaRegistro DESC',
    );
    return filas.map(Servicio.fromMap).toList();
  }

  Future<Servicio?> obtenerPorId(int id) async {
    final db = await _dbHelper.database;
    final filas = await db.query(
      DatabaseHelper.tablaServicios,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (filas.isEmpty) return null;
    return Servicio.fromMap(filas.first);
  }

  Future<List<Servicio>> buscar(ServicioFiltro filtro) async {
    final db = await _dbHelper.database;
    final condiciones = <String>[];
    final argumentos = <Object?>[];

    final texto = filtro.texto.trim();
    if (texto.isNotEmpty) {
      final patron = '%$texto%';
      condiciones.add(
        '(nombrePrestador LIKE ? OR oficioCategoria LIKE ? OR '
        'descripcion LIKE ? OR zona LIKE ?)',
      );
      argumentos.addAll([patron, patron, patron, patron]);
    }

    if (filtro.categoria != null && filtro.categoria!.isNotEmpty) {
      condiciones.add('oficioCategoria = ?');
      argumentos.add(filtro.categoria);
    }

    if (filtro.zona != null && filtro.zona!.isNotEmpty) {
      condiciones.add('zona = ?');
      argumentos.add(filtro.zona);
    }

    if (filtro.precioMax != null) {
      condiciones.add('(precioAprox IS NULL OR precioAprox <= ?)');
      argumentos.add(filtro.precioMax);
    }

    final filas = await db.query(
      DatabaseHelper.tablaServicios,
      where: condiciones.isEmpty ? null : condiciones.join(' AND '),
      whereArgs: argumentos.isEmpty ? null : argumentos,
      orderBy: 'fechaRegistro DESC',
    );
    return filas.map(Servicio.fromMap).toList();
  }

  Future<List<String>> obtenerZonas() async {
    final db = await _dbHelper.database;
    final filas = await db.rawQuery(
      'SELECT DISTINCT zona FROM ${DatabaseHelper.tablaServicios} '
      'WHERE zona IS NOT NULL AND zona != "" ORDER BY zona ASC',
    );
    return filas.map((f) => f['zona'] as String).toList();
  }

  Future<int> contar() async {
    final db = await _dbHelper.database;
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM ${DatabaseHelper.tablaServicios}',
    );
    return Sqflite.firstIntValue(resultado) ?? 0;
  }
}
