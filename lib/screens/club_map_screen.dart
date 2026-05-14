import 'package:flutter/material.dart';
import 'booking_screen.dart';

class ClubMapScreen extends StatefulWidget {
  const ClubMapScreen({super.key});

  @override
  State<ClubMapScreen> createState() => _ClubMapScreenState();
}

class _ClubMapScreenState extends State<ClubMapScreen> {
  // Имитация данных о компьютерах на карте
  final List<Map<String, dynamic>> _pcLocations = [
    // VIP Zone
    {'id': 'PC #01 (VIP)', 'x': 50, 'y': 50, 'status': 'available', 'type': 'vip'},
    {'id': 'PC #02 (VIP)', 'x': 120, 'y': 50, 'status': 'occupied', 'type': 'vip'},
    {'id': 'PC #03 (VIP)', 'x': 190, 'y': 50, 'status': 'available', 'type': 'vip'},
    
    // Standard Zone
    {'id': 'PC #05 (Standard)', 'x': 50, 'y': 150, 'status': 'available', 'type': 'std'},
    {'id': 'PC #06 (Standard)', 'x': 100, 'y': 150, 'status': 'available', 'type': 'std'},
    {'id': 'PC #07 (Standard)', 'x': 150, 'y': 150, 'status': 'occupied', 'type': 'std'},
    {'id': 'PC #08 (Standard)', 'x': 200, 'y': 150, 'status': 'available', 'type': 'std'},
    
    {'id': 'PC #10 (Standard)', 'x': 50, 'y': 220, 'status': 'available', 'type': 'std'},
    {'id': 'PC #11 (Standard)', 'x': 100, 'y': 220, 'status': 'occupied', 'type': 'std'},
    {'id': 'PC #12 (Standard)', 'x': 150, 'y': 220, 'status': 'available', 'type': 'std'},
    {'id': 'PC #13 (Standard)', 'x': 200, 'y': 220, 'status': 'available', 'type': 'std'},
  ];

  String? _selectedPcId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта зала'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(Colors.green, 'Свободно'),
                _buildLegendItem(Colors.red, 'Занято'),
                _buildLegendItem(Colors.blue, 'Выбрано'),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Container(
                    width: 300,
                    height: 400,
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey.shade900 
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
                    ),
                    child: Stack(
                      children: [
                        // Стены / Зоны
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Text('VIP ZONE', 
                            style: TextStyle(color: Colors.blue.withOpacity(0.5), fontWeight: FontWeight.bold)),
                        ),
                        Positioned(
                          top: 110,
                          left: 10,
                          child: Text('STANDARD ZONE', 
                            style: TextStyle(color: Colors.grey.withOpacity(0.5), fontWeight: FontWeight.bold)),
                        ),
                        
                        // Отрисовка компьютеров
                        ..._pcLocations.map((pc) => _buildPcNode(pc)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_selectedPcId != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Выбран: $_selectedPcId', 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(initialPcName: _selectedPcId),
                          ),
                        );
                      },
                      child: const Text('ПЕРЕЙТИ К БРОНИРОВАНИЮ'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildPcNode(Map<String, dynamic> pc) {
    bool isOccupied = pc['status'] == 'occupied';
    bool isSelected = _selectedPcId == pc['id'];
    
    Color color = isOccupied ? Colors.red : (isSelected ? Colors.blue : Colors.green);

    return Positioned(
      left: pc['x'].toDouble(),
      top: pc['y'].toDouble(),
      child: GestureDetector(
        onTap: isOccupied ? null : () {
          setState(() {
            _selectedPcId = pc['id'];
          });
        },
        child: Column(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                border: Border.all(color: color, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 8)] : null,
              ),
              child: Icon(
                pc['type'] == 'vip' ? Icons.star : Icons.computer,
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              pc['id'].toString().split(' ')[1], // Просто номер
              style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
