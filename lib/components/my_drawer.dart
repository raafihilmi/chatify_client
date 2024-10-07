import 'package:chatify_client/pages/settings_page.dart';
import 'package:flutter/material.dart';

import '../services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    final authService = AuthService();
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                  child: Center(
                child: Icon(
                  Icons.message,
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
              )),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text("Home"),
                      leading: const Icon(Icons.home),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text("Settings"),
                      leading: const Icon(Icons.settings),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 32),
            child: ListTile(
              title: const Text("Logout"),
              leading: const Icon(Icons.logout),
              onTap: logout,
            ),
          ),
        ],
      ),
    );
  }
}
