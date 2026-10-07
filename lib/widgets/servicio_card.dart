import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/servicio.dart';

IconData iconoParaCategoria(String categoria) {
  switch (categoria) {
    case 'Albañilería':
      return Icons.construction;
    case 'Electricidad':
      return Icons.electrical_services;
    case 'Plomería':
      return Icons.plumbing;
    case 'Carpintería':
      return Icons.carpenter;
    case 'Pintura':
      return Icons.format_paint;
    case 'Limpieza':
      return Icons.cleaning_services;
    case 'Jardinería':
      return Icons.yard;
    case 'Costura y confección':
      return Icons.checkroom;
    case 'Belleza y peluquería':
      return Icons.content_cut;
    case 'Refrigeración y aire':
      return Icons.ac_unit;
    case 'Informática y tecnología':
      return Icons.computer;
    case 'Transporte y mudanzas':
      return Icons.local_shipping;
    case 'Cocina y catering':
      return Icons.restaurant;
    case 'Clases y tutorías':
      return Icons.school;
    default:
      return Icons.work_outline;
  }
}

class ServicioCard extends StatelessWidget {
  final Servicio servicio;
  final VoidCallback onTap;
  final Widget? trailing;

  const ServicioCard({
    super.key,
    required this.servicio,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final precio = servicio.precioAprox;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  iconoParaCategoria(servicio.oficioCategoria),
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      servicio.nombrePrestador,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      servicio.oficioCategoria,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      servicio.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _Dato(
                          icono: Icons.location_on_outlined,
                          texto: servicio.zona,
                        ),
                        if (precio != null)
                          _Dato(
                            icono: Icons.attach_money,
                            texto: NumberFormat.currency(
                              locale: 'es',
                              symbol: 'Bs ',
                              decimalDigits: 0,
                            ).format(precio),
                          ),
                        _Dato(
                          icono: Icons.calendar_today_outlined,
                          texto: DateFormat('dd/MM/yyyy')
                              .format(servicio.fechaRegistro),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing ?? const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _Dato({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 14, color: theme.colorScheme.outline),
        const SizedBox(width: 3),
        Text(texto, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
