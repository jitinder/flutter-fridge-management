import 'dart:convert';
import 'classes/fridge-item.dart';
import 'package:http/http.dart' as http;

class OpenFoodFacts {
  static Future<FridgeItem> getFridgeItem(String barcode) async {
    String apiUrl =
        "https://world.openfoodfacts.org/api/v0/product/$barcode.json";
    http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      //  successful
      try {
        FridgeItem fridgeItem = FridgeItem.fromJson(jsonDecode(response.body));
        return fridgeItem;
      } catch (e) {
        return FridgeItem.invalid();
      }
    } else {
      //  unsuccessful
    }
  }
}
