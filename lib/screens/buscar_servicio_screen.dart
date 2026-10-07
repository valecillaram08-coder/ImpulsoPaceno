import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/categorias.dart';
import '../data/servicio_repository.dart';
import '../models/servicio.dart';
import '../providers/servicio_provider.dart';
import '../widgets/servicio_card.dart';
import 'detalle_servicio_screen.dart';

class BuscarServicioScreen extends StatefulWidget {
  final int refreshSignal;

  const BuscarServicioScreen({super.key, this.refreshSignal = 0});

  @override
  State<BuscarServicioScreen> createState() => _BuscarServicioScreenState();
}

class _BuscarServicioScreenState extends State<BuscarServicioScreen> {
  final _busquedaCtrl = TextEditingController();
  String? _categoria;
  String? _zona;
  List<String> _zonas = [];
  List<Servicio> _resultados = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  @override
  void didUpdateWidget(covariant BuscarServicioScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshSignal != widget.refreshSignal) {
      _inicializar();
    }
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  Future<void> _inicializar() async {
    final provider = context.read<ServicioProvider>();
    _zonas = await provider.zonasDisponibles();
    await _buscar();
  }

  Future<void> _buscar() async {
    setState(() => _cargando = true);
    final provider = context.read<ServicioProvider>();
    final resultados = await provider.buscar(
      ServicioFiltro(
        texto: _busquedaCtrl.text,
        categoria: _categoria,
        zona: _zona,
      ),
    );
    if (!mounted) return;
    setState(() {
      _resultados = resultados;
      _cargando = false;
    });
  }

  Future<void> _abrirDetalle(Servicio servicio) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleServicioScreen(servicio: servicio),
      ),
    );
    if (mounted) _buscar();
  }

  void _limpiarFiltros() {
    setState(() {
      _busquedaCtrl.clear();
      _categoria = null;
      _zona = null;
    });
    _buscar();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hayFiltros = _categoria != null || _zona != null ||
        _busquedaCtrl.text.trim().isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _busquedaCtrl,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _buscar(),
            onChanged: (_) => _buscar(),
            decoration: InputDecoration(
              hintText: 'Buscar por oficio, nombre o descripción',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _busquedaCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _busquedaCtrl.clear();
                        _buscar();
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: ChoiceChip(
                  label: const Text('Todas'),
                  selected: _categoria == null,
                  onSelected: (_) {
                    setState(() => _categoria = null);
                    _buscar();
                  },
                ),
              ),
              ...kCategorias.map(
                (c) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: _categoria == c,
                    onSelected: (_) {
                      setState(() => _categoria = _categoria == c ? null : c);
                      _buscar();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: _zona,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Zona',
                    isDense: true,
                    prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Todas las zonas'),
                    ),
                    ..._zonas.map(
                      (z) => DropdownMenuItem<String?>(
                        value: z,
                        child: Text(z),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() => _zona = v);
                    _buscar();
                  },
                ),
              ),
              if (hayFiltros) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Limpiar filtros',
                  onPressed: _limpiarFiltros,
                  icon: const Icon(Icons.filter_alt_off_outlined),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_resultados.length} servicio(s) encontrado(s)',
              style: theme.textTheme.labelMedium,
            ),
          ),
        ),
        Expanded(
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _resultados.isEmpty
                  ? _SinResultados(
                      conFiltros: hayFiltros,
                      onLimpiar: _limpiarFiltros,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _resultados.length,
                      itemBuilder: (_, i) => ServicioCard(
                        servicio: _resultados[i],
                        onTap: () => _abrirDetalle(_resultados[i]),
                      ),
                    ),
        ),
      ],
    );
  }
}

class _SinResultados extends StatelessWidget {
  final bool conFiltros;
  final VoidCallback onLimpiar;

  const _SinResultados({required this.conFiltros, required this.onLimpiar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              conFiltros
                  ? 'No se encontraron servicios con esos filtros.'
                  : 'Aún no hay servicios registrados.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              conFiltros
                  ? 'Prueba con otra búsqueda o limpia los filtros.'
                  : 'Sé el primero en registrar un servicio.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            if (conFiltros) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onLimpiar,
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('Limpiar filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
