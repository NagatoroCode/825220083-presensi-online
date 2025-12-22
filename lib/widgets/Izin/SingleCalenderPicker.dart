import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Singlecalenderpicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final Function(DateTime) onDateChanged;
  final bool singleDateMode;
  final bool Function(DateTime)? selectableDayPredicate;

  const Singlecalenderpicker({
    super.key,
    this.initialStartDate,
    required this.onDateChanged,
    this.singleDateMode = false,
    this.selectableDayPredicate,
  });

  @override
  State<Singlecalenderpicker> createState() => _SinglecalenderpickerState();
}

class _SinglecalenderpickerState extends State<Singlecalenderpicker> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialStartDate ?? DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      selectableDayPredicate: widget.selectableDayPredicate,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMMM yyyy').format(_selectedDate);
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
