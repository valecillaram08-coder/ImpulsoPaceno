import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/servicio.dart';
import '../widgets/servicio_card.dart';

class DetalleServicioScreen extends StatelessWidget {
  final Servicio servicio;

  const DetalleServicioScreen({super.key, required this.servicio});

  String _soloDigitos(String valor) =>
      valor.replaceAll(RegExp(r'[^0-9+]'), '');

  Future<void> _abrir(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la aplicación.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final precio = servicio.precioAprox;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del servicio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  iconoParaCategoria(servicio.oficioCategoria),
                  size: 32,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      servicio.nombrePrestador,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      servicio.oficioCategoria,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (servicio.fotoPath != null &&
              File(servicio.fotoPath!).existsSync()) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(servicio.fotoPath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
          ],
          _Seccion(
            titulo: 'Descripción',
            hijos: [Text(servicio.descripcion, style: theme.textTheme.bodyLarge)],
          ),
          _Seccion(
            titulo: 'Ubicación y disponibilidad',
            hijos: [
              _FilaDato(
                icono: Icons.location_on_outlined,
                etiqueta: 'Zona',
                valor: servicio.zona,
              ),
              _FilaDato(
                icono: Icons.schedule_outlined,
                etiqueta: 'Disponibilidad',
                valor: servicio.disponibilidad?.isNotEmpty == true
                    ? servicio.disponibilidad!
                    : 'No especificada',
              ),
              _FilaDato(
                icono: Icons.attach_money,
                etiqueta: 'Precio aproximado',
                valor: precio != null
                    ? NumberFormat.currency(
                        locale: 'es',
                        symbol: 'Bs ',
                        decimalDigits: 0,
                      ).format(precio)
                    : 'A convenir',
              ),
              _FilaDato(
                icono: Icons.calendar_today_outlined,
                etiqueta: 'Registrado',
                valor: DateFormat('dd/MM/yyyy HH:mm')
                    .format(servicio.fechaRegistro),
              ),
            ],
          ),
          _Seccion(
            titulo: 'Contacto',
            hijos: [
              _FilaDato(
                icono: Icons.phone_outlined,
                etiqueta: 'Teléfono',
                valor: servicio.telefono,
              ),
              if (servicio.whatsapp?.isNotEmpty == true)
                _FilaDato(
                  icono: Icons.chat_outlined,
                  etiqueta: 'WhatsApp',
                  valor: servicio.whatsapp!,
                ),
              if (servicio.email?.isNotEmpty == true)
                _FilaDato(
                  icono: Icons.email_outlined,
                  etiqueta: 'Correo',
                  valor: servicio.email!,
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _abrir(
                    context,
                    Uri(scheme: 'tel', path: _soloDigitos(servicio.telefono)),
                  ),
                  icon: const Icon(Icons.call),
                  label: const Text('Llamar'),
                ),
              ),
              const SizedBox(width: 10),
              if (servicio.whatsapp?.isNotEmpty == true)
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _abrir(
                      context,
                      Uri.parse(
                        'https://wa.me/${_soloDigitos(servicio.whatsapp!)}'
                        '?text=${Uri.encodeComponent('Hola, vi tu servicio de ${servicio.oficioCategoria} en Impulso Paceño.')}',
                      ),
                    ),
                    icon: const Icon(Icons.chat),
                    label: const Text('WhatsApp'),
                  ),
                ),
              if (servicio.email?.isNotEmpty == true) ...[
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  onPressed: () => _abrir(
                    context,
                    Uri(
                      scheme: 'mailto',
                      path: servicio.email,
                      query: 'subject=${Uri.encodeComponent('Consulta por servicio')}',
                    ),
                  ),
                  icon: const Icon(Icons.email),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final List<Widget> hijos;

  const _Seccion({required this.titulo, required this.hijos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...hijos,
        ],
      ),
    );
  }
}

class _FilaDato extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _FilaDato({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurface),
                children: [
                  TextSpan(
                    text: '$etiqueta: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: valor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
