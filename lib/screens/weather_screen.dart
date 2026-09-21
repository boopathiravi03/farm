import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  final String token;

  const WeatherScreen({
    super.key,
    required this.token,
  });

  @override
  State<WeatherScreen> createState() =>
      _WeatherScreenState();
}

class _WeatherScreenState
    extends State<WeatherScreen> {
  static const String apiUrl =
      "https://farm-trading-backend.onrender.com/api";

  final locationController =
      TextEditingController();

  final cropController =
      TextEditingController();

  List<dynamic> locations = [];
  Map<String, dynamic>? selectedLocation;

  Map<String, dynamic>? weather;

  List<dynamic> daily = [];
  List<dynamic> hourly = [];
  List<dynamic> alerts = [];

  Map<String, dynamic>? aiAdvice;

  bool loading = false;
  bool aiLoading = false;

  @override
  void dispose() {
    locationController.dispose();
    cropController.dispose();
    super.dispose();
  }

  // ==================================================
  // LOCATION SEARCH
  // ==================================================

  Future<void> searchLocation(
    String query,
  ) async {
    if (query.trim().length < 2) {
      setState(() {
        locations = [];
      });

      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          "$apiUrl/weather/location-search?q=${Uri.encodeComponent(query)}",
        ),
        headers: {
          "Authorization":
              "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(
          response.body,
        );

        if (mounted) {
          setState(() {
            locations =
                data["locations"] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ==================================================
  // SELECT LOCATION
  // ==================================================

  Future<void> selectLocation(
    Map<String, dynamic> location,
  ) async {
    setState(() {
      selectedLocation = location;

      locationController.text =
          location["name"] ?? "";

      locations = [];
    });

    await loadWeather();
  }

  // ==================================================
  // LOAD WEATHER
  // ==================================================

  Future<void> loadWeather() async {
    if (selectedLocation == null) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final latitude =
          selectedLocation!["latitude"];

      final longitude =
          selectedLocation!["longitude"];

      final name =
          selectedLocation!["name"];

      final response = await http.get(
        Uri.parse(
          "$apiUrl/weather/forecast"
          "?latitude=$latitude"
          "&longitude=$longitude"
          "&location=${Uri.encodeComponent(name)}",
        ),
        headers: {
          "Authorization":
              "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(
          response.body,
        );

        if (mounted) {
          setState(() {
            weather = data["current"];
            daily = data["daily"] ?? [];
            hourly = data["hourly"] ?? [];
          });
        }

        await loadAlerts();
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  // ==================================================
  // ALERTS
  // ==================================================

  Future<void> loadAlerts() async {
    try {
      final response = await http.post(
        Uri.parse(
          "$apiUrl/weather/alerts",
        ),
        headers: {
          "Content-Type":
              "application/json",
          "Authorization":
              "Bearer ${widget.token}",
        },
        body: jsonEncode({
          "daily": daily,
          "hourly": hourly,
          "crop": cropController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(
          response.body,
        );

        if (mounted) {
          setState(() {
            alerts =
                data["alerts"] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ==================================================
  // GROQ ADVICE
  // ==================================================

  Future<void> getAIAdvice() async {
    if (weather == null) {
      return;
    }

    setState(() {
      aiLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "$apiUrl/weather/ai-advice",
        ),
        headers: {
          "Content-Type":
              "application/json",
          "Authorization":
              "Bearer ${widget.token}",
        },
        body: jsonEncode({
          "crop":
              cropController.text,

          "location":
              selectedLocation?["name"],

          "weather":
              weather,

          "forecast":
              daily,

          "soilType":
              "Not provided",

          "growthStage":
              "Not provided",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(
          response.body,
        );

        if (mounted) {
          setState(() {
            aiAdvice =
                data["advice"];
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() {
        aiLoading = false;
      });
    }
  }

  // ==================================================
  // WEATHER ICON
  // ==================================================

  IconData weatherIcon(
    dynamic code,
  ) {
    final value =
        int.tryParse(
              code.toString(),
            ) ??
            0;

    if (value == 0) {
      return Icons.wb_sunny;
    }

    if (value >= 1 && value <= 3) {
      return Icons.cloud;
    }

    if (value >= 51 &&
        value <= 67) {
      return Icons.grain;
    }

    if (value >= 80 &&
        value <= 82) {
      return Icons.water_drop;
    }

    if (value >= 95) {
      return Icons.thunderstorm;
    }

    return Icons.cloud;
  }

  Color riskColor(
    String? risk,
  ) {
    switch (risk) {
      case "High":
        return Colors.red;

      case "Medium":
        return Colors.orange;

      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F8F3),

      appBar: AppBar(
        title:
            const Text("Farm Weather"),
        backgroundColor:
            const Color(0xFF167D39),
        foregroundColor:
            Colors.white,
      ),

      body: RefreshIndicator(
        onRefresh: loadWeather,

        child: ListView(
          padding:
              const EdgeInsets.all(16),

          children: [
            // ======================================
            // LOCATION
            // ======================================

            const Text(
              "📍 Farm Location",
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller:
                  locationController,

              onChanged:
                  searchLocation,

              decoration:
                  InputDecoration(
                hintText:
                    "Search village / city",
                prefixIcon:
                    const Icon(
                  Icons.location_on,
                ),
                filled: true,
                fillColor:
                    Colors.white,
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            if (locations.isNotEmpty)
              Container(
                margin:
                    const EdgeInsets.only(
                  top: 5,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),

                child: Column(
                  children:
                      locations.map(
                    (location) {
                      return ListTile(
                        leading:
                            const Icon(
                          Icons.location_on,
                          color:
                              Color(
                            0xFF167D39,
                          ),
                        ),

                        title: Text(
                          location[
                                  "name"] ??
                              "",
                        ),

                        subtitle: Text(
                          "${location["district"] ?? ""}, ${location["state"] ?? ""}",
                        ),

                        onTap: () =>
                            selectLocation(
                          Map<String,
                              dynamic>.from(
                            location,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),

            const SizedBox(height: 20),

            // ======================================
            // CROP
            // ======================================

            const Text(
              "🌱 Your Crop",
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller:
                  cropController,

              onChanged: (_) {
                if (weather != null) {
                  loadAlerts();
                }
              },

              decoration:
                  InputDecoration(
                hintText:
                    "Example: Tomato",
                prefixIcon:
                    const Icon(
                  Icons.eco,
                ),
                filled: true,
                fillColor:
                    Colors.white,
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ======================================
            // CURRENT WEATHER
            // ======================================

            if (loading)
              const Center(
                child:
                    CircularProgressIndicator(),
              ),

            if (weather != null)
              Container(
                padding:
                    const EdgeInsets.all(
                  22,
                ),

                decoration:
                    BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xFF167D39),
                      Color(0xFF4CAF50),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),
                ),

                child: Column(
                  children: [
                    Icon(
                      weatherIcon(
                        weather![
                            "weatherCode"],
                      ),
                      size: 65,
                      color:
                          Colors.white,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      "${weather!["temperature"] ?? "--"}°C",
                      style:
                          const TextStyle(
                        fontSize: 42,
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    Text(
                      weather![
                              "condition"] ??
                          "",
                      style:
                          const TextStyle(
                        fontSize: 17,
                        color:
                            Colors.white,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceAround,
                      children: [
                        weatherInfo(
                          Icons.water_drop,
                          "${weather!["humidity"] ?? "--"}%",
                          "Humidity",
                        ),

                        weatherInfo(
                          Icons.air,
                          "${weather!["windSpeed"] ?? "--"} km/h",
                          "Wind",
                        ),

                        weatherInfo(
                          Icons.umbrella,
                          "${weather!["precipitation"] ?? "--"} mm",
                          "Rain",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 25),

            // ======================================
            // ALERTS
            // ======================================

            if (alerts.isNotEmpty) ...[
              const Text(
                "🚨 Farm Alerts",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ...alerts.map(
                (alert) => Container(
                  margin:
                      const EdgeInsets.only(
                    bottom: 10,
                  ),

                  padding:
                      const EdgeInsets.all(
                    15,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),

                    border:
                        Border.all(
                      color:
                          alert["severity"] ==
                                  "high"
                              ? Colors.red
                              : Colors.orange,
                    ),
                  ),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      Icon(
                        alert["severity"] ==
                                "high"
                            ? Icons.warning
                            : Icons.info,
                        color:
                            alert["severity"] ==
                                    "high"
                                ? Colors.red
                                : Colors.orange,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            Text(
                              alert["title"] ??
                                  "",
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              alert["message"] ??
                                  "",
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              "Action: ${alert["action"] ?? ""}",
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ======================================
            // 7 DAY FORECAST
            // ======================================

            if (daily.isNotEmpty) ...[
              const SizedBox(height: 10),

              const Text(
                "📅 7-Day Forecast",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 180,

                child: ListView.builder(
                  scrollDirection:
                      Axis.horizontal,

                  itemCount:
                      daily.length,

                  itemBuilder:
                      (context, index) {
                    final day =
                        daily[index];

                    return Container(
                      width: 145,

                      margin:
                          const EdgeInsets
                              .only(
                        right: 12,
                      ),

                      padding:
                          const EdgeInsets
                              .all(14),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                      ),

                      child: Column(
                        children: [
                          Text(
                            day["date"]
                                    ?.toString()
                                    .substring(
                                      5,
                                    ) ??
                                "",
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          Icon(
                            weatherIcon(
                              day[
                                  "weatherCode"],
                            ),

                            size: 35,

                            color:
                                const Color(
                              0xFF167D39,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            "${day["maxTemperature"]}° / ${day["minTemperature"]}°",
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            "🌧 ${day["rainProbability"] ?? 0}%",

                            style:
                                const TextStyle(
                              color:
                                  Colors.blue,
                            ),
                          ),

                          Text(
                            "${day["rainfall"] ?? 0} mm",
                            style:
                                const TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 25),

            // ======================================
            // AI BUTTON
            // ======================================

            SizedBox(
              height: 58,

              child:
                  ElevatedButton.icon(
                onPressed:
                    aiLoading
                        ? null
                        : getAIAdvice,

                icon: aiLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          color:
                              Colors.white,
                          strokeWidth:
                              2,
                        ),
                      )
                    : const Icon(
                        Icons.auto_awesome,
                      ),

                label: Text(
                  aiLoading
                      ? "AI Analysing..."
                      : "Get AI Farm Advice",
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF167D39,
                  ),

                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ======================================
            // AI RESULT
            // ======================================

            if (aiAdvice != null)
              Container(
                padding:
                    const EdgeInsets.all(
                  18,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),

                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      color:
                          Colors.black12,
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons
                              .auto_awesome,
                          color:
                              Color(
                            0xFF167D39,
                          ),
                        ),

                        SizedBox(width: 8),

                        Text(
                          "Farm Trading AI",
                          style:
                              TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .all(12),

                      decoration:
                          BoxDecoration(
                        color:
                            riskColor(
                          aiAdvice![
                              "overallRisk"],
                        ).withValues(
                          alpha: 0.1,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),

                      child: Text(
                        "Overall Risk: ${aiAdvice!["overallRisk"] ?? "Low"}",
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          color:
                              riskColor(
                            aiAdvice![
                                "overallRisk"],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Text(
                      aiAdvice![
                              "summary"] ??
                          "",
                      style:
                          const TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    adviceCard(
                      "💧 Irrigation",
                      aiAdvice![
                          "irrigation"],
                    ),

                    adviceCard(
                      "🧴 Spraying",
                      aiAdvice![
                          "spraying"],
                    ),

                    adviceCard(
                      "🌱 Fertilizer",
                      aiAdvice![
                          "fertilizer"],
                    ),

                    adviceCard(
                      "🌾 Harvest",
                      aiAdvice![
                          "harvest"],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      "Priority Actions",
                      style:
                          TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    ...((aiAdvice![
                                    "actions"] ??
                                [])
                            as List)
                        .map(
                      (action) => Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 7,
                        ),

                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            const Text(
                              "✓ ",
                              style:
                                  TextStyle(
                                color:
                                    Color(
                                  0xFF167D39,
                                ),
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            Expanded(
                              child:
                                  Text(
                                action
                                    .toString(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      "🛡 ${aiAdvice!["cropProtection"] ?? ""}",
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget weatherInfo(
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          value,
          style:
              const TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        Text(
          label,
          style:
              const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget adviceCard(
    String title,
    dynamic data,
  ) {
    if (data is! Map) {
      return const SizedBox();
    }

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
          const EdgeInsets.all(12),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFFF4F8F3),

        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [
          Text(
            title,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            "${data["status"] ?? ""}",
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(0xFF167D39),
            ),
          ),

          Text(
            data["reason"] ??
                "",
          ),
        ],
      ),
    );
  }
}

