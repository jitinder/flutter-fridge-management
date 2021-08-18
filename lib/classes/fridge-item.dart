import 'dart:convert';

class FridgeItem {
  final String barcode;
  final String imageUrl;
  String name;
  final DateTime dateAdded;
  DateTime _dateExpiring;

  FridgeItem({
    this.barcode,
    this.imageUrl,
    this.name,
    this.dateAdded,
  });

  factory FridgeItem.fromJson(Map<String, dynamic> json) {
    return FridgeItem(
      barcode: json['code'],
      imageUrl: json['product']['image_url'],
      name: json['product']['product_name'],
      dateAdded: DateTime.now(),
    );
  }

  factory FridgeItem.fromSharedPrefs(Map<String, dynamic> json) {
    FridgeItem item = FridgeItem(
      barcode: json['code'],
      imageUrl: json['image_url'],
      name: json['name'],
      dateAdded: DateTime.parse(json['dateAdded']),
    );
    item.dateExpiring = DateTime.parse(json['dateExpiring']);
    return item;
  }

  factory FridgeItem.invalid() {
    return FridgeItem(
      barcode: null,
      imageUrl: null,
      name: "",
      dateAdded: DateTime.now(),
    );
  }

  DateTime get dateExpiring => _dateExpiring;

  set dateExpiring(DateTime value) {
    _dateExpiring = value;
  }

  static Map<String, dynamic> toMap(FridgeItem item) => {
        'barcode': item.barcode,
        'imageUrl': item.imageUrl,
        'name': item.name,
        'dateAdded': item.dateAdded.toString(),
        'dateExpiring': item.dateExpiring.toString(),
      };

  static String encode(List<FridgeItem> items) => jsonEncode(
        items
            .map<Map<String, dynamic>>((item) => FridgeItem.toMap(item))
            .toList(),
      );

  static List<FridgeItem> decode(String items) =>
      (jsonDecode(items) as List<dynamic>)
          .map<FridgeItem>((item) => FridgeItem.fromSharedPrefs(item))
          .toList();

  @override
  String toString() {
    return 'FridgeItem{barcode: $barcode, imageUrl: $imageUrl, name: $name, dateAdded: $dateAdded, dateExpiring: $dateExpiring}';
  }
}
