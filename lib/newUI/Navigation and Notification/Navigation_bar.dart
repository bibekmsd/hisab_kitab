import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/analytics_page.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/Homepage.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/settings_page.dart';

class NavigationBarBanako extends StatefulWidget {
  final String userRole;
  final String username; // Add username parameter

  const NavigationBarBanako(
      {super.key,
      required this.userRole,
      required this.username}); // Update constructor

  @override
  _NavigationBarBanakoState createState() => _NavigationBarBanakoState();
}

class _NavigationBarBanakoState extends State<NavigationBarBanako> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages;

    print("Navigation role: ${widget.userRole}"); // Debug print

    // Pass username to pages that need it
    if (widget.userRole == 'admin') {
      pages = [
        HomePage(userRole: widget.userRole, username: widget.username),
        AnalyticsPage() // Update constructor if needed
      ];
    } else {
      pages = [
        HomePage(userRole: widget.userRole, username: widget.username),
        AnalyticsPage() // Update constructor if needed
      ];
    }

    return Scaffold(
      body: pages[currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (value) {
          setState(() {
            currentPage = value;
          });
        },
        iconSize: 28,
        items: const [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home_outlined),
          ),
          BottomNavigationBarItem(
            label: "Analytics",
            icon: Icon(Icons.auto_graph_outlined),
          ),
          BottomNavigationBarItem(
            label: "Settings",
            icon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}
