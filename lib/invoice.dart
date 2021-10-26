import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Invoice extends StatefulWidget {

  @override
  _InvoiceState createState() => _InvoiceState();
}

class _InvoiceState extends State<Invoice> {
  String billID = "-1";
  String sText = "";
  int selectedIndex=0;
  int groupValue=0;//for get data
  StreamController _streamControllerGetdata = StreamController();
  StreamController _streamControllerGetcard = StreamController();
  StreamController _streamControllerCus = StreamController();
  var itmsearchControllr = TextEditingController();

  String total ="0.00";
  String discount="0.00";
  String netTotal='0.00';
  String payMethod="Not Select";
  String CusID="Not Select";
  String balance="0.00";



  Future getData() async {
    final response = await http.post("http://127.0.0.1/loadBill.php", body: {
      "BillID": "$billID",
      "Date": "",
    });

    var data = await  json.decode(response.body);
    _streamControllerGetdata.add(data);
  }

  static Future<List> getBillSearch(String billID) async {
    final response = await http.post("http://127.0.0.1/billItemSearch.php", body: {
      "BillID": "$billID",
    });
    var items= await  json.decode(response.body);

    return List.generate(items.length, (index) {
      return {'id': items[index]["Bill ID"],'Time': items[index]["Time"]};
    });
  }


