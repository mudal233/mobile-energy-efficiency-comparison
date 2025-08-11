import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(home: GpsBenchmarkApp()));
}

class GpsBenchmarkApp extends StatefulWidget {
  @override
  _GpsBenchmarkAppState createState() => _GpsBenchmarkAppState();
}

class _GpsBenchmarkAppState extends State<GpsBenchmarkApp> {
  TextEditingController countController = TextEditingController();
  String result = "Aktueller Standort erscheint hier...";
  bool isRunning = false;

  int totalRequests = 0;
  int currentCount = 0;
  final int intervalMs = 2000;

  Future<void> requestPermission() async {
    await Permission.location.request();
  }

  Future<void> startLocationTest() async {
    await requestPermission();

    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() {
        result = "Standortdienst ist deaktiviert.";
      });
      return;
    }

    try {
      totalRequests = int.parse(countController.text);
    } catch (_) {
      setState(() {
        result = "Bitte gültige Zahl eingeben.";
      });
      return;
    }

    setState(() {
      isRunning = true;
      currentCount = 0;
    });

    await fetchLocationRecursive();
  }

  Future<void> fetchLocationRecursive() async {
    if (currentCount >= totalRequests) {
      setState(() {
        isRunning = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      String address = "Keine Adresse gefunden";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          address = "${place.street}, ${place.locality}, ${place.country}";
        }
      } catch (e) {
        address = "Adresse konnte nicht geladen werden";
      }

      currentCount++;
      setState(() {
        result = "Abruf $currentCount von $totalRequests\n"
            "Latitude: ${position.latitude}\n"
            "Longitude: ${position.longitude}\n"
            "Adresse: $address";
      });

      await Future.delayed(Duration(milliseconds: intervalMs));
      await fetchLocationRecursive();
    } catch (e) {
      setState(() {
        result = "Fehler beim Abrufen der Position: $e";
        isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("GPS Benchmark",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(height: 24),
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Wie oft Standort abrufen?",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isRunning ? null : startLocationTest,
              child: Text(isRunning ? "Läuft..." : "Start"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3F51B5),
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 120),
              color: Color(0xFFE0E0E0),
              child: Text(
                result,
                style: TextStyle(fontSize: 16, color: Color(0xFF424242)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
