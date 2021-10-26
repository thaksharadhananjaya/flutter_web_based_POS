import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class ItemReport extends StatefulWidget {
  @override
  _ItemReportState createState() => _ItemReportState();
}

class _ItemReportState extends State<ItemReport> {
  String itmID = "-1"; //for get data
  String dateCat;
  String monthCat;
  String yearCat;
  String mode = "";
  String dateValue;

  FocusNode changeFocusNode = new FocusNode();
  TextEditingController itmsearchControllr = TextEditingController();
  final List<PopulationData> sallData = [];
  final List<PopulationData> returnData = [];
  StreamController allDay = new StreamController();
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

  Future getSummery() async {
    final response =
        await http.post("http://127.0.0.1/getGraphSummery.php", body: {
      "ItemID": "$itmID",
      "Date": "$dateValue",
    });
    var items = await json.decode(response.body);
    allDay.add(items);
  }

  Future getData() async {
    final response =
        await http.post("http://127.0.0.1/graphAllItem.php", body: {
      "ItemID": "$itmID",
      "Date": "$dateValue",
    });

    var items = await json.decode(response.body);

    final _response =
        await http.post("http://127.0.0.1/getReturnQty.php", body: {
      "ItemID": "$itmID",
      "Date": "$dateValue",
    });

    var itemsRtn = await json.decode(_response.body);

    sallData.clear();
    returnData.clear();
    setState(() {
      for (int i = 0; i < items.length; i++) {
        if (items[i]["Qty"].toString() != "null") {
          sallData.add(PopulationData(
              quantity: double.parse(items[i]["Qty"]),
              itemName: items[i]["Item Name"],
              barColor: charts.ColorUtil.fromDartColor(Colors.lightBlue)));
        }
      }

      for (int i = 0; i < itemsRtn.length; i++) {
        if (itemsRtn[i]["RtnQty"].toString() != "null") {
          returnData.add(PopulationData(
              quantity: double.parse(itemsRtn[i]["RtnQty"]),
              itemName: itemsRtn[i]["Item Name"],
              barColor: charts.ColorUtil.fromDartColor(Colors.redAccent)));
        }
      }
    });
  }

  _getSeriesData() {
    return [
      new charts.Series<PopulationData, String>(
          id: "Salles",
          data: sallData,
          domainFn: (PopulationData series, _) => series.itemName,
          measureFn: (PopulationData series, _) => series.quantity,
          colorFn: (PopulationData series, _) => series.barColor),
      new charts.Series<PopulationData, String>(
          id: "Return",
          data: returnData,
          domainFn: (PopulationData series, _) => series.itemName,
          measureFn: (PopulationData series, _) => series.quantity,
          colorFn: (PopulationData series, _) => series.barColor),
    ];
  }