  Future get_cardData() async {
    final response = await http.post("http://127.0.0.1/getItem4Return.php", body: {
      "BillID": "$billID",
    });
    var data = await json.decode(response.body);
    _streamControllerGetcard.add(data);
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

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double ScreenWidth = MediaQuery.of(context).size.width;
    double ScreenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.transparent,
        height: ScreenHeight,
        width: ScreenWidth-80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24,top: 40),
                  child: Container(
                      padding: EdgeInsets.only(top: 5),
                      alignment: Alignment.center,
                      width: ScreenWidth/3,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                            autofocus: false,
                            controller: itmsearchControllr,
                            style: DefaultTextStyle.of(context).style.copyWith(
                                fontSize: 16
                            ),
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white
                                  )
                              ),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white
                                  )
                              ),
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white
                                  )
                              ),
                              contentPadding: EdgeInsets.only(top:10, left: 10.0),
                              hintText: "Search...",
                              suffixIcon: Icon(Icons.search, color: Colors.grey.withOpacity(0.4) ,),
                            ),
                            enabled: true,
                            onChanged: (text){
                              if(text.length==0) {
                                billID = "-1";
                                getData();
                              }
                            }
                        ),
                        suggestionsCallback: (pattern) async {
                          return await getBillSearch(pattern);
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            title: AutoSizeText(suggestion['id'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,),
                            subtitle: Column(
                              children: [
                                AutoSizeText((suggestion['Time']),
                                  maxLines: 1,),
                              ],
                            ),
                          );
                        },
                        onSuggestionSelected: (suggestion) {
                          billID = suggestion['id'];
                          itmsearchControllr.text=suggestion['id'];
                          getData();
                        },
                      )
                  ),
                ),
                SizedBox(height: 5,),
                Container(
                  height: ScreenHeight-150,
                  width: ScreenWidth/1.8-200,
                  padding: EdgeInsets.all(8),
                  child: StreamBuilder(
                      stream: _streamControllerGetdata.stream,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        //var blob = snapshot.data[0]["img"];
                        //var image = Base64Codec().decode(blob);
                        if (snapshot.hasData) {
                          if(snapshot.data[0]["Bill ID"]!="not"){
                            return Scrollbar(
                              child: ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index){
                                    double bal =double.parse(snapshot.data[index]["BalValue"]);
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: new Container(
                                        width: 120,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey.withOpacity(0.9),
                                                blurRadius: 6
                                            )
                                          ],
                                          borderRadius: BorderRadius.circular(8),
                                          color: bal>=0? Colors.white : Colors.red[100],
                                        ),
                                        child: FlatButton(
                                          child: Stack(
                                            children: [
                                              SizedBox(width: 8,),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    AutoSizeText(snapshot.data[index]["Bill ID"],
                                                      style:  GoogleFonts.robotoCondensed(
                                                          fontSize: 22, fontWeight: FontWeight.w500,
                                                          color: Colors.brown
                                                      ), maxLines: 1,
                                                    ),
                                                    SizedBox(width: 30,),
                                                    AutoSizeText("${snapshot.data[index]["Time"]}",
                                                      style:  GoogleFonts.robotoCondensed(
                                                          fontSize: 22, fontWeight: FontWeight.w500,
                                                          color: Colors.black87
                                                      ), maxLines: 1,),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: AutoSizeText("${snapshot.data[index]["NetTotal"]}",
                                                  style:  GoogleFonts.robotoCondensed(
                                                      fontSize: 24, fontWeight: FontWeight.w500,
                                                      color: Colors.black87
                                                  ), maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onPressed: (){
                                            setState(() {
                                              billID=snapshot.data[index]["Bill ID"];
                                              total=snapshot.data[index]["Total"];
                                              discount=snapshot.data[index]["Dis"];
                                              netTotal=snapshot.data[index]["NetTotal"];
                                              payMethod=snapshot.data[index]["PayMethod"];
                                              CusID=snapshot.data[index]["Cus"];
                                              balance=bal.toString();
                                              get_cardData();
                                              getCustomer();
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  }
                              ),
                            );
                          }else{
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset("assets/images/no_items_found.jpg", width: 340,
                                  height: 340,fit: BoxFit.scaleDown,),
                              ],
                            );
                          }
                        }else{
                          return Center(child: CircularProgressIndicator());
                        }
                      }
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40,left: 24),
              child: Container(
                height: ScreenHeight-50,
                width: ScreenWidth/2.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color:  Colors.white,
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          width:(ScreenWidth/2.2-50) ,
                          height: ScreenHeight-300,
                          child: Column(
                            children: [
                              AutoSizeText("Items",
                                style:  GoogleFonts.robotoCondensed(
                                    fontSize: 22, fontWeight: FontWeight.w500,
                                    color: Colors.brown
                                ), maxLines: 1,
                              ),
                              StreamBuilder(
                                  stream: _streamControllerGetcard.stream,
                                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if(snapshot.hasData) {
                                      return Container(
                                        height: ScreenHeight-350,
                                        child: ListView.builder(
                                            itemCount: snapshot.data.length,
                                            padding: EdgeInsets.all(16),
                                            itemBuilder: (BuildContext context, int index){
                                              var qtyControllr = TextEditingController();
                                              qtyControllr.text = "${snapshot.data[index]["Quantity"]}";
                                              final oCcy = new NumberFormat("#,##0.00", "en_US");
                                              String price =oCcy.format(double.parse(snapshot.data[index]["Price"]));
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 16),
                                                child: Container(
                                                  height: 100,
                                                  padding: EdgeInsets.all(10),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.grey.withOpacity(0.5),
                                                            blurRadius: 9
                                                        )
                                                      ],
                                                      color: Colors.white
                                                  ),
                                                  child:
                                                  Stack(
                                                    children: [
                                                      Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Image.network("http://127.0.0.1/images/${snapshot.data[index]["image"]}",width: 50, height: 50, fit: BoxFit.scaleDown,),
                                                            SizedBox(width:20,),
                                                            Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                AutoSizeText(snapshot.data[index]["Item Name"],
                                                                  style:  GoogleFonts.robotoCondensed(
                                                                    fontSize: 20, fontWeight: FontWeight.w500,
                                                                    color: Colors.black87),),
                                                                SizedBox(height: 5,),
                                                                AutoSizeText(price,
                                                                  style:  GoogleFonts.robotoCondensed(
                                                                      fontSize: 20, fontWeight: FontWeight.w500,
                                                                      color: Colors.grey[600]),),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child:Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        SizedBox(width: 50,),
                                                        AutoSizeText(snapshot.data[index]["Quantity"],
                                                          style:  GoogleFonts.robotoCondensed(
                                                              fontSize: 24, fontWeight: FontWeight.w500,
                                                              color: Colors.black87)),
                                                      ],
                                                    ),
                                                  ),

                                                      Align(
                                                        alignment: Alignment.topRight,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            AutoSizeText("${snapshot.data[index]["Total (Rs.)"]}",
                                                              style:  GoogleFonts.robotoCondensed(
                                                                  fontSize: 20, fontWeight: FontWeight.w500,
                                                                  color: Colors.grey[600]),),
                                                            SizedBox(height: 8,),
                                                            AutoSizeText("${snapshot.data[index]["Discount"]}",
                                                              style:  GoogleFonts.robotoCondensed(
                                                                  fontSize: 20, fontWeight: FontWeight.w500,
                                                                  color: Colors.grey[600]),),
                                                            SizedBox(height: 8,),
                                                            AutoSizeText("${snapshot.data[index]["Net Total (Rs.)"]}",
                                                              style:  GoogleFonts.robotoCondensed(
                                                                  fontSize: 21, fontWeight: FontWeight.w500,
                                                                  color: Colors.black87),),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                        ),
                                      );
                                    }else {
                                      return Text("");
                                    }
                                  }
                              ),
                            ],
                          ),
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
                            width: ScreenWidth - (ScreenWidth/1.8-185)-240,
                            padding: EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 32),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200]
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width:ScreenWidth - (ScreenWidth/1.8-185)-108,
                                    child: Stack(
                                      children: [
                                        Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text("Total")
                                        ),
                                        Align(
                                            alignment: Alignment.topRight,
                                            child: Text(total)),
                                      ],
                                    )
                                ),
                                SizedBox(height: 8,),
                                Container(
                                    width:ScreenWidth - (ScreenWidth/1.8-185)-108,
                                    child: Stack(
                                      children: [
                                        Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text("Discount")
                                        ),
                                        Align(
                                            alignment: Alignment.topRight,
                                            child: Text(discount)),
                                      ],
                                    )
                                ),
                                SizedBox(height: 8,),
                                Container(
                                    width:ScreenWidth - (ScreenWidth/1.8-185)-108,
                                    child: Stack(
                                      children: [
                                        Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text("Net Total")
                                        ),
                                        Align(
                                            alignment: Alignment.topRight,
                                            child: Text(netTotal)),
                                      ],
                                    )
                                ),
                                SizedBox(height: 8,),
                                StreamBuilder(
                                    stream: _streamControllerCus.stream,
                                    builder: (context, snapshot) {
                                      if(snapshot.hasData){
                                        return Container(
                                            width:ScreenWidth - (ScreenWidth/1.8-185)-108,
                                            child: Stack(
                                              children: [
                                                Align(
                                                    alignment: Alignment.bottomLeft,
                                                    child: Text("Customer ID")
                                                ),
                                                Align(
                                                    alignment: Alignment.topRight,
                                                    child: CusID!=''?GestureDetector(
                                                        onTap: (){
                                                          showDialog(context: context,
                                                              builder: (BuildContext context) {
                                                                getCustomer();
                                                                return WillPopScope(
                                                                    onWillPop: () async => null,
                                                                    child: StatefulBuilder(
                                                                        builder: (BuildContext context, StateSetter setState) {
                                                                          return AlertDialog(
                                                                            shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                            ),
                                                                            title: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Icon(Icons.contacts, color: Colors.black87,),
                                                                                SizedBox(width: 20,),
                                                                                Text("Customer Details", style: GoogleFonts.robotoCondensed(
                                                                                    fontSize: 20, fontWeight: FontWeight.w500
                                                                                ),),
                                                                                SizedBox(width: 260,),
                                                                                Container(
                                                                                  width: 40,
                                                                                  height: 40,
                                                                                  child: IconButton(icon: Icon(Icons.close, color: Colors.red,),
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      }),
                                                                                )
                                                                              ],
                                                                            ),
                                                                            titlePadding: EdgeInsets.only(left: 16, top: 0, bottom: 2),
                                                                            content: Container(
                                                                              width: 400,
                                                                              height: 280,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  SizedBox(height: 16,),
                                                                                  AutoSizeText("ID",
                                                                                    style:  GoogleFonts.robotoCondensed(
                                                                                        fontSize: 20, fontWeight: FontWeight.w600
                                                                                    ), maxLines: 1,),
                                                                                  SizedBox(height: 8,),
                                                                                  AutoSizeText('$CusID',
                                                                                    style:  GoogleFonts.robotoCondensed(
                                                                                        fontSize: 20, fontWeight: FontWeight.w500
                                                                                    ), maxLines: 1,  ),
                                                                                  SizedBox(height: 16,),

                                                                                  AutoSizeText('Name',
                                                                                    style:  GoogleFonts.robotoCondensed(
                                                                                        fontSize: 20, fontWeight: FontWeight.w600
                                                                                    ), maxLines: 1,  ),
                                                                                  SizedBox(height: 8,),
                                                                                  AutoSizeText('${snapshot.data[0]["Name"]}',
                                                                                    style:  GoogleFonts.robotoCondensed(
                                                                                        fontSize: 20, fontWeight: FontWeight.w500
                                                                                    ), maxLines: 1,  ),
                                                                                  SizedBox(height: 16,),

                                                                                  AutoSizeText('Address',
                                                                                    style:  GoogleFonts.robotoCondensed(
                                                                                        fontSize: 20, fontWeight: FontWeight.w600
                                                                                    ), maxLines: 1,  ),
                                                                                  SizedBox(height: 8,),
                                                                                  AutoSizeText('${snapshot.data[0]["Address"]}',
                                                                                    style:  GoogleFonts.robotoCondensed(
                                                                                        fontSize: 20, fontWeight: FontWeight.w500
                                                                                    ), maxLines: 1,  ),
                                                                                  SizedBox(height: 16,),

                                                                                  AutoSizeText('Contact',
                                                                                    style:  GoogleFonts.robotoCondensed(
                                                                                        fontSize: 20, fontWeight: FontWeight.w600
                                                                                    ), maxLines: 1,  ),
                                                                                  SizedBox(height: 8,),
                                                                                  AutoSizeText('${snapshot.data[0]["Contact"]}',
                                                                                    style:  GoogleFonts.robotoCondensed(
                                                                                        fontSize: 20, fontWeight: FontWeight.w500
                                                                                    ), maxLines: 1,  ),

                                                                                ],
                                                                              ),
                                                                            ),
                                                                            contentPadding: EdgeInsets.only(top: 4, left: 16, right: 16),
                                                                          );
                                                                        }
                                                                    )
                                                                );
                                                              }
                                                          );
                                                        },
                                                        child: Text(CusID)
                                                    ):
                                                    Text('Not ID')
                                                ),
                                              ],
                                            )
                                        );
                                      }else{
                                        return Container(
                                            width:ScreenWidth - (ScreenWidth/1.8-185)-108,
                                            child: Stack(
                                              children: [
                                                Align(
                                                    alignment: Alignment.bottomLeft,
                                                    child: Text("Customer")
                                                ),
                                                Align(
                                                    alignment: Alignment.topRight,
                                                    child: Text("No Data")),
                                              ],
                                            )
                                        );
                                      }

                                    }
                                ),
                                SizedBox(height: 8,),
                                Container(
                                    width:ScreenWidth - (ScreenWidth/1.8-185)-108,
                                    child: Stack(
                                      children: [
                                        Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text("Pament By")
                                        ),
                                        Align(
                                            alignment: Alignment.topRight,
                                            child: Text(payMethod)),
                                      ],
                                    )
                                ),
                                SizedBox(height: 8,),
                                Container(
                                    width:ScreenWidth - (ScreenWidth/1.8-185)-108,
                                    child: Stack(
                                      children: [
                                        Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Text("Balance")
                                        ),
                                        Align(
                                            alignment: Alignment.topRight,
                                            child: Text(balance)),
                                      ],
                                    )
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15,),
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
