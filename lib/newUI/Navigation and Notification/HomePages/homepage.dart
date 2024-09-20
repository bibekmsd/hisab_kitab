import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/analytics_page.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/HomePages/homepage_body.dart';
import 'package:hisab_kitab/newUI/settings%20folder/settings_page.dart';
import 'package:hisab_kitab/utils/constants/appcolors.dart';

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
  late List<String> _pageTitles;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

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
    _pageTitles = ['Home', 'Analytics', 'Settings'];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: _currentIndex,
          height: 60.0,
          items: const <Widget>[
            HeroIcon(HeroIcons.home, color: Colors.white),
            Icon(Icons.auto_graph_sharp, color: Colors.white),
            HeroIcon(HeroIcons.cog, color: Colors.white),
          ],
          color: const Color.fromARGB(255, 20, 110, 180),
          // rgba(20, 110, 180, 255)
          buttonBackgroundColor: AppColors.bottomNavBarColor,
          backgroundColor: Colors.white,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 400),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          letIndexChange: (index) => true,
        ),
      ),
    );
  }
}
