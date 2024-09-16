import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/return_item.dart';
import 'package:hisab_kitab/reuseable_widgets/card_wigdet.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/My%20customers/my_customers.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/My%20Stock/my_stock.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/Add%20Products/nabhetekoProductAdd.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/New%20Bill/newBill.dart';
import 'package:hisab_kitab/reuseable_widgets/row_card_widget.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/staff_homepage.dart';
import 'package:hisab_kitab/pages/sign_up_page.dart';
import 'package:hisab_kitab/utils/gradiants.dart';

class HomepageBody extends StatefulWidget {
  const HomepageBody({super.key});

  @override
  State<HomepageBody> createState() => _HomepageBodyState();
}

class _HomepageBodyState extends State<HomepageBody> {
  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  builder: (context) {
                    return const Newbill();
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 20), // Add some spacing

          Expanded(
            child: GridView.builder(
              // scrollDirection: Axis.vertical,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 items per row
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1, // Adjust as needed
              ),
              itemCount: 6, // Number of items
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
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return const MyStock();
                          },
                        ));
                      },
                    );
                  case 1:
                    return BanakoCardColumn(
                        text: "View\nSupplies",
                        textColor: Colors.white,
                        backgroundGradient: MeroGradiant(),
                        radius: 16,
                        rakhneIcon: Icons.view_list_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const StaffHomePage();
                              },
                            ),

                            ////
                          );
                        });
                  case 2:
                    return BanakoCardColumn(
                        text: "My\nCustomers",
                        textColor: Colors.white,
                        backgroundGradient: MeroGradiant(),
                        radius: 16,
                        rakhneIcon: Icons.person_search_sharp,
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const MyCustomers();
                          }));
                        });
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
                            builder: (context) {
                              return ReturnItem();
                            },
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
                            builder: (context) {
                              return NabhetekoProductPage();
                            },
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
                            builder: (context) {
                              return const SignUpPage();
                            },
                          ),
                        );
                      },
                    );
                  default:
                    return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
