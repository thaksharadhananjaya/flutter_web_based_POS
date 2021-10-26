import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Return extends StatefulWidget {
  @override
  _ReturnState createState() => _ReturnState();
}

class _ReturnState extends State<Return> {
  String billID = "-1";
  String sText = "";
  int selectedIndex = -1;
  String dateCat;
  String monthCat;
  String yearCat;
  static String dateValue = "";
  int groupValue = 0; //for get data
  StreamController _streamControllerGetdata = StreamController();
  StreamController _streamControllerGetcard = StreamController();
  StreamController _streamControllerReturnCard = StreamController();
  StreamController _streamControllerCus = StreamController();
  final List<ReturnItem> item = [];
  var itmsearchControllr = TextEditingController();

  String total = "0.00";
  String discount = "0.00";
  String netTotal = '0.00';
  String payMethod = "Not Select";
  String CusID = "Not Select";
  String balance = "0.00";
  String returnQuery = "";
  double balc = 0;
  List<DropdownMenuItem<String>> date = new List();
  List<DropdownMenuItem<String>> month = new List();
  List<DropdownMenuItem<String>> year = new List();

  Future getDate() async {
    final response = await http.get('http://127.0.0.1//getDate.php');
    var data = await json.decode(response.body);

    date = new List();
    for (int i = 0; i < data.length; i++) {
      String cat = data[i]["Date"];
      date.add(new DropdownMenuItem(value: cat, child: new Text(cat)));
    }
    dateCat = data[0]["Date"];
  }

  Future getMonth() async {
    final response = await http.get('http://127.0.0.1//getMonth.php');
    var data = await json.decode(response.body);
    month = new List();
    for (int i = 0; i < data.length; i++) {
      String cat = data[i]["Month"];
      month.add(new DropdownMenuItem(value: cat, child: new Text(cat)));
    }
    monthCat = data[0]["Month"];
  }

  Future getYear() async {
    final response = await http.get('http://127.0.0.1//getYear.php');
    var data = await json.decode(response.body);
    year = new List();
    for (int i = 0; i < data.length; i++) {
      String cat = data[i]["Year"];
      year.add(new DropdownMenuItem(value: cat, child: new Text(cat)));
    }
    yearCat = data[0]["Year"];
  }

  void addIteme(
      String itemID,
      String itemName,
      String img,
      String netAmount,
      String Qty,
      double total,
      double net,
      double price,
      double sPrice,
      double dis) {
    for (int i = 0; i < item.length; i++) {
      if (item[i].itemName == itemName) {
        item.removeAt(i);
        break;
      }
    }
    item.add(ReturnItem(
      itemID: itemID,
      itemName: itemName,
      netAmount: netAmount,
      image: img,
      Qty: Qty,
      netTotal: net,
      total: total,
      price: price,
      sPrice: sPrice,
      balance: dis,
    ));
    _streamControllerReturnCard.add(item);
  }

  Future updateItem(String id, String q) async {
    final response = await http.post("http://127.0.0.1/updateItemR.php", body: {
      "ItemID": "$id",
      "Qty": "$q",
    });
  }

  Future getData() async {
    final response = await http.post("http://127.0.0.1/loadBill.php", body: {
      "BillID": "$billID",
      "Date": "$dateValue",
    });

    var data = await json.decode(response.body);
    _streamControllerGetdata.add(data);
  }

  static Future<List> getBillSearch(String billID) async {
    final response =
        await http.post("http://127.0.0.1/billItemSearch.php", body: {
      "BillID": "$billID",
      "Date": "$dateValue",
    });
    var items = await json.decode(response.body);

    return List.generate(items.length, (index) {
      return {'id': items[index]["Bill ID"], 'Time': items[index]["Time"]};
    });
  }

  Future getCardData() async {
    final response =
        await http.post("http://127.0.0.1/getItem4Return.php", body: {
      "BillID": "$billID",
    });
    var data = await json.decode(response.body);
    _streamControllerGetcard.add(data);
  }

