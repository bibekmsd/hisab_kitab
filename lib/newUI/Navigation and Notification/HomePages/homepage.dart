import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/analytics_page.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/HomePages/homepage_body.dart';
import 'package:hisab_kitab/newUI/settings%20folder/settings_page.dart';


class HomePage extends StatefulWidget {
  final String userRole;
  final String username;
  final String email;
  final String panNo;

  const HomePage({
    Key? key,
    required this.userRole,
    required this.username,
    required this.email,
    required this.panNo,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomepageBody(
        userRole: widget.userRole,
        email: widget.email,
        panNo: widget.panNo,
      ),
      const AnalyticsPage(),
      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: "Home",
            icon: HeroIcon(HeroIcons.home),
          ),
          BottomNavigationBarItem(
            label: "Analytics",
            icon: HeroIcon(HeroIcons.chartBar),
          ),
          BottomNavigationBarItem(
            label: "Settings",
            icon: HeroIcon(HeroIcons.cog),
          ),
        ],
      ),
    );
  }
}
