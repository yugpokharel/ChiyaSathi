import 'package:chiya_sathi/features/menu/data/repositories/menu_repository.dart';
import 'package:chiya_sathi/features/menu/domain/entities/menu_item.dart';
import 'package:flutter/material.dart';

class MenuCategoryScreen extends StatelessWidget {
  final String category;
  const MenuCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final menuItems = MenuRepository().getMenuItemsByCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.orange.shade400,
      ),
      body: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return MenuItemCard(item: item);
        },
      ),
    );
  }
}

class MenuItemCard extends StatefulWidget {
  final MenuItem item;

  const MenuItemCard({super.key, required this.item});

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> {
  int _quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                widget.item.image ?? 'assets/images/placeholder.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/placeholder.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${widget.item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (_quantity > 0) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
