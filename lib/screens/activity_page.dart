import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  LatLng? _currentPosition;
  late final MapController _mapController;
  StreamSubscription<Position>? _positionSubscription;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _startLocationUpdates();
  }

  void _startLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // Get initial position
    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return; // <-- Add this line
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    // Listen to position updates and store the subscription
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position pos) {
      if (!mounted) return; // <-- Add this line for extra safety
      final newLatLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _currentPosition = newLatLng;
      });
      if (_mapReady) {
        _mapController.move(newLatLng, _mapController.camera.zoom);
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel(); // <-- This prevents setState after dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _ActivityStat(label: 'Steps', value: '8,542'),
              _ActivityStat(label: 'Distance', value: '6.2 km'),
              _ActivityStat(label: 'Calories', value: '420'),
              _ActivityStat(label: 'Active', value: '1h 12m'),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Today\'s Route', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: _currentPosition,
                      zoom: 16,
                      onMapReady: () {
                        setState(() {
                          _mapReady = true;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.fitbud',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40,
                            height: 40,
                            point: _currentPosition!,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ActivityStat extends StatelessWidget {
  final String label;
  final String value;
  const _ActivityStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }
}