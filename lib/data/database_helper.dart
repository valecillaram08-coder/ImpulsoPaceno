import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'impulso_paceno.db';
  static const String tablaServicios = 'servicios';

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final String ruta = p.join(await getDatabasesPath(), _dbName);
    return openDatabase(
      ruta,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablaServicios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombrePrestador TEXT NOT NULL,
        oficioCategoria TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        telefono TEXT NOT NULL,
        whatsapp TEXT,
        email TEXT,
        zona TEXT NOT NULL,
        precioAprox REAL,
        disponibilidad TEXT,
        fotoPath TEXT,
        fechaRegistro INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_servicios_categoria ON $tablaServicios (oficioCategoria)',
    );
    await db.execute(
      'CREATE INDEX idx_servicios_zona ON $tablaServicios (zona)',
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