  Future insertReturnBill(String id, String name, String quantity, double balc,
      String usr, String typ) async {
    final response =
        await http.post("http://127.0.0.1/insertReturn.php", body: {
      "BillID": "$billID",
      "ItemName": "$name",
      "ItemID": "$id",
      "Qty": "$quantity",
      "Bal": "$balc",
      "User": "$usr",
      "Type": "$typ",
    });
  }

  Future updateBillitem(
      String itemID, String qty, String total, String netTotal) async {
    var bill = billID;
    final response =
        await http.post("http://127.0.0.1/updetReturnItm.php", body: {
      "BillID": "$billID",
      "ItemID": "$itemID",
      "Qty": "$qty",
      "Total": "$total",
      "NetTotal": "$netTotal",
    });
  }

  Future updateBillItemOnline(String returnQry) async {
    final responseServer = await http.post(
        "http://shinegroup98656.000webhostapp.com/updateReturnItm.php",
        body: {
          "Query": "$returnQry",
        });
  }

  Future updateBill(
      double discount, double total, double netT, double bal) async {
    final response = await http.post("http://127.0.0.1/updateBillR.php", body: {
      "BillID": "$billID",
      "Dis": "$discount",
      "Total": "$total",
      "NetTotal": "$netT",
      "Balance": "$bal",
    });
  }

  Future getCustomer() async {
    final response = await http.post("http://127.0.0.1/getCustomer.php", body: {
      "ID": "$CusID",
    });
    var data = await json.decode(response.body);
    _streamControllerCus.add(data);
  }

