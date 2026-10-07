import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/servicio.dart';
import '../providers/servicio_provider.dart';
import '../widgets/servicio_card.dart';
import 'detalle_servicio_screen.dart';
import 'registrar_servicio_screen.dart';

class MisServiciosScreen extends StatefulWidget {
  const MisServiciosScreen({super.key});

  @override
  State<MisServiciosScreen> createState() => _MisServiciosScreenState();
}

class _MisServiciosScreenState extends State<MisServiciosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ServicioProvider>().cargarMisServicios(),
    );
  }

  Future<void> _confirmarEliminar(Servicio servicio) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar servicio'),
        content: Text(
          '¿Seguro que deseas eliminar el servicio de '
          '${servicio.oficioCategoria} de ${servicio.nombrePrestador}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    await context.read<ServicioProvider>().eliminarServicio(servicio.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Servicio eliminado.')),
    );
  }

  Future<void> _editar(Servicio servicio) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrarServicioScreen(servicioEditar: servicio),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServicioProvider>();
    final theme = Theme.of(context);

    if (provider.cargando && provider.misServicios.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.misServicios.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.work_off_outlined,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                'Todavía no registraste servicios.',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Usa la pestaña “Registrar” para publicar tu primer servicio.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.cargarMisServicios,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: provider.misServicios.length,
        itemBuilder: (_, i) {
          final servicio = provider.misServicios[i];
          return Dismissible(
            key: ValueKey(servicio.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: theme.colorScheme.error,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: theme.colorScheme.onError),
            ),
            confirmDismiss: (_) async {
              await _confirmarEliminar(servicio);
              return false;
            },
            child: ServicioCard(
              servicio: servicio,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalleServicioScreen(servicio: servicio),
                ),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (opcion) {
                  if (opcion == 'editar') {
                    _editar(servicio);
                  } else if (opcion == 'eliminar') {
                    _confirmarEliminar(servicio);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Eliminar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
