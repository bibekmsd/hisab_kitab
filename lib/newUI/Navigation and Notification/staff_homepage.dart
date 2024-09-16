// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/homepage_body.dart';

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
      // drawer: StaffUserScreen(
      //     userName: userName,
      //     shopName: shopName,
      //     phoneNumber: phoneNumber,
      //     loginTime: loginTime),
    );
  }
}
