import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'emg_screen.dart';
import 'fingers_screen.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _conectado = false;
  bool _dialogoMostrado = false;

  final List<Widget> _screens = const [
    EMGScreen(),
    FingersScreen(),
    ChatScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dialogoMostrado && mounted) {
        _dialogoMostrado = true;
        _mostrarDialogoConexion();
      }
    });
  }

  void _mostrarDialogoConexion() {
    if (Navigator.of(context, rootNavigator: true).canPop()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.bluetooth_searching, color: Color(0xFF00BCD4)),
            SizedBox(width: 8),
            Text('Conectando...', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF00BCD4)),
            const SizedBox(height: 16),
            const Text(
              'Buscando prótesis Aurora...',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (mounted) setState(() => _conectado = false);
              },
              child: const Text(
                'Entrar sin conexión',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ],
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
              leading: const Icon(Icons.person, color: Color(0xFF00BCD4)),
              title: const Text('Usuario', style: TextStyle(color: Colors.white70)),
              subtitle: Text(user?.email ?? 'Sin sesión',
                  style: const TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(
                _conectado ? Icons.wifi : Icons.wifi_off,
                color: _conectado ? Colors.greenAccent : Colors.redAccent,
              ),
              title: const Text('Prótesis', style: TextStyle(color: Colors.white70)),
              subtitle: Text(
                _conectado ? 'Conectada' : 'Sin conexión',
                style: TextStyle(
                    color: _conectado ? Colors.greenAccent : Colors.redAccent),
              ),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.wifi_find, color: Color(0xFF00BCD4)),
              title: const Text('Buscar prótesis',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _mostrarDialogoConexion();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Cerrar sesión',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('Aurora',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _conectado ? Colors.greenAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _conectado ? 'Conectado' : 'Sin conexión',
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
      body: _screens[_currentIndex],
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