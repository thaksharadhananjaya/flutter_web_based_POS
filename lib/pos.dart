import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:smart_pos/util/customDailogBox.dart';
import 'package:flutter/material.dart';

class POS extends StatefulWidget {
  @override
  _POSState createState() => _POSState();
}

class _POSState extends State<POS> {
  String billID = "";
  String category = "All";
  String sText = "";
  String holdOne;
  int selectedIndex = 0;
  int itmID = -1; //for get data
  int cusValidator = 0;

  StreamController _streamControllerGetdata = StreamController();
  StreamController _streamControllerGetcat = StreamController();
  StreamController _streamControllerGetcard = StreamController();
  StreamController _streamControllerGetnetamount = StreamController();
  StreamController _streamControllerpay = StreamController();
  StreamController _streamControllerHold = StreamController();
  StreamController _streamControllerCusID = StreamController();
  StreamController _streamControllerCheque = StreamController();
  TextEditingController itmsearchControllr = TextEditingController();
  TextEditingController cussearchControllr = TextEditingController();

  FocusNode qtyFoucusNode = new FocusNode();

  Future getData() async {
    final response = await http.post("http://127.0.0.1/fetch_data.php", body: {
      "ItemID": "$itmID",
      "Cat": "$category",
    });

    var data = await json.decode(response.body);
    _streamControllerGetdata.add(data);
  }

  Future getCat() async {
    final response = await http.get('http://127.0.0.1//getCatogary.php');
    var data = await json.decode(response.body);
    _streamControllerGetcat.add(data);
  }

  Future getHold() async {
    final response = await http.get('http://127.0.0.1//getHold.php');
    var data = await json.decode(response.body);
    _streamControllerHold.add(data);
  }

  Future getCheque() async {
    final response = await http.get('http://127.0.0.1//getCheque.php');
    var data = await json.decode(response.body);
    _streamControllerCheque.add(data);
  }

  Future deletCheque() async {
    final response = await http.get('http://127.0.0.1//deleteCheque.php');
    getCheque();
  }

  Future deleteHold() async {
    final response = await http.post("http://127.0.0.1/deleteHold.php", body: {
      "BillID": "$billID",
    });
    getHold();
  }

