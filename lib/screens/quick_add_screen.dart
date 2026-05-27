import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/diary_entry.dart';
import '../services/storage_service.dart';

class QuickAddScreen extends StatefulWidget {

  const QuickAddScreen({super.key});

  @override
  State<QuickAddScreen> createState() =>
      _QuickAddScreenState();
}

class _QuickAddScreenState
    extends State<QuickAddScreen> {

  final controller =
  TextEditingController();

  List<Map<String, dynamic>>
  entries = [];

  String get today =>

      DateFormat('yyyy-MM-dd')
          .format(DateTime.now());

  @override
  void initState() {

    super.initState();

    loadTodayEntry();
  }

  void loadTodayEntry() {

    final entry =
    StorageService.getEntry(today);

    entries =
        entry?.entries ?? [];
  }

  Future saveQuickEntry() async {

    if (controller.text
        .trim()
        .isEmpty) {
      return;
    }

    final existingEntry =
    StorageService.getEntry(today);

    final existingAI =
        existingEntry?.aiReflection;

    entries.add({

      "time":
      DateFormat('hh:mm a')
          .format(DateTime.now()),

      "content":
      controller.text.trim(),
    });

    final entry = DiaryEntry(

      date: today,

      entries: entries,

      aiReflection:
      existingAI,

      aiNeedsRefresh: true,
    );

    await StorageService
        .saveEntry(entry);

    controller.clear();

    if (mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Entry added",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFF0F172A),

      appBar: AppBar(

        backgroundColor:
        const Color(0xFF0F172A),

        title: const Text(
          "Quick Add",
        ),
      ),

      body: Padding(

        padding:
        const EdgeInsets.all(16),

        child: Column(

          children: [

            Expanded(

              child: TextField(

                controller:
                controller,

                autofocus: true,

                expands: true,
                maxLines: null,
                minLines: null,

                style: const TextStyle(

                  color: Colors.white,

                  fontSize: 16,

                  height: 1.5,
                ),

                decoration:
                InputDecoration(

                  hintText:
                  "Write your thoughts...",

                  hintStyle:
                  const TextStyle(
                    color: Colors.white54,
                  ),

                  filled: true,

                  fillColor:
                  Colors.white10,

                  border:
                  OutlineInputBorder(

                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),

                  contentPadding:
                  const EdgeInsets.all(
                    20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(

              width: double.infinity,

              child:
              ElevatedButton.icon(

                onPressed:
                saveQuickEntry,

                icon: const Icon(
                  Icons.add,
                ),

                label: const Text(
                  "Add Entry",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}