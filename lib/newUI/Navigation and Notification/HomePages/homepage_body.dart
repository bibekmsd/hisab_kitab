import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hisab_kitab/newUI/Drawers/newAdminDrawer.dart';
import 'package:hisab_kitab/newUI/Drawers/newStaffDrawer.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/New%20Bill/newBill.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/HomePages/grid_items.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/notification.dart';
import 'package:hisab_kitab/reuseable_widgets/row_card_widget.dart';
import 'package:hisab_kitab/utils/gradiants.dart';


class HomepageBody extends StatelessWidget {
  final String userRole;
  final String email;
  final String panNo;

  const HomepageBody({
    Key? key,
    required this.userRole,
    required this.email,
    required this.panNo,
  }) : super(key: key);

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
      drawer: userRole == 'admin'
          ? AdminDrawer(email: email, panNo: panNo)
          : const StaffDrawer(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      BanakoCardRow(
                        width: double.infinity,
                        height: constraints.maxHeight * 0.25,
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
                      const SizedBox(height: 40),
                      Opacity(
                        opacity: 0.3,
                        child: Image.asset(
                          'assets/logo.png',
                          width: double.infinity,
                          height: constraints.maxHeight * 0.15,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return buildGridItem(getGridItemData(index), context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
