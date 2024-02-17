import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    getForecastWeather();
  }

  Future<Map<String, dynamic>> getForecastWeather() async {
    try {
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=Bangkok,th&APPID=9066a1eb3b2c9dcc1da6a16cb9f147b5'));
      final json = jsonDecode(res.body);

      if (json['cod'] != '200') {
        throw 'an unexpected error occur';
      }
      return json;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'weather app',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.refresh))
          ],
        ),
        body: FutureBuilder(
            future: getForecastWeather(),
            builder: (context, snapshort) {
              if (snapshort.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshort.hasError) {
                final err = snapshort.error;
                return Center(
                  child: Text(err.toString()),
                );
              }

              final data = snapshort.data!;

              final currentData = data['list'][0]['main']['temp'];
              final skyStatus = data['list'][0]['weather'][0]['main'];
              final currentPresure = data['list'][0]['main']['pressure'];
              final windSpeed = data['list'][0]['wind']['speed'];
              final humidity = data['list'][0]['main']['humidity'];
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10,
                              sigmaY: 10,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    '$currentData K',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Icon(
                                    skyStatus == 'Clouds' || skyStatus == 'Rain'
                                        ? Icons.cloud
                                        : Icons.sunny,
                                    size: 64,
                                  ),
                                  Text(
                                    skyStatus,
                                    style: const TextStyle(fontSize: 20),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'hourly forecast',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            final time = DateTime.parse(
                                data['list'][index + 1]['dt_txt']);
                            final timeFormat = DateFormat('j').format(time);
                            return HourlyForecastItem(
                              time: timeFormat,
                              icon: data['list'][index + 1]['weather'][0]
                                              ['main'] ==
                                          'Clouds' ||
                                      data['list'][0]['weather'][0]['main'] ==
                                          'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                              value:
                                  '${data['list'][index + 1]['main']['temp']} K',
                            );
                          }),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'additional information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInfoItem(
                          icon: Icons.water_drop,
                          label: 'humidity',
                          value: humidity.toString(),
                        ),
                        AdditionalInfoItem(
                          icon: Icons.air,
                          label: 'wind speed',
                          value: windSpeed.toString(),
                        ),
                        AdditionalInfoItem(
                          icon: Icons.umbrella,
                          label: 'pressure',
                          value: currentPresure.toString(),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }));
  }
}
