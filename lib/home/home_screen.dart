import 'package:flutter/material.dart';

import '../features/authentication/presentation/viewmodels/auth_view_model.dart';
import '../features/authentication/presentation/views/welcome_page.dart';

class HomePage extends StatefulWidget {
  final AuthViewModel authViewModel;

  const HomePage({super.key, required this.authViewModel});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<String> _titles = ['Inicio', 'Bienestar', 'Perfil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
        ],
      ),

      body: Center(
        child: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Bienestar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await widget.authViewModel.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => WelcomePage(authViewModel: widget.authViewModel),
      ),
      (route) => false,
    );
  }
}
