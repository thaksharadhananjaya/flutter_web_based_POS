import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'util/comfirmDailogBox.dart';

class Inventory extends StatefulWidget {
  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  String category = "All";
  int selectedIndex = 0;
  int itmSelect = 0;
  String itmID = "-1"; //for get data
  List<DropdownMenuItem<String>> items = new List();
  StreamController _streamControllerGetdata = StreamController();
  StreamController _streamControllerGetcat = StreamController();
  StreamController _streamControllerView = StreamController();
  StreamController _streamControllerNew = StreamController();

  var itmsearchControllr = TextEditingController();

  // FocusNode newVtnFoucusNode = new FocusNode();
  FocusNode newBtnFocusNode = new FocusNode();
  // FocusNode newBtnFocusNode = new FocusNode();

  Future getData() async {
    final response = await http.post("http://127.0.0.1/fetch_data.php", body: {
      "itemID": "$itmID",
      "category": "$category",
    });

    var data = await json.decode(response.body);
    _streamControllerView.add(data);
    _streamControllerNew.add(data);
    _streamControllerGetdata.add(data);
  }

  Future getCat() async {
    final response = await http.get('http://127.0.0.1//getCatogary.php');
    var data = await json.decode(response.body);

    items = new List();
    for (int i = 0; i < data.length; i++) {
      String cat = data[i]["Catogery"];
      if (cat == "All") {
        cat = "Uncategory";
      }
      items.add(new DropdownMenuItem(value: cat, child: new Text(cat)));
    }
    _streamControllerGetcat.add(data);
  }

  static Future<List> getItmSearch(String itemName) async {
    final response = await http.post("http://127.0.0.1/itemSearch.php", body: {
      "name": "$itemName",
    });
    var items = await json.decode(response.body);
    return List.generate(items.length, (index) {
      return {
        'id': items[index]["ID"],
        'name': items[index]["Item Name"],
        'quantity': items[index]["Quantity"],
        'alt_qty': items[index]["AltQty"],
        'Image': items[index]["image"]
      };
    });
  }

  Future deleteItemAll() async {
    final response =
        await http.post("http://127.0.0.1/deleteItemAll.php", body: {});
  }

  Future deleteItem(String itemId) async {
    final response = await http.post("http://127.0.0.1/deleteItem.php", body: {
      "ItemID": "$itemId",
    });
  }

  Future removeCategoy(String cat) async {
    final response = await http.post("http://127.0.0.1/removeCat.php", body: {
      "Category": "$cat",
    });
  }

  Future addItem(String itemId, String barcode, String name, String image,
      String bPrice, String sPrice, String qty, String altQ, String cat) async {
    final response = await http.post("http://127.0.0.1/addItem.php", body: {
      "ID": "$itemId",
      "BarCode": "$barcode",
      "Name": "$name",
      "Image": "$image",
      "BuyingPrice": "$bPrice",
      "SellingPrice": "$sPrice",
      "Quantity": "$qty",
      "Alt": "$altQ",
      "Category": "$cat",
    });
  }

  Future addCategory(String cat) async {
    final response = await http.post("http://127.0.0.1/addCat.php", body: {
      "Category": "$cat",
    });
  }

  Future updateItem(
      String itemId,
      String name,
      String bCode,
      String image,
      String bPrice,
      String sPrice,
      String qty,
      String altQty,
      String cat) async {
    final response = await http.post("http://127.0.0.1/updateItem.php", body: {
      "ItemID": "$itemId",
      "ItemName": "$name",
      "BarCode": "$bCode",
      "Image": "$image",
      "BuyingPrice": "$bPrice",
      "SellingPrice": "$sPrice",
      "Quantity": "$qty",
      "Alt": "$altQty",
      "Category": "$cat"
    });
  }

  Future insertReturnBill(String id, String name, String quantity) async {
    final response =
        await http.post("http://127.0.0.1/insertReturn.php", body: {
      "BillID": "",
      "ItemName": "$name",
      "ItemID": "$id",
      "Qty": "$quantity",
      "Bal": "0",
      "User": "TestUser",
      "Type": "Exipire",
    });
    print(id);
  }

