// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last
import 'package:flutter/material.dart';
import 'package:hisab_kitab/newUI/card_wigdet.dart';
import 'package:hisab_kitab/newUI/my_stock.dart';
import 'package:hisab_kitab/newUI/newBill.dart';
import 'package:hisab_kitab/newUI/row_card_widget.dart';

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
        child: Column(children: [
          BanakoCardRow(
            width: double.infinity,
            height: 150,
            title: "New Bill",
            subtitle: "Naaya-Bill",
            textColor: Colors.white,
            backgroundGradient: LinearGradient(
              colors: const [
                Color.fromARGB(255, 34, 34, 34), // Dark grey
                Color.fromARGB(255, 45, 12, 65), // Dark purple
                Color.fromARGB(255, 79, 65, 34), // Dark gold
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            radius: 16,
            rakhneIcon: Icons.shopping_cart_checkout,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const Newbill();
                },
              ));
            },
          ),
          SizedBox(height: 20), // Add some spacing
          Container(
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 235, 229, 233),
                borderRadius: BorderRadius.circular(12)),
            height: 120,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  BanakoCardColumn(
                    text: "My      Stock",
                    textColor: Colors.white,
                    backgroundGradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 34, 34, 34), // Dark grey
                        Color.fromARGB(255, 45, 12, 65), // Dark purple
                        Color.fromARGB(255, 79, 65, 34), // Dark gold
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    radius: 16,
                    rakhneIcon: Icons.store_mall_directory_outlined,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const MyStock();
                        },
                      ));
                    },
                  ),
                  BanakoCardColumn(
                    text: "View Supplies",
                    textColor: Colors.white,
                    backgroundGradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 34, 34, 34), // Dark grey
                        Color.fromARGB(255, 45, 12, 65), // Dark purple
                        Color.fromARGB(255, 79, 65, 34), // Dark gold
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    radius: 16,
                    rakhneIcon: Icons.view_list_outlined,
                    onTap: () {},
                  ),
                  BanakoCardColumn(
                    text: "My Customers",
                    textColor: Colors.white,
                    backgroundGradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 34, 34, 34), // Dark grey
                        Color.fromARGB(255, 45, 12, 65), // Dark purple
                        Color.fromARGB(255, 79, 65, 34), // Dark gold
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    radius: 16,
                    rakhneIcon: Icons.person_search_sharp,
                    onTap: () {},
                  ),
                  BanakoCardColumn(
                    text: "Post  Orders",
                    textColor: Colors.white,
                    backgroundGradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 34, 34, 34), // Dark grey
                        Color.fromARGB(255, 45, 12, 65), // Dark purple
                        Color.fromARGB(255, 79, 65, 34), // Dark gold
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    radius: 16,
                    rakhneIcon: Icons.pages,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ]));
  }
}
