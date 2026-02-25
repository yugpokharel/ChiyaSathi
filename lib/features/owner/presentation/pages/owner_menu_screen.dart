import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chiya_sathi/features/menu/presentation/providers/menu_provider.dart';
import 'package:chiya_sathi/features/menu/domain/entities/menu_item.dart';

class OwnerMenuScreen extends ConsumerStatefulWidget {
  const OwnerMenuScreen({super.key});

  @override
  ConsumerState<OwnerMenuScreen> createState() => _OwnerMenuScreenState();
}

class _OwnerMenuScreenState extends ConsumerState<OwnerMenuScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(menuProvider.notifier).fetchMenu());
  }

  @override
  Widget build(BuildContext context) {
    final menu = ref.watch(menuProvider);
    final categories = menu.categories;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Menu Management',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.orange.shade700),
            onPressed: () => ref.read(menuProvider.notifier).fetchMenu(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange.shade400,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Item',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        onPressed: () => _showAddDialog(context),
      ),
      body: menu.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.restaurant_menu,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No menu items yet',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade500)),
                      const SizedBox(height: 8),
                      Text('Tap + to add your first item',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade400)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final items = menu.byCategory(category);
                    return _CategorySection(
                      category: category,
                      items: items,
                      onEdit: (item) => _showEditDialog(context, item),
                      onDelete: (item) => _showDeleteConfirm(context, item),
                    );
                  },
                ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedCategory = 'Tea';
    final categories = ['Tea', 'Coffee', 'Cigarette', 'Snacks'];
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Menu Item',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.fastfood),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price (Rs.)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v.trim()) == null) return 'Invalid';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setDialogState(() => selectedCategory = v);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade400,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                final ok = await ref.read(menuProvider.notifier).addItem(
                      name: nameCtrl.text.trim(),
                      price: double.parse(priceCtrl.text.trim()),
                      category: selectedCategory,
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Item added!' : 'Failed to add item'),
                      backgroundColor: ok ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child:
                  const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, MenuItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final priceCtrl =
        TextEditingController(text: item.price.toStringAsFixed(0));
    String selectedCategory = item.category;
    final categories = ['Tea', 'Coffee', 'Cigarette', 'Snacks'];
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Menu Item',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.fastfood),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price (Rs.)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v.trim()) == null) return 'Invalid';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setDialogState(() => selectedCategory = v);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade400,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                final ok = await ref.read(menuProvider.notifier).updateItem(
                      itemId: item.id,
                      name: nameCtrl.text.trim(),
                      price: double.parse(priceCtrl.text.trim()),
                      category: selectedCategory,
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(ok ? 'Item updated!' : 'Failed to update'),
                      backgroundColor: ok ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child:
                  const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, MenuItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Item',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Remove "${item.name}" from the menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok =
                  await ref.read(menuProvider.notifier).deleteItem(item.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Item deleted' : 'Failed to delete'),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Category Section ──────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  final String category;
  final List<MenuItem> items;
  final ValueChanged<MenuItem> onEdit;
  final ValueChanged<MenuItem> onDelete;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _categoryColor(category).withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _categoryIcon(category),
              color: _categoryColor(category),
              size: 22,
            ),
          ),
          title: Text(
            category,
            style:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          subtitle: Text(
            '${items.length} items',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          children: items
              .map((item) => _MenuItemTile(
                    item: item,
                    onEdit: () => onEdit(item),
                    onDelete: () => onDelete(item),
                  ))
              .toList(),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Tea':
        return Icons.emoji_food_beverage;
      case 'Coffee':
        return Icons.coffee;
      case 'Cigarette':
        return Icons.smoking_rooms;
      case 'Snacks':
        return Icons.lunch_dining;
      default:
        return Icons.fastfood;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Tea':
        return Colors.green;
      case 'Coffee':
        return Colors.brown;
      case 'Cigarette':
        return Colors.blueGrey;
      case 'Snacks':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

// ─── Single Menu Item Tile ─────────────────────────────────────────────────

class _MenuItemTile extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MenuItemTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(Icons.fastfood, size: 20, color: Colors.grey.shade400),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.name,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500)),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Rs. ${item.price.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.green.shade700,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.edit, size: 18, color: Colors.blue.shade400),
            onPressed: onEdit,
            splashRadius: 20,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 18, color: Colors.red.shade400),
            onPressed: onDelete,
            splashRadius: 20,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}

