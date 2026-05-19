import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/client_api_service.dart';
import '../utils/error_handler.dart';

class BookingScreen extends StatefulWidget {
  final String? initialPcName;

  const BookingScreen({super.key, this.initialPcName});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? _selectedPc;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _duration = 1;
  List<String> _pcs = [];
  bool _isLoadingPcs = true;

  @override
  void initState() {
    super.initState();
    _loadPcs();
  }

  Future<void> _loadPcs() async {
    try {
      final apiService = Provider.of<ClientApiService>(context, listen: false);
      final pcs = await apiService.getAvailablePCs();
      final matchedInitialPc = _matchPcName(widget.initialPcName, pcs);

      setState(() {
        _pcs = pcs;
        _isLoadingPcs = false;

        if (matchedInitialPc != null) {
          _selectedPc = matchedInitialPc;
        } else if (_pcs.isNotEmpty) {
          _selectedPc = _pcs.first;
        }
      });
    } catch (e) {
      setState(() => _isLoadingPcs = false);
      if (mounted) {
        ErrorHandler.show(
          context,
          e,
          customMessage: 'Не удалось загрузить список компьютеров',
        );
      }
    }
  }

  String? _matchPcName(String? requestedPcName, List<String> pcs) {
    if (requestedPcName == null || pcs.isEmpty) {
      return null;
    }

    if (pcs.contains(requestedPcName)) {
      return requestedPcName;
    }

    final requestedDigits = RegExp(r'\d+')
        .allMatches(requestedPcName)
        .map((m) => m.group(0))
        .whereType<String>()
        .map((value) => value.padLeft(2, '0'))
        .toSet();

    if (requestedDigits.isEmpty) {
      return null;
    }

    for (final pc in pcs) {
      final pcDigits = RegExp(r'\d+')
          .allMatches(pc)
          .map((m) => m.group(0))
          .whereType<String>()
          .map((value) => value.padLeft(2, '0'))
          .toSet();

      if (pcDigits.any(requestedDigits.contains)) {
        return pc;
      }
    }

    return null;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _confirmBooking() async {
    if (_selectedPc == null) {
      return;
    }

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final apiService = Provider.of<ClientApiService>(context, listen: false);
      final success = await apiService.createBooking(
        _selectedPc!,
        startDateTime,
        _duration,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (success) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Успешно!'),
            content: Text(
              'Вы забронировали $_selectedPc на ${DateFormat('dd.MM HH:mm').format(startDateTime)}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ErrorHandler.show(
          context,
          'Ошибка при бронировании. Попробуйте другое время.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ErrorHandler.show(context, e, customMessage: 'Ошибка при бронировании');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Бронирование')),
      body: _isLoadingPcs
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Выберите компьютер:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_pcs.isEmpty)
                    const Text(
                      'Нет свободных компьютеров',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedPc,
                          items: _pcs
                              .map(
                                (pc) => DropdownMenuItem<String>(
                                  value: pc,
                                  child: Text(pc),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => _selectedPc = value),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Дата и время:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                          ),
                          title: const Text('Дата'),
                          subtitle: Text(
                            DateFormat('dd MMMM yyyy', 'ru').format(_selectedDate),
                          ),
                          onTap: _selectDate,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.access_time,
                            color: Colors.blue,
                          ),
                          title: const Text('Время начала'),
                          subtitle: Text(_formatTime(_selectedTime)),
                          onTap: _selectTime,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Длительность:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$_duration ч.',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _duration.toDouble(),
                    min: 1,
                    max: 12,
                    divisions: 11,
                    label: '$_duration ч.',
                    onChanged: (value) => setState(() => _duration = value.toInt()),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _pcs.isEmpty ? null : _confirmBooking,
                      child: const Text(
                        'Подтвердить бронирование',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
