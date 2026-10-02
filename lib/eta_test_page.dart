import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EtaTestPage extends StatefulWidget {
  const EtaTestPage({super.key});

  @override
  State<EtaTestPage> createState() => _EtaTestPageState();
}

class _EtaTestPageState extends State<EtaTestPage> {
  static const baseUrl = 'http://127.0.0.1:8000';
  bool loading = false;
  String message = 'Tap the button to request an ETA.';

  Future<void> getPrediction() async {
    setState(() {
      loading = true;
      message = 'Getting prediction...';
    });
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'distance_to_target_km': 3.5,
          'current_speed_kmh': 28.0,
          'hour': 9,
          'day_of_week': 0,
          'is_weekend': 0,
          'road_type': 'narrow_road',
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final data = jsonDecode(response.body)
          as Map<String, dynamic>;
      final eta = (data['eta_minutes'] as num).toDouble();
      
      if (!mounted) return;
      setState(() {
        message = 'Estimated arrival: '
            '${eta.toStringAsFixed(1)} minutes';
      });
    } catch (e) {
      if (mounted) setState(() => message = 'Error: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Truck ETA test')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : getPrediction,
              child: Text(loading ? 'Loading...' : 'Get ETA'),
            ),
          ],
        ),
      ),
    );
  }
}
