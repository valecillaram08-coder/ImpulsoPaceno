import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/servicio_provider.dart';
import 'buscar_servicio_screen.dart';
import 'mis_servicios_screen.dart';
import 'registrar_servicio_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indice = 0;
  int _refreshSignal = 0;

  static const List<String> _titulos = [
    'Buscar servicios',
    'Mis servicios',
  ];

  Future<void> _abrirRegistro() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistrarServicioScreen()),
    );
    if (!mounted) return;
    setState(() => _refreshSignal++);
    await context.read<ServicioProvider>().cargarMisServicios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_indice]),
        centerTitle: false,
      ),
      body: IndexedStack(
        index: _indice,
        children: [
          BuscarServicioScreen(refreshSignal: _refreshSignal),
          const MisServiciosScreen(),
        ],
      ),
      floatingActionButton: _indice == 0
          ? FloatingActionButton.extended(
              onPressed: _abrirRegistro,
              icon: const Icon(Icons.add),
              label: const Text('Registrar'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Mis servicios',
          ),
        ],
      ),
    );
  }
}
