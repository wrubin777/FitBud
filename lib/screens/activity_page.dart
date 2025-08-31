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

  List<LatLng> _routePoints = [];
  double _distanceMeters = 0.0;
  bool _isTracking = false;

  Duration _activeTime = Duration.zero;
  DateTime? _runStartTime;

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

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    final startLatLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentPosition = startLatLng;
      _routePoints = [startLatLng];
      _distanceMeters = 0.0;
      _isTracking = true;
      _runStartTime = DateTime.now();
    });

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position pos) {
      if (!mounted) return;
      final newLatLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _currentPosition = newLatLng;
        if (_isTracking) {
          if (_routePoints.isNotEmpty) {
            final last = _routePoints.last;
            final distance = Geolocator.distanceBetween(
              last.latitude, last.longitude,
              newLatLng.latitude, newLatLng.longitude,
            );
            _distanceMeters += distance;
          }
          _routePoints.add(newLatLng);
          _activeTime = DateTime.now().difference(_runStartTime!);
        }
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

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) {
      return '${twoDigits(h)}h ${twoDigits(m)}m';
    } else {
      return '${twoDigits(m)}m ${twoDigits(s)}s';
    }
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
            children: [
              _ActivityStat(label: 'Steps', value: '8,542'), // Placeholder for now
              _ActivityStat(
                label: 'Distance',
                value: '${(_distanceMeters / 1000).toStringAsFixed(2)} km',
              ),
              _ActivityStat(label: 'Calories', value: '420'), // Placeholder for now
              _ActivityStat(
                label: 'Active',
                value: _formatDuration(_activeTime),
              ),
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
                            width: 10,
                            height: 10,
                            point: _currentPosition!,
                            child: const _PulsatingBlueDot(),
                          ),
                        ],
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            color: Colors.blue,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (_isTracking) {
                      // Stop run
                      _isTracking = false;
                      if (_runStartTime != null) {
                        _activeTime += DateTime.now().difference(_runStartTime!);
                        _runStartTime = null;
                      }
                    } else {
                      // Start run
                      _routePoints = _currentPosition != null ? [_currentPosition!] : [];
                      _distanceMeters = 0.0;
                      _isTracking = true;
                      _runStartTime = DateTime.now();
                      _activeTime = Duration.zero;
                    }
                  });
                },
                child: Text(_isTracking ? 'Stop Run' : 'Start Run'),
              ),
              const SizedBox(width: 16),
              if (!_isTracking && _routePoints.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _routePoints.clear();
                      _distanceMeters = 0.0;
                      _activeTime = Duration.zero;
                      _runStartTime = null;
                    });
                  },
                  child: const Text('Reset'),
                ),
            ],
          ),
          const SizedBox(height: 16),
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

class _PulsatingBlueDot extends StatefulWidget {
  const _PulsatingBlueDot({Key? key}) : super(key: key);

  @override
  State<_PulsatingBlueDot> createState() => _PulsatingBlueDotState();
}

class _PulsatingBlueDotState extends State<_PulsatingBlueDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (_controller.value * 1.2);
        final opacity = 1.0 - (_controller.value * 0.7);
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 32 * scale,
                height: 32 * scale,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(opacity * 0.4),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent,
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}