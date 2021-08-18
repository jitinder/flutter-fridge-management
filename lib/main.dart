import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fridge_management/api-manager.dart';
import 'package:shape_of_view/shape_of_view.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'classes/fridge-item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fridge Management',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'F.I.N.A.L'), // Fridge Item Notifying AppLication
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String dropdownValue = "Expiry (Earliest)";
  List<FridgeItem> items = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSharedPrefs();
  }

  void _loadSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String itemsString = prefs.getString('items_key');
    if (itemsString == null) {
      setState(() {
        items = [];
      });
    } else {
      setState(() {
        items = FridgeItem.decode(itemsString);
        _sortItems();
      });
    }
  }

  void _addItem(FridgeItem fridgeItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      items.add(fridgeItem);
      _sortItems();
    });
    prefs.setString('items_key', FridgeItem.encode(items));
  }

  void _deleteItem(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      items.removeAt(index);
    });
    prefs.setString('items_key', FridgeItem.encode(items));
  }

  Widget _infoColumn(String title, String value, Color color) {
    var maxWidth = MediaQuery.of(context).size.width / 4;
    return Container(
      width: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: color,
                  ),
                ),
                SizedBox(
                  width: 7.5,
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666",
      "Cancel",
      false,
      ScanMode.BARCODE,
    );
    // If -1, cancelled - Show manual entry dialog
    // else find item and show dialog with result from openfoodfacts
    print("Barcode scan result: " + barcodeScanRes);
    return barcodeScanRes;
  }

  void _showLoadingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return SimpleDialog(
            title: Text("Fetching Item Information..."),
            titlePadding: EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            children: [
              Center(
                child: CircularProgressIndicator(),
              ),
            ],
          );
        });
  }

  void _selectDate(StateSetter setter) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setter(() {
        selectedDate = picked;
      });
  }

  void _showItemSheet(FridgeItem fridgeItem) {
    selectedDate = DateTime.now();
    TextEditingController _controller =
        TextEditingController(text: fridgeItem.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setter) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 24,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                ),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShapeOfView(
                    shape: CircleShape(),
                    elevation: 0,
                    child: fridgeItem.imageUrl != null
                        ? Image.network(
                            fridgeItem.imageUrl,
                            height: 150,
                            width: 150,
                            fit: BoxFit.fitHeight,
                          )
                        : Image.asset(
                            "images/food.png",
                            height: 150,
                            width: 150,
                            fit: BoxFit.fitHeight,
                          ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 100,
                          child: TextField(
                            controller: _controller,
                            enabled: true,
                            onSubmitted: (String text) {
                              setter(() {
                                fridgeItem.name = text;
                              });
                            },
                          ),
                        ),
                        Icon(Icons.edit),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _selectDate(setter);
                    },
                    child: Text(
                      "Expiry Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}",
                    ),
                  ),
                  ButtonBar(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel"),
                      ),
                      RaisedButton(
                        onPressed: () {
                          fridgeItem.dateExpiring = selectedDate;
                          _addItem(fridgeItem);
                          Navigator.pop(context);
                        },
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: Text("Add"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  int _getExpiredItemCount() {
    DateTime expiryThreshold = DateTime.now();
    int count = 0;
    for (FridgeItem item in items) {
      if (item.dateExpiring.isBefore(expiryThreshold)) {
        count++;
      }
    }
    return count;
  }

  void _sortItems() {
    if (dropdownValue == 'Expiry (Earliest)') {
      _sortByExpiry(true);
    } else if (dropdownValue == 'Expiry (Latest)') {
      _sortByExpiry(false);
    } else if (dropdownValue == 'Name (Ascending)') {
      _sortByName(true);
    } else {
      _sortByName(false);
    }
  }

  void _sortByExpiry(bool earliest) {
    items.sort((a, b) => a.dateExpiring.isBefore(b.dateExpiring) ? -1 : 1);
    if (!earliest) {
      items = items.reversed.toList();
    }
  }

  void _sortByName(bool asc) {
    items.sort((a, b) => a.name.compareTo(b.name));
    if (!asc) {
      items = items.reversed.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    var topHeight = MediaQuery.of(context).size.height * 4 / 10;

    return Scaffold(
      backgroundColor: Colors.deepPurple,
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton.extended(
        label: Text("New Item"),
        icon: Icon(Icons.add),
        onPressed: () {
          _scanBarcode().then((barcode) {
            if (barcode == -1) {
              // Show manual entry dialog
              _showItemSheet(FridgeItem.invalid());
            } else {
              // Show info dialog
              _showLoadingDialog();

              OpenFoodFacts.getFridgeItem(barcode).then((fridgeItem) {
                // Dismiss loading dialog
                Navigator.pop(context);
                _showItemSheet(fridgeItem);
              });
            }
          });
        },
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: topHeight,
              width: MediaQuery.of(context).size.width,
              // alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Hi Sidak",
                    style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Your Fridge Items",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12),
                      // color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _infoColumn(
                              "Total", items.length.toString(), Colors.blue),
                          _infoColumn(
                              "Valid",
                              (items.length - _getExpiredItemCount())
                                  .toString(),
                              Colors.green),
                          _infoColumn("Expired",
                              _getExpiredItemCount().toString(), Colors.red),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: topHeight - 10),
              height: MediaQuery.of(context).size.height - topHeight,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                ),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Item List",
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                  icon: Icon(Icons.sort),
                                  value: dropdownValue,
                                  items: <String>[
                                    'Expiry (Earliest)',
                                    'Expiry (Latest)',
                                    'Name (Ascending)',
                                    'Name (Descending)'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      dropdownValue = newValue;
                                      _sortItems();
                                    });
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: ListView.separated(
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        FridgeItem item = items[index];
                        return ListTile(
                          leading: ShapeOfView(
                            shape: CircleShape(),
                            elevation: 0,
                            child: item.imageUrl != null
                                ? Image.network(
                                    item.imageUrl,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.fitHeight,
                                  )
                                : Image.asset(
                                    "images/food.png",
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.fitHeight,
                                  ),
                          ),
                          title: Text(item.name),
                          subtitle: Text(DateFormat('dd MMM yyyy')
                              .format(item.dateExpiring)),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteItem(index);
                            },
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
