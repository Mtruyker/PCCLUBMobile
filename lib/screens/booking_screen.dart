import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/client_api_service.dart';
import '../utils/error_handler.dart';

class BookingScreen extends StatefulWidget {
  final String? initialPcName;
  final Future<List<String>> Function()? loadAvailablePcs;
  final Future<bool> Function(String pcName, DateTime startTime, int duration)? submitBooking;

  const BookingScreen({
    super.key,
    this.initialPcName,
    this.loadAvailablePcs,
    this.submitBooking,
  });

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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadPcs();
      }
    });
  }

  ClientApiService _getApiService() {
    return Provider.of<ClientApiService?>(context, listen: false) ?? ClientApiService();
  }

  Future<void> _loadPcs() async {
    setState(() {
      _isLoadingPcs = true;
      _errorMessage = null;
    });

    try {
      final pcs = await (widget.loadAvailablePcs?.call() ?? _getApiService().getAvailablePCs());
      final matchedInitialPc = _matchPcName(widget.initialPcName, pcs);

      if (!mounted) {
        return;
      }

      setState(() {
        _pcs = pcs;
        _isLoadingPcs = false;

        if (matchedInitialPc != null) {
          _selectedPc = matchedInitialPc;
        } else if (_pcs.isNotEmpty) {
          _selectedPc = _pcs.first;
        } else {
          _selectedPc = null;
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingPcs = false;
        _errorMessage = 'Не удалось загрузить список компьютеров';
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ErrorHandler.show(context, e, customMessage: _errorMessage);
        }
      });
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
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final initialDate = _selectedDate.isBefore(firstDate) ? firstDate : _selectedDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 7)),
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

  String _formatBookingDate(DateTime date) {
    try {
      return DateFormat('dd MMMM yyyy', 'ru').format(date);
    } catch (_) {
      return DateFormat('dd.MM.yyyy').format(date);
    }
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

    LoadingOverlay.show(context);

    try {
      final success = await (widget.submitBooking?.call(_selectedPc!, startDateTime, _duration) ??
          _getApiService().createBooking(_selectedPc!, startDateTime, _duration));

      if (!mounted) {
        return;
      }

      LoadingOverlay.hide(context);

      if (success) {
        showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Успешно!'),
            content: Text(
              'Вы забронировали $_selectedPc на ${DateFormat('dd.MM HH:mm').format(startDateTime)}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
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
      if (!mounted) {
        return;
      }

      LoadingOverlay.hide(context);
      ErrorHandler.show(context, e, customMessage: 'Ошибка при бронировании');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Бронирование')),
      body: _isLoadingPcs
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? ErrorStateWidget(
                  message: _errorMessage!,
                  onRetry: _loadPcs,
                )
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
                              subtitle: Text(_formatBookingDate(_selectedDate)),
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
