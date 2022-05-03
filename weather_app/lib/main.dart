import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_icons/weather_icons.dart';
import 'weather.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/constants.dart';
import 'package:weather_app/weather.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Weather parseWeather(String cevap) {
    return Weather.fromJson(json.decode(cevap));
  }

  String city = "London";
  Future<Weather> weatherShow() async {
    var url = Uri.parse("https://weatherdbi.herokuapp.com/data/weather/$city");

    var cvp = await http.get(url);

    return parseWeather(cvp.body);
  }

  late Future<Weather> future;
  @override
  void initState() {
    future = weatherShow();

    super.initState();
  }

  var searchText = TextEditingController();
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          title: isSearching
              ? Container(
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: TextField(
                    onSubmitted: (value) => setState(() {
                      city = value;
                      future = weatherShow();
                      isSearching = false;
                    }),
                    controller: searchText,
                    style: GoogleFonts.rubik(fontSize: 15, color: Colors.white),
                    decoration: InputDecoration(
                      hintStyle:
                          GoogleFonts.rubik(fontSize: 15, color: Colors.white),
                      hintText: 'Search your city',
                      suffixIcon: IconButton(
                          onPressed: () => setState(() {
                                city = searchText.text;
                                future = weatherShow();
                                isSearching = false;
                              }),
                          icon: Icon(
                            Icons.search,
                            color: Colors.white,
                          )),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(20),
                    ),
                  ),
                )
              : Text("Weather Forecast",
                  style: GoogleFonts.rubik(fontSize: 20, color: Colors.white)),
          actions: [
            Visibility(
              visible: isSearching ? false : true,
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                  icon: Icon(Icons.search)),
            )
          ],
        ),
        backgroundColor: primaryColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder<Weather>(
                future: future,
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WeatherPanel(
                          weatherData: snapshot.data!,
                        ),
                        otherDetailPage(weatherData: snapshot.data!),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "Next 7 Days",
                            style: GoogleFonts.rubik(
                                fontSize: 15, color: selectedColor),
                          ),
                        ),
                        nextDaysPanel(
                          weatherData: snapshot.data!,
                        )
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      "ERROR",
                      style: GoogleFonts.rubik(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                          color: selectedColor),
                    ));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherPanel extends StatefulWidget {
  const WeatherPanel({Key? key, required this.weatherData}) : super(key: key);
  final Weather weatherData;
  @override
  State<WeatherPanel> createState() => _WeatherPanelState();
}

class _WeatherPanelState extends State<WeatherPanel> {
  @override
  Widget build(BuildContext context) {
    var display = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        decoration: BoxDecoration(
            color: accentColor, borderRadius: BorderRadius.circular(25)),
        height: display.height / 3,
        width: display.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25.0, right: 25, left: 25),
              child: Row(
                children: [
                  Text("Today",
                      style:
                          GoogleFonts.rubik(color: Colors.white, fontSize: 30)),
                  Spacer(),
                  Text(
                    widget.weatherData.currentConditions.dayhour,
                    style: GoogleFonts.rubik(fontSize: 15, color: Colors.white),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, right: 25, left: 25),
              child: Row(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: widget.weatherData.currentConditions.temp.c
                                .toString(),
                            style: GoogleFonts.rubik(
                                fontSize: 70, color: Colors.white)),
                        TextSpan(
                            text: "°C",
                            style: GoogleFonts.rubik(
                                fontSize: 70, color: selectedColor))
                      ],
                    ),
                  ),
                  Spacer(),
                  Image.network(
                    widget.weatherData.currentConditions.iconUrl,
                    scale: 0.5,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15.0, right: 25, left: 25, bottom: 20),
              child: Row(
                children: [
                  Icon(
                    const IconData(
                      0xf193,
                      fontFamily: 'MaterialIcons',
                    ),
                    color: selectedColor,
                  ),
                  Expanded(
                    child: Text(
                      widget.weatherData.region,
                      overflow: TextOverflow.ellipsis,
                      style:
                          GoogleFonts.rubik(fontSize: 15, color: Colors.white),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class otherDetailPage extends StatefulWidget {
  const otherDetailPage({Key? key, required this.weatherData})
      : super(key: key);
  final Weather weatherData;
  @override
  State<otherDetailPage> createState() => _otherDetailPageState();
}

class _otherDetailPageState extends State<otherDetailPage> {
  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        height: screensize.height / 10,
        width: screensize.width,
        decoration: BoxDecoration(
            color: accentColor, borderRadius: BorderRadius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Icon(
                    WeatherIcons.strong_wind,
                    color: selectedColor,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    widget.weatherData.currentConditions.wind.km.toString() +
                        " Km/h",
                    style: GoogleFonts.rubik(fontSize: 15, color: Colors.white),
                  )
                ],
              ),
              Column(
                children: [
                  Icon(
                    WeatherIcons.humidity,
                    color: selectedColor,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    widget.weatherData.currentConditions.humidity,
                    style: GoogleFonts.rubik(fontSize: 15, color: Colors.white),
                  )
                ],
              ),
              Column(
                children: [
                  Icon(
                    WeatherIcons.rain,
                    color: selectedColor,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    widget.weatherData.currentConditions.precip,
                    style: GoogleFonts.rubik(fontSize: 15, color: Colors.white),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class nextDaysPanel extends StatefulWidget {
  const nextDaysPanel({Key? key, required this.weatherData}) : super(key: key);
  final Weather weatherData;
  @override
  State<nextDaysPanel> createState() => _nextDaysPanelState();
}

class _nextDaysPanelState extends State<nextDaysPanel> {
  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;
    return Container(
      height: screensize.height / 5,
      width: double.infinity,
      child: ListView.builder(
        itemCount: widget.weatherData.nextDays.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: screensize.width / 3,
              decoration: BoxDecoration(
                  color: accentColor, borderRadius: BorderRadius.circular(25)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                        alignment: Alignment.topRight,
                        child: Image.network(
                            widget.weatherData.nextDays[index].iconUrl)),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, right: 20, left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.weatherData.nextDays[index].day,
                        style: GoogleFonts.rubik(
                            fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: widget
                                    .weatherData.nextDays[index].maxTemp.c
                                    .toString(),
                                style: GoogleFonts.rubik(
                                    fontSize: 30, color: Colors.white)),
                            TextSpan(
                                text: "°C",
                                style: GoogleFonts.rubik(
                                    fontSize: 15, color: selectedColor))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
