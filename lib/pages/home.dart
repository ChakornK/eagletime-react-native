import 'dart:convert';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart';

class HomeData {
  String blockRotation;
  Map<String, String> weather;

  HomeData({required this.blockRotation, required this.weather});

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(blockRotation: json["blockRotation"].toString(), weather: json["weather"]);
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

final weatherIcons = {
  // Day icons
  "01d": WeatherIcons.day_sunny,
  "02d": WeatherIcons.day_cloudy,
  "03d": WeatherIcons.cloud,
  "04d": WeatherIcons.cloudy,
  "09d": WeatherIcons.showers,
  "10d": WeatherIcons.rain,
  "11d": WeatherIcons.thunderstorm,
  "13d": WeatherIcons.snow,
  "50d": WeatherIcons.fog,

  // Night icons
  "01n": WeatherIcons.night_clear,
  "02n": WeatherIcons.night_alt_cloudy,
  "03n": WeatherIcons.cloud,
  "04n": WeatherIcons.cloudy,
  "09n": WeatherIcons.showers,
  "10n": WeatherIcons.rain,
  "11n": WeatherIcons.thunderstorm,
  "13n": WeatherIcons.snow,
  "50n": WeatherIcons.fog,

  // others
  "unknown": Icons.question_mark_rounded
};

class _HomePageState extends State<HomePage> {
  late Future<HomeData> futureData;

  Future<HomeData> fetchData() async {
    final blockRotation = await http.get(Uri.parse("https://eagletime.vercel.app/block"));
    final weather = await http.get(Uri.parse("https://eagletime.vercel.app/weather"));

    var b = "N/A";
    if (blockRotation.statusCode == 200 && blockRotation.body.isNotEmpty) {
      var lst = jsonDecode(blockRotation.body) as List;
      b = lst[0]["name"];
    }
    var w = {"condition": "N/A", "icon": "unknown", "temperature": "N/A"};
    if (weather.statusCode == 200 && weather.body.isNotEmpty) {
      var json = jsonDecode(weather.body) as Map<String, dynamic>;
      w["condition"] = json["weather"][0]["main"].toString();
      w["icon"] = json["weather"][0]["icon"].toString();
      w["temperature"] = "${json["main"]["temp"].round().toString()}°C";
    }
    return HomeData.fromJson({"blockRotation": b, "weather": w});
  }