  void initState() {
    getData();
    getDate();
    getMonth();
    getYear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 40),
                  child: Row(
                    children: [
                      Container(
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
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    border: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    contentPadding:
                                        EdgeInsets.only(top: 10, left: 10.0),
                                    hintText: "Search...",
                                    suffixIcon: IconButton(
                                        icon: Icon(Icons.filter_list),
                                        hoverColor: Colors.transparent,
                                        tooltip: 'Select Date',
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                int groupValue = 0;
                                                String val = "";
                                                String getMonth(String m) {
                                                  switch (m) {
                                                    case 'January':
                                                      return '01';
                                                      break;
                                                    case 'February':
                                                      return '02';
                                                      break;
                                                    case 'March':
                                                      return '03';
                                                      break;
                                                    case 'April':
                                                      return '04';
                                                      break;
                                                    case 'May':
                                                      return '05';
                                                      break;
                                                    case 'June':
                                                      return '06';
                                                      break;
                                                    case 'July':
                                                      return '07';
                                                      break;
                                                    case 'August':
                                                      return '08';
                                                      break;
                                                    case 'September':
                                                      return '09';
                                                      break;
                                                    case 'October':
                                                      return '10';
                                                      break;
                                                    case 'November':
                                                      return '11';
                                                      break;
                                                    case 'December':
                                                      return '12';
                                                  }
                                                }

                                                String d =
                                                    dateCat.split(' ')[2];
                                                String m = getMonth(
                                                    dateCat.split(' ')[1]);

                                                dateValue =
                                                    "${dateCat.split(' ')[0]}-$m-$d";
                                                return WillPopScope(
                                                    onWillPop: () async => null,
                                                    child: StatefulBuilder(
                                                        builder: (BuildContext
                                                                context,
                                                            StateSetter
                                                                setState) {
                                                      return AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        title: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Icon(
                                                              Icons.filter_list,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                            SizedBox(
                                                              width: 20,
                                                            ),
                                                            Text(
                                                              "Change",
                                                              style: GoogleFonts
                                                                  .robotoCondensed(
                                                                      fontSize:
                                                                          20,
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
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                  onPressed:
                                                                      () {
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
                                                          height: 180,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SizedBox(
                                                                height: 12,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    height: 8,
                                                                    width: 8,
                                                                    child:
                                                                        Radio(
                                                                      value: 0,
                                                                      groupValue:
                                                                          groupValue,
                                                                      materialTapTargetSize:
                                                                          MaterialTapTargetSize
                                                                              .shrinkWrap,
                                                                      onChanged:
                                                                          (int
                                                                              value) {
                                                                        setState(
                                                                            () {
                                                                          groupValue =
                                                                              0;
                                                                          dateValue =
                                                                              "";
                                                                          String
                                                                              val =
                                                                              "";
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 12,
                                                                  ),
                                                                  Text(
                                                                    "All",
                                                                    style: GoogleFonts.robotoCondensed(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 30,
                                                                  ),
                                                                  Container(
                                                                    height: 8,
                                                                    width: 8,
                                                                    child:
                                                                        Radio(
                                                                      value: 1,
                                                                      groupValue:
                                                                          groupValue,
                                                                      materialTapTargetSize:
                                                                          MaterialTapTargetSize
                                                                              .shrinkWrap,
                                                                      onChanged:
                                                                          (int
                                                                              value) {
                                                                        setState(
                                                                            () {
                                                                          groupValue =
                                                                              1;
                                                                          val =
                                                                              "Date";
                                                                          String
                                                                              m =
                                                                              getMonth(dateCat.split(" ")[1]);
                                                                          dateValue =
                                                                              "${dateCat.split(" ")[0]}-$m-${dateCat.split(" ")[2]}";
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 12,
                                                                  ),
                                                                  Text(
                                                                    "Daily",
                                                                    style: GoogleFonts.robotoCondensed(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 30,
                                                                  ),
                                                                  Container(
                                                                    height: 8,
                                                                    width: 8,
                                                                    child:
                                                                        Radio(
                                                                      value: 2,
                                                                      groupValue:
                                                                          groupValue,
                                                                      materialTapTargetSize:
                                                                          MaterialTapTargetSize
                                                                              .shrinkWrap,
                                                                      onChanged:
                                                                          (int
                                                                              value) {
                                                                        setState(
                                                                            () {
                                                                          groupValue =
                                                                              2;
                                                                          val =
                                                                              "Month";
                                                                          String
                                                                              m =
                                                                              getMonth(monthCat.split(" ")[1]);
                                                                          dateValue =
                                                                              "${monthCat.split(" ")[0]}-$m";
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 12,
                                                                  ),
                                                                  Text(
                                                                    "Monthy",
                                                                    style: GoogleFonts.robotoCondensed(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 30,
                                                                  ),
                                                                  Container(
                                                                    height: 8,
                                                                    width: 8,
                                                                    child:
                                                                        Radio(
                                                                      value: 3,
                                                                      groupValue:
                                                                          groupValue,
                                                                      materialTapTargetSize:
                                                                          MaterialTapTargetSize
                                                                              .shrinkWrap,
                                                                      onChanged:
                                                                          (int
                                                                              value) {
                                                                        setState(
                                                                            () {
                                                                          groupValue =
                                                                              3;
                                                                          val =
                                                                              "Year";
                                                                          dateValue =
                                                                              yearCat;
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 12,
                                                                  ),
                                                                  Text(
                                                                    "Yearly",
                                                                    style: GoogleFonts.robotoCondensed(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 40,
                                                              ),
                                                              Text(
                                                                "Select $val",
                                                                style: GoogleFonts.robotoCondensed(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              SizedBox(
                                                                height: 5,
                                                              ),
                                                              Container(
                                                                height: 40,
                                                                width: 200,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(0),
                                                                child: groupValue ==
                                                                        0
                                                                    ? Text(
                                                                        'All',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              24,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign
                                                                                .center)
                                                                    : (groupValue ==
                                                                            1
                                                                        ? DropdownButtonFormField(
                                                                            value:
                                                                                dateCat,
                                                                            items:
                                                                                date,
                                                                            onChanged:
                                                                                (selectValue) {
                                                                              dateCat = selectValue;

                                                                              String m = dateCat.split(' ')[1];
                                                                              String d = dateCat.split(' ')[2];
                                                                              String month = getMonth(m);

                                                                              dateValue = "${dateCat.split(' ')[0]}-$month-$d";
                                                                            },
                                                                            decoration:
                                                                                InputDecoration(
                                                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white)),
                                                                              contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                                                            ),
                                                                          )
                                                                        : (groupValue ==
                                                                                2
                                                                            ? DropdownButtonFormField(
                                                                                value: monthCat,
                                                                                items: month,
                                                                                onChanged: (selectValue) {
                                                                                  monthCat = selectValue;

                                                                                  String m = monthCat.split(' ')[1];
                                                                                  String month = getMonth(m);

                                                                                  dateValue = "${monthCat.split(' ')[0]}-$month";
                                                                                },
                                                                                decoration: InputDecoration(
                                                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white)),
                                                                                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                                                                ),
                                                                              )
                                                                            : DropdownButtonFormField(
                                                                                value: yearCat,
                                                                                items: year,
                                                                                onChanged: (selectValue) {
                                                                                  yearCat = selectValue;
                                                                                  dateValue = yearCat;
                                                                                },
                                                                                decoration: InputDecoration(
                                                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white)),
                                                                                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                                                                ),
                                                                              ))),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                top: 4,
                                                                left: 16,
                                                                right: 16),
                                                        actionsPadding:
                                                            EdgeInsets.only(
                                                                right: 170,
                                                                bottom: 8),
                                                        actions: [
                                                          Container(
                                                            height: 35,
                                                            width: 100,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                            child:
                                                                FlatButton.icon(
                                                                    focusColor:
                                                                        Colors
                                                                            .transparent,
                                                                    icon: Icon(
                                                                        Icons
                                                                            .done,
                                                                        color: Colors
                                                                            .white),
                                                                    label: Text(
                                                                      "OK",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      if (groupValue ==
                                                                          0) {
                                                                        dateValue =
                                                                            "";
                                                                      }
                                                                      getData();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    }),
                                                          )
                                                        ],
                                                      );
                                                    }));
                                              });
                                        }),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Colors.grey.withOpacity(0.4),
                                    )),
                                enabled: true,
                                onChanged: (text) {
                                  if (text.length == 0) {
                                    billID = "-1";
                                    setState(() {
                                      getData();
                                      getCardData();
                                      item.clear();
                                    });
                                  }
                                }),
                            suggestionsCallback: (pattern) async {
                              return await getBillSearch(pattern);
                            },
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: AutoSizeText(
                                  suggestion['id'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                ),
                                subtitle: Column(
                                  children: [
                                    AutoSizeText(
                                      (suggestion['Time']),
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              );
                            },
                            onSuggestionSelected: (suggestion) {
                              billID = suggestion['id'];
                              itmsearchControllr.text = suggestion['id'];
                              getData();
                              setState(() {
                                selectedIndex = 0;
                                item.clear();
                                getCardData();
                              });
                            },
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                    width: ScreenWidth / 1.8 - 200,
                    height: 40,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.transparent),
                    child: Stack(children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          'Invoice No',
                          style: GoogleFonts.robotoCondensed(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.brown),
                          maxLines: 1,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: AutoSizeText(
                          "Date & Time",
                          style: GoogleFonts.robotoCondensed(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                          maxLines: 1,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: AutoSizeText(
                          "Net Total",
                          style: GoogleFonts.robotoCondensed(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                          maxLines: 1,
                        ),
                      ),
                    ])),
                Container(
                  height: ScreenHeight - 160,
                  width: ScreenWidth / 1.8 - 200,
                  padding: EdgeInsets.all(8),
                  child: StreamBuilder(
                      stream: _streamControllerGetdata.stream,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data[0]["Bill ID"] != "not") {
                            return Scrollbar(
                              child: ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    double bal = double.parse(
                                        snapshot.data[index]["BalValue"]);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 4),
                                      child: new Container(
                                        width: 120,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: selectedIndex == index
                                              ? (bal >= 0
                                                  ? Colors.grey.withOpacity(0.7)
                                                  : Colors.red[300]
                                                      .withOpacity(0.7))
                                              : (bal >= 0
                                                  ? Colors.white
                                                  : Colors.red[100]),
                                        ),
                                        child: FlatButton(
                                          child: Stack(
                                            children: [
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: AutoSizeText(
                                                  snapshot.data[index]
                                                      ["Bill ID"],
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.brown),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.center,
                                                child: AutoSizeText(
                                                  "${snapshot.data[index]["Time"]}",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.black87),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    AutoSizeText(
                                                      "${snapshot.data[index]["NetTotal"]}",
                                                      style: GoogleFonts
                                                          .robotoCondensed(
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Colors
                                                                  .black87),
                                                      maxLines: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          onPressed: () {
                                            item.clear();
                                            if (bal > 0) {
                                              bal = 0;
                                            }
                                            setState(() {
                                              billID = snapshot.data[index]
                                                  ["Bill ID"];
                                              total =
                                                  snapshot.data[index]["Total"];
                                              discount =
                                                  snapshot.data[index]["Dis"];
                                              netTotal = snapshot.data[index]
                                                  ["NetTotal"];
                                              payMethod = snapshot.data[index]
                                                  ["PayMethod"];
                                              CusID =
                                                  snapshot.data[index]["Cus"];
                                              balance = bal.toString();
                                              balc = double.parse(snapshot
                                                  .data[index]["BalValue"]);
                                              selectedIndex = index;
                                              getCardData();
                                              getCustomer();
                                            });
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
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 24),
              child: Container(
                height: ScreenHeight - 50,
                width: ScreenWidth - (ScreenWidth / 1.8 - 185) - 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: (ScreenWidth - (ScreenWidth / 1.8 - 140)) /
                                      2 -
                                  40,
                              height: ScreenHeight - 300,
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(color: Colors.black54)),
                                  color: Colors.white),
                              child: Column(
                                children: [
                                  AutoSizeText(
                                    "Items",
                                    style: GoogleFonts.robotoCondensed(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.brown),
                                    maxLines: 1,
                                  ),
                                  StreamBuilder(
                                      stream: _streamControllerGetcard.stream,
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        if (snapshot.hasData) {
                                          return Container(
                                            height: ScreenHeight - 350,
                                            child: ListView.builder(
                                                itemCount: snapshot.data.length,
                                                padding: EdgeInsets.all(16),
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  var qtyControllr =
                                                      TextEditingController();
                                                  qtyControllr.text =
                                                      "${snapshot.data[index]["Quantity"]}";
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 16),
                                                    child: Container(
                                                      width: 100,
                                                      height: 60,
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.5),
                                                                blurRadius: 9)
                                                          ],
                                                          color: Colors.white),
                                                      child: Stack(
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Image.network(
                                                                  "http://127.0.0.1/images/${snapshot.data[index]["image"]}",
                                                                  width: 30,
                                                                  height: 30,
                                                                  fit: BoxFit
                                                                      .scaleDown,
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
                                                                    AutoSizeText(
                                                                      snapshot.data[
                                                                              index]
                                                                          [
                                                                          "Item Name"],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              11),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    AutoSizeText(
                                                                      "Rs. ${snapshot.data[index]["Net Total (Rs.)"]}",
                                                                      style: TextStyle(
                                                                          color: Colors.grey[
                                                                              600],
                                                                          fontSize:
                                                                              11),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Container(
                                                                  height: 40,
                                                                  width: 40,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .black54,
                                                                        width:
                                                                            1),
                                                                  ),
                                                                  child:
                                                                      TextField(
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      enabledBorder:
                                                                          UnderlineInputBorder(
                                                                              borderSide: BorderSide(color: Colors.white)),
                                                                      focusedBorder:
                                                                          UnderlineInputBorder(
                                                                              borderSide: BorderSide(color: Colors.white)),
                                                                      border: UnderlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(color: Colors.white)),
                                                                      contentPadding:
                                                                          EdgeInsets.only(
                                                                              bottom: 5),
                                                                    ),
                                                                    controller:
                                                                        qtyControllr,
                                                                    enabled: snapshot.data[index]["isFree"] ==
                                                                            '0'
                                                                        ? true
                                                                        : false,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 6,
                                                                ),
                                                                snapshot.data[index]
                                                                            [
                                                                            "isFree"] ==
                                                                        '0'
                                                                    ? Container(
                                                                        width:
                                                                            36,
                                                                        height:
                                                                            36,
                                                                        decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(4),
                                                                            color: Colors.orange),
                                                                        alignment:
                                                                            Alignment.center,
                                                                        child: IconButton(
                                                                            icon: Icon(
                                                                              Icons.arrow_forward_ios,
                                                                              color: Colors.white,
                                                                            ),
                                                                            tooltip: 'Add to return',
                                                                            padding: EdgeInsets.all(0),
                                                                            onPressed: () {
                                                                              double q = double.parse(qtyControllr.text);
                                                                              if (q > 0 && q <= double.parse(snapshot.data[index]["Quantity"])) {
                                                                                final oCcy = new NumberFormat("#,##0.00", "en_US");
                                                                                double total = q * double.parse(snapshot.data[index]["SPrice"]);
                                                                                double netT = q * double.parse(snapshot.data[index]["Price"]);
                                                                                setState(() {
                                                                                  addIteme(snapshot.data[index]["Item ID"], snapshot.data[index]["Item Name"], snapshot.data[index]["image"], oCcy.format(netT), q.toString(), total, netT, double.parse(snapshot.data[index]["Price"]), double.parse(snapshot.data[index]["SPrice"]), double.parse(snapshot.data[index]["Dis"]));
                                                                                });
                                                                                FocusScope.of(context).unfocus();
                                                                              } else {
                                                                                qtyControllr.text = snapshot.data[index]["Quantity"];
                                                                                FocusScope.of(context).unfocus();
                                                                                Flushbar(
                                                                                  messageText: Text(
                                                                                    'Invalied Quantity',
                                                                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                  icon: Icon(
                                                                                    Icons.info_outline,
                                                                                    size: 28.0,
                                                                                    color: Colors.orange[800],
                                                                                  ),
                                                                                  duration: Duration(seconds: 5),
                                                                                  margin: EdgeInsets.all(8),
                                                                                  borderRadius: 8,
                                                                                  maxWidth: ScreenWidth / 2,
                                                                                )..show(context);
                                                                              }
                                                                            }),
                                                                      )
                                                                    : AutoSizeText(
                                                                        "Free",
                                                                        style: GoogleFonts.robotoCondensed(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            color: Colors.green),
                                                                        maxLines:
                                                                            1,
                                                                      ),
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
                                ],
                              ),
                            ),
                            Container(
                              width: (ScreenWidth - (ScreenWidth / 1.8 - 140)) /
                                      2 -
                                  40,
                              height: ScreenHeight - 300,
                              child: Column(
                                children: [
                                  AutoSizeText(
                                    "Return List",
                                    style: GoogleFonts.robotoCondensed(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.brown),
                                    maxLines: 1,
                                  ),
                                  Container(
                                    height: ScreenHeight - 350,
                                    child: ListView.builder(
                                        itemCount: item.length,
                                        padding: EdgeInsets.all(16),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16),
                                            child: Container(
                                              width: 100,
                                              height: 60,
                                              padding: EdgeInsets.all(10),
                                              alignment: Alignment.center,
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
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Image.network(
                                                          "http://127.0.0.1/images/${item[index].image}",
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
                                                            AutoSizeText(
                                                              item[index]
                                                                  .itemName,
                                                              style: TextStyle(
                                                                  fontSize: 11),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            AutoSizeText(
                                                              "Rs. ${item[index].netAmount}",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                  fontSize: 11),
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
                                                        AutoSizeText(
                                                          item[index].Qty,
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                          maxLines: 1,
                                                        ),
                                                        SizedBox(
                                                          width: 16,
                                                        ),
                                                        Container(
                                                          width: 36,
                                                          height: 36,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                              color:
                                                                  Colors.red),
                                                          alignment:
                                                              Alignment.center,
                                                          child: IconButton(
                                                              icon: Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              tooltip: 'Remove',
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                              onPressed: () {
                                                                setState(() {
                                                                  item.removeAt(
                                                                      index);
                                                                });
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
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 150,
                            width:
                                ScreenWidth - (ScreenWidth / 1.8 - 185) - 120,
                            padding: EdgeInsets.only(
                                top: 8, bottom: 8, left: 8, right: 32),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200]),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width: ScreenWidth -
                                        (ScreenWidth / 1.8 - 185) -
                                        108,
                                    child: Stack(
                                      children: [
                                        Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text("Total")),
                                        Align(
                                            alignment: Alignment.topRight,
                                            child: Text(total)),
                                      ],
                                    )),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                    width: ScreenWidth -
                                        (ScreenWidth / 1.8 - 185) -
                                        108,
                                    child: Stack(
                                      children: [
                                        Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text("Discount")),
                                        Align(
                                            alignment: Alignment.topRight,
                                            child: Text(discount)),
                                      ],
                                    )),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                    width: ScreenWidth -
                                        (ScreenWidth / 1.8 - 185) -
                                        108,
                                    child: Stack(
                                      children: [
                                        Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text("Net Total")),
                                        Align(
                                            alignment: Alignment.topRight,
                                            child: Text(netTotal)),
                                      ],
                                    )),
                                SizedBox(
                                  height: 8,
                                ),
                                StreamBuilder(
                                    stream: _streamControllerCus.stream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Container(
                                            width: ScreenWidth -
                                                (ScreenWidth / 1.8 - 185) -
                                                108,
                                            child: Stack(
                                              children: [
                                                Align(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Text("Customer ID")),
                                                Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: CusID != ''
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    getCustomer();
                                                                    return WillPopScope(
                                                                        onWillPop:
                                                                            () async =>
                                                                                null,
                                                                        child: StatefulBuilder(builder: (BuildContext
                                                                                context,
                                                                            StateSetter
                                                                                setState) {
                                                                          return AlertDialog(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                            ),
                                                                            title:
                                                                                Row(
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
                                                                                  "Customer Details",
                                                                                  style: GoogleFonts.robotoCondensed(fontSize: 20, fontWeight: FontWeight.w500),
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
                                                                            titlePadding: EdgeInsets.only(
                                                                                left: 16,
                                                                                top: 0,
                                                                                bottom: 2),
                                                                            content:
                                                                                Container(
                                                                              width: 400,
                                                                              height: 280,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  SizedBox(
                                                                                    height: 16,
                                                                                  ),
                                                                                  AutoSizeText(
                                                                                    "ID",
                                                                                    style: GoogleFonts.robotoCondensed(fontSize: 20, fontWeight: FontWeight.w600),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 8,
                                                                                  ),
                                                                                  AutoSizeText(
                                                                                    '$CusID',
                                                                                    style: GoogleFonts.robotoCondensed(fontSize: 20, fontWeight: FontWeight.w500),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 16,
                                                                                  ),
                                                                                  AutoSizeText(
                                                                                    'Name',
                                                                                    style: GoogleFonts.robotoCondensed(fontSize: 20, fontWeight: FontWeight.w600),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 8,
                                                                                  ),
                                                                                  AutoSizeText(
                                                                                    '${snapshot.data[0]["Name"]}',
                                                                                    style: GoogleFonts.robotoCondensed(fontSize: 20, fontWeight: FontWeight.w500),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 16,
                                                                                  ),
                                                                                  AutoSizeText(
                                                                                    'Address',
                                                                                    style: GoogleFonts.robotoCondensed(fontSize: 20, fontWeight: FontWeight.w600),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 8,
                                                                                  ),
                                                                                  AutoSizeText(
                                                                                    '${snapshot.data[0]["Address"]}',
                                                                                    style: GoogleFonts.robotoCondensed(fontSize: 20, fontWeight: FontWeight.w500),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 16,
                                                                                  ),
                                                                                  AutoSizeText(
                                                                                    'Contact',
                                                                                    style: GoogleFonts.robotoCondensed(fontSize: 20, fontWeight: FontWeight.w600),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 8,
                                                                                  ),
                                                                                  AutoSizeText(
                                                                                    '${snapshot.data[0]["Contact"]}',
                                                                                    style: GoogleFonts.robotoCondensed(fontSize: 20, fontWeight: FontWeight.w500),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            contentPadding: EdgeInsets.only(
                                                                                top: 4,
                                                                                left: 16,
                                                                                right: 16),
                                                                          );
                                                                        }));
                                                                  });
                                                            },
                                                            child: Text(CusID))
                                                        : Text('Not ID')),
                                              ],
                                            ));
                                      } else {
                                        return Container(
                                            width: ScreenWidth -
                                                (ScreenWidth / 1.8 - 185) -
                                                108,
                                            child: Stack(
                                              children: [
                                                Align(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Text("Customer")),
                                                Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Text("No Data")),
                                              ],
                                            ));
                                      }
                                    }),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                    width: ScreenWidth -
                                        (ScreenWidth / 1.8 - 185) -
                                        108,
                                    child: Stack(
                                      children: [
                                        Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text("Pament By")),
                                        Align(
                                            alignment: Alignment.topRight,
                                            child: Text(payMethod)),
                                      ],
                                    )),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                    width: ScreenWidth -
                                        (ScreenWidth / 1.8 - 185) -
                                        108,
                                    child: Stack(
                                      children: [
                                        Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text("Balance")),
                                        Align(
                                            alignment: Alignment.topRight,
                                            child: Text(balance)),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 30,
                              ),
                              Text(
                                "Customer",
                                style: GoogleFonts.robotoCondensed(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Container(
                                height: 8,
                                width: 8,
                                child: Radio(
                                  value: 0,
                                  groupValue: groupValue,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onChanged: (int value) {
                                    setState(() {
                                      groupValue = 0;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Text(
                                "Exipire",
                                style: GoogleFonts.robotoCondensed(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
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
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 50,
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
                                        if (item.length > 0) {
                                          String type = groupValue == 0
                                              ? 'Customer'
                                              : 'Expire';
                                          double netT = 0;
                                          double t = 0;
                                          for (int i = 0;
                                              i < item.length;
                                              i++) {
                                            updateBillitem(
                                                item[i].itemID,
                                                item[i].Qty,
                                                item[i].total.toString(),
                                                item[i].netTotal.toString());
                                            netT += item[i].netTotal;
                                            t += item[i].total;

                                            insertReturnBill(
                                                item[i].itemID,
                                                item[i].itemName,
                                                item[i].Qty,
                                                item[i].netTotal,
                                                "testuser",
                                                type);
                                            returnQuery +=
                                                "UPDATE `billitem` SET `Quantity` = `Quantity`-${item[i].Qty}, `Total (Rs.)` = `Total (Rs.)`-${item[i].total}, `Net Total (Rs.)` = `Net Total (Rs.)` -${item[i].netTotal} WHERE `billitem`.`Item ID` = '${item[i].itemID}' AND `billitem`.`Bill ID`='$billID' AND `isFree` = '0';";
                                            if (groupValue == 0) {
                                              updateItem(
                                                  item[i].itemID, item[i].Qty);
                                            }
                                          }

                                          updateBillItemOnline(returnQuery);
                                          returnQuery = "";
                                          double balance = netT + balc;
                                          double discount = t - netT;
                                          updateBill(
                                              discount, t, netT, balance);
                                          if (balc < 0) {
                                            netT = balance;
                                          }
                                          final oCcy = new NumberFormat(
                                              "#,##0.00", "en_US");
                                          setState(() {
                                            billID = "-1";
                                            item.clear();
                                            getCardData();
                                            getData();
                                          });
                                          Flushbar(
                                            messageText: Text(
                                              'Item Returned. Balance = ${oCcy.format(netT)}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            icon: Icon(
                                              Icons.info_outline,
                                              size: 28.0,
                                              color: Colors.blue[800],
                                            ),
                                            duration: Duration(seconds: 5),
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            maxWidth: ScreenWidth / 2,
                                          )..show(context);
                                        } else {
                                          Flushbar(
                                            messageText: Text(
                                              'Return List Empty',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            icon: Icon(
                                              Icons.info_outline,
                                              size: 28.0,
                                              color: Colors.orange[800],
                                            ),
                                            duration: Duration(seconds: 5),
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            maxWidth: ScreenWidth / 2,
                                          )..show(context);
                                        }
                                      },
                                      icon: Icon(
                                        Icons.assignment_returned,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        "Return",
                                        style: TextStyle(color: Colors.white),
                                      ))),
                            ],
                          ),
                          SizedBox(
                            height: 8,
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
    );
  }
}

class ReturnItem {
  String itemID;
  String itemName;
  String netAmount;
  String image;
  String Qty;
  double total;
  double netTotal;
  double price;
  double balance;
  double sPrice;

  ReturnItem(
      {@required this.itemID,
      @required this.itemName,
      @required this.netAmount,
      @required this.image,
      @required this.Qty,
      @required this.total,
      @required this.netTotal,
      @required this.price,
      @required this.balance,
      @required this.sPrice});
}
