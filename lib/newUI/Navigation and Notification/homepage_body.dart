import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/Transactions.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/return_item.dart';
import 'package:hisab_kitab/newUI/Drawers/newAdminDrawer.dart';
import 'package:hisab_kitab/newUI/Drawers/newStaffDrawer.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/analytics_page.dart';
import 'package:hisab_kitab/newUI/settings%20folder/settings_page.dart';
import 'package:hisab_kitab/reuseable_widgets/card_wigdet.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/My%20customers/my_customers.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/My%20Stock/my_stock.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/Add%20Products/nabhetekoProductAdd.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/New%20Bill/newBill.dart';
import 'package:hisab_kitab/reuseable_widgets/row_card_widget.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/return_item.dart';
import 'package:hisab_kitab/pages/sign_up_page.dart';
import 'package:hisab_kitab/utils/gradiants.dart';

class HomePage extends StatefulWidget {
  final String userRole;
  final String username;

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
    print(widget.userRole);
    print(widget.username);
    super.initState();
    // Initialize _pages list based on the user's role
    _pages.addAll([
      HomepageBody(userRole: widget.userRole), // Home page
      AnalyticsPage(), // Analytics
      SettingsPage(), // Settings
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the current page based on _currentIndex
      body: _pages[_currentIndex],

      // Bottom navigation bar to switch between pages
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

class HomepageBody extends StatelessWidget {
  final String userRole;

  const HomepageBody({Key? key, required this.userRole}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notification button press
            },
          ),
        ],
      ),
      // Conditional drawer based on userRole
      drawer: userRole == 'admin' ? AdminDrawer() : StaffDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              BanakoCardRow(
                width: double.infinity,
                height: 150,
                title: "New Bill",
                subtitle: "Naaya-Bill",
                textColor: Colors.white,
                backgroundGradient: MeroGradiant(),
                radius: 16,
                rakhneIcon: Icons.shopping_cart_checkout,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Newbill(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return BanakoCardColumn(
                          text: "My\nStock",
                          textColor: Colors.white,
                          backgroundGradient: MeroGradiant(),
                          radius: 16,
                          rakhneIcon: Icons.store_mall_directory_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyStock(),
                              ),
                            );
                          },
                        );
                      case 1:
                        return BanakoCardColumn(
                          text: "My\nTransactions",
                          textColor: Colors.white,
                          backgroundGradient: MeroGradiant(),
                          radius: 16,
                          rakhneIcon: Icons.view_list_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TransactionsPage(),
                              ),
                            );
                          },
                        );
                      case 2:
                        return BanakoCardColumn(
                          text: "My\nCustomers",
                          textColor: Colors.white,
                          backgroundGradient: MeroGradiant(),
                          radius: 16,
                          rakhneIcon: Icons.person_search_sharp,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyCustomers(),
                              ),
                            );
                          },
                        );
                      case 3:
                        return BanakoCardColumn(
                          text: "Return\nItem",
                          textColor: Colors.white,
                          backgroundGradient: MeroGradiant(),
                          radius: 16,
                          rakhneIcon: Icons.pages,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReturnItem(),
                              ),
                            );
                          },
                        );
                      case 4:
                        return BanakoCardColumn(
                          text: "Add\nProducts",
                          textColor: Colors.white,
                          backgroundGradient: MeroGradiant(),
                          radius: 16,
                          rakhneIcon: Icons.store_mall_directory_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NabhetekoProductPage(),
                              ),
                            );
                          },
                        );
                      case 5:
                        return BanakoCardColumn(
                          text: "Add\nStaff",
                          textColor: Colors.white,
                          backgroundGradient: MeroGradiant(),
                          radius: 16,
                          rakhneIcon: Icons.person_3_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpPage(),
                              ),
                            );
                          },
                        );
                      default:
                        return Container(); // Default empty container for unexpected cases
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
}
