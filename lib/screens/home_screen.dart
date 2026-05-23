import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';
import 'add_entry_screen.dart';
import 'calendar_screen.dart';
import '../widgets/entry_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DiaryEntry> entries = [];

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  void loadEntries() {
    entries = StorageService.getEntries();

    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EchoMind"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CalendarScreen(),
                ),
              );

              loadEntries();
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return EntryCard(entry: entries[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEntryScreen(),
            ),
          );

          loadEntries();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}