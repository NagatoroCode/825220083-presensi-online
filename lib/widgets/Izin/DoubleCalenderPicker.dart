import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;

class tanggalCalenderPicker extends StatefulWidget {
  final Function(DateTime start, DateTime end) onDateChanged;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const tanggalCalenderPicker({
    super.key,
    required this.onDateChanged,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<tanggalCalenderPicker> createState() => _tanggalCalenderPickerState();
}

class _tanggalCalenderPickerState extends State<tanggalCalenderPicker> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();
    // 👉 mulai dari besok
    final tomorrow = DateTime(today.year, today.month, today.day + 1);

    selectedStartDate = widget.initialStartDate ?? tomorrow;
    selectedEndDate = widget.initialEndDate ?? tomorrow;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDateChanged(selectedStartDate!, selectedEndDate!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final nextMonth = DateTime(today.year, today.month + 1, today.day);

    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: dp.RangePicker(
          // periode awal ditampilkan
          selectedPeriod: dp.DatePeriod(selectedStartDate!, selectedEndDate!),

          // 🟢 tidak bisa pilih hari ini, hanya besok dan seterusnya
          firstDate: tomorrow,
          lastDate: nextMonth,

          onChanged: (dp.DatePeriod newPeriod) {
            setState(() {
              selectedStartDate = newPeriod.start;
              selectedEndDate = newPeriod.end;
            });
            widget.onDateChanged(newPeriod.start, newPeriod.end);
          },

          datePickerStyles: dp.DatePickerRangeStyles(
            selectedPeriodLastDecoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            selectedPeriodStartDecoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                bottomLeft: Radius.circular(10.0),
              ),
            ),
            selectedPeriodMiddleDecoration: BoxDecoration(
              color: Colors.blue[200],
              shape: BoxShape.rectangle,
            ),
          ),
        ),
      ),
    );
  }
}
