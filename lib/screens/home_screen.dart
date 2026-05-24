import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/diary_entry.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  DateTime selectedDate = DateTime.now();

  final TextEditingController controller = TextEditingController();

  String get formattedDate =>
      DateFormat('yyyy-MM-dd').format(selectedDate);

  String get displayDate =>
      DateFormat.yMMMMd().format(selectedDate);

  @override
  void initState() {
    super.initState();

    loadEntry();
  }

  void loadEntry() {
    final entry = StorageService.getEntry(formattedDate);

    controller.text = entry?.content ?? "";

    setState(() {});
  }

  Future saveEntry() async {
    final entry = DiaryEntry(
      date: formattedDate,
      content: controller.text,
    );

    await StorageService.saveEntry(entry);
  }

  void previousDay() async {
    await saveEntry();

    selectedDate = selectedDate.subtract(
      const Duration(days: 1),
    );

    loadEntry();
  }

  void nextDay() async {
    await saveEntry();

    selectedDate = selectedDate.add(
      const Duration(days: 1),
    );

    loadEntry();
  }

  Future pickDate() async {
    await saveEntry();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDate = picked;

      loadEntry();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("EchoMind"),

        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: pickDate,
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [

                IconButton(
                  onPressed: previousDay,
                  icon: const Icon(Icons.arrow_left),
                ),

                Text(
                  displayDate,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  onPressed: nextDay,
                  icon: const Icon(Icons.arrow_right),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: TextField(
                controller: controller,

                expands: true,
                maxLines: null,
                minLines: null,

                decoration: InputDecoration(
                  hintText:
                  "Write about your day...",

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  contentPadding:
                  const EdgeInsets.all(20),
                ),

                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),

                onChanged: (_) {
                  saveEntry();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}