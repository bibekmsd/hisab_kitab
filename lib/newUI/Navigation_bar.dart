// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:hisab_kitab/admin/admin_page.dart';
import 'package:hisab_kitab/newUI/drawer.dart';
// Assuming this is a typo in your import
import 'package:hisab_kitab/newUI/row_card_widget.dart';
import 'package:hisab_kitab/newUI/Homepage.dart';
import 'package:hisab_kitab/user/staff_user_page.dart';

class NavigationBarBanako extends StatefulWidget {
  const NavigationBarBanako({super.key});

  @override
  State<NavigationBarBanako> createState() => _NavigationBarBanakoState();
}

class _NavigationBarBanakoState extends State<NavigationBarBanako> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [HomePage(), AdminUserScreen(), StaffUserScreen()];

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
        items: [
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
      drawer: BanakoDrawer(),
    );
  }
}
