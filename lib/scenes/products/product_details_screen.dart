class Product {
  final int id;
  final String name;
  final String category;
  final int quantity;
  final String location;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.location,
  });
} // Map to PostgreSQL later