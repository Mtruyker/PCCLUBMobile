import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/client_api_service.dart';
import '../utils/error_handler.dart';
import 'booking_screen.dart';

class ClubMapScreen extends StatefulWidget {
  const ClubMapScreen({super.key});

  @override
  State<ClubMapScreen> createState() => _ClubMapScreenState();
}

class _ClubMapScreenState extends State<ClubMapScreen> {
  static const List<_PcLayoutSlot> _layoutSlots = [
    _PcLayoutSlot(number: '01', x: 50, y: 50, zone: _PcZone.vip),
    _PcLayoutSlot(number: '02', x: 120, y: 50, zone: _PcZone.vip),
    _PcLayoutSlot(number: '03', x: 190, y: 50, zone: _PcZone.vip),
    _PcLayoutSlot(number: '05', x: 50, y: 150, zone: _PcZone.standard),
    _PcLayoutSlot(number: '06', x: 100, y: 150, zone: _PcZone.standard),
    _PcLayoutSlot(number: '07', x: 150, y: 150, zone: _PcZone.standard),
    _PcLayoutSlot(number: '08', x: 200, y: 150, zone: _PcZone.standard),
    _PcLayoutSlot(number: '10', x: 50, y: 220, zone: _PcZone.standard),
    _PcLayoutSlot(number: '11', x: 100, y: 220, zone: _PcZone.standard),
    _PcLayoutSlot(number: '12', x: 150, y: 220, zone: _PcZone.standard),
    _PcLayoutSlot(number: '13', x: 200, y: 220, zone: _PcZone.standard),
  ];

  bool _isLoading = true;
  String? _loadError;
  String? _selectedPcName;
  List<_RenderedPcNode> _pcNodes = const [];

  @override
  void initState() {
    super.initState();
    _loadMap();
  }

  Future<void> _loadMap() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final apiService = Provider.of<ClientApiService>(context, listen: false);
      final availablePcs = await apiService.getAvailablePCs();
      final nodes = _buildNodes(availablePcs);

      if (!mounted) return;
      setState(() {
        _pcNodes = nodes;
        _isLoading = false;
        if (_selectedPcName != null &&
            !_pcNodes.any((node) => node.pcName == _selectedPcName && node.isAvailable)) {
          _selectedPcName = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Не удалось загрузить актуальную карту зала';
      });
      ErrorHandler.show(context, e, customMessage: _loadError);
    }
  }

  List<_RenderedPcNode> _buildNodes(List<String> availablePcs) {
    final remaining = List<String>.from(availablePcs);

    return _layoutSlots.map((slot) {
      final matchIndex = remaining.indexWhere((pcName) => _matchesSlot(pcName, slot));
      final matchedPcName = matchIndex >= 0 ? remaining.removeAt(matchIndex) : null;

      return _RenderedPcNode(
        slot: slot,
        pcName: matchedPcName ?? slot.fallbackName,
        isAvailable: matchedPcName != null,
      );
    }).toList();
  }

  bool _matchesSlot(String pcName, _PcLayoutSlot slot) {
    final normalized = pcName.toLowerCase();
    final digits = RegExp(r'\d+').allMatches(pcName).map((m) => m.group(0)).whereType<String>().toList();
    final numberMatched = digits.any((value) => value.padLeft(2, '0') == slot.number);
    if (!numberMatched) {
      return false;
    }

    final mentionsVip = normalized.contains('vip');
    final mentionsStandard = normalized.contains('standard') || normalized.contains('std');

    if (slot.zone == _PcZone.vip) {
      return !mentionsStandard;
    }

    return !mentionsVip || mentionsStandard;
  }

  void _selectPc(_RenderedPcNode pc) {
    if (!pc.isAvailable) return;

    setState(() {
      _selectedPcName = pc.pcName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта зала'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _LegendItem(color: Colors.green, label: 'Свободно'),
                _LegendItem(color: Colors.red, label: 'Занято'),
                _LegendItem(color: Colors.blue, label: 'Выбрано'),
              ],
            ),
          ),
          Expanded(child: _buildBody(context)),
          if (_selectedPcName != null) _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMap,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
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
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 10,
                  child: Text(
                    'VIP ZONE',
                    style: TextStyle(
                      color: Colors.blue.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: 110,
                  left: 10,
                  child: Text(
                    'STANDARD ZONE',
                    style: TextStyle(
                      color: Colors.grey.withValues(alpha: 0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ..._pcNodes.map(_buildPcNode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Выбрано: $_selectedPcName',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
                    builder: (context) => BookingScreen(initialPcName: _selectedPcName),
                  ),
                );
              },
              child: const Text('Перейти к бронированию'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPcNode(_RenderedPcNode pc) {
    final isSelected = _selectedPcName == pc.pcName;
    final color = pc.isAvailable ? (isSelected ? Colors.blue : Colors.green) : Colors.red;

    return Positioned(
      left: pc.slot.x,
      top: pc.slot.y,
      child: GestureDetector(
        onTap: pc.isAvailable ? () => _selectPc(pc) : null,
        child: Column(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                border: Border.all(color: color, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.35),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                pc.slot.zone == _PcZone.vip ? Icons.star : Icons.computer,
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '#${pc.slot.number}',
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PcZone { vip, standard }

class _PcLayoutSlot {
  final String number;
  final double x;
  final double y;
  final _PcZone zone;

  const _PcLayoutSlot({
    required this.number,
    required this.x,
    required this.y,
    required this.zone,
  });

  String get fallbackName => 'PC #$number (${zone == _PcZone.vip ? 'VIP' : 'Standard'})';
}

class _RenderedPcNode {
  final _PcLayoutSlot slot;
  final String pcName;
  final bool isAvailable;

  const _RenderedPcNode({
    required this.slot,
    required this.pcName,
    required this.isAvailable,
  });
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
