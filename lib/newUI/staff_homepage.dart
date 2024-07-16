// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/admin_drawer.dart';
import 'package:hisab_kitab/newUI/card_wigdet.dart';
import 'package:hisab_kitab/newUI/drawer.dart';
import 'package:hisab_kitab/newUI/homepage_body.dart';
import 'package:hisab_kitab/newUI/row_card_widget.dart';
import 'package:hisab_kitab/newUI/staff_drawer.dart';
import 'package:hisab_kitab/pages/log_in_page.dart';
import 'package:hisab_kitab/pages/sign_up_page.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_active_outlined),
          ),
        ],
        title: const Text("Hamro Baazar"),
      ),
      body: HomepageBody(),
      drawer: StaffDrawer(),
    );
  }
}
