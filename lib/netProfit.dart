import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class Profit extends StatefulWidget {
  @override
  _ProfitState createState() => _ProfitState();
}

class _ProfitState extends State<Profit> {
  String dateCat;
  String monthCat;
  String yearCat;
  String mode = "";
  String dateValue;
  String xAxis = "Hour";

  FocusNode changeFocusNode = new FocusNode();
  final List<PopulationData> earnData = [];
  final List<PopulationData> profitData = [];
  final List<PopulationData> costData = [];
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

  Future getSummery() async {
    final response =
        await http.post("http://127.0.0.1/getProfitSummery.php", body: {
      "Date": "$dateValue",
    });
    var items = await json.decode(response.body);
    allDay.add(items);
  }

  Future getData(String file) async {
    final response = await http.post("http://127.0.0.1/$file", body: {
      "Date": "$dateValue",
    });

    var items = await json.decode(response.body);

    earnData.clear();
    profitData.clear();
    costData.clear();
    setState(() {
      for (int i = 0; i < items.length; i++) {
        if (items[i]["Earn"].toString() != "null") {
          earnData.add(PopulationData(
            amount: double.parse(items[i]["Earn"]),
            time: int.parse(items[i]["Time"]),
          ));
        }

        if (items[i]["Profit"].toString() != "null") {
          profitData.add(PopulationData(
            amount: double.parse(items[i]["Profit"]),
            time: int.parse(items[i]["Time"]),
          ));
        }
        if (items[i]["Cost"].toString() != "null") {
          costData.add(PopulationData(
            amount: double.parse(items[i]["Cost"]),
            time: int.parse(items[i]["Time"]),
          ));
        }
      }
    });
  }

  _getSeriesData() {
    return [
      new charts.Series<PopulationData, int>(
          id: "Earn",
          data: earnData,
          domainFn: (PopulationData series, _) => series.time,
          measureFn: (PopulationData series, _) => series.amount,
          colorFn: (PopulationData series, _) =>
              charts.MaterialPalette.blue.shadeDefault),
      new charts.Series<PopulationData, int>(
          id: "profit",
          data: profitData,
          domainFn: (PopulationData series, _) => series.time,
          measureFn: (PopulationData series, _) => series.amount,
          colorFn: (PopulationData series, _) =>
              charts.MaterialPalette.green.shadeDefault),
      new charts.Series<PopulationData, int>(
          id: "cost",
          data: costData,
          domainFn: (PopulationData series, _) => series.time,
          measureFn: (PopulationData series, _) => series.amount,
          colorFn: (PopulationData series, _) =>
              charts.MaterialPalette.red.shadeDefault),
    ];
  }

