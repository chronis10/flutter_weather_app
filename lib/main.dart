// Based on https://flutter.dev/docs/cookbook/networking/fetch-data example
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:fluttericon/meteocons_icons.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:gradient_app_bar/gradient_app_bar.dart';

//Load json data
Future<List<Weather>> fetchCities(apikey ,http.Client client) async {
  final response = await http.get("http://api.openweathermap.org/data/2.5/group?id=264371,3169070,2643743,2988506,2950158,3117735,524901,5128581,&APPID="+apikey+"&units=metric");
  if (response.statusCode == 200) {
    return compute(parseCityList, response.body);
  } else {
    throw Exception('Failed to load Data from Open Weather');
  }
}

//Parse data to the list of model Weather
List<Weather> parseCityList(String responseBody) {  
  final parsed = jsonDecode(responseBody)['list'].cast<Map<String, dynamic>>(); 
  return parsed.map<Weather>((json) => Weather.fromJson(json)).toList();
}

class Weather {
  final String wmain;
  final String town;
  final String country;
  final String wdesctiption;
  final double temp;
  final double feel;
  final double humidity;
  final double wind;

  Weather({this.wmain, this.wdesctiption, this.temp,
            this.feel, this.humidity, this.wind,this.town,this.country});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return  Weather(
      wmain: json['weather'][0]['main'],
      wdesctiption: json['weather'][0]['description'],
      temp: json['main']['temp'].toDouble(),
      feel: json['main']['feels_like'].toDouble(),
      humidity: json['main']['humidity'].toDouble(),
      wind: json['wind']['speed'].toDouble(),
      town: json['name'],
      country: json['sys']['country'],
    );
  }
}

void main() => runApp(MyApp());

//Mainscreen of the app
class MyApp extends StatefulWidget {


  MyApp({Key key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}




class _MyAppState extends State<MyApp> { 
  String apikey;
  @override
  void initState() {
    super.initState();
    this.loadjson();
  }

  //Future for apikey load from secrets.json
  Future<String> loadjson() async{ 
   String jsondata = await rootBundle.loadString('secrets.json');
    setState(() {
      apikey = json.decode(jsondata)['api_key'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: 
        GradientAppBar(
          title: Text('Flutter Weather App'),
          backgroundColorStart: Colors.cyan,
          backgroundColorEnd: Colors.indigo,
        ),
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.blue, Colors.purple]
              )
            ),
            
            child: FutureBuilder<List<Weather>>(   
                    
            future: fetchCities(apikey,http.Client(),),
            builder: (context, snapshot) {              
              if (snapshot.hasData) {
                return CityList(cities: snapshot.data);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default, show a loading spinner.
              return Center(child:CircularProgressIndicator());
            },        
        ),
      ),
      ),
    );
  }
}

//Custom Card 
class CityCard extends StatelessWidget{  
  CityCard(this.data);
  final Weather data;
  Icon _getweathericon(condition){
    if(condition == "Clear"){    
      return Icon(Meteocons.sun_inv, color: Colors.yellow  , size: 60);
    }else if (condition == "Clouds"){
      return Icon(Meteocons.cloud_inv, color: Colors.white  , size: 60);
    }else if (condition == "Rain"){
      return Icon(Meteocons.rain_inv, color: Colors.white  , size: 60);
    }else{
      return Icon(Icons.do_not_disturb_on, color: Colors.white  , size: 60);
    }
  }
  @override 
  Widget build(BuildContext context){
    return Container(
      
      //height: 124.0,
      margin: new EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(15),  
      decoration: new BoxDecoration(
          color: new Color(0xFF333366),
          shape: BoxShape.rectangle,
          borderRadius: new BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
              BoxShadow(  
                color: Colors.black54,
                blurRadius: 10.0,
                offset: new Offset(0.0, 10.0),
                ),
            ],
      ),
      child: Row(
        children: [
          
          Expanded(
            
            child:
              Column(
                children:[
                  Text( "${data.town}, ${data.country}" , style: TextStyle(color: Colors.white, fontSize: 20)),
                  SizedBox(height: 5),
                  _getweathericon(data.wmain),
                  SizedBox(height: 5),
                  Text("${data.wmain}" , style: TextStyle(color: Colors.white, fontSize: 20) )
                ], 
              ),
          ),
          Container(
            //color: Colors.black,
            child:
              Expanded(
                 flex: 2,
                  child: Column ( 
                                  children:[ 
                                              Text( "  ${data.wdesctiption[0].toUpperCase()}${data.wdesctiption.substring(1)}" , style: TextStyle(color: Colors.white, fontSize: 20)),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                    Container(
                                                     // color: Colors.yellow,
                                                      child: Column(
                                                        children:[
                                                          Row(
                                                            children:[
                                                              Icon(Meteocons.temperature, color: Colors.red, size: 30),
                                                              Text( " ${data.temp} °C" , style: TextStyle(color: Colors.white, fontSize: 15))
                                                            ]
                                                          ),
                                                          SizedBox(height: 10),
                                                          Row(
                                                            children: [
                                                              Icon(Icons.accessibility_new, color: Colors.orange.shade100, size: 30),
                                                              Text( " ${data.feel} °C" , style: TextStyle(color: Colors.white, fontSize: 15))

                                                            ]

                                                          )
                                                        ]
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Container(
                                                      //color: Colors.red,
                                                      child: Column(
                                                        children:[
                                                          Row(
                                                            children:[
                                                              Icon(LineariconsFree.drop, color: Colors.blue, size: 30),
                                                              Text( " ${data.humidity} %" , style: TextStyle(color: Colors.white, fontSize: 15)),
                                                            ]
                                                          ),
                                                          SizedBox(height: 10),
                                                          Row(
                                                            children: [
                                                              Icon(Meteocons.wind, color: Colors.white , size: 30),
                                                              Text(" ${data.wind}" , style: TextStyle(color: Colors.white, fontSize: 15))

                                                            ]

                                                          )
                                                        ]
                                                      ),
                                                    ),
                                                  ],
                                              ),
                                  ],

                                              ),
              ),
                               
                                              ), 
        ],
              ),
          );
 
         
  }
}

//Create the the custom listview
class CityList extends StatelessWidget {
  final List<Weather> cities;
  CityList({Key key, this.cities}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cities.length,
      itemBuilder: (context, index) {
        return CityCard(cities[index]);
      },
    );
  }
}