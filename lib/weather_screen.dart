import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
          'https://api.openweathermap.org/data/2.5/forecast?q=London,uk&APPID=9066a1eb3b2c9dcc1da6a16cb9f147b5'));
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

              final currentData = snapshort.data!['list'][0]['main']['temp'];
              final skyStatus =
                  snapshort.data!['list'][0]['weather'][0]['main'];
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
                      'weather forecast',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          HourlyForecastItem(
                            time: '10.00',
                            icon: Icons.cloud,
                            value: '24.55 cel',
                          ),
                          HourlyForecastItem(
                            time: '10.00',
                            icon: Icons.cloud,
                            value: '24.55 cel',
                          ),
                          HourlyForecastItem(
                            time: '10.00',
                            icon: Icons.cloud,
                            value: '24.55 cel',
                          ),
                          HourlyForecastItem(
                            time: '10.00',
                            icon: Icons.cloud,
                            value: '24.55 cel',
                          ),
                        ],
                      ),
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInfoItem(
                          icon: Icons.water_drop,
                          label: 'humidity',
                          value: '91',
                        ),
                        AdditionalInfoItem(
                          icon: Icons.air,
                          label: 'wind speed',
                          value: '7.76',
                        ),
                        AdditionalInfoItem(
                          icon: Icons.umbrella,
                          label: 'pressure',
                          value: '1006',
                        ),
                      ],
                    )
                  ],
                ),
              );
            }));
  }
}
