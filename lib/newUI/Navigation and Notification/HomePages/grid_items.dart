import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/My%20Stock/my_stock.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/Transactions.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/My%20customers/my_customers.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/return_item.dart';
import 'package:hisab_kitab/newUI/Home%20page%20icons/Add%20Products/nabhetekoProductAdd.dart';
import 'package:hisab_kitab/newUI/Navigation%20and%20Notification/categories.dart';
import 'package:hisab_kitab/utils/gradiants.dart';

class GridItemData {
  final String text;
  final HeroIcons icon;
  final Widget page;

  GridItemData(this.text, this.icon, this.page);
}

Widget buildGridItem(GridItemData data, BuildContext context) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => data.page)),
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
                data.icon,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

GridItemData getGridItemData(int index) {
  switch (index) {
    case 0:
      return GridItemData("My Stock", HeroIcons.cube, const MyStock());
    case 1:
      return GridItemData(
          "Transactions", HeroIcons.documentText, const TransactionsPage());
    case 2:
      return GridItemData(
          "Customers", HeroIcons.userGroup, const MyCustomers());
    case 3:
      return GridItemData(
          "Return Item", HeroIcons.arrowUturnLeft, const ReturnItem());
    case 4:
      return GridItemData(
          "Add Products", HeroIcons.plusCircle, const NabhetekoProductPage());
    case 5:
      return GridItemData("Categories", HeroIcons.tag, CategoriesPage());
    default:
      throw Exception("Invalid index");
  }
}