  Timer _timer;
  void initState() {
    dateValue = "${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
    mode = "${DateFormat('yyyy MMMM dd').format(DateTime.now())}";

    getData();
    getSummery();
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
        changeFocusNode.requestFocus();
      },
      child: Container(
          color: Colors.transparent,
          height: ScreenHeight - 5,
          width: ScreenWidth - 80,
          child: Column(
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
                        width: ScreenWidth / 2 - 50,
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
                                if (text.toString().isNotEmpty) {
                                  itmID = text;
                                  getSummery();
                                  getData();
                                }
                                changeFocusNode.requestFocus();
                              },
                              style: GoogleFonts.robotoCondensed(
                                  fontSize: 20, fontWeight: FontWeight.w500),
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
                                hintText:
                                    "Enter Item. Currently Result Show All Items",
                                suffixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey.withOpacity(0.4),
                                ),
                              ),
                              enabled: true,
                              onChanged: (text) {
                                if (text.length == 0) {
                                  itmID = "-1";
                                  getSummery();
                                  getData();
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
                                    color: double.parse(
                                                suggestion['quantity']) <
                                            1
                                        ? Colors.red[300]
                                        : (double.parse(
                                                    suggestion['quantity']) <=
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

                            getData();
                            getSummery();
                          },
                        )),
                    SizedBox(
                      width: 30,
                    ),
                    Container(
                      child: AutoSizeText(
                        mode,
                        style: GoogleFonts.robotoCondensed(
                            fontSize: 30, fontWeight: FontWeight.w500),
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Container(
                      width: 120,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.blue),
                      child: FlatButton.icon(
                          onPressed: () {
                            changeFocusNode.requestFocus();
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  FocusNode okFocusNode = new FocusNode();
                                  int groupValue = 0;
                                  String val = "Date";
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

                                  String d = dateCat.split(' ')[2];
                                  String m = getMonth(dateCat.split(' ')[1]);

                                  dateValue = "${dateCat.split(' ')[0]}-$m-$d";
                                  mode = dateCat;
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
                                                Icons.filter_list,
                                                color: Colors.black87,
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                "Change",
                                                style:
                                                    GoogleFonts.robotoCondensed(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w500),
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
                                                      Navigator.of(context)
                                                          .pop();
                                                    }),
                                              )
                                            ],
                                          ),
                                          titlePadding: EdgeInsets.only(
                                              left: 16, top: 0, bottom: 2),
                                          content: Container(
                                            width: 400,
                                            height: 180,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 12,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      height: 8,
                                                      width: 8,
                                                      child: Radio(
                                                        value: 0,
                                                        groupValue: groupValue,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        onChanged: (int value) {
                                                          setState(() {
                                                            groupValue = 0;
                                                            val = "Date";
                                                            mode = dateCat;
                                                            String m = getMonth(
                                                                dateCat.split(
                                                                    " ")[1]);
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
                                                      style: GoogleFonts
                                                          .robotoCondensed(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                    SizedBox(
                                                      width: 30,
                                                    ),
                                                    Container(
                                                      height: 8,
                                                      width: 8,
                                                      child: Radio(
                                                        value: 1,
                                                        groupValue: groupValue,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        onChanged: (int value) {
                                                          setState(() {
                                                            groupValue = 1;
                                                            val = "Month";
                                                            String m = getMonth(
                                                                monthCat.split(
                                                                    " ")[1]);
                                                            mode = monthCat;
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
                                                      style: GoogleFonts
                                                          .robotoCondensed(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                    SizedBox(
                                                      width: 30,
                                                    ),
                                                    Container(
                                                      height: 8,
                                                      width: 8,
                                                      child: Radio(
                                                        value: 2,
                                                        groupValue: groupValue,
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                        onChanged: (int value) {
                                                          setState(() {
                                                            groupValue = 2;
                                                            val = "Year";
                                                            mode = yearCat;
                                                            dateValue = yearCat;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 12,
                                                    ),
                                                    Text(
                                                      "Yearly",
                                                      style: GoogleFonts
                                                          .robotoCondensed(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 40,
                                                ),
                                                Text(
                                                  "Select $val",
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Container(
                                                  height: 40,
                                                  width: 200,
                                                  padding: EdgeInsets.all(0),
                                                  child: groupValue == 0
                                                      ? DropdownButtonFormField(
                                                          value: dateCat,
                                                          items: date,
                                                          onChanged:
                                                              (selectValue) {
                                                            dateCat =
                                                                selectValue;

                                                            String m = dateCat
                                                                .split(' ')[1];
                                                            String d = dateCat
                                                                .split(' ')[2];
                                                            String month =
                                                                getMonth(m);

                                                            dateValue =
                                                                "${dateCat.split(' ')[0]}-$month-$d";
                                                            mode = dateCat;
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .white)),
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            4),
                                                          ),
                                                        )
                                                      : (groupValue == 1
                                                          ? DropdownButtonFormField(
                                                              value: monthCat,
                                                              items: month,
                                                              onChanged:
                                                                  (selectValue) {
                                                                monthCat =
                                                                    selectValue;

                                                                String m =
                                                                    monthCat.split(
                                                                        ' ')[1];
                                                                String month =
                                                                    getMonth(m);

                                                                dateValue =
                                                                    "${monthCat.split(' ')[0]}-$month";
                                                                mode = monthCat;
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Colors.white)),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            4),
                                                              ),
                                                            )
                                                          : DropdownButtonFormField(
                                                              value: yearCat,
                                                              items: year,
                                                              onChanged:
                                                                  (selectValue) {
                                                                yearCat =
                                                                    selectValue;
                                                                dateValue =
                                                                    yearCat;
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                border: OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    borderSide:
                                                                        BorderSide(
                                                                            color:
                                                                                Colors.white)),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            4),
                                                              ),
                                                            )),
                                                ),
                                              ],
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.only(
                                              top: 4, left: 16, right: 16),
                                          actionsPadding:
                                              EdgeInsets.only(right: 170),
                                          actions: [
                                            Container(
                                              height: 35,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.green,
                                              ),
                                              child: FlatButton.icon(
                                                  focusNode: okFocusNode,
                                                  focusColor:
                                                      Colors.transparent,
                                                  icon: Icon(Icons.done,
                                                      color: Colors.white),
                                                  label: Text(
                                                    "OK",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  onPressed: () {
                                                    getSummery();
                                                    getData();
                                                    Navigator.of(context).pop();
                                                  }),
                                            )
                                          ],
                                        );
                                      }));
                                });
                          },
                          focusColor: Colors.transparent,
                          focusNode: changeFocusNode,
                          icon: Icon(Icons.filter_list, color: Colors.white),
                          label: Text(
                            "Change",
                            style: TextStyle(color: Colors.white),
                          )),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 16),
                child: Container(
                  height: ScreenHeight - 290,
                  width: ScreenWidth - 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 1)
                      ]),
                  padding: EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              "Quantity",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          )),
                      Container(
                        height: ScreenHeight - 330,
                        width: ScreenWidth - 150,
                        padding: EdgeInsets.only(left: 20, right: 100),
                        child: new charts.BarChart(
                          _getSeriesData(),
                          animate: true,
                        ),
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Container(
                                      width: 14,
                                      height: 14,
                                      child: CircleAvatar(
                                        radius: 80,
                                        backgroundColor: Colors.blue,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      "Sales",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Container(
                                      width: 14,
                                      height: 14,
                                      child: CircleAvatar(
                                        radius: 80,
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      "Return",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            "Item Name",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          )),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StreamBuilder(
                    stream: allDay.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          width: ScreenWidth - 200,
                          height: 150,
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 170,
                                height: 130,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.blue[200],
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26, blurRadius: 5)
                                    ]),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
                                      "Total Salle",
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                    ),
                                    SizedBox(
                                      height: 18,
                                    ),
                                    AutoSizeText(
                                      snapshot.data[0]["Qty"].toString() ==
                                              "null"
                                          ? "0"
                                          : snapshot.data[0]["Qty"],
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 150,
                              ),
                              Container(
                                width: 170,
                                height: 130,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.redAccent[100],
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26, blurRadius: 5)
                                    ]),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
                                      "Total Return",
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                    ),
                                    SizedBox(
                                      height: 18,
                                    ),
                                    AutoSizeText(
                                      snapshot.data[0]["RtnQty"].toString() ==
                                              "null"
                                          ? "0"
                                          : snapshot.data[0]["RtnQty"],
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 150,
                              ),
                              Container(
                                width: 170,
                                height: 130,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.green[200],
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26, blurRadius: 5)
                                    ]),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
                                      "Total Profit",
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                    ),
                                    SizedBox(
                                      height: 18,
                                    ),
                                    AutoSizeText(
                                      snapshot.data[0]["Pofit"].toString() ==
                                              "null"
                                          ? "0"
                                          : snapshot.data[0]["Pofit"],
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 150,
                              ),
                              Container(
                                width: 170,
                                height: 130,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.green[200],
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26, blurRadius: 5)
                                    ]),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
                                      "Total Free",
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                    ),
                                    SizedBox(
                                      height: 18,
                                    ),
                                    AutoSizeText(
                                      snapshot.data[0]["Free"].toString() ==
                                              "null"
                                          ? "0"
                                          : snapshot.data[0]["Free"],
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Text("");
                      }
                    }),
              )
            ],
          )),
    );
  }
}

class PopulationData {
  double quantity;
  String itemName;
  charts.Color barColor;
  PopulationData(
      {@required this.quantity,
      @required this.itemName,
      @required this.barColor});
}