  final browser = ChromeSafariBrowser();

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        print(MediaQuery.sizeOf(context).width);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Flex(
              direction: MediaQuery.sizeOf(context).width > 600 ? Axis.horizontal : Axis.vertical,
              children: [
                Card(
                  shadowColor: Color(0x00FFFFFF),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: MediaQuery.sizeOf(context).width > 600 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      mainAxisAlignment: MediaQuery.sizeOf(context).width > 600 ? MainAxisAlignment.center : MainAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat("EEEE MMMM d, yyyy").format(DateTime.now()),
                          textScaler: TextScaler.linear(1.25),
                        ),
                        FutureBuilder<HomeData>(
                            future: futureData,
                            builder: (context, snapshot) {
                              return Column(
                                children: [
                                  Text(
                                    (snapshot.data?.blockRotation.toString() ?? "N/A"),
                                    textScaler: TextScaler.linear(1.75),
                                  ),
                                ],
                              );
                            }),
                        Divider(
                          height: 24,
                        ),
                        FutureBuilder<HomeData>(
                            future: futureData,
                            builder: (context, snapshot) {
                              if (MediaQuery.sizeOf(context).width > 600) {
                                return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                  Icon(
                                    weatherIcons[snapshot.data?.weather["icon"].toString() ?? "unknown"],
                                  ),
                                  Text(
                                    snapshot.data?.weather["condition"].toString() ?? "N/A",
                                    textScaler: TextScaler.linear(1.35),
                                  ),
                                  Text(
                                    snapshot.data?.weather["temperature"].toString() ?? "N/A",
                                    textScaler: TextScaler.linear(1.35),
                                  ),
                                ]);
                              } else {
                                return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                  Icon(
                                    weatherIcons[snapshot.data?.weather["icon"].toString() ?? "unknown"],
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    snapshot.data?.weather["condition"].toString() ?? "N/A",
                                    textScaler: TextScaler.linear(1.35),
                                  ),
                                  SizedBox(width: 6),
                                  Text("•", textScaler: TextScaler.linear(1.35)),
                                  SizedBox(width: 6),
                                  Text(
                                    snapshot.data?.weather["temperature"].toString() ?? "N/A",
                                    textScaler: TextScaler.linear(1.35),
                                  ),
                                ]);
                              }
                            })
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Expanded(
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shadowColor: Color(0x00FFFFFF),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(Icons.schedule_outlined, size: 24),
                                  SizedBox(width: 16),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Bell Schedule", textScaler: TextScaler.linear(1.25)),
                                        Text("Regular, Late Start Tuesday and Early Dismissal", textScaler: TextScaler.linear(0.9)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 0.5,
                            height: 1,
                          ),
                          InkWell(
                            onTap: () {
                              showImageViewer(
                                context,
                                Image.asset("lib/assets/school_map.png").image,
                                doubleTapZoomable: true,
                                swipeDismissible: true,
                                useSafeArea: true,
                                immersive: false,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(Icons.map_outlined, size: 24),
                                  SizedBox(width: 16),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("School Map", textScaler: TextScaler.linear(1.25)),
                                        Text("Level 1 / Level 2", textScaler: TextScaler.linear(0.9)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          ...[
                            {
                              "index": 0,
                              "title": "Website",
                              "subtitle": "surreyschools.ca/johnht",
                              "link": "https://www.surreyschools.ca/johnht/",
                              "icon": Icons.public_outlined
                            },
                            {
                              "index": 1,
                              "title": "MyEdBC",
                              "subtitle": "Check grades, schedule, and view report cards",
                              "link": "https://myeducation.gov.bc.ca/aspen/logon.do",
                              "icon": Icons.school_outlined
                            },
                            {
                              "index": 2,
                              "title": "School Cash Online",
                              "subtitle": "Pay school fees",
                              "link": "https://www.schoolcashonline.com/",
                              "icon": Icons.payments_outlined
                            },
                            {
                              "index": 3,
                              "title": "Counsellor Appointments",
                              "subtitle": "Book an appointment online",
                              "link": "https://jh.counsellorappointments.com/",
                              "icon": Icons.calendar_month_outlined
                            },
                            {
                              "index": 4,
                              "title": "Locker Assignments",
                              "subtitle": "Register and choose a locker. Student ID# required",
                              "link": "https://jh.lockerassignment.com",
                              "icon": Icons.lock_outline
                            },
                            {"index": 5, "title": "Phone", "subtitle": "(604) 581-5500", "link": "tel:+16045815500", "icon": Icons.phone_outlined},
                            {
                              "index": 6,
                              "title": "Email",
                              "subtitle": "johnstonheights@surreyschools.ca",
                              "link": "mailto:johnstonheights@surreyschools.ca",
                              "icon": Icons.email_outlined
                            },
                            {
                              "index": 7,
                              "title": "Map / Directions",
                              "subtitle": "15350 - 99th Avenue, Surrey, BC V3R 0R9",
                              "link": "https://goo.gl/maps/K8cF7KdCun4r6RV89",
                              "icon": Icons.place_outlined
                            },
                            {
                              "index": 8,
                              "title": "Student Accident Insurance",
                              "subtitle": "How to purchase student accident insurance",
                              "link": "https://eagletime.appazur.com/media/info/eagletime/2021-2022_Student_Accident_-_newsletter_schools_wording_937zRqp.pdf",
                              "icon": Icons.medical_services_outlined
                            },
                            {
                              "index": 9,
                              "title": "Insure My Kids",
                              "subtitle": "",
                              "link": "https://insuremykids.com/",
                              "icon": Icons.medical_services_outlined
                            },
                            {
                              "index": 10,
                              "title": "StudyInsured Student Accident Insurance",
                              "subtitle": "",
                              "link": "https://www.studyinsuredstudentaccident.com/",
                              "icon": Icons.medical_services_outlined
                            },
                          ].map(
                            (e) => (Column(
                              children: [
                                Divider(
                                  thickness: 0.5,
                                  height: 1,
                                ),
                                InkWell(
                                  onTap: () async {
                                    var uri = WebUri(e["link"] as String);

                                    if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(
                                          uri,
                                        );
                                      }
                                    } else {
                                      await browser.open(url: uri);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Icon(e["icon"] as IconData, size: 24),
                                        SizedBox(width: 16),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              (e["title"] != "") ? Text(e["title"] as String, textScaler: TextScaler.linear(1.25)) : Container(),
                                              (e["subtitle"] != "") ? Text(e["subtitle"] as String, textScaler: TextScaler.linear(0.9)) : Container(),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )),
                          )
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
    );
  }
}