  Future getNetAmount() async {
    final response =
        await http.post("http://127.0.0.1/getNetAmount.php", body: {
      "BillID": "$billID",
    });
    var data = await json.decode(response.body);
    _streamControllerGetnetamount.add(data);
    _streamControllerpay.add(data);
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

  static Future<List> getCusSearch(String cusID) async {
    final response = await http.post("http://127.0.0.1/cusSearch.php", body: {
      "id": "$cusID",
    });
    var items = await json.decode(response.body);
    return List.generate(items.length, (index) {
      return {
        'id': items[index]["ID"],
        'name': items[index]["Name"],
        'len': "${items.length}"
      };
    });
  }

  Future<List> getCustomerID(String cusID) async {
    final response = await http.post("http://127.0.0.1/getCusID.php", body: {
      "id": "$cusID",
    });
    var data = await json.decode(response.body);
    _streamControllerCusID.add(data);
    return data;
  }

  Future hold() async {
    if (billID != "") {
      //String billID = this.billID;
      final response =
          await http.post("http://127.0.0.1/insertHold.php", body: {
        "BillID": "$billID",
      });

      var data = await json.decode(response.body);
      if (data[0]['result'].toString() == '1') {
        billID = "";
        getNetAmount();
        getCardData(-1, -3, 0, 0, 0);
        cussearchControllr.clear();
        getHold();
        Flushbar(
          // View snackBar messege
          messageText: Text(
            'Invoice Hold',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          icon: Icon(
            Icons.done,
            size: 28.0,
            color: Colors.green[600],
          ),
          duration: Duration(seconds: 6),
          margin: EdgeInsets.all(8),
          borderRadius: 8,
          maxWidth: 500,
        )..show(context);
      } else {
        Flushbar(
          messageText: Text(
            'Database error! #${data[0]['result'].toString()}',
            style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          icon: Icon(
            Icons.error,
            size: 28.0,
            color: Colors.red[600],
          ),
          duration: Duration(seconds: 5),
          margin: EdgeInsets.all(8),
          borderRadius: 8,
          maxWidth: 500,
        )..show(context);
      }
    }
  }

  Future getCardData(int itemID, double quantity, double total, double netTotal,
      int free) async {
    final response =
        await http.post("http://127.0.0.1/get_cardData.php", body: {
      "BillID": "$billID",
      "ItemID": "$itemID",
      "Qty": "$quantity",
      "Total": "$total",
      "NetTotal": "$netTotal",
      "Free": "$free",
    });

    var data = await json.decode(response.body);
    _streamControllerGetcard.add(data);

    final responseServer = await http.post(
        "http://shinegroup98656.000webhostapp.com//upateBillItem.php",
        body: {
          "BillID": "$billID",
          "ItemID": "$itemID",
          "Qty": "$quantity",
          "Total": "$total",
          "NetTotal": "$netTotal",
          "Free": "$free",
        });
  }

  Future insertBill(
      String billID,
      String invoiceNo,
      String date,
      String user,
      String customerID,
      double cash,
      double balance,
      String payMethod,
      String bankDate) async {
    final response = await http.post("http://127.0.0.1/insertBill.php", body: {
      "BillID": "$billID",
      "InvoiceNo": "$invoiceNo",
      "Date": "$date",
      "User": "$user",
      "Cus": "$customerID",
      "Cash": "$cash",
      "Bal": "$balance",
      "PMthd": "$payMethod",
      "BankDate": "$bankDate",
    });
    var data = await json.decode(response.body);

    if (data[0]['result'].toString() == '1') {
      final oCcy = new NumberFormat("#,##0.00", "en_US");
      this.billID = "";
      getNetAmount();
      getCardData(-1, -3, 0, 0, 0);
      cussearchControllr.clear();
      //html.window.open("http://localhost/poshtml.html",'Inovice');

      Navigator.of(context).pop(); // Close payment dailogBox
      Flushbar(
        // View snackBar messege
        messageText: Text(
          payMethod == 'Cash'
              ? 'Order completed. Pay by cash.   Balance = Rs. ${oCcy.format(balance)}'
              : 'Order completed. Pay by cheque',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        icon: Icon(
          Icons.done,
          size: 28.0,
          color: Colors.green[600],
        ),
        duration: Duration(seconds: 6),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        maxWidth: 500,
      )..show(context);
      String time = "${DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now())}";
      final responseServer = await http.post(
          "http://shinegroup98656.000webhostapp.com//insertBill.php",
          body: {
            "BillID": "$billID",
            "InvoiceNo": "$invoiceNo",
            "Time": "$time",
          });
    } else {
      Flushbar(
        messageText: Text(
          data[0]['result'].toString() == '1062'
              ? 'Invoice No already use! Try another one'
              : 'Database error!',
          style: TextStyle(
              color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        icon: Icon(
          Icons.error,
          size: 28.0,
          color: Colors.red[600],
        ),
        duration: Duration(seconds: 5),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        maxWidth: 500,
      )..show(context);
      FocusScope.of(context).unfocus();
    }
  }

  Future deleteBill() async {
    var bill = billID;
    final response = await http.post("http://127.0.0.1/deleteBill.php", body: {
      "BillID": "$billID",
    });

    final responseServer = await http.post(
        "http://shinegroup98656.000webhostapp.com//deleteBill.php",
        body: {
          "BillID": "$bill",
        });
  }

  Future sendData(
      int itemId, String name, double bPrice, double sPrice, int free) async {
    final response =
        await http.post("http://127.0.0.1/sendData_billItemNew.php", body: {
      "BillID": "$billID",
      "ItemID": "$itemId",
      "ItemName": "$name",
      "BuyingPrice": "$bPrice",
      "SellingPrice": "$sPrice",
      "Total": "$sPrice",
      "NetTotal": "$sPrice",
      "Free": "$free",
    });

    final responseServer = await http.post(
        "http://shinegroup98656.000webhostapp.com//insertBillItem.php",
        body: {
          "BillID": "$billID",
          "ItemID": "$itemId",
          "BuyingPrice": "$bPrice",
          "SellingPrice": "$sPrice",
          "Price": "$sPrice",
          "Quantity": "1",
          "Total": "$sPrice",
          "Discount": "0",
          "NetTotal": "$sPrice",
          "Free": "$free",
        });
  }

  /* Future insertTempBill(String id) async {
    final response = await http.post("http://127.0.0.1/insertTempBill.php", body: {
      "BillID": "$id",
    });
  }
  */
  Future addCustomer(
      String cusId, String name, String adds, String contact) async {
    final response = await http.post("http://127.0.0.1/addCus.php", body: {
      "ID": "$cusId",
      "Name": "$name",
      "Address": "$adds",
      "Contact": "$contact",
    });

    var data = await json.decode(response.body);

    if (data[0]['result'].toString() == '1') {
      Navigator.of(context).pop();
      cussearchControllr.text = cusId;
      Flushbar(
        messageText: Text(
          'New customer added',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        icon: Icon(
          Icons.info,
          size: 28.0,
          color: Colors.blue,
        ),
        duration: Duration(seconds: 5),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        maxWidth: 500,
      )..show(context);
    } else {
      Flushbar(
        messageText: Text(
          data[0]['result'].toString() == '1062'
              ? 'Customer ID already use! Try another one'
              : 'Database error!',
          style: TextStyle(
              color: Colors.orange[300],
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        icon: Icon(
          Icons.warning,
          size: 28.0,
          color: Colors.orange[800],
        ),
        duration: Duration(seconds: 5),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        maxWidth: 500,
      )..show(context);
      FocusScope.of(context).unfocus();
    }
  }

  Future updateBill(
      int itemId, double discount, double price, double netTotal) async {
    final response = await http.post("http://127.0.0.1/addDiscount.php", body: {
      "BillID": "$billID",
      "ItemID": "$itemId",
      "DisPer": "$discount",
      "Price": "$price",
      "NetTotal": "$netTotal",
    });
  }

  void cardTimer() {
    Timer _timer;
    int time = 0;

    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      getCardData(-1, -3, 0, 0, 0);
      time += 200;
      if (time > 1000) {
        _timer.cancel();
        qtyFoucusNode.requestFocus();
      }
    });
  }

  Timer _timer;
  void initState() {
    getData();
    getCardData(-1, -3, 0, 0, 0);
    getCat();
    getCheque();
    getHold();
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      getData();
      //get_cardData(-1,-3,0,0,0);
      getNetAmount();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getNetAmount();
    getCustomerID("");
    double ScreenWidth = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.transparent,
        height: ScreenHeight,
        width: ScreenWidth - 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Item section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Search Box
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 56),
                  child: Container(
                      padding: EdgeInsets.only(top: 5),
                      alignment: Alignment.center,
                      width: ScreenWidth / 3,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                            autofocus: false,
                            controller: itmsearchControllr,
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
                                itmID = -1;
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
                          itmID = int.parse(suggestion['id']);
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

                // Category
                StreamBuilder(
                    stream: _streamControllerGetcat.stream,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          width: ScreenWidth / 1.8,
                          height: 40,
                          padding: EdgeInsets.only(left: 18),
                          child: ListView.builder(
                            padding: EdgeInsets.all(8),
                            itemCount: snapshot.data.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 24),
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
                                          fontSize: 20),
                                      maxLines: 1,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                        category =
                                            snapshot.data[index]["Catogery"];
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return Text("");
                      }
                    }),
                // Items
                Container(
                  height: ScreenHeight - 155,
                  width: ScreenWidth / 1.8,
                  padding: EdgeInsets.all(8),
                  child: StreamBuilder(
                      stream: _streamControllerGetdata.stream,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        //var blob = snapshot.data[0]["img"];
                        //var image = Base64Codec().decode(blob);
                        if (snapshot.hasData) {
                          if (snapshot.data[0]["Item ID"] != "not") {
                            return Scrollbar(
                              child: GridView.builder(
                                  itemCount: snapshot.data.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              ScreenWidth < 1260 ? 3 : 4),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    double q = double.parse(
                                        snapshot.data[index]["Quantity"]);
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, bottom: 20),
                                      child: new Container(
                                        width: 180,
                                        height: 240,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.9),
                                                blurRadius: 6)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: q < 1
                                              ? Colors.red[100]
                                              : (q <
                                                      double.parse(snapshot
                                                              .data[index]
                                                          ["Alert Quantity"])
                                                  ? Colors.orange[100]
                                                  : Colors.white),
                                        ),
                                        child: FlatButton(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Image.network(
                                                "http://127.0.0.1/images/${snapshot.data[index]["image"]}",
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.scaleDown,
                                              ),
                                              SizedBox(
                                                height: 16,
                                              ),
                                              AutoSizeText(
                                                snapshot.data[index]
                                                    ["Item Name"],
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w200),
                                                maxLines: 1,
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              AutoSizeText(
                                                "Rs. ${snapshot.data[index]["Selling Price (Rs.)"]}",
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          onPressed: () {
                                            // Call addItemToCard method for add item
                                            addItemToCard(
                                                context,
                                                index,
                                                int.parse(snapshot.data[index]
                                                    ["Item ID"]),
                                                snapshot.data[index]
                                                    ["Item Name"],
                                                double.parse(snapshot
                                                    .data[index]["Quantity"]),
                                                double.parse(
                                                    snapshot.data[index]
                                                        ["Buying Price (Rs.)"]),
                                                double.parse(snapshot
                                                        .data[index]
                                                    ["Selling Price (Rs.)"]),
                                                0);
                                          },
                                          onLongPress: () {
                                            // Call addItemToCard method for add free item
                                            addItemToCard(
                                                context,
                                                index,
                                                int.parse(snapshot.data[index]
                                                    ["Item ID"]),
                                                snapshot.data[index]
                                                    ["Item Name"],
                                                double.parse(snapshot
                                                    .data[index]["Quantity"]),
                                                double.parse(
                                                    snapshot.data[index]
                                                        ["Buying Price (Rs.)"]),
                                                double.parse(snapshot
                                                        .data[index]
                                                    ["Selling Price (Rs.)"]),
                                                1);
                                          },
                                        ),
                                      ),
                                    );
                                  }),
                            );
                          } else {
                            return Center(
                              child: Image.asset(
                                "assets/images/no_items_found.jpg",
                                width: 340,
                                height: 340,
                                fit: BoxFit.scaleDown,
                              ),
                            );
                          }
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }),
                )
              ],
            ),
            // Card Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 6,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      child: StreamBuilder(
                          stream: _streamControllerHold.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return IconButton(
                                padding: EdgeInsets.all(0),
                                hoverColor: Colors.transparent,
                                icon: Icon(
                                  Icons.pause_circle_filled,
                                  color: Colors.black,
                                  size: 38,
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return WillPopScope(
                                            onWillPop: () async => null,
                                            child: StatefulBuilder(builder:
                                                (BuildContext context,
                                                    StateSetter setState) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.pause_circle_filled,
                                                      color: Colors.black87,
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    Text(
                                                      "Hold",
                                                      style: GoogleFonts
                                                          .robotoCondensed(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                    SizedBox(
                                                      width: 280,
                                                    ),
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      child: IconButton(
                                                          hoverColor: Colors
                                                              .transparent,
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
                                                content: Container(
                                                    width: 400,
                                                    height: 350,
                                                    child: ListView.builder(
                                                        itemCount: snapshot
                                                            .data.length,
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              billID = snapshot
                                                                          .data[
                                                                      index]
                                                                  ['BillID'];
                                                              getCardData(-1,
                                                                  -3, 0, 0, 0);
                                                              cardTimer();
                                                              deleteHold();
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6),
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(4),
                                                                height: 40,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    color: Colors
                                                                            .grey[
                                                                        100]),
                                                                child: Stack(
                                                                  children: [
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        snapshot.data[index]
                                                                            [
                                                                            'BillID'],
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontSize: 14),
                                                                      ),
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          Text(
                                                                        snapshot.data[index]
                                                                            [
                                                                            'Time'],
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontSize: 14),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        })),
                                                contentPadding: EdgeInsets.only(
                                                    top: 10,
                                                    left: 16,
                                                    right: 16),
                                              );
                                            }));
                                      });
                                },
                              );
                            } else {
                              return IconButton(
                                  padding: EdgeInsets.all(0),
                                  hoverColor: Colors.transparent,
                                  icon: Icon(
                                    Icons.pause_circle_filled,
                                    color: Colors.black,
                                    size: 38,
                                  ),
                                  onPressed: null);
                            }
                          }),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      child: StreamBuilder(
                          stream: _streamControllerCheque.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              String dateValue =
                                  "${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
                              print("date: $dateValue");
                              print("lenthDB: ${snapshot.data.length}");
                              int numOfCheque = 0;
                              for (int i = 0; i < snapshot.data.length; i++) {
                                print("dbb: ${snapshot.data[i]['bankDate']}");
                                if (snapshot.data[i]['bankDate'] == dateValue) {
                                  numOfCheque++;
                                }
                              }
                              print("num: $numOfCheque");
                              return Stack(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.all(0),
                                    hoverColor: Colors.transparent,
                                    icon: Icon(
                                      Icons.notifications,
                                      color: Colors.black,
                                      size: 38,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return WillPopScope(
                                                onWillPop: () async => null,
                                                child: StatefulBuilder(builder:
                                                    (BuildContext context,
                                                        StateSetter setState) {
                                                  return AlertDialog(
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
                                                          Icons.notifications,
                                                          color: Colors.black87,
                                                        ),
                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        Text(
                                                          "Nofitications",
                                                          style: GoogleFonts
                                                              .robotoCondensed(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                        SizedBox(
                                                          width: 280,
                                                        ),
                                                        Container(
                                                          width: 40,
                                                          height: 40,
                                                          child: IconButton(
                                                              hoverColor: Colors
                                                                  .transparent,
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
                                                    content: Container(
                                                        width: 400,
                                                        height: 350,
                                                        child: ListView.builder(
                                                            itemCount: snapshot
                                                                .data.length,
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              return Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(6),
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              4),
                                                                  height: 40,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      color: snapshot.data[index]['bankDate'] ==
                                                                              dateValue
                                                                          ? Colors.red[
                                                                              100]
                                                                          : Colors
                                                                              .grey[100]),
                                                                  child: Stack(
                                                                    children: [
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child:
                                                                            Text(
                                                                          'Cheque',
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 14),
                                                                        ),
                                                                      ),
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        child:
                                                                            Text(
                                                                          snapshot.data[index]
                                                                              [
                                                                              'bankDate'],
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 14),
                                                                        ),
                                                                      ),
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.centerRight,
                                                                        child:
                                                                            Text(
                                                                          snapshot.data[index]
                                                                              [
                                                                              'BillID'],
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.w500,
                                                                              fontSize: 14),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            })),
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            top: 10,
                                                            left: 16,
                                                            right: 16),
                                                    actions: [
                                                      Container(
                                                        width: 100,
                                                        height: 34,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            color: Colors.red),
                                                        child: FlatButton.icon(
                                                            onPressed: () {
                                                              deletCheque();
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            icon: Icon(
                                                              Icons.clear,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            label: Text(
                                                              'Clear',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            )),
                                                      )
                                                    ],
                                                    actionsPadding:
                                                        EdgeInsets.only(
                                                            top: 10,
                                                            right: 180),
                                                  );
                                                }));
                                          });
                                    },
                                  ),
                                  numOfCheque > 0
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(left: 25),
                                          child: CircleAvatar(
                                            radius: 8,
                                            backgroundColor: Colors.red,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                '$numOfCheque',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Text("")
                                ],
                              );
                            } else {
                              return IconButton(
                                  padding: EdgeInsets.all(0),
                                  hoverColor: Colors.transparent,
                                  icon: Icon(
                                    Icons.notifications,
                                    color: Colors.black,
                                    size: 38,
                                  ),
                                  onPressed: null);
                            }
                          }),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Container(
                    height: ScreenHeight - 64,
                    width: ScreenWidth / 2.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            // Customer Search Box
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                height: 40,
                                width: ScreenWidth < 1260 ? 150 : 250,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.black54, width: 1)),
                                child: TypeAheadField(
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    autofocus: false,
                                    controller: cussearchControllr,
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .copyWith(fontSize: 16),
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      contentPadding:
                                          EdgeInsets.only(top: 6, left: 10.0),
                                      hintText: "Enter Customer ID",
                                      suffixIcon: Icon(
                                        Icons.contacts,
                                        color: Colors.grey.withOpacity(0.4),
                                      ),
                                    ),
                                    enabled: true,
                                  ),
                                  suggestionsCallback: (pattern) async {
                                    return await getCusSearch(pattern);
                                  },
                                  itemBuilder: (context, suggestion) {
                                    int len = int.parse(suggestion['len']);
                                    if (len > 1 || len == 0) {
                                      cusValidator = 0;
                                    } else {
                                      if (cussearchControllr.text ==
                                          suggestion['id']) {
                                        cusValidator = 1;
                                      } else {
                                        cusValidator = 0;
                                      }
                                    }

                                    return ListTile(
                                      //leading: Image.network("http://127.0.0.1/images/SamsungS10.png",width: 40, height: 40, fit: BoxFit.scaleDown,),
                                      title: AutoSizeText(
                                        suggestion['name'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                      ),
                                      subtitle: AutoSizeText(suggestion['id']),
                                    );
                                  },
                                  onSuggestionSelected: (suggestion) {
                                    cussearchControllr.text = suggestion['id'];
                                    cusValidator = 1;
                                  },
                                  noItemsFoundBuilder: (context) {
                                    return Container(
                                      child: Text("Not Customer ID Found!"),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Container(
                                width: 90,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.blue,
                                ),
                                child: StreamBuilder(
                                    stream: _streamControllerCusID.stream,
                                    builder: (context, snapshot) {
                                      return FlatButton.icon(
                                          icon: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                          label: AutoSizeText(
                                            "New",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          onPressed: () {
                                            buildCustomerDialog(
                                                context, snapshot, ScreenWidth);
                                          });
                                    }))
                          ],
                        ),

                        // Invoice Item Viwer (List View)
                        Container(
                          height: ScreenHeight - 320,
                          child: StreamBuilder(
                              stream: _streamControllerGetcard.stream,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasData) {
                                  return Container(
                                    height: ScreenHeight - 300,
                                    padding: EdgeInsets.only(top: 16),
                                    child: ListView.builder(
                                        itemCount: snapshot.data.length,
                                        padding: EdgeInsets.all(16),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          TextEditingController qtyControllr =
                                              TextEditingController();
                                          qtyControllr.text =
                                              snapshot.data[index]["Quantity"];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16),
                                            child: Container(
                                              width: 200,
                                              height: 60,
                                              padding: EdgeInsets.all(10),
                                              alignment: Alignment.centerLeft,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        blurRadius: 9)
                                                  ],
                                                  color: Colors.white),
                                              child: Stack(
                                                children: [
                                                  // Set Item Image
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Image.network(
                                                          "http://127.0.0.1/images/${snapshot.data[index]["image"]}",
                                                          width: 30,
                                                          height: 30,
                                                          fit: BoxFit.scaleDown,
                                                        ),
                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            AutoSizeText(snapshot
                                                                    .data[index]
                                                                ["Item Name"]),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            AutoSizeText(
                                                              "Rs. ${snapshot.data[index]["Net Total (Rs.)"]}",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          height: 40,
                                                          width: 60,
                                                          alignment:
                                                              Alignment.center,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .black54,
                                                                width: 1),
                                                          ),
                                                          child: TextField(
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            textAlign: TextAlign
                                                                .center,
                                                            decoration:
                                                                InputDecoration(
                                                              enabledBorder: UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.white)),
                                                              focusedBorder: UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.white)),
                                                              border: UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.white)),
                                                              contentPadding:
                                                                  EdgeInsets.only(
                                                                      bottom:
                                                                          5),
                                                            ),
                                                            controller:
                                                                qtyControllr,
                                                            onSubmitted:
                                                                (text) {
                                                              double q =
                                                                  double.parse(
                                                                      qtyControllr
                                                                          .text);
                                                              double qty = double
                                                                  .parse(snapshot
                                                                              .data[
                                                                          index]
                                                                      [
                                                                      "Quantity"]);
                                                              if (q > 0) {
                                                                // Check valied input quantity

                                                                if (q <= qty) {
                                                                  // Input quantity less than current quantity
                                                                  double total =
                                                                      double.parse(snapshot.data[index]
                                                                              [
                                                                              "SellingPrice"]) *
                                                                          q;
                                                                  double
                                                                      netTotal =
                                                                      double.parse(snapshot.data[index]
                                                                              [
                                                                              "Price"]) *
                                                                          q;
                                                                  getCardData(
                                                                      int.parse(
                                                                          snapshot.data[index]
                                                                              [
                                                                              "Item ID"]),
                                                                      q,
                                                                      total,
                                                                      netTotal,
                                                                      int.parse(
                                                                          snapshot.data[index]
                                                                              [
                                                                              "isFree"]));
                                                                  getNetAmount();
                                                                  cardTimer();
                                                                } else {
                                                                  // Input quantity more than current quantity
                                                                  double
                                                                      avl_qty =
                                                                      q - qty;
                                                                  if (avl_qty <=
                                                                      double.parse(
                                                                          snapshot.data[index]
                                                                              [
                                                                              "Qty"])) {
                                                                    double
                                                                        total =
                                                                        double.parse(snapshot.data[index]["SellingPrice"]) *
                                                                            q;
                                                                    double
                                                                        netTotal =
                                                                        double.parse(snapshot.data[index]["Price"]) *
                                                                            q;
                                                                    getCardData(
                                                                        int.parse(snapshot.data[index]
                                                                            [
                                                                            "Item ID"]),
                                                                        q,
                                                                        total,
                                                                        netTotal,
                                                                        int.parse(snapshot.data[index]
                                                                            [
                                                                            "isFree"]));
                                                                    getNetAmount();
                                                                    cardTimer();
                                                                  } else {
                                                                    Flushbar(
                                                                      messageText:
                                                                          Text(
                                                                        'Not Avalibal Quantity !',
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .orange,
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .warning,
                                                                        size:
                                                                            28.0,
                                                                        color: Colors
                                                                            .red,
                                                                      ),
                                                                      duration: Duration(
                                                                          seconds:
                                                                              5),
                                                                      margin: EdgeInsets
                                                                          .all(
                                                                              8),
                                                                      borderRadius:
                                                                          8,
                                                                      maxWidth:
                                                                          ScreenWidth /
                                                                              2,
                                                                    )..show(
                                                                        context);
                                                                  }
                                                                }
                                                              } else {
                                                                Flushbar(
                                                                  messageText:
                                                                      Text(
                                                                    'Invalied Quantity !',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .orange,
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
                                                                        .red,
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
                                                              }
                                                            },
                                                            enabled: true,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        int.parse(snapshot.data[
                                                                        index][
                                                                    "isFree"]) ==
                                                                0
                                                            ? Container(
                                                                width: 40,
                                                                height: 40,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .blue,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6)),
                                                                child:
                                                                    IconButton(
                                                                        tooltip:
                                                                            'Add Discount',
                                                                        icon: Image
                                                                            .asset(
                                                                          "assets/images/discount.png",
                                                                          width:
                                                                              36,
                                                                          height:
                                                                              36,
                                                                          fit: BoxFit
                                                                              .scaleDown,
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          buildDiscountDialog(
                                                                              context,
                                                                              snapshot,
                                                                              index,
                                                                              ScreenWidth);
                                                                        }),
                                                              )
                                                            : Container(
                                                                width: 40,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child:
                                                                    AutoSizeText(
                                                                  "Free",
                                                                  style: GoogleFonts.robotoCondensed(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .green),
                                                                  maxLines: 1,
                                                                ),
                                                              ),
                                                        SizedBox(
                                                          width: 4,
                                                        ),
                                                        Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                              color: Colors.red,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6)),
                                                          child: IconButton(
                                                              tooltip: 'Remove',
                                                              icon: Icon(
                                                                Icons.cancel,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                getCardData(
                                                                    int.parse(snapshot
                                                                            .data[index]
                                                                        [
                                                                        "Item ID"]),
                                                                    -4,
                                                                    0,
                                                                    0,
                                                                    int.parse(snapshot
                                                                            .data[index]
                                                                        [
                                                                        "isFree"]));
                                                                getNetAmount();
                                                              }),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                  );
                                } else {
                                  return Text("");
                                }
                              }),
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        // Net amount summery viewer
                        Container(
                          height: 100,
                          width: ScreenWidth / 2.8 - 30,
                          padding: EdgeInsets.only(
                              top: 8, bottom: 8, left: 8, right: 32),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200]),
                          child: StreamBuilder(
                              stream: _streamControllerGetnetamount.stream,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasData) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: ScreenWidth / 3 - 30,
                                          child: Stack(
                                            children: [
                                              Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Text("Total")),
                                              Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text(snapshot.data[0]
                                                      ["sumOfTotal"])),
                                            ],
                                          )),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Container(
                                          width: ScreenWidth / 3 - 30,
                                          child: Stack(
                                            children: [
                                              Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Text("Discount")),
                                              Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text(snapshot.data[0]
                                                      ["sumOfDis"])),
                                            ],
                                          )),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Container(
                                          width: ScreenWidth / 3 - 30,
                                          child: Stack(
                                            children: [
                                              Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Text("Net Total")),
                                              Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text(snapshot.data[0][
                                                                  "sumOfNetTotal"]
                                                              .toString() !=
                                                          'null'
                                                      ? snapshot.data[0]
                                                          ["sumOfNetTotal"]
                                                      : '0.00')),
                                            ],
                                          )),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: ScreenWidth / 3 - 30,
                                          child: Stack(
                                            children: [
                                              Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Text("Total")),
                                              Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text("0.00")),
                                            ],
                                          )),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Container(
                                          width: ScreenWidth / 3 - 30,
                                          child: Stack(
                                            children: [
                                              Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Text("Discount")),
                                              Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text("0.00")),
                                            ],
                                          )),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Container(
                                          width: ScreenWidth / 3 - 30,
                                          child: Stack(
                                            children: [
                                              Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Text("Net Total")),
                                              Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text("0.00")),
                                            ],
                                          )),
                                    ],
                                  );
                                }
                              }),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // POS buttons (Pay, Hold, Clear)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                              child: StreamBuilder(
                                  stream: _streamControllerpay.stream,
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    return FlatButton.icon(
                                        onPressed: () {
                                          FocusScope.of(context).unfocus();
                                          if (double.parse(snapshot.data[0]
                                                  ["sumOfNet"]) ==
                                              0) {
                                            Flushbar(
                                              messageText: Text(
                                                'Items not included',
                                                style: TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              icon: Icon(
                                                Icons.info_outline,
                                                size: 28.0,
                                                color: Colors.red[500],
                                              ),
                                              duration: Duration(seconds: 3),
                                              margin: EdgeInsets.all(8),
                                              borderRadius: 8,
                                              maxWidth: ScreenWidth / 2,
                                            )..show(context);
                                          } else if (cusValidator == 0 &&
                                              cussearchControllr
                                                  .text.isNotEmpty) {
                                            Flushbar(
                                              messageText: Text(
                                                'Custemer ID Invalied!',
                                                style: TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              icon: Icon(
                                                Icons.info_outline,
                                                size: 28.0,
                                                color: Colors.red[500],
                                              ),
                                              duration: Duration(seconds: 3),
                                              margin: EdgeInsets.all(8),
                                              borderRadius: 8,
                                              maxWidth: ScreenWidth / 2,
                                            )..show(context);
                                            cussearchControllr.clear();
                                          } else {
                                            // Call buildPaynentDailog method for show Payment Dailog
                                            buildPaymentDialog(
                                                context, ScreenWidth, snapshot);
                                          }
                                        },
                                        icon: Icon(
                                          Icons.payment,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          "Pay",
                                          style: TextStyle(color: Colors.white),
                                        ));
                                  }),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 40,
                              width: ScreenWidth / 9 - 18,
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black54, blurRadius: 8)
                                  ]),
                              child: FlatButton.icon(
                                  onPressed: () {
                                    hold();
                                  },
                                  icon: Icon(
                                    Icons.pause_circle_outline,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "Hold",
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                            SizedBox(
                              width: 10,
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
                                  onPressed: () {
                                    deleteBill();
                                    billID = "";
                                    getNetAmount();
                                    getCardData(-1, -3, 0, 0, 0);
                                  },
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.white),
                                  )),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future buildPaymentDialog(
      BuildContext context, double screenWidth, AsyncSnapshot snapshot) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          int groupValue = 0;
          TextEditingController invoiceNoTextController =
              new TextEditingController();
          TextEditingController cashTextController =
              new TextEditingController();
          TextEditingController balanceTextController =
              new TextEditingController();
          TextEditingController dateController = new TextEditingController();
          final oCcy = new NumberFormat("#,##0.00", "en_US");
          double balance = -1;
          balanceTextController.text = "0.00";
          return WillPopScope(
            onWillPop: () async => null,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.payment,
                    color: Colors.black87,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Payment",
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
                          Navigator.of(context).pop();
                        }),
                  )
                ],
              ),
              titlePadding: EdgeInsets.only(left: 16, top: 0, bottom: 6),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                  width: 400,
                  height: 200,
                  child: Column(
                    children: [
                      Container(
                          width: screenWidth / 3 - 30,
                          child: Stack(
                            children: [
                              Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text("Invoice No")),
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    height: 20,
                                    width: 120,
                                    child: TextField(
                                      autofocus: true,
                                      textAlign: TextAlign.right,
                                      keyboardType: TextInputType.number,
                                      controller: invoiceNoTextController,
                                      decoration: InputDecoration(
                                        hintText: "$billID",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        contentPadding: EdgeInsets.only(
                                            left: 6.0, right: 0, bottom: 13),
                                      ),
                                      enabled: true,
                                    ),
                                  )),
                            ],
                          )),
                      SizedBox(
                        height: 14,
                      ),
                      Container(
                          width: screenWidth / 3 - 30,
                          child: Stack(
                            children: [
                              Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text("Date & Time")),
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    height: 20,
                                    width: 160,
                                    child: TextField(
                                      autofocus: true,
                                      textAlign: TextAlign.right,
                                      keyboardType: TextInputType.datetime,
                                      controller: dateController,
                                      decoration: InputDecoration(
                                        hintText: "yyyy-mm-dd hh:mm",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        contentPadding: EdgeInsets.only(
                                            left: 6.0, right: 0, bottom: 13),
                                      ),
                                      enabled: true,
                                    ),
                                  )),
                            ],
                          )),
                      SizedBox(
                        height: 14,
                      ),
                      Container(
                        child: Stack(
                          children: [
                            Align(
                                alignment: Alignment.bottomLeft,
                                child: Text("Payment Mothed")),
                            Align(
                                alignment: Alignment.topRight,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text("Cash"),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Container(
                                      height: 8,
                                      width: 8,
                                      child: Radio(
                                        value: 0,
                                        groupValue: groupValue,
                                        focusColor: Colors.transparent,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        onChanged: (int value) {
                                          setState(() {
                                            groupValue = 0;
                                            FocusScope.of(context).unfocus();
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 40),
                                    Text("Cheque"),
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Container(
                                      height: 8,
                                      width: 8,
                                      child: Radio(
                                        value: 1,
                                        groupValue: groupValue,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        onChanged: (int value) {
                                          setState(() {
                                            groupValue = 1;
                                            balanceTextController.text = "0.00";
                                            FocusScope.of(context).unfocus();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      Container(
                          width: screenWidth / 3 - 30,
                          child: Stack(
                            children: [
                              Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text("Net Total")),
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child:
                                      Text(snapshot.data[0]["sumOfNetTotal"])),
                            ],
                          )),
                      SizedBox(
                        height: 14,
                      ),
                      Container(
                        child: Stack(
                          children: [
                            Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                    groupValue == 0 ? "Cash" : "Bank Date")),
                            Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  height: 20,
                                  width: 120,
                                  child: TextField(
                                    autofocus: true,
                                    textAlign: TextAlign.right,
                                    keyboardType: TextInputType.number,
                                    controller: cashTextController,
                                    onChanged: (text) {
                                      if (text != "" && groupValue == 0) {
                                        balance = double.parse(text) -
                                            double.parse(
                                                snapshot.data[0]["sumOfNet"]);
                                        balanceTextController.text =
                                            oCcy.format(balance);
                                      } else {
                                        balanceTextController.text = "0.00";
                                      }
                                    },
                                    onSubmitted: (text) {
                                      if (text.isNotEmpty || groupValue == 1) {
                                        String invoiceNo =
                                            invoiceNoTextController.text;
                                        String date = dateController.text;

                                        finishOrder(
                                            cashTextController,
                                            invoiceNo,
                                            date,
                                            balance,
                                            screenWidth,
                                            groupValue);
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: groupValue == 0
                                          ? "0.00"
                                          : "yyyy-mm-dd",
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      contentPadding: EdgeInsets.only(
                                          left: 6.0, right: 0, bottom: 13),
                                    ),
                                    enabled: true,
                                  ),
                                ))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: Stack(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Balance",
                                  style: GoogleFonts.robotoCondensed(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                )),
                            Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  height: 20,
                                  width: 200,
                                  child: TextField(
                                    autofocus: true,
                                    textAlign: TextAlign.right,
                                    keyboardType: TextInputType.number,
                                    controller: balanceTextController,
                                    style: GoogleFonts.robotoCondensed(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      disabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      contentPadding:
                                          EdgeInsets.only(bottom: 10),
                                    ),
                                    enabled: false,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              actionsPadding: EdgeInsets.only(right: 155),
              actions: [
                Container(
                  height: 35,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.blue,
                  ),
                  child: FlatButton.icon(
                      onPressed: () {
                        String invoiceNo = invoiceNoTextController.text;
                        String date = dateController.text;
                        finishOrder(cashTextController, invoiceNo, date,
                            balance, screenWidth, groupValue);
                      },
                      icon: Icon(
                        Icons.done,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Finish",
                        style: TextStyle(color: Colors.white),
                      )),
                )
              ],
            ),
          );
        });
  }

  Future buildDiscountDialog(BuildContext context, AsyncSnapshot snapshot,
      int index, double screenWidth) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          final oCcy = new NumberFormat("#,##0.00", "en_US");
          int groupValue = 0;
          TextEditingController perDisTextController =
              new TextEditingController();
          TextEditingController netTextController = new TextEditingController();
          TextEditingController priceTextController =
              new TextEditingController();
          int itemId = int.parse(snapshot.data[index]["Item ID"]);
          double discount = 0;
          FocusNode focusNode = FocusNode();
          FocusNode btnFocusNode = FocusNode();
          double netTotal = -1;
          double price = 0;
          priceTextController.text = snapshot.data[index]["SPrice"];
          netTextController.text = "${snapshot.data[index]["Net Total (Rs.)"]}";
          String dis = snapshot.data[index]["Discount"];
          if (dis != "0.00") {
            perDisTextController.text = "$dis";
          }
          return WillPopScope(
            onWillPop: () async => null,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.loyalty,
                    color: Colors.black87,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Discount",
                    style: GoogleFonts.robotoCondensed(
                        fontSize: 20, fontWeight: FontWeight.w500),
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
                          Navigator.of(context).pop();
                        }),
                  )
                ],
              ),
              titlePadding: EdgeInsets.only(left: 16, top: 0, bottom: 6),
              content: Container(
                  width: 400,
                  height: 280,
                  child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Option",
                          style: GoogleFonts.robotoCondensed(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              groupValue = 0;
                              perDisTextController.clear();
                              netTextController.text =
                                  "${snapshot.data[index]["Net Total (Rs.)"]}";
                              netTotal = -1;
                              price = 0;
                              focusNode.requestFocus();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 8),
                            child: Row(
                              children: [
                                Container(
                                  height: 8,
                                  width: 8,
                                  child: Radio(
                                    value: 0,
                                    groupValue: groupValue,
                                    focusNode: focusNode,
                                    focusColor: Colors.transparent,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (int value) {
                                      setState(() {
                                        groupValue = 0;
                                        perDisTextController.clear();
                                        netTextController.text = "0.00";
                                        focusNode.requestFocus();
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  "Discount Per Qty",
                                  style: GoogleFonts.robotoCondensed(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              groupValue = 1;
                              perDisTextController.clear();
                              netTextController.text =
                                  "${snapshot.data[index]["Net Total (Rs.)"]}";
                              netTotal = -1;
                              price = 0;
                              focusNode.requestFocus();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 8),
                            child: Row(
                              children: [
                                Container(
                                  height: 8,
                                  width: 8,
                                  child: Radio(
                                    value: 1,
                                    groupValue: groupValue,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (int value) {
                                      setState(() {
                                        groupValue = 1;
                                        perDisTextController.clear();
                                        netTextController.text = "0.00";
                                        btnFocusNode.requestFocus();
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text("Discount All Qty",
                                    style: GoogleFonts.robotoCondensed(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              groupValue = 2;
                              perDisTextController.clear();
                              netTextController.text =
                                  "${snapshot.data[index]["Net Total (Rs.)"]}";
                              netTotal = -1;
                              price = 0;
                              focusNode.requestFocus();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 8),
                            child: Row(
                              children: [
                                Container(
                                  height: 8,
                                  width: 8,
                                  child: Radio(
                                    value: 2,
                                    groupValue: groupValue,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (int value) {
                                      setState(() {
                                        groupValue = 2;
                                        perDisTextController.clear();
                                        netTextController.text = "0.00";
                                        btnFocusNode.requestFocus();
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  "Custom Price Per Qty",
                                  style: GoogleFonts.robotoCondensed(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              groupValue = 3;
                              perDisTextController.clear();
                              netTextController.text =
                                  "${snapshot.data[index]["Net Total (Rs.)"]}";
                              netTotal = -1;
                              price = 0;
                              focusNode.requestFocus();
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 8),
                            child: Row(
                              children: [
                                Container(
                                  height: 8,
                                  width: 8,
                                  child: Radio(
                                    value: 3,
                                    groupValue: groupValue,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (int value) {
                                      setState(() {
                                        groupValue = 3;
                                        perDisTextController.clear();
                                        netTextController.text = "0.00";
                                        btnFocusNode.requestFocus();
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  "Custom Price All Qty",
                                  style: GoogleFonts.robotoCondensed(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                            width: screenWidth / 3 - 30,
                            child: Stack(
                              children: [
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      "Total",
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    )),
                                Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      snapshot.data[index]["Total (Rs.)"],
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    )),
                              ],
                            )),
                        SizedBox(
                          height: 12,
                        ),
                        Container(
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: groupValue == 0
                                    ? Text(
                                        "Discount Per Qty",
                                        style: GoogleFonts.robotoCondensed(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      )
                                    : (groupValue == 1
                                        ? Text(
                                            "Discount All Qty",
                                            style: GoogleFonts.robotoCondensed(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          )
                                        : (groupValue == 2
                                            ? Text(
                                                "Custom Price Per Qty",
                                                style:
                                                    GoogleFonts.robotoCondensed(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500),
                                              )
                                            : Text(
                                                "Custom Price All Qty",
                                                style:
                                                    GoogleFonts.robotoCondensed(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500),
                                              ))),
                              ),
                              Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    height: 20,
                                    width: 120,
                                    child: TextField(
                                      autofocus: true,
                                      textAlign: TextAlign.right,
                                      keyboardType: TextInputType.number,
                                      controller: perDisTextController,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          discount = double.parse(text);
                                          double qty = double.parse(
                                              snapshot.data[index]["Quantity"]);

                                          switch (groupValue) {
                                            case 0:
                                              {
                                                double sellingPrice =
                                                    double.parse(
                                                        snapshot.data[index]
                                                            ["SellingPrice"]);
                                                price = sellingPrice - discount;
                                                netTotal = price * qty;
                                                priceTextController.text =
                                                    oCcy.format(price);
                                                netTextController.text =
                                                    oCcy.format(netTotal);
                                                break;
                                              }
                                            case 1:
                                              {
                                                double total = double.parse(
                                                    snapshot.data[0]["Total"]);
                                                netTotal = total - discount;
                                                price = netTotal / qty;
                                                discount /= qty;
                                                priceTextController.text =
                                                    oCcy.format(price);
                                                netTextController.text =
                                                    oCcy.format(netTotal);
                                                break;
                                              }
                                            case 2:
                                              {
                                                double sellingPrice =
                                                    double.parse(
                                                        snapshot.data[index]
                                                            ["SellingPrice"]);
                                                price = discount;
                                                netTotal = price * qty;
                                                discount = sellingPrice - price;
                                                priceTextController.text =
                                                    oCcy.format(price);
                                                netTextController.text =
                                                    oCcy.format(netTotal);
                                                break;
                                              }
                                            case 3:
                                              {
                                                double sellingPrice =
                                                    double.parse(
                                                        snapshot.data[index]
                                                            ["SellingPrice"]);
                                                netTotal = discount;
                                                price = netTotal / qty;
                                                discount = sellingPrice - price;
                                                priceTextController.text =
                                                    oCcy.format(price);
                                                netTextController.text =
                                                    oCcy.format(netTotal);
                                                break;
                                              }
                                          }
                                        } else {
                                          netTextController.text = snapshot
                                              .data[index]["Net Total (Rs.)"];
                                          priceTextController.text =
                                              snapshot.data[index]["SPrice"];
                                        }
                                      },
                                      onSubmitted: (text) {
                                        if (text.isNotEmpty) {
                                          updateBill(itemId, discount, price,
                                              netTotal);
                                          Navigator.of(context).pop();
                                          getCardData(-1, -3, 0, 0, 0);
                                        } else {
                                          Flushbar(
                                            messageText: Text(
                                              'Enter value for discount!',
                                              style: TextStyle(
                                                  color: Colors.orange[300],
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            icon: Icon(
                                              Icons.warning,
                                              size: 28.0,
                                              color: Colors.orange[800],
                                            ),
                                            duration: Duration(seconds: 5),
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            maxWidth: screenWidth / 2,
                                          )..show(context);
                                          btnFocusNode.requestFocus();
                                        }
                                      },
                                      decoration: InputDecoration(
                                        hintStyle: GoogleFonts.robotoCondensed(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300),
                                        hintText: "0.00",
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        contentPadding: EdgeInsets.only(
                                            left: 6.0, right: 0, bottom: 13),
                                      ),
                                      enabled: true,
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Container(
                          width: 402,
                          alignment: Alignment.centerRight,
                          child: Stack(
                            children: [
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Discount With Price",
                                    style: GoogleFonts.robotoCondensed(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  )),
                              Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.all(0),
                                    height: 20,
                                    width: 200,
                                    child: TextField(
                                      autofocus: true,
                                      textAlign: TextAlign.right,
                                      keyboardType: TextInputType.number,
                                      controller: priceTextController,
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        contentPadding: EdgeInsets.only(
                                            bottom: 16, right: 0),
                                      ),
                                      enabled: false,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Container(
                          child: Stack(
                            children: [
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Net Total",
                                    style: GoogleFonts.robotoCondensed(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    height: 20,
                                    width: 200,
                                    child: TextField(
                                      autofocus: true,
                                      textAlign: TextAlign.right,
                                      keyboardType: TextInputType.number,
                                      controller: netTextController,
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        contentPadding:
                                            EdgeInsets.only(bottom: 10),
                                      ),
                                      enabled: false,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    );
                  })),
              actionsPadding: EdgeInsets.only(right: 165),
              actions: [
                Container(
                  height: 35,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green,
                  ),
                  child: FlatButton.icon(
                      focusNode: btnFocusNode,
                      focusColor: Colors.transparent,
                      onPressed: () {
                        if (perDisTextController.text.isNotEmpty) {
                          updateBill(itemId, discount, price, netTotal);
                          Navigator.of(context).pop();
                          getCardData(-1, -3, 0, 0, 0);
                        } else {
                          Flushbar(
                            messageText: Text(
                              'Enter value for discount!',
                              style: TextStyle(
                                  color: Colors.orange[300],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            icon: Icon(
                              Icons.warning,
                              size: 28.0,
                              color: Colors.orange[800],
                            ),
                            duration: Duration(seconds: 5),
                            margin: EdgeInsets.all(8),
                            borderRadius: 8,
                            maxWidth: screenWidth / 2,
                          )..show(context);
                          btnFocusNode.requestFocus();
                        }
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Add",
                        style: TextStyle(color: Colors.white),
                      )),
                )
              ],
            ),
          );
        });
  }

  Future buildCustomerDialog(
      BuildContext context, AsyncSnapshot snapshot, double screenWidth) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController idController = TextEditingController();
          TextEditingController nameController = TextEditingController();
          TextEditingController addsController = TextEditingController();
          TextEditingController contactController = TextEditingController();

          return WillPopScope(
              onWillPop: () async => null,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.contacts,
                      color: Colors.black87,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "New Customer",
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 20, fontWeight: FontWeight.w500),
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
                            Navigator.of(context).pop();
                          }),
                    )
                  ],
                ),
                titlePadding: EdgeInsets.only(left: 16, top: 0, bottom: 6),
                content: Container(
                  width: 400,
                  height: 312,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      // ID text feild
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: TextFormField(
                          autofocus: true,
                          controller: idController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.black87)),
                              contentPadding:
                                  EdgeInsets.only(left: 6, bottom: 5),
                              labelText: "ID",
                              labelStyle: TextStyle(fontSize: 17),
                              suffixIcon: Icon(Icons.contacts)),
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      // Name text feild
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.black87)),
                              contentPadding:
                                  EdgeInsets.only(left: 6, bottom: 5),
                              labelText: "Name",
                              labelStyle: TextStyle(fontSize: 17),
                              suffixIcon: Icon(Icons.person_outline)),
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      // Address text feild
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: TextFormField(
                          controller: addsController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.black87)),
                              contentPadding:
                                  EdgeInsets.only(left: 6, bottom: 5),
                              labelText: "Address",
                              labelStyle: TextStyle(fontSize: 17),
                              suffixIcon: Icon(Icons.account_balance)),
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      // Contact text feild
                      Container(
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: TextFormField(
                          controller: contactController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.black87)),
                              contentPadding: EdgeInsets.only(left: 6, top: 6),
                              labelText: "Contact",
                              labelStyle: TextStyle(fontSize: 17),
                              suffixIcon: Icon(Icons.smartphone)),
                          maxLines: 1,
                          maxLength: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                actionsPadding: EdgeInsets.only(right: 175),
                actions: [
                  Container(
                    height: 35,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.green,
                    ),
                    child: FlatButton.icon(
                        onPressed: () {
                          // Call addNewCustomer method
                          addNewCustomer(
                            idController.text,
                            nameController.text,
                            addsController.text,
                            contactController.text,
                          );
                        },
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        label: Text(
                          "Add",
                          style: TextStyle(color: Colors.white),
                        )),
                  )
                ],
              ));
        });
  }

/*----------------------- Backend Methods -----------------------*/

// Finish order for item finish button
  Future finishOrder(
    TextEditingController cashAndBankDate,
    String invoiceNo,
    String date,
    double balance,
    double screenWidth,
    int groupValue,
  ) async {
    if (invoiceNo.isNotEmpty) {
      // Use custom invoice no

      if (groupValue == 0) {
        // Cash payment

        double cash = double.parse(cashAndBankDate.text);
        insertBill(billID, invoiceNo, date, "TestUser",
            cussearchControllr.text.toString(), cash, balance, "Cash", "");
      } else {
        // Cheque payment
        String bankDate = cashAndBankDate.text;
        insertBill(billID, invoiceNo, date, "TestUser",
            cussearchControllr.text.toString(), 0, 0, "Cheque", bankDate);
        getCheque();
      }
    } else {
      // Use auto genarated invoice no

      if (groupValue == 0) {
        // Cash payment

        double cash = double.parse(cashAndBankDate.text);
        insertBill(billID, billID, date, "TestUser",
            cussearchControllr.text.toString(), cash, balance, "Cash", "");
      } else {
        // Cheque payment
        String bankDate = cashAndBankDate.text;
        insertBill(billID, billID, date, "TestUser",
            cussearchControllr.text.toString(), 0, 0, "Cheque", bankDate);
        getCheque();
      }
    }
  }

// Add item to card for item press & long press
  void addItemToCard(
      BuildContext context,
      int index,
      int itemID,
      String itemName,
      double quantity,
      double buyingPrice,
      double sellingPrice,
      int free) {
    if (quantity < 1) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBox(
              title: itemName,
              descriptions: "Out Of Stock",
              text: "OK",
            );
          });
    } else {
      if (billID == "") {
        int day = Jiffy().dayOfYear;
        billID =
            "${new DateTime.now().year.toString().substring(2, 4)}$day${new DateTime.now().hour}${new DateTime.now().minute}${new DateTime.now().second}";
      }

      sendData(itemID, itemName, buyingPrice, sellingPrice, free);
      getNetAmount();
      getCardData(-1, -3, 0, 0, 0);
      cardTimer();
      getNetAmount();
    }
  }

// Add new customer for Add button
  void addNewCustomer(
    String customerID,
    String customerName,
    String custmoerAddress,
    String customerContact,
  ) {
    if (customerID.isNotEmpty ||
        customerName.isNotEmpty ||
        customerContact.isNotEmpty) {
      addCustomer(customerID, customerName, custmoerAddress, customerContact);
    } else {
      Flushbar(
        messageText: Text(
          'Enter Customer ID, Name & Contact!',
          style: TextStyle(
              color: Colors.orange[300],
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        icon: Icon(
          Icons.warning,
          size: 28.0,
          color: Colors.orange[800],
        ),
        duration: Duration(seconds: 5),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        maxWidth: 500,
      )..show(context);
      FocusScope.of(context).unfocus();
    }
  }
}
