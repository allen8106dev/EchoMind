import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';
import '../widgets/entry_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();

  List<DiaryEntry> getEntriesForDay(DateTime day) {
    final entries = StorageService.getEntries();

    return entries.where((entry) {
      return entry.createdAt.year == day.year &&
          entry.createdAt.month == day.month &&
          entry.createdAt.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final entries = getEntriesForDay(selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Diary Calendar"),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2035),
            focusedDay: selectedDay,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (_, index) {
                return EntryCard(entry: entries[index]);
              },
            ),
          )
        ],
      ),
    );
  }
}