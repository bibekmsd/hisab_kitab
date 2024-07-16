// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last
import 'package:flutter/material.dart';
import 'package:hisab_kitab/pages/log_in_page.dart';
import 'package:hisab_kitab/pages/sign_up_page.dart';

class ReusableDrawer extends StatelessWidget {
  final String shopName;
  final String userName;
  final String loginTime;
  final String phoneNumber;
  final Color headerColor;
  final List<Widget> drawerItems;
  final List<Widget> footerItems;
  final double height;

  const ReusableDrawer({
    super.key,
    required this.shopName,
    required this.userName,
    required this.loginTime,
    required this.phoneNumber,
    this.headerColor = const Color.fromARGB(255, 49, 55, 61),
    required this.drawerItems,
    required this.footerItems,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(
                height: height,
                width: double.infinity,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: headerColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shopName,
                        style: TextStyle(
                          color: Color.fromARGB(255, 230, 220, 220),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'User: $userName',
                        style: TextStyle(
                          color: Color.fromARGB(255, 230, 220, 220),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Login Time: $loginTime',
                        style: TextStyle(
                          color: Color.fromARGB(255, 230, 220, 220),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Phone: $phoneNumber',
                        style: TextStyle(
                          color: Color.fromARGB(255, 230, 220, 220),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...drawerItems,
            ],
          ),
          Column(
            children: footerItems,
          ),
        ],
      ),
      width: 200,
    );
  }
}