  Timer _timer;
  void initState() {
    getData();
    getCat();
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      getData();
      getCat();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double ScreenWidth = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        newBtnFocusNode.requestFocus();
      },
      child: Container(
        color: Colors.transparent,
        height: ScreenHeight,
        width: ScreenWidth - 80,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 40),
                  child: Container(
                      padding: EdgeInsets.only(top: 5),
                      alignment: Alignment.center,
                      width: ScreenWidth / 2 - 30,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                            autofocus: false,
                            controller: itmsearchControllr,
                            onSubmitted: (text) {
                              if (text != "") {
                                itmID = text;
                                if (selectedIndex != 0) {
                                  setState(() {
                                    category = "All";
                                    selectedIndex = 0;
                                  });
                                }
                              }
                              newBtnFocusNode.requestFocus();
                            },
                            style: DefaultTextStyle.of(context)
                                .style
                                .copyWith(fontSize: 16),
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              contentPadding:
                                  EdgeInsets.only(top: 10, left: 10.0),
                              hintText: "Search...",
                              suffixIcon: Icon(
                                Icons.search,
                                color: Colors.grey.withOpacity(0.4),
                              ),
                            ),
                            enabled: true,
                            onChanged: (text) {
                              if (text.length == 0) {
                                itmID = "-1";
                              }
                            }),
                        suggestionsCallback: (pattern) async {
                          return await getItmSearch(pattern);
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            leading: Image.network(
                              "http://127.0.0.1/images/${suggestion['Image']}",
                              width: 40,
                              height: 40,
                              fit: BoxFit.scaleDown,
                            ),
                            title: AutoSizeText(
                              suggestion['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                            ),
                            subtitle: AutoSizeText(
                              double.parse(suggestion['quantity']) > 0
                                  ? 'Stock: ${suggestion['quantity']}'
                                  : "Out Of Stock",
                              style: TextStyle(
                                  color: double.parse(suggestion['quantity']) <
                                          1
                                      ? Colors.red[300]
                                      : (double.parse(suggestion['quantity']) <=
                                              double.parse(
                                                  suggestion['alt_qty'])
                                          ? Colors.orange[300]
                                          : Colors.green[300]),
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                            ),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          itmID = suggestion['id'];
                          itmsearchControllr.text = suggestion['name'];
                          if (selectedIndex != 0) {
                            setState(() {
                              category = "All";
                              selectedIndex = 0;
                            });
                          }
                        },
                      )),
                ),
                SizedBox(
                  height: 5,
                ),
                StreamBuilder(
                    stream: _streamControllerGetcat.stream,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          width: ScreenWidth / 2.1,
                          height: 40,
                          padding: EdgeInsets.only(left: 18),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: (ScreenWidth / 2.1) - 80,
                                  height: 40,
                                  child: ListView.builder(
                                    padding: EdgeInsets.all(8),
                                    itemCount: snapshot.data.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 24),
                                        child: Container(
                                          height: 40,
                                          child: GestureDetector(
                                            child: AutoSizeText(
                                              snapshot.data[index]["Catogery"],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: index == selectedIndex
                                                      ? Colors.black
                                                      : Colors.grey,
                                                  fontSize: 24),
                                              maxLines: 1,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                selectedIndex = index;
                                                itmSelect = 0;
                                                category = snapshot.data[index]
                                                    ["Catogery"];
                                              });
                                            },
                                            onLongPress: () {
                                              if (snapshot.data[index]
                                                      ["Catogery"] !=
                                                  "All") {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return ComfirmDailogBox(
                                                        title:
                                                            "${snapshot.data[index]["Catogery"]}",
                                                        descriptions:
                                                            "Remove this catogery",
                                                        yesButton: Container(
                                                          height: 32,
                                                          width: 75,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              color: Colors
                                                                  .red[300]),
                                                          child: FlatButton(
                                                              onPressed: () {
                                                                String
                                                                    category =
                                                                    snapshot.data[
                                                                            index]
                                                                        [
                                                                        "Catogery"];
                                                                removeCategoy(
                                                                    category);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                //selectedIndex=0;
                                                                getCat();
                                                                Flushbar(
                                                                  messageText:
                                                                      Text(
                                                                    '$category is removed',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  icon: Icon(
                                                                    Icons
                                                                        .info_outline,
                                                                    size: 28.0,
                                                                    color: Colors
                                                                            .blue[
                                                                        800],
                                                                  ),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              5),
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  borderRadius:
                                                                      8,
                                                                  maxWidth:
                                                                      ScreenWidth /
                                                                          2,
                                                                )..show(
                                                                    context);
                                                              },
                                                              child: Text(
                                                                "Yes",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    color: Colors
                                                                        .white),
                                                              )),
                                                        ),
                                                      );
                                                    });
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: 60,
                                  height: 36,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.blue),
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              FocusNode btnAddFocusNode =
                                                  new FocusNode();
                                              TextEditingController
                                                  catController =
                                                  new TextEditingController();
                                              return WillPopScope(
                                                onWillPop: () async => null,
                                                child: AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  title: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Icon(
                                                        Icons.category,
                                                        color: Colors.black87,
                                                      ),
                                                      SizedBox(
                                                        width: 20,
                                                      ),
                                                      Text(
                                                        "Add Category",
                                                      ),
                                                      SizedBox(
                                                        width: 260,
                                                      ),
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        child: IconButton(
                                                            icon: Icon(
                                                              Icons.close,
                                                              color: Colors.red,
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            }),
                                                      )
                                                    ],
                                                  ),
                                                  titlePadding: EdgeInsets.only(
                                                      left: 16,
                                                      top: 0,
                                                      bottom: 6),
                                                  content: Container(
                                                    width: 250,
                                                    height: 100,
                                                    child: Center(
                                                      child: Container(
                                                        height: 40,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(7),
                                                        ),
                                                        child: TextFormField(
                                                          autofocus: true,
                                                          controller:
                                                              catController,
                                                          onFieldSubmitted:
                                                              (category) {
                                                            if (category
                                                                .isNotEmpty) {
                                                              bool exitingID =
                                                                  true;
                                                              for (int i = 0;
                                                                  i <
                                                                      snapshot
                                                                          .data
                                                                          .length;
                                                                  i++) {
                                                                if (snapshot
                                                                        .data[i]
                                                                            [
                                                                            'Catogery']
                                                                        .toString()
                                                                        .toLowerCase() ==
                                                                    category
                                                                        .toLowerCase()) {
                                                                  exitingID =
                                                                      false;
                                                                  break;
                                                                }
                                                              }
                                                              if (exitingID) {
                                                                String temp =
                                                                    category
                                                                        .substring(
                                                                            0,
                                                                            1);
                                                                temp = temp
                                                                    .toUpperCase();
                                                                temp = temp +
                                                                    category
                                                                        .substring(
                                                                            1)
                                                                        .toLowerCase();
                                                                addCategory(
                                                                    temp);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Flushbar(
                                                                  messageText:
                                                                      Text(
                                                                    "Added New Category",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  icon: Icon(
                                                                    Icons.done,
                                                                    size: 28.0,
                                                                    color: Colors
                                                                            .green[
                                                                        600],
                                                                  ),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              4),
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  borderRadius:
                                                                      8,
                                                                  maxWidth:
                                                                      ScreenWidth /
                                                                          2,
                                                                )..show(
                                                                    context);
                                                              } else {
                                                                Flushbar(
                                                                  messageText:
                                                                      Text(
                                                                    'Category name already use !',
                                                                    style: TextStyle(
                                                                        color: Colors.orange[
                                                                            300],
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  icon: Icon(
                                                                    Icons
                                                                        .warning,
                                                                    size: 28.0,
                                                                    color: Colors
                                                                            .orange[
                                                                        800],
                                                                  ),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              5),
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  borderRadius:
                                                                      8,
                                                                  maxWidth:
                                                                      ScreenWidth /
                                                                          2,
                                                                )..show(
                                                                    context);
                                                                btnAddFocusNode
                                                                    .requestFocus();
                                                              }
                                                            } else {
                                                              Flushbar(
                                                                messageText:
                                                                    Text(
                                                                  'Enter Category Name!',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .orange[
                                                                          300],
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                icon: Icon(
                                                                  Icons.warning,
                                                                  size: 28.0,
                                                                  color: Colors
                                                                          .orange[
                                                                      800],
                                                                ),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            5),
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                borderRadius: 8,
                                                                maxWidth:
                                                                    ScreenWidth /
                                                                        2,
                                                              )..show(context);
                                                              btnAddFocusNode
                                                                  .requestFocus();
                                                            }
                                                          },
                                                          decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .black87)),
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              6,
                                                                          bottom:
                                                                              5),
                                                              labelText:
                                                                  "Category Name",
                                                              labelStyle:
                                                                  TextStyle(
                                                                      fontSize:
                                                                          17),
                                                              suffixIcon: Icon(
                                                                  Icons
                                                                      .category)),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  actionsPadding:
                                                      EdgeInsets.only(
                                                          right: 178),
                                                  actions: [
                                                    Container(
                                                      height: 35,
                                                      width: 100,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        color: Colors.green,
                                                      ),
                                                      child: FlatButton.icon(
                                                          focusNode:
                                                              btnAddFocusNode,
                                                          focusColor: Colors
                                                              .transparent,
                                                          onPressed: () {
                                                            if (catController
                                                                .text
                                                                .isNotEmpty) {
                                                              String category =
                                                                  catController
                                                                      .text;
                                                              bool exitingID =
                                                                  true;
                                                              for (int i = 0;
                                                                  i <
                                                                      snapshot
                                                                          .data
                                                                          .length;
                                                                  i++) {
                                                                if (snapshot
                                                                        .data[i]
                                                                            [
                                                                            'Catogery']
                                                                        .toString()
                                                                        .toLowerCase() ==
                                                                    category
                                                                        .toLowerCase()) {
                                                                  exitingID =
                                                                      false;
                                                                  break;
                                                                }
                                                              }
                                                              if (exitingID) {
                                                                String temp =
                                                                    category
                                                                        .substring(
                                                                            0,
                                                                            1);
                                                                temp = temp
                                                                    .toUpperCase();
                                                                temp = temp +
                                                                    category
                                                                        .substring(
                                                                            1)
                                                                        .toLowerCase();
                                                                addCategory(
                                                                    temp);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Flushbar(
                                                                  messageText:
                                                                      Text(
                                                                    "Added New Category",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  icon: Icon(
                                                                    Icons.done,
                                                                    size: 28.0,
                                                                    color: Colors
                                                                            .green[
                                                                        600],
                                                                  ),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              4),
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  borderRadius:
                                                                      8,
                                                                  maxWidth:
                                                                      ScreenWidth /
                                                                          2,
                                                                )..show(
                                                                    context);
                                                              } else {
                                                                Flushbar(
                                                                  messageText:
                                                                      Text(
                                                                    'Category name already use !',
                                                                    style: TextStyle(
                                                                        color: Colors.orange[
                                                                            300],
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  icon: Icon(
                                                                    Icons
                                                                        .warning,
                                                                    size: 28.0,
                                                                    color: Colors
                                                                            .orange[
                                                                        800],
                                                                  ),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              5),
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  borderRadius:
                                                                      8,
                                                                  maxWidth:
                                                                      ScreenWidth /
                                                                          2,
                                                                )..show(
                                                                    context);
                                                                btnAddFocusNode
                                                                    .requestFocus();
                                                              }
                                                            } else {
                                                              Flushbar(
                                                                messageText:
                                                                    Text(
                                                                  'Enter Category Name!',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .orange[
                                                                          300],
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                icon: Icon(
                                                                  Icons.warning,
                                                                  size: 28.0,
                                                                  color: Colors
                                                                          .orange[
                                                                      800],
                                                                ),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            5),
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                borderRadius: 8,
                                                                maxWidth:
                                                                    ScreenWidth /
                                                                        2,
                                                              )..show(context);
                                                              btnAddFocusNode
                                                                  .requestFocus();
                                                            }
                                                          },
                                                          icon: Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                          ),
                                                          label: Text(
                                                            "Add",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          )),
                                                    )
                                                  ],
                                                ),
                                              );
                                            });
                                      }),
                                ),
                              )
                            ],
                          ),
                        );
                      } else {
                        return Text("");
                      }
                    }),
                Container(
                  height: ScreenHeight - 200,
                  width: ScreenWidth / 1.9,
                  padding: EdgeInsets.all(8),
                  child: StreamBuilder(
                      stream: _streamControllerGetdata.stream,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        //var blob = snapshot.data[0]["img"];
                        //var image = Base64Codec().decode(blob);
                        if (snapshot.hasData) {
                          if (snapshot.data[0]["Item ID"] != "not") {
                            return Scrollbar(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: ListView.builder(
                                    itemCount: snapshot.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      double q = double.parse(snapshot
                                          .data[index]["Quantity"]
                                          .toString());
                                      String img =
                                          snapshot.data[index]["image"];
                                      return Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: new Container(
                                          //width: 180,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.9),
                                                  blurRadius: 6)
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: itmSelect == index
                                                ? (q < 1
                                                    ? Colors.red[100]
                                                        .withOpacity(0.6)
                                                    : (q <=
                                                            int.parse(snapshot
                                                                    .data[index][
                                                                "Alert Quantity"])
                                                        ? Colors.orange[100]
                                                            .withOpacity(0.6)
                                                        : Colors.grey
                                                            .withOpacity(0.7)))
                                                : (q < 1
                                                    ? Colors.red[100]
                                                    : (q <=
                                                            int.parse(
                                                                snapshot.data[index]
                                                                    ["Alert Quantity"])
                                                        ? Colors.orange[100]
                                                        : Colors.white)),
                                          ),
                                          child: FlatButton(
                                            child: Stack(
                                              children: [
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Image.network(
                                                      "http://127.0.0.1/images/$img",
                                                      width: 70,
                                                      height: 70,
                                                      fit: BoxFit.scaleDown,
                                                    )),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 100),
                                                    child: AutoSizeText(
                                                      "${snapshot.data[index]["Item ID"]}",
                                                      style: GoogleFonts
                                                          .robotoCondensed(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w200),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 190),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        AutoSizeText(
                                                          snapshot.data[index]
                                                              ["Item Name"],
                                                          style: GoogleFonts
                                                              .robotoCondensed(
                                                                  fontSize: 26,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                          maxLines: 1,
                                                        ),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        AutoSizeText(
                                                          "Rs. ${snapshot.data[index]["Selling Price (Rs.)"]}",
                                                          style: GoogleFonts
                                                              .robotoCondensed(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w200),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 50),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        AutoSizeText(
                                                          "Stock",
                                                          style: GoogleFonts
                                                              .robotoCondensed(
                                                                  fontSize: 24,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                          maxLines: 1,
                                                        ),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        AutoSizeText(
                                                          "${snapshot.data[index]["Quantity"]}",
                                                          style: GoogleFonts
                                                              .robotoCondensed(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w200),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                itmSelect = index;
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            );
                          } else {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/no_items_found.jpg",
                                  width: 340,
                                  height: 340,
                                  fit: BoxFit.scaleDown,
                                ),
                              ],
                            );
                          }
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }),
                ),
                StreamBuilder(
                    stream: _streamControllerNew.stream,
                    builder: (context, snapshot) {
                      return Container(
                        width: ScreenWidth / 1.9,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 40,
                              width: ScreenWidth / 9 - 18,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black54, blurRadius: 8)
                                  ]),
                              child: FlatButton.icon(
                                  focusNode: newBtnFocusNode,
                                  focusColor: Colors.transparent,
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          FocusNode addFocusNode =
                                              new FocusNode();
                                          TextEditingController idController =
                                              TextEditingController();
                                          TextEditingController
                                              barCodeController =
                                              TextEditingController();
                                          TextEditingController nameController =
                                              TextEditingController();
                                          TextEditingController
                                              stockController =
                                              TextEditingController();
                                          TextEditingController
                                              alertController =
                                              TextEditingController();
                                          TextEditingController
                                              buyingController =
                                              TextEditingController();
                                          TextEditingController
                                              sellingController =
                                              TextEditingController();
                                          TextEditingController imgController =
                                              TextEditingController();

                                          String category = "Uncategory";

                                          return WillPopScope(
                                              onWillPop: () async => null,
                                              child: AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.add,
                                                      color: Colors.black87,
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    Text(
                                                      "Add New Item",
                                                      style: GoogleFonts
                                                          .robotoCondensed(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    SizedBox(
                                                      width: 260,
                                                    ),
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      child: IconButton(
                                                          icon: Icon(
                                                            Icons.close,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }),
                                                    )
                                                  ],
                                                ),
                                                titlePadding: EdgeInsets.only(
                                                    left: 16,
                                                    top: 0,
                                                    bottom: 2),
                                                content: SingleChildScrollView(
                                                  child: Container(
                                                    width: 400,
                                                    height: 530,
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                            height: 40,
                                                            width: 440,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  height: 40,
                                                                  width: 330,
                                                                  child:
                                                                      TextFormField(
                                                                    enabled:
                                                                        false,
                                                                    controller:
                                                                        imgController,
                                                                    decoration: InputDecoration(
                                                                        border: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                                8),
                                                                            borderSide: BorderSide(
                                                                                color: Colors
                                                                                    .black87)),
                                                                        contentPadding: EdgeInsets.only(
                                                                            left:
                                                                                6,
                                                                            bottom:
                                                                                5),
                                                                        labelText:
                                                                            "Image",
                                                                        labelStyle: TextStyle(
                                                                            fontSize:
                                                                                17),
                                                                        suffixIcon:
                                                                            Icon(Icons.image)),
                                                                    maxLines: 1,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 20,
                                                                ),
                                                                Container(
                                                                  height: 40,
                                                                  width: 80,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      color: Colors
                                                                          .blue),
                                                                  child:
                                                                      FlatButton(
                                                                          onPressed:
                                                                              () async {
                                                                            FilePickerResult
                                                                                result;
                                                                            result =
                                                                                await FilePicker.platform.pickFiles();
                                                                            imgController.text =
                                                                                result.files.single.name;
                                                                            addFocusNode.requestFocus();
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            "Browse",
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          )),
                                                                ),
                                                              ],
                                                            )),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Container(
                                                          height: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                          ),
                                                          child: TextFormField(
                                                            autofocus: true,
                                                            controller:
                                                                idController,
                                                            decoration: InputDecoration(
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .black87)),
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        left: 6,
                                                                        bottom:
                                                                            5),
                                                                labelText:
                                                                    "Item ID",
                                                                labelStyle:
                                                                    TextStyle(
                                                                        fontSize:
                                                                            17),
                                                                suffixIcon:
                                                                    Icon(Icons
                                                                        .attach_file)),
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Container(
                                                          height: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                          ),
                                                          child: TextFormField(
                                                            autofocus: true,
                                                            controller:
                                                                nameController,
                                                            decoration: InputDecoration(
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .black87)),
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        left: 6,
                                                                        bottom:
                                                                            5),
                                                                labelText:
                                                                    "Item Name",
                                                                labelStyle:
                                                                    TextStyle(
                                                                        fontSize:
                                                                            17),
                                                                suffixIcon:
                                                                    Icon(Icons
                                                                        .store)),
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Container(
                                                          height: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                          ),
                                                          child: TextFormField(
                                                            controller:
                                                                barCodeController,
                                                            decoration: InputDecoration(
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .black87)),
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        left: 6,
                                                                        bottom:
                                                                            5),
                                                                labelText:
                                                                    "Bar Code",
                                                                labelStyle:
                                                                    TextStyle(
                                                                        fontSize:
                                                                            17),
                                                                suffixIcon:
                                                                    Icon(Icons
                                                                        .format_color_text)),
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Container(
                                                          height: 40,
                                                          width: 450,
                                                          padding:
                                                              EdgeInsets.all(0),
                                                          child:
                                                              DropdownButtonFormField(
                                                            value: category,
                                                            items: items,
                                                            onChanged:
                                                                (selectValue) {
                                                              category =
                                                                  selectValue;
                                                            },
                                                            decoration: InputDecoration(
                                                                labelText:
                                                                    "Category",
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .black87)),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            4),
                                                                suffixIcon:
                                                                    Icon(Icons
                                                                        .category)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Container(
                                                          height: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                          ),
                                                          child: TextFormField(
                                                            controller:
                                                                stockController,
                                                            decoration: InputDecoration(
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8),
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .black87)),
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        left: 6,
                                                                        bottom:
                                                                            5),
                                                                labelText:
                                                                    "Stock",
                                                                labelStyle:
                                                                    TextStyle(
                                                                        fontSize:
                                                                            17),
                                                                suffixIcon:
                                                                    Icon(Icons
                                                                        .store)),
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Container(
                                                          height: 40,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                          ),
                                                          child: TextFormField(
                                                            controller:
                                                                alertController,
                                                            decoration: InputDecoration(
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .black87)),
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        left: 6,
                                                                        top: 6),
                                                                labelText:
                                                                    "Alert Level",
                                                                labelStyle:
                                                                    TextStyle(
                                                                        fontSize:
                                                                            17),
                                                                suffixIcon:
                                                                    Icon(Icons
                                                                        .warning)),
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Container(
                                                          height: 40,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                          ),
                                                          child: TextFormField(
                                                            controller:
                                                                buyingController,
                                                            decoration: InputDecoration(
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .black87)),
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        left: 6,
                                                                        top: 6),
                                                                labelText:
                                                                    "Buying Price (Rs.)",
                                                                labelStyle:
                                                                    TextStyle(
                                                                        fontSize:
                                                                            17),
                                                                suffixIcon:
                                                                    Icon(Icons
                                                                        .attach_money)),
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Container(
                                                          height: 40,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7),
                                                          ),
                                                          child: TextFormField(
                                                            controller:
                                                                sellingController,
                                                            decoration: InputDecoration(
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    borderSide: BorderSide(
                                                                        color: Colors
                                                                            .black87)),
                                                                contentPadding:
                                                                    EdgeInsets.only(
                                                                        left: 6,
                                                                        top: 6),
                                                                labelText:
                                                                    "Selling Price (Rs.)",
                                                                labelStyle:
                                                                    TextStyle(
                                                                        fontSize:
                                                                            17),
                                                                suffixIcon:
                                                                    Icon(Icons
                                                                        .attach_money)),
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                contentPadding: EdgeInsets.only(
                                                    top: 4,
                                                    left: 16,
                                                    right: 16),
                                                actionsPadding:
                                                    EdgeInsets.only(right: 170),
                                                actions: [
                                                  Container(
                                                    height: 35,
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: Colors.green,
                                                    ),
                                                    child: FlatButton.icon(
                                                        focusNode: addFocusNode,
                                                        focusColor:
                                                            Colors.transparent,
                                                        onPressed: () {
                                                          if (idController.text.isNotEmpty &&
                                                              nameController
                                                                  .text
                                                                  .isNotEmpty &&
                                                              sellingController
                                                                  .text
                                                                  .isNotEmpty &&
                                                              buyingController
                                                                  .text
                                                                  .isNotEmpty &&
                                                              stockController
                                                                  .text
                                                                  .isNotEmpty) {
                                                            bool exitingID =
                                                                true;
                                                            for (int i = 0;
                                                                i <
                                                                    snapshot
                                                                        .data
                                                                        .length;
                                                                i++) {
                                                              if (snapshot.data[
                                                                          i][
                                                                      'Item ID'] ==
                                                                  idController
                                                                      .text) {
                                                                exitingID =
                                                                    false;
                                                                break;
                                                              }
                                                            }
                                                            if (exitingID) {
                                                              if (alertController
                                                                  .text
                                                                  .isEmpty) {
                                                                alertController
                                                                    .text = "0";
                                                              }
                                                              if (imgController
                                                                  .text
                                                                  .isEmpty) {
                                                                imgController
                                                                        .text =
                                                                    "defualt.png";
                                                              }
                                                              addItem(
                                                                  idController
                                                                      .text,
                                                                  '4',
                                                                  nameController
                                                                      .text,
                                                                  imgController
                                                                      .text,
                                                                  buyingController
                                                                      .text,
                                                                  sellingController
                                                                      .text,
                                                                  stockController
                                                                      .text,
                                                                  alertController
                                                                      .text,
                                                                  category);
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              Flushbar(
                                                                messageText:
                                                                    Text(
                                                                  "Added New Item",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                icon: Icon(
                                                                  Icons.done,
                                                                  size: 28.0,
                                                                  color: Colors
                                                                          .green[
                                                                      600],
                                                                ),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            4),
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                borderRadius: 8,
                                                                maxWidth:
                                                                    ScreenWidth /
                                                                        2,
                                                              )..show(context);
                                                            } else {
                                                              Flushbar(
                                                                messageText:
                                                                    Text(
                                                                  'Item ID already use !',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .orange[
                                                                          300],
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                icon: Icon(
                                                                  Icons.warning,
                                                                  size: 28.0,
                                                                  color: Colors
                                                                          .orange[
                                                                      800],
                                                                ),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            5),
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                borderRadius: 8,
                                                                maxWidth:
                                                                    ScreenWidth /
                                                                        2,
                                                              )..show(context);
                                                              addFocusNode
                                                                  .requestFocus();
                                                            }
                                                          } else {
                                                            Flushbar(
                                                              messageText: Text(
                                                                'Enter Values!',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                            .orange[
                                                                        300],
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              icon: Icon(
                                                                Icons.warning,
                                                                size: 28.0,
                                                                color: Colors
                                                                        .orange[
                                                                    800],
                                                              ),
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          5),
                                                              margin: EdgeInsets
                                                                  .all(8),
                                                              borderRadius: 8,
                                                              maxWidth:
                                                                  ScreenWidth /
                                                                      2,
                                                            )..show(context);
                                                            addFocusNode
                                                                .requestFocus();
                                                          }
                                                        },
                                                        icon: Icon(
                                                          Icons.add,
                                                          color: Colors.white,
                                                        ),
                                                        label: Text(
                                                          "Add",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )),
                                                  )
                                                ],
                                              ));
                                        });
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "New",
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                            SizedBox(
                              width: 60,
                            ),
                            Container(
                              height: 40,
                              width: ScreenWidth / 9 - 18,
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black54, blurRadius: 8)
                                  ]),
                              child: FlatButton.icon(
                                  onPressed: () async {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ComfirmDailogBox(
                                            title: "Delete All",
                                            descriptions:
                                                "Do you want to delete All ??",
                                            yesButton: Container(
                                              height: 32,
                                              width: 75,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  color: Colors.red[300]),
                                              child: FlatButton(
                                                  onPressed: () {
                                                    String name =
                                                        snapshot.data[itmSelect]
                                                            ["Item Name"];
                                                    deleteItemAll();
                                                    itmSelect = 0;
                                                    Navigator.of(context).pop();
                                                    Flushbar(
                                                      messageText: Text(
                                                        'All items deleted!',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      icon: Icon(
                                                        Icons.info_outline,
                                                        size: 28.0,
                                                        color: Colors.blue[800],
                                                      ),
                                                      duration:
                                                          Duration(seconds: 5),
                                                      margin: EdgeInsets.all(8),
                                                      borderRadius: 8,
                                                      maxWidth: ScreenWidth / 2,
                                                    )..show(context);
                                                  },
                                                  child: Text(
                                                    "Yes",
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        color: Colors.white),
                                                  )),
                                            ),
                                          );
                                        });
                                  },
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "Delete All",
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                          ],
                        ),
                      );
                    })
              ],
            ),
            SizedBox(
              width: 40,
            ),
            StreamBuilder(
                stream: _streamControllerView.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data[0]["Item ID"] != "not") {
                      String img = snapshot.data[itmSelect]["image"];
                      double totalValue = double.parse(
                              snapshot.data[itmSelect]["Selling Price (Rs.)"]) *
                          double.parse(snapshot.data[itmSelect]["Quantity"]);
                      final oCcy = new NumberFormat("#,##0.00", "en_US");
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            width: ScreenWidth / 2.7,
                            height: ScreenHeight - 120,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: ScreenWidth / 2.7,
                                        height: 50,
                                        alignment: Alignment.center,
                                        child: AutoSizeText(
                                          snapshot.data[itmSelect]["Item Name"],
                                          style: GoogleFonts.robotoCondensed(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w500),
                                          maxLines: 1,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 14,
                                      ),
                                      Container(
                                          child: Image.network(
                                        "http://127.0.0.1/images/$img",
                                        width: ScreenHeight < 766 ? 150 : 220,
                                        height: ScreenHeight < 766 ? 150 : 220,
                                        fit: BoxFit.scaleDown,
                                      )),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: ScreenWidth / 2.7 - 24,
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: ScreenWidth / 2.7 - 48,
                                          padding: EdgeInsets.only(bottom: 3),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.black45))),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  "Item ID",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  snapshot.data[itmSelect]
                                                      ["Item ID"],
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Container(
                                          width: ScreenWidth / 2.7 - 48,
                                          padding: EdgeInsets.only(bottom: 3),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.black45))),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  "Item Name",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  snapshot.data[itmSelect]
                                                      ["Item Name"],
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Container(
                                          width: ScreenWidth / 2.7 - 48,
                                          padding: EdgeInsets.only(bottom: 3),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.black45))),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  "Category",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  snapshot.data[itmSelect]
                                                      ["Category"],
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Container(
                                          width: ScreenWidth / 2.7 - 48,
                                          padding: EdgeInsets.only(bottom: 3),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.black45))),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  "Stock",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  snapshot.data[itmSelect]
                                                      ["Quantity"],
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Container(
                                          width: ScreenWidth / 2.7 - 48,
                                          padding: EdgeInsets.only(bottom: 3),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.black45))),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  "Alert Level",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  snapshot.data[itmSelect]
                                                      ["Alert Quantity"],
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Container(
                                          width: ScreenWidth / 2.7 - 48,
                                          padding: EdgeInsets.only(bottom: 3),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.black45))),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  "Buying Price (Rs.)",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  snapshot.data[itmSelect]
                                                      ["Buying Price (Rs.)"],
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Container(
                                          width: ScreenWidth / 2.7 - 48,
                                          padding: EdgeInsets.only(bottom: 3),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.black45))),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  "Selling Price (Rs.)",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  snapshot.data[itmSelect]
                                                      ["Selling Price (Rs.)"],
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Container(
                                          width: ScreenWidth / 2.7 - 48,
                                          padding: EdgeInsets.only(bottom: 3),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  "Total Value",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  "${oCcy.format(totalValue)}",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: ScreenWidth / 2.7,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: ScreenWidth / 9 - 18,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black54,
                                            blurRadius: 8)
                                      ]),
                                  child: FlatButton.icon(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              FocusNode addFocusNode =
                                                  new FocusNode();
                                              var idController =
                                                  TextEditingController();
                                              var nameController =
                                                  TextEditingController();
                                              var barCodeController =
                                                  TextEditingController();
                                              var stockController =
                                                  TextEditingController();
                                              var alertController =
                                                  TextEditingController();
                                              var buyingController =
                                                  TextEditingController();
                                              var sellingController =
                                                  TextEditingController();
                                              var imgController =
                                                  TextEditingController();

                                              String category = snapshot
                                                  .data[itmSelect]["Category"];
                                              idController.text = snapshot
                                                  .data[itmSelect]["Item ID"];
                                              nameController.text = snapshot
                                                  .data[itmSelect]["Item Name"];
                                              barCodeController.text = snapshot
                                                  .data[itmSelect]["BarCode"];
                                              imgController.text = snapshot
                                                  .data[itmSelect]["image"];
                                              stockController.text = snapshot
                                                  .data[itmSelect]["Quantity"];
                                              alertController.text =
                                                  snapshot.data[itmSelect]
                                                      ["Alert Quantity"];
                                              buyingController.text =
                                                  snapshot.data[itmSelect]
                                                      ["Buying Price (Rs.)"];
                                              sellingController.text =
                                                  snapshot.data[itmSelect]
                                                      ["Selling Price (Rs.)"];

                                              return WillPopScope(
                                                  onWillPop: () async => null,
                                                  child: AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    title: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(
                                                          Icons.edit,
                                                          color: Colors.black87,
                                                        ),
                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        Text(
                                                          "Edit Item",
                                                          style: GoogleFonts
                                                              .robotoCondensed(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                        SizedBox(
                                                          width: 260,
                                                        ),
                                                        Container(
                                                          width: 40,
                                                          height: 40,
                                                          child: IconButton(
                                                              icon: Icon(
                                                                Icons.close,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              }),
                                                        )
                                                      ],
                                                    ),
                                                    titlePadding:
                                                        EdgeInsets.only(
                                                            left: 16,
                                                            top: 0,
                                                            bottom: 2),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: Container(
                                                        width: 400,
                                                        height: 530,
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                                height: 40,
                                                                width: 400,
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      height:
                                                                          40,
                                                                      width:
                                                                          300,
                                                                      child:
                                                                          TextFormField(
                                                                        enabled:
                                                                            false,
                                                                        controller:
                                                                            imgController,
                                                                        decoration: InputDecoration(
                                                                            border:
                                                                                OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.black87)),
                                                                            contentPadding: EdgeInsets.only(left: 6, bottom: 5),
                                                                            labelText: "Image",
                                                                            labelStyle: TextStyle(fontSize: 17),
                                                                            suffixIcon: Icon(Icons.image)),
                                                                        maxLines:
                                                                            1,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 20,
                                                                    ),
                                                                    Container(
                                                                      height:
                                                                          40,
                                                                      width: 80,
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              8),
                                                                          color:
                                                                              Colors.blue),
                                                                      child: FlatButton(
                                                                          onPressed: () async {
                                                                            FilePickerResult
                                                                                result;
                                                                            result =
                                                                                await FilePicker.platform.pickFiles();
                                                                            imgController.text =
                                                                                result.files.single.name;
                                                                          },
                                                                          child: Text(
                                                                            "Browse",
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          )),
                                                                    ),
                                                                  ],
                                                                )),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Container(
                                                              height: 40,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7),
                                                              ),
                                                              child:
                                                                  TextFormField(
                                                                enabled: false,
                                                                controller:
                                                                    idController,
                                                                decoration: InputDecoration(
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                8),
                                                                        borderSide: BorderSide(
                                                                            color: Colors
                                                                                .black87)),
                                                                    contentPadding: EdgeInsets.only(
                                                                        left: 6,
                                                                        bottom:
                                                                            5),
                                                                    labelText:
                                                                        "Item ID",
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            17),
                                                                    suffixIcon:
                                                                        Icon(Icons
                                                                            .attach_file)),
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Container(
                                                              height: 40,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7),
                                                              ),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    nameController,
                                                                decoration: InputDecoration(
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                8),
                                                                        borderSide: BorderSide(
                                                                            color: Colors
                                                                                .black87)),
                                                                    contentPadding: EdgeInsets.only(
                                                                        left: 6,
                                                                        bottom:
                                                                            5),
                                                                    labelText:
                                                                        "Item Name",
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            17),
                                                                    suffixIcon:
                                                                        Icon(Icons
                                                                            .store)),
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Container(
                                                              height: 40,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7),
                                                              ),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    barCodeController,
                                                                decoration: InputDecoration(
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                8),
                                                                        borderSide: BorderSide(
                                                                            color: Colors
                                                                                .black87)),
                                                                    contentPadding: EdgeInsets.only(
                                                                        left: 6,
                                                                        bottom:
                                                                            5),
                                                                    labelText:
                                                                        "Bar Code",
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            17),
                                                                    suffixIcon:
                                                                        Icon(Icons
                                                                            .format_color_text)),
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Container(
                                                              height: 40,
                                                              width: 450,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                              child:
                                                                  DropdownButtonFormField(
                                                                value: category,
                                                                items: items,
                                                                onChanged:
                                                                    (selectValue) {
                                                                  category =
                                                                      selectValue;
                                                                },
                                                                decoration: InputDecoration(
                                                                    labelText:
                                                                        "Category",
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                8),
                                                                        borderSide: BorderSide(
                                                                            color: Colors
                                                                                .black87)),
                                                                    contentPadding:
                                                                        EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                4),
                                                                    suffixIcon:
                                                                        Icon(Icons
                                                                            .category)),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Container(
                                                              height: 40,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7),
                                                              ),
                                                              child:
                                                                  TextFormField(
                                                                autofocus: true,
                                                                controller:
                                                                    stockController,
                                                                decoration: InputDecoration(
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                8),
                                                                        borderSide: BorderSide(
                                                                            color: Colors
                                                                                .black87)),
                                                                    contentPadding: EdgeInsets.only(
                                                                        left: 6,
                                                                        bottom:
                                                                            5),
                                                                    labelText:
                                                                        "Stock",
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            17),
                                                                    suffixIcon:
                                                                        Icon(Icons
                                                                            .store)),
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Container(
                                                              height: 40,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7),
                                                              ),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    alertController,
                                                                decoration: InputDecoration(
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                8),
                                                                        borderSide: BorderSide(
                                                                            color: Colors
                                                                                .black87)),
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                            left:
                                                                                6,
                                                                            top:
                                                                                6),
                                                                    labelText:
                                                                        "Alert Level",
                                                                    labelStyle:
                                                                        TextStyle(
                                                                            fontSize:
                                                                                17),
                                                                    suffixIcon:
                                                                        Icon(Icons
                                                                            .warning)),
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Container(
                                                              height: 40,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7),
                                                              ),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    buyingController,
                                                                decoration: InputDecoration(
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                8),
                                                                        borderSide: BorderSide(
                                                                            color: Colors
                                                                                .black87)),
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                            left:
                                                                                6,
                                                                            top:
                                                                                6),
                                                                    labelText:
                                                                        "Buying Price (Rs.)",
                                                                    labelStyle:
                                                                        TextStyle(
                                                                            fontSize:
                                                                                17),
                                                                    suffixIcon:
                                                                        Icon(Icons
                                                                            .attach_money)),
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Container(
                                                              height: 40,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7),
                                                              ),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    sellingController,
                                                                decoration: InputDecoration(
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                8),
                                                                        borderSide: BorderSide(
                                                                            color: Colors
                                                                                .black87)),
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                            left:
                                                                                6,
                                                                            top:
                                                                                6),
                                                                    labelText:
                                                                        "Selling Price (Rs.)",
                                                                    labelStyle:
                                                                        TextStyle(
                                                                            fontSize:
                                                                                17),
                                                                    suffixIcon:
                                                                        Icon(Icons
                                                                            .attach_money)),
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            top: 4,
                                                            left: 16,
                                                            right: 16),
                                                    actionsPadding:
                                                        EdgeInsets.only(
                                                            right: 170),
                                                    actions: [
                                                      Container(
                                                        height: 35,
                                                        width: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: Colors.green,
                                                        ),
                                                        child: FlatButton.icon(
                                                            focusNode:
                                                                addFocusNode,
                                                            focusColor: Colors
                                                                .transparent,
                                                            onPressed: () {
                                                              if (idController
                                                                      .text
                                                                      .isNotEmpty &&
                                                                  nameController
                                                                      .text
                                                                      .isNotEmpty &&
                                                                  sellingController
                                                                      .text
                                                                      .isNotEmpty &&
                                                                  buyingController
                                                                      .text
                                                                      .isNotEmpty &&
                                                                  stockController
                                                                      .text
                                                                      .isNotEmpty) {
                                                                if (alertController
                                                                    .text
                                                                    .isEmpty) {
                                                                  alertController
                                                                          .text =
                                                                      "0";
                                                                }
                                                                if (imgController
                                                                    .text
                                                                    .isEmpty) {
                                                                  imgController
                                                                          .text =
                                                                      "defualt.png";
                                                                }

                                                                updateItem(
                                                                    snapshot.data[
                                                                            itmSelect]
                                                                        [
                                                                        "Item ID"],
                                                                    nameController
                                                                        .text,
                                                                    barCodeController
                                                                        .text,
                                                                    imgController
                                                                        .text,
                                                                    buyingController
                                                                        .text,
                                                                    sellingController
                                                                        .text,
                                                                    stockController
                                                                        .text,
                                                                    alertController
                                                                        .text,
                                                                    category);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                Flushbar(
                                                                  messageText:
                                                                      Text(
                                                                    "Item update success",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  icon: Icon(
                                                                    Icons.done,
                                                                    size: 28.0,
                                                                    color: Colors
                                                                            .green[
                                                                        600],
                                                                  ),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              4),
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  borderRadius:
                                                                      8,
                                                                  maxWidth:
                                                                      ScreenWidth /
                                                                          2,
                                                                )..show(
                                                                    context);
                                                              } else {
                                                                Flushbar(
                                                                  messageText:
                                                                      Text(
                                                                    'Enter Values!',
                                                                    style: TextStyle(
                                                                        color: Colors.orange[
                                                                            300],
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  icon: Icon(
                                                                    Icons
                                                                        .warning,
                                                                    size: 28.0,
                                                                    color: Colors
                                                                            .orange[
                                                                        800],
                                                                  ),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              5),
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8),
                                                                  borderRadius:
                                                                      8,
                                                                  maxWidth:
                                                                      ScreenWidth /
                                                                          2,
                                                                )..show(
                                                                    context);
                                                                addFocusNode
                                                                    .requestFocus();
                                                              }
                                                            },
                                                            icon: Icon(
                                                              Icons.done,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            label: Text(
                                                              "OK",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            )),
                                                      )
                                                    ],
                                                  ));
                                            });
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        "Edit",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Container(
                                  height: 40,
                                  width: ScreenWidth / 9 - 18,
                                  decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black54,
                                            blurRadius: 8)
                                      ]),
                                  child: FlatButton.icon(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              TextEditingController qty =
                                                  new TextEditingController();
                                              return AlertDialog(
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.assignment_return,
                                                      color: Colors.black87,
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    Text(
                                                      "Return ${snapshot.data[itmSelect]["Item Name"]}",
                                                      style: GoogleFonts
                                                          .robotoCondensed(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    SizedBox(
                                                      width: 260,
                                                    ),
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      child: IconButton(
                                                          icon: Icon(
                                                            Icons.close,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }),
                                                    )
                                                  ],
                                                ),
                                                titlePadding: EdgeInsets.only(
                                                    left: 16,
                                                    top: 0,
                                                    bottom: 6),
                                                content: Container(
                                                  width: 180,
                                                  height: 100,
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        'Return Quantity',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(
                                                        height: 30,
                                                      ),
                                                      Container(
                                                        width: 150,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .black54)),
                                                        child: TextField(
                                                          controller: qty,
                                                          autofocus: true,
                                                          textAlign:
                                                              TextAlign.center,
                                                          decoration:
                                                              InputDecoration(
                                                            enabledBorder: UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .white)),
                                                            focusedBorder: UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  Container(
                                                    height: 35,
                                                    width: 120,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      color: Colors.green,
                                                    ),
                                                    child: FlatButton.icon(
                                                        onPressed: () {
                                                          if (qty.text
                                                                  .isNotEmpty &&
                                                              double.parse(qty
                                                                      .text) >
                                                                  0) {
                                                            insertReturnBill(
                                                                snapshot.data[
                                                                        itmSelect]
                                                                    ["Item ID"],
                                                                snapshot.data[
                                                                        itmSelect]
                                                                    [
                                                                    "Item Name"],
                                                                qty.text);

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            Flushbar(
                                                              messageText: Text(
                                                                '${snapshot.data[itmSelect]["Item Name"]} is returned',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              icon: Icon(
                                                                Icons
                                                                    .info_outline,
                                                                size: 28.0,
                                                                color: Colors
                                                                    .blue[800],
                                                              ),
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          5),
                                                              margin: EdgeInsets
                                                                  .all(8),
                                                              borderRadius: 8,
                                                              maxWidth:
                                                                  ScreenWidth /
                                                                      2,
                                                            )..show(context);
                                                          }
                                                        },
                                                        icon: Icon(Icons.done,
                                                            color:
                                                                Colors.white),
                                                        label: Text(
                                                          'OK',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )),
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                      icon: Icon(
                                        Icons.assignment_return,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        "Return",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Container(
                                  height: 40,
                                  width: ScreenWidth / 9 - 18,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black54,
                                            blurRadius: 8)
                                      ]),
                                  child: FlatButton.icon(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ComfirmDailogBox(
                                                title: "Delete Item",
                                                descriptions:
                                                    "Do you want to delete this ?",
                                                yesButton: Container(
                                                  height: 32,
                                                  width: 75,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: Colors.red[300]),
                                                  child: FlatButton(
                                                      onPressed: () {
                                                        String name = snapshot
                                                                .data[itmSelect]
                                                            ["Item Name"];
                                                        deleteItem(snapshot
                                                                .data[itmSelect]
                                                            ["Item ID"]);
                                                        itmSelect = 0;
                                                        Navigator.of(context)
                                                            .pop();
                                                        Flushbar(
                                                          messageText: Text(
                                                            '$name is deleted',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          icon: Icon(
                                                            Icons.info_outline,
                                                            size: 28.0,
                                                            color: Colors
                                                                .blue[800],
                                                          ),
                                                          duration: Duration(
                                                              seconds: 5),
                                                          margin:
                                                              EdgeInsets.all(8),
                                                          borderRadius: 8,
                                                          maxWidth:
                                                              ScreenWidth / 2,
                                                        )..show(context);
                                                      },
                                                      child: Text(
                                                        "Yes",
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            color:
                                                                Colors.white),
                                                      )),
                                                ),
                                              );
                                            });
                                      },
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            width: ScreenWidth / 2.7,
                            height: ScreenHeight - 120,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: ScreenWidth / 2.7,
                                        height: 50,
                                        alignment: Alignment.center,
                                        child: AutoSizeText(
                                          "Not Select",
                                          style: GoogleFonts.robotoCondensed(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w500),
                                          maxLines: 1,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 14,
                                      ),
                                      Container(
                                          child: Icon(
                                        Icons.info,
                                        size: ScreenHeight < 766 ? 150 : 200,
                                        color: Colors.yellow,
                                      )),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: ScreenWidth / 2.7 - 24,
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: ScreenWidth / 2.7 - 48,
                                          padding: EdgeInsets.only(bottom: 3),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.black45))),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  "Item ID",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  "Not Select",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Container(
                                          width: ScreenWidth / 2.7 - 48,
                                          padding: EdgeInsets.only(bottom: 3),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.black45))),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  "Item Name",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  "Not Select",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Container(
                                          width: ScreenWidth / 2.7 - 48,
                                          padding: EdgeInsets.only(bottom: 3),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.black45))),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  "Category",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  "Not Select",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Container(
                                          width: ScreenWidth / 2.7 - 48,
                                          padding: EdgeInsets.only(bottom: 3),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.black45))),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  "Stock",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  "Not Select",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Container(
                                          width: ScreenWidth / 2.7 - 48,
                                          padding: EdgeInsets.only(bottom: 3),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.black45))),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  "Alert Level",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  "Not Select",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Container(
                                          width: ScreenWidth / 2.7 - 48,
                                          padding: EdgeInsets.only(bottom: 3),
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.black45))),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  "Buying Price (Rs.)",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  "Not Select",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Container(
                                          width: ScreenWidth / 2.7 - 48,
                                          padding: EdgeInsets.only(bottom: 3),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  "Selling Price (Rs.)",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: AutoSizeText(
                                                  "Not Select",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 24,
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: ScreenWidth / 2.7,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: ScreenWidth / 9 - 18,
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black54,
                                            blurRadius: 8)
                                      ]),
                                  child: FlatButton.icon(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      "Edit",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                                SizedBox(
                                  width: 50,
                                ),
                                Container(
                                  height: 40,
                                  width: ScreenWidth / 9 - 18,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black54,
                                            blurRadius: 8)
                                      ]),
                                  child: FlatButton.icon(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {},
                                      label: Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    }
                  } else {
                    return Text("");
                  }
                })
          ],
        ),
      ),
    );
  }
}
