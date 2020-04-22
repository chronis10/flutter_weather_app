// Based on https://flutter.dev/docs/cookbook/networking/fetch-data example
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:fluttericon/meteocons_icons.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;


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
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Weather App'),
        ),
        body: FutureBuilder<List<Weather>>(            
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
    return Card(
      // Card weathercard(data){
      // return Card (
      child: Container(
        padding: const EdgeInsets.all(25),  
        //decoration: BoxDecoration(
        color: Colors.blue.shade300,
        //borderRadius: BorderRadius.circular(10)),        
        child:Row (
       // mainAxisSize: MainAxisSize.min,
       //crossAxisAlignment: CrossAxisAlignment.end,
      //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,        
        children: [
          Column(
           // mainAxisSize: MainAxisSize.min,
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:[
              Text( "${data.town}, ${data.country}" , style: TextStyle(color: Colors.white, fontSize: 20)),
              _getweathericon(data.wmain),
              Text("${data.wmain}" , style: TextStyle(color: Colors.white, fontSize: 25) )
            ],  
          ),
          Column(            
          // mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
            children:[           
              Row(
                children:[
                  Icon(Meteocons.temperature, color: Colors.red, size: 30),
                  Text( " ${data.temp} °C" , style: TextStyle(color: Colors.white, fontSize: 15)),
                ]
              ),
              Row(
                children:[
                  Icon(Icons.accessibility_new, color: Colors.orange.shade100, size: 30),
                  Text( " ${data.feel} °C" , style: TextStyle(color: Colors.white, fontSize: 15)),
                ]
              ),
              //Text( "  ${data.wdesctiption}" , style: TextStyle(color: Colors.white, fontSize: 20)),         
            ],
          ),
          Column(          
         // mainAxisSize: MainAxisSize.min,
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //  crossAxisAlignment: CrossAxisAlignment.start,
          children:[
             Row(
              children:[
                Icon(LineariconsFree.drop, color: Colors.blue, size: 30),
                Text( " ${data.humidity} %" , style: TextStyle(color: Colors.white, fontSize: 15)),
              ],
            ),
            Row(             
              children:[
                Icon(Meteocons.wind, color: Colors.white , size: 30),
                Text(" ${data.wind}" , style: TextStyle(color: Colors.white, fontSize: 15))
              ]
            )
          ],
        ),
        ],        
      ) ,
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