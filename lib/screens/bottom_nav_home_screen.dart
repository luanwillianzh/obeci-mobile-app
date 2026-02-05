import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/turmas_list_screen.dart';
import '../screens/lembretes_screen.dart';
import '../screens/admin/admin_screen_wrapper.dart';
import '../screens/user_data_screen.dart';

class BottomNavHomeScreen extends StatefulWidget {
  const BottomNavHomeScreen({Key? key}) : super(key: key);

  @override
  _BottomNavHomeScreenState createState() => _BottomNavHomeScreenState();
}

class _BottomNavHomeScreenState extends State<BottomNavHomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _pages = [
      const TurmasListScreen(),
      const LembretesScreen(),
      const UserDataScreen(),
      const AdminScreenWrapper(),
    ];
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Atualiza as páginas e destinos dependendo se o usuário é admin
    final bool isAdmin = authProvider.isAdmin;

    List<Widget> pages = [
      const TurmasListScreen(),
      const LembretesScreen(),
      const UserDataScreen(),
    ];

    List<NavigationDestination> destinations = [
      const NavigationDestination(
        icon: Icon(Icons.school_outlined),
        selectedIcon: Icon(Icons.school),
        label: 'Turmas',
      ),
      const NavigationDestination(
        icon: Icon(Icons.notes_outlined),
        selectedIcon: Icon(Icons.notes),
        label: 'Lembretes',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ];

    if (isAdmin) {
      pages.add(const AdminScreenWrapper());
      destinations.add(const NavigationDestination(
        icon: Icon(Icons.admin_panel_settings_outlined),
        selectedIcon: Icon(Icons.admin_panel_settings),
        label: 'Admin',
      ));
    }

    final int effectiveIndex = (_selectedIndex < pages.length) ? _selectedIndex : 0;

    return Scaffold(
      body: IndexedStack(
        index: effectiveIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: destinations,
        // Material You 3 styling
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}