import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';
import 'emg_screen.dart';
import 'fingers_screen.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import '../services/bluetooth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _conectado = false;
  Map<String, dynamic> _datosBrazo = {};
  List<ScanResult> _dispositivos = [];
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    BTService.onDatosRecibidos = (datos) {
      if (mounted) setState(() => _datosBrazo = datos);
    };
    BTService.onConexionCambiada = (conectado) {
      if (mounted) setState(() => _conectado = conectado);
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostrarDialogoConexion();
    });
  }

  @override
  void dispose() {
    BTService.desconectar();
    super.dispose();
  }

  Future<void> _buscarDispositivos() async {
    setState(() => _buscando = true);
    final resultados = await BTService.buscarDispositivos();
    if (mounted) setState(() {
      _dispositivos = resultados;
      _buscando = false;
    });
  }

  void enviarAccion(String accion, {int? angulo}) {
    BTService.enviarAccion(accion, angulo: angulo);
  }

  void _mostrarDialogoConexion() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.bluetooth_searching, color: Color(0xFF52B788)),
              SizedBox(width: 8),
              Text('Conectar protesis', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _buscando ? null : () async {
                    setStateDialog(() => _buscando = true);
                    final resultados = await BTService.buscarDispositivos();
                    setStateDialog(() {
                      _dispositivos = resultados;
                      _buscando = false;
                    });
                  },
                  icon: _buscando
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.search, color: Colors.white),
                  label: Text(
                    _buscando ? 'Buscando...' : 'Buscar dispositivos',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                if (_dispositivos.isEmpty && !_buscando)
                  const Text(
                    'No se encontraron dispositivos.\nPresiona buscar para escanear.',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                if (_dispositivos.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _dispositivos.length,
                      itemBuilder: (context, index) {
                        final device = _dispositivos[index].device;
                        return ListTile(
                          leading: const Icon(Icons.bluetooth,
                              color: Color(0xFF52B788)),
                          title: Text(
                            device.platformName.isEmpty
                                ? 'Dispositivo desconocido'
                                : device.platformName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            device.remoteId.toString(),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11),
                          ),
                          onTap: () async {
                            setStateDialog(() => _buscando = true);
                            final ok = await BTService.conectar(device);
                            if (mounted) {
                              setState(() => _conectado = ok);
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (mounted) setState(() => _conectado = false);
                  },
                  child: const Text(
                    'Entrar sin conexion',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarAjustes() {
    final user = FirebaseAuth.instance.currentUser;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ajustes',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF52B788)),
              title: const Text('Usuario',
                  style: TextStyle(color: Colors.white70)),
              subtitle: Text(user?.email ?? 'Sin sesion',
                  style: const TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(
                _conectado ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                color: _conectado ? Colors.greenAccent : Colors.redAccent,
              ),
              title: const Text('Protesis',
                  style: TextStyle(color: Colors.white70)),
              subtitle: Text(
                _conectado ? 'Conectada' : 'Sin conexion',
                style: TextStyle(
                    color: _conectado ? Colors.greenAccent : Colors.redAccent),
              ),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.bluetooth_searching,
                  color: Color(0xFF52B788)),
              title: const Text('Buscar protesis',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _mostrarDialogoConexion();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Cerrar sesion',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                await BTService.desconectar();
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      EMGScreen(datos: _datosBrazo),
      FingersScreen(datos: _datosBrazo, onAccion: enviarAccion),
      const ChatScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('Aurora',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _conectado
                    ? Colors.greenAccent.withOpacity(0.2)
                    : Colors.redAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _conectado ? 'Conectado' : 'Sin conexion',
                style: TextStyle(
                    color: _conectado ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: _mostrarAjustes,
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.monitor_heart),
            label: 'EMG',
          ),
          NavigationDestination(
            icon: Icon(Icons.back_hand),
            label: 'Dedos',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}