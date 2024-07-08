// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last
import 'package:flutter/material.dart';
import 'package:hisab_kitab/pages/log_in_page.dart';
import 'package:hisab_kitab/pages/sign_up_page.dart';

class BanakoDrawer extends StatefulWidget {
  const BanakoDrawer({super.key});

  @override
  State<BanakoDrawer> createState() => _BanakoDrawerState();
}

class _BanakoDrawerState extends State<BanakoDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top section with header and list items
          Column(
            children: [
              SizedBox(
                height: 80,
                width: double.infinity,
                child: const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 49, 55, 61),
                  ),
                  child: Text(
                    'Utilities',
                    style: TextStyle(color: Color.fromARGB(255, 230, 220, 220)),
                  ),
                  curve: Curves.bounceIn,
                  duration: Durations.medium2,
                ),
              ),
              ListTile(
                title: const Text('Item 1'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          ),
          // Footer section with login and signup options

          Column(
            children: [
              Divider(
                height: 0,
              ),
              ListTile(
                leading: Icon(Icons.login),
                title: Text('Login'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return SignInPage();
                    },
                  ));
                },
              ),
              Divider(
                height: 0,
              ),
              ListTile(
                leading: Icon(Icons.app_registration),
                title: Text('Signup'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return SignUpPage();
                    },
                  ));
                },
              ),
            ],
          ),
        ],
      ),
      width: 200,
    );
  }
}
