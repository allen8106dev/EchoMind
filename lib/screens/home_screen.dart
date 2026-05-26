import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../services/ai_response.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AIResponse? aiResponse;

  bool isLoadingSummary = false;

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

  Future generateSummary() async {

    if (controller.text.trim().isEmpty) {
      return;
    }

    setState(() {
      isLoadingSummary = true;
    });

    try {

      final response =
      await AIService.summarizeDay(
        controller.text,
      );

      setState(() {
        aiResponse = response;
      });

    } catch (e) {

      print("ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }

    setState(() {
      isLoadingSummary = false;
    });
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
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed:
                isLoadingSummary
                    ? null
                    : generateSummary,

                icon: const Icon(Icons.auto_awesome),

                label: Text(
                  isLoadingSummary
                      ? "Generating..."
                      : "Summarize My Day",
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (aiResponse != null)

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white10,

                  borderRadius:
                  BorderRadius.circular(20),
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      aiResponse!.title,

                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Mood: ${aiResponse!.mood}",

                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      aiResponse!.summary,

                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Highlights",

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    ...aiResponse!.highlights.map(
                          (highlight) => Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 4,
                        ),

                        child: Text(
                          "• $highlight",
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Suggestion",

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      aiResponse!.suggestion,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}