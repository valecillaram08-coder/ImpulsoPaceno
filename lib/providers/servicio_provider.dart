import 'package:flutter/foundation.dart';

import '../data/servicio_repository.dart';
import '../models/servicio.dart';

class ServicioProvider extends ChangeNotifier {
  final ServicioRepository _repository;

  ServicioProvider({ServicioRepository? repository})
      : _repository = repository ?? ServicioRepository();

  List<Servicio> _misServicios = [];
  bool _cargando = false;
  String? _error;

  List<Servicio> get misServicios => _misServicios;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargarMisServicios() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _misServicios = await _repository.obtenerTodos();
    } catch (e) {
      _error = 'No se pudieron cargar los servicios: $e';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<int> registrar(Servicio servicio) async {
    final id = await _repository.insertar(servicio);
    await cargarMisServicios();
    return id;
  }

  Future<void> actualizarServicio(Servicio servicio) async {
    await _repository.actualizar(servicio);
    await cargarMisServicios();
  }

  Future<void> eliminarServicio(int id) async {
    await _repository.eliminar(id);
    await cargarMisServicios();
  }

  Future<List<Servicio>> buscar(ServicioFiltro filtro) {
    return _repository.buscar(filtro);
  }

  Future<List<String>> zonasDisponibles() {
    return _repository.obtenerZonas();
  }
}
