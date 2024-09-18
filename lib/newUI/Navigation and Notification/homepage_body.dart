import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hisab_kitab/newUI/Drawers/newAdminDrawer.dart';
import 'package:hisab_kitab/newUI/Drawers/newStaffDrawer.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/Add%20Products/nabhetekoProductAdd.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/My%20Stock/my_stock.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/My%20customers/my_customers.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/New%20Bill/newBill.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/Transactions.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/analytics_page.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/categories.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/notification.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/return_item.dart';
import 'package:hisab_kitab/newUI/settings%20folder/settings_page.dart';
import 'package:hisab_kitab/reuseable_widgets/row_card_widget.dart';
import 'package:hisab_kitab/utils/gradiants.dart';

class HomePage extends StatefulWidget {
  final String userRole;
  final String username;

  // ignore: use_super_parameters
  const HomePage({Key? key, required this.userRole, required this.username})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    // Initialize _pages list based on the user's role
    _pages.addAll([
      HomepageBody(userRole: widget.userRole), // Home page
      const AnalyticsPage(), // Analytics
      const SettingsPage(), // Settings
    ]);
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

class HomepageBody extends StatelessWidget {
  final String userRole;

  const HomepageBody({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const HeroIcon(HeroIcons.bell),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: userRole == 'admin' ? AdminDrawer() : StaffDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              BanakoCardRow(
                width: double.infinity,
                height: 120,
                title: "New Bill",
                subtitle: "Create a new bill",
                backgroundGradient: MeroGradiant(),
                radius: 16,
                rakhneIcon: Icons.shopping_cart_checkout_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Newbill(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return _buildGridItem(
                          "My Stock",
                          HeroIcons.cube,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyStock())),
                        );
                      case 1:
                        return _buildGridItem(
                          "Transactions",
                          HeroIcons.documentText,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const TransactionsPage())),
                        );
                      case 2:
                        return _buildGridItem(
                          "Customers",
                          HeroIcons.userGroup,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyCustomers())),
                        );
                      case 3:
                        return _buildGridItem(
                          "Return Item",
                          HeroIcons.arrowUturnLeft,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ReturnItem())),
                        );
                      case 4:
                        return _buildGridItem(
                          "Add Products",
                          HeroIcons.plusCircle,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const NabhetekoProductPage())),
                        );
                      case 5:
                        return _buildGridItem(
                          "Categories",
                          HeroIcons.tag,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CategoriesPage())),
                        );
                      default:
                        return Container();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(String text, HeroIcons heroIcon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: MeroGradiant(),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: HeroIcon(
                  heroIcon,
                  size: 32,
                  // color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(
                  // color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