  void initState() {
    dateValue = "${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
    mode = "${DateFormat('yyyy MMMM dd').format(DateTime.now())}";

    getData("getDayProfit.php");
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
                child: Container(
                  width: ScreenWidth - 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
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

                                    dateValue =
                                        "${dateCat.split(' ')[0]}-$m-$d";
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
                                                  style: GoogleFonts
                                                      .robotoCondensed(
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
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        height: 8,
                                                        width: 8,
                                                        child: Radio(
                                                          value: 0,
                                                          groupValue:
                                                              groupValue,
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          onChanged:
                                                              (int value) {
                                                            setState(() {
                                                              groupValue = 0;
                                                              val = "Date";
                                                              mode = dateCat;
                                                              xAxis = "Hour";
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
                                                          groupValue:
                                                              groupValue,
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          onChanged:
                                                              (int value) {
                                                            setState(() {
                                                              groupValue = 1;
                                                              val = "Month";
                                                              xAxis = "Day";
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
                                                          groupValue:
                                                              groupValue,
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          onChanged:
                                                              (int value) {
                                                            setState(() {
                                                              groupValue = 2;
                                                              val = "Year";
                                                              mode = yearCat;
                                                              xAxis = "Month";
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
                                                                FontWeight
                                                                    .w500),
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

                                                              String m =
                                                                  dateCat.split(
                                                                      ' ')[1];
                                                              String d =
                                                                  dateCat.split(
                                                                      ' ')[2];
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
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.white)),
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
                                                                      getMonth(
                                                                          m);

                                                                  dateValue =
                                                                      "${monthCat.split(' ')[0]}-$month";
                                                                  mode =
                                                                      monthCat;
                                                                },
                                                                decoration:
                                                                    InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.white)),
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
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.white)),
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
                                                      switch (groupValue) {
                                                        case 0:
                                                          getData(
                                                              "getDayProfit.php");
                                                          break;
                                                        case 1:
                                                          getData(
                                                              "getMonthProfit.php");
                                                          break;
                                                        case 2:
                                                          getData(
                                                              "getYearProfit.php");
                                                          break;
                                                      }
                                                      Navigator.of(context)
                                                          .pop();
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
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 16),
                child: Container(
                  height: ScreenHeight - 290,
                  width: ScreenWidth - 150,
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
                              "Amount",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          )),
                      Container(
                        height: ScreenHeight - 330,
                        width: ScreenWidth - 150,
                        padding: EdgeInsets.only(left: 20, right: 100),
                        child: new charts.LineChart(
                          _getSeriesData(),
                          animate: true,
                          behaviors: [
                            charts.SlidingViewport(),
                            charts.PanAndZoomBehavior(),
                          ],
                          defaultRenderer: charts.LineRendererConfig(
                            includePoints: true,
                          ),
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
                                      "Total Earn",
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
                                        backgroundColor: Colors.red,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      "Total Cost",
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
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      "Net Profit",
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
                            xAxis,
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
                        TextEditingController costController =
                            new TextEditingController();
                        TextEditingController profitController =
                            new TextEditingController();
                        costController.text = '0';
                        profitController.text =
                            snapshot.data[0]["Profit"].toString() == "null"
                                ? "0"
                                : snapshot.data[0]["Profit"].toString();
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
                                      "Total Earn",
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                    ),
                                    SizedBox(
                                      height: 18,
                                    ),
                                    AutoSizeText(
                                      snapshot.data[0]["Earn"].toString() ==
                                              "null"
                                          ? "0"
                                          : snapshot.data[0]["Earn"],
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
                                      "Cost",
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                    ),
                                    SizedBox(
                                      height: 18,
                                    ),
                                    AutoSizeText(
                                        snapshot.data[0]["Cost"].toString() ==
                                                "null"
                                            ? "0"
                                            : snapshot.data[0]["Cost"],
                                        style: GoogleFonts.robotoCondensed(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w500),
                                        maxLines: 1),
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
                                    color: Colors.orange,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black26, blurRadius: 5)
                                    ]),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
                                      "Other Cost",
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                    ),
                                    SizedBox(
                                      height: 18,
                                    ),
                                    TextField(
                                      autofocus: true,
                                      controller: costController,
                                      textAlign: TextAlign.center,
                                      onChanged: (text) {
                                        double cost = double.parse(text);
                                        if (cost > 0) {
                                          double profit = double.parse(
                                              profitController.text);
                                          double netProfit = profit - cost;
                                          profitController.text =
                                              netProfit.toString();
                                        }
                                      },
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent)),
                                        contentPadding:
                                            EdgeInsets.only(left: 6, bottom: 5),
                                      ),
                                    )
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
                                      "Net Profit",
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                    ),
                                    SizedBox(
                                      height: 18,
                                    ),
                                    TextField(
                                      enabled: false,
                                      controller: profitController,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent)),
                                        disabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.transparent)),
                                        contentPadding:
                                            EdgeInsets.only(left: 6, bottom: 5),
                                      ),
                                    )
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
  double amount;
  int time;

  PopulationData({
    @required this.amount,
    @required this.time,
  });
}
