import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Timepicker extends StatefulWidget {
  final String label;
  final TimeOfDay? initialTime;
  final Function(TimeOfDay) onTimeSelected;
  final int minHour;
  final int maxHour;
  final bool readOnly; // jika true, user tidak bisa pilih waktu

  const Timepicker({
    super.key,
    required this.label,
    required this.onTimeSelected,
    required this.minHour,
    required this.maxHour,
    this.initialTime,
    this.readOnly = false,
  });

  @override
  State<Timepicker> createState() => _TimepickerState();
}

class _TimepickerState extends State<Timepicker> {
  TimeOfDay? selectedTime;

  // Generate slot 30 menit sesuai minHour dan maxHour
  List<TimeOfDay> get availableTimes {
    final List<TimeOfDay> times = [];
    for (int h = widget.minHour; h <= widget.maxHour; h++) {
      times.add(TimeOfDay(hour: h, minute: 0));
      if (h != widget.maxHour) times.add(TimeOfDay(hour: h, minute: 30));
    }
    return times;
  }

  String _format24(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  void _showTimePicker(BuildContext context) {
    if (widget.readOnly) return; // tidak boleh buka picker jika readonly
    if (availableTimes.isEmpty) return;

    int initialIndex = 0;
    if (selectedTime != null) {
      initialIndex = availableTimes.indexWhere(
        (t) => t.hour == selectedTime!.hour && t.minute == selectedTime!.minute,
      );
      if (initialIndex == -1) initialIndex = 0;
    }

    int tempIndex = initialIndex;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: initialIndex,
                    ),
                    itemExtent: 40,
                    onSelectedItemChanged: (index) => tempIndex = index,
                    children: availableTimes
                        .map(
                          (t) => Center(
                            child: Text(
                              _format24(t),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedTime = availableTimes[tempIndex];
                    });
                    widget.onTimeSelected(selectedTime!);
                    Navigator.pop(ctx);
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTimePicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(
          selectedTime != null ? _format24(selectedTime!) : "Pilih Waktu",
          style: TextStyle(color: widget.readOnly ? Colors.grey : Colors.black),
        ),
      ),
    );
  }
}
