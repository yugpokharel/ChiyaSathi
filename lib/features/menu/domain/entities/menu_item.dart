class MenuItem {
  final String id;
  final String name;
  final double price;
  final String? image;
  final String category;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.image,
    required this.category,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    var image = json['image'] as String?;
    if (image != null && image.isNotEmpty && !image.startsWith('http')) {
      image = 'http://192.168.1.5:5000$image';
    }
    return MenuItem(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      image: image,
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'category': category,
      if (image != null) 'image': image,
    };
  }

  MenuItem copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    String? category,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      category: category ?? this.category,
    );
  }
}
