import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final controller = TextEditingController();

  Future saveEntry() async {
    if (controller.text.trim().isEmpty) return;

    final entry = DiaryEntry(
      text: controller.text.trim(),
      createdAt: DateTime.now(),
    );

    await StorageService.addEntry(entry);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Entry"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: "Write your thoughts...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveEntry,
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}