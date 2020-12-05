import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:persian_date/persian_date.dart';

class ShowCountryInformation extends StatefulWidget {
  final country;
  ShowCountryInformation({@required this.country});
  @override
  _ShowCountryInformationState createState() => _ShowCountryInformationState();
}

class _ShowCountryInformationState extends State<ShowCountryInformation> {

  List items=new List();
  bool loading=true;
  PersianDate persianDate = PersianDate();
  var toDate;
  var fromDate;
  var date=DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    toDate=date.toString().split(" ")[0];
    fromDate=DateTime(date.year,date.month-1,date.day-2).toString().split(" ")[0];
    
    _setData();
  }
  @override
  Widget build(BuildContext context) {

    return Directionality(textDirection: TextDirection.rtl,child: Scaffold(
      body: NestedScrollView(headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
        return [
          SliverAppBar(
            title: new Text('${widget.country['Slug']}'),
            backgroundColor: Colors.indigo,
            pinned: true,
            actions: [
              new Container(
                child: Image.asset("assets/flags/${widget.country['ISO2'].toLowerCase()}.png",width: 60,height: 60,),
              )
            ],
          )
        ];
      }, body: _buildBody()),
    ),);
  }

 Widget _buildBody() {
    if(loading){
      return SpinKitRotatingCircle(
        color: Colors.indigo,
        size: 60.0,
      );
    }
    return new Container(
      child: new Column(
        children: [
        new Expanded(child:   ListView.builder(
          padding: EdgeInsets.zero,
            itemCount: items.length,
            itemBuilder: (BuildContext context,int index){
              var item=items[index];
              if(index==0){
                return new Container();
              }
          return Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: new Material(
              elevation: 3,
              shadowColor: Colors.indigo.withOpacity(0.3),
              child: new ListTile(
                subtitle: new Text('${persianDate.gregorianToJalali(item['Date'],"yyyy-m-d ")}',style: TextStyle(height: 1.8),),
                title: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    new Text('مبتلایان‌جدید: ${items[index]['Confirmed']-items[index-1]['Confirmed']}',style: new TextStyle(fontSize: 13),),
                    new Text('بهبودیافتگان: ${items[index]['Recovered']-items[index-1]['Recovered']}',style: new TextStyle(fontSize: 13),),
                    new Text('جان‌باختگان: ${items[index]['Deaths']-items[index-1]['Deaths']}',style: new TextStyle(fontSize: 13),),
                  ],
                ),
              ),
            ),
          );
        }),)
        ],
      ),
    );
 }

  void _setData() async{
    // https://developers.google.com/books/docs/overview
    var url = "https://api.covid19api.com/country/${widget.country['Slug']}?from=${fromDate}T00:00:00Z&to=${toDate}T00:00:00Z";
    print(url);

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      items.addAll(jsonResponse);
      setState(() {
        loading=false;
      });
    } else {
      
    }
  }
}
