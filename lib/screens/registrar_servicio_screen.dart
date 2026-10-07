import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/categorias.dart';
import '../models/servicio.dart';
import '../providers/servicio_provider.dart';

class RegistrarServicioScreen extends StatefulWidget {
  final Servicio? servicioEditar;

  const RegistrarServicioScreen({super.key, this.servicioEditar});

  @override
  State<RegistrarServicioScreen> createState() =>
      _RegistrarServicioScreenState();
}

class _RegistrarServicioScreenState extends State<RegistrarServicioScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _categoriaOtroCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _zonaCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _disponibilidadCtrl = TextEditingController();

  String? _categoriaSeleccionada;
  String? _fotoPath;
  bool _guardando = false;

  bool get _esEdicion => widget.servicioEditar != null;

  @override
  void initState() {
    super.initState();
    final s = widget.servicioEditar;
    if (s != null) {
      _nombreCtrl.text = s.nombrePrestador;
      _descripcionCtrl.text = s.descripcion;
      _telefonoCtrl.text = s.telefono;
      _whatsappCtrl.text = s.whatsapp ?? '';
      _emailCtrl.text = s.email ?? '';
      _zonaCtrl.text = s.zona;
      _precioCtrl.text =
          s.precioAprox != null ? s.precioAprox!.toStringAsFixed(0) : '';
      _disponibilidadCtrl.text = s.disponibilidad ?? '';
      _fotoPath = s.fotoPath;
      if (kCategorias.contains(s.oficioCategoria)) {
        _categoriaSeleccionada = s.oficioCategoria;
      } else {
        _categoriaSeleccionada = kCategoriaOtro;
        _categoriaOtroCtrl.text = s.oficioCategoria;
      }
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _categoriaOtroCtrl.dispose();
    _descripcionCtrl.dispose();
    _telefonoCtrl.dispose();
    _whatsappCtrl.dispose();
    _emailCtrl.dispose();
    _zonaCtrl.dispose();
    _precioCtrl.dispose();
    _disponibilidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    final origen = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar una foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            if (_fotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Quitar foto'),
                onTap: () {
                  setState(() => _fotoPath = null);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
    if (origen == null) return;

    try {
      final picker = ImagePicker();
      final archivo = await picker.pickImage(source: origen, imageQuality: 70);
      if (archivo != null) {
        setState(() => _fotoPath = archivo.path);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener la imagen.')),
      );
    }
  }

  String? _validarRequerido(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa $campo';
    }
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final categoria = _categoriaSeleccionada == kCategoriaOtro
        ? _categoriaOtroCtrl.text.trim()
        : _categoriaSeleccionada!;

    final servicio = Servicio(
      id: widget.servicioEditar?.id,
      nombrePrestador: _nombreCtrl.text.trim(),
      oficioCategoria: categoria,
      descripcion: _descripcionCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      whatsapp: _whatsappCtrl.text.trim().isEmpty
          ? null
          : _whatsappCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      zona: _zonaCtrl.text.trim(),
      precioAprox: double.tryParse(_precioCtrl.text.trim()),
      disponibilidad: _disponibilidadCtrl.text.trim().isEmpty
          ? null
          : _disponibilidadCtrl.text.trim(),
      fotoPath: _fotoPath,
      fechaRegistro: widget.servicioEditar?.fechaRegistro ?? DateTime.now(),
    );

    final provider = context.read<ServicioProvider>();
    try {
      if (_esEdicion) {
        await provider.actualizarServicio(servicio);
      } else {
        await provider.registrar(servicio);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _esEdicion
                ? 'Servicio actualizado correctamente.'
                : 'Servicio registrado correctamente.',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar servicio' : 'Registrar servicio'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Datos del prestador',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nombreCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre completo *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => _validarRequerido(v, 'tu nombre'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _categoriaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Oficio / categoría *',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: kCategorias
                  .map(
                    (c) => DropdownMenuItem(value: c, child: Text(c)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _categoriaSeleccionada = v),
              validator: (v) =>
                  v == null ? 'Selecciona una categoría' : null,
            ),
            if (_categoriaSeleccionada == kCategoriaOtro) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriaOtroCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Especifica tu oficio *',
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                validator: (v) => _categoriaSeleccionada == kCategoriaOtro
                    ? _validarRequerido(v, 'tu oficio')
                    : null,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionCtrl,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción del servicio *',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description_outlined),
              ),
              validator: (v) => _validarRequerido(v, 'una descripción'),
            ),
            const SizedBox(height: 24),
            Text(
              'Ubicación y tarifa',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _zonaCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Zona / ciudad *',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (v) => _validarRequerido(v, 'la zona donde atiendes'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _precioCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Precio aproximado (Bs)',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _disponibilidadCtrl,
              decoration: const InputDecoration(
                labelText: 'Disponibilidad (ej. Lun a Vie, 8:00 - 18:00)',
                prefixIcon: Icon(Icons.schedule_outlined),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Contacto',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefonoCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Teléfono *',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) => _validarRequerido(v, 'tu teléfono'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _whatsappCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
              ],
              decoration: const InputDecoration(
                labelText: 'WhatsApp',
                prefixIcon: Icon(Icons.chat_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) {
                final valor = v?.trim() ?? '';
                if (valor.isEmpty) return null;
                final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                return regex.hasMatch(valor) ? null : 'Correo no válido';
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Foto (opcional)',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _FotoSelector(fotoPath: _fotoPath, onTap: _seleccionarFoto),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_esEdicion ? 'Actualizar' : 'Registrar servicio'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _FotoSelector extends StatelessWidget {
  final String? fotoPath;
  final VoidCallback onTap;

  const _FotoSelector({required this.fotoPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (fotoPath != null && File(fotoPath!).existsSync()) {
      return InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(fotoPath!),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.surface,
                child: const Icon(Icons.edit),
              ),
            ),
          ],
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_a_photo_outlined),
      label: const Text('Agregar foto'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(100),
      ),
    );
  }
}
