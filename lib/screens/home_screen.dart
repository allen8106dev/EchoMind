import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/diary_entry.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../services/ai_response.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  AIResponse? aiResponse;

  bool isLoadingSummary = false;

  DateTime selectedDate = DateTime.now();

  final TextEditingController controller =
  TextEditingController();

  List<Map<String, dynamic>> entries = [];

  String get formattedDate =>
      DateFormat('yyyy-MM-dd')
          .format(selectedDate);

  String get displayDate =>
      DateFormat.yMMMMd()
          .format(selectedDate);

  @override
  void initState() {

    super.initState();

    loadEntry();
  }

  void loadEntry() {

    final entry =
    StorageService.getEntry(
      formattedDate,
    );

    entries = entry?.entries ?? [];

    setState(() {});
  }

  Future saveEntry() async {

    final entry = DiaryEntry(
      date: formattedDate,
      entries: entries,
    );

    await StorageService
        .saveEntry(entry);
  }

  void addEntry() async {

    if (controller.text
        .trim()
        .isEmpty) {
      return;
    }

    entries.add({

      "time":
      DateFormat('hh:mm a')
          .format(DateTime.now()),

      "content":
      controller.text.trim(),
    });

    controller.clear();

    await saveEntry();

    setState(() {});
  }

  void editEntry(int index) {

    final editController =
    TextEditingController(

      text: entries[index]['content'],
    );

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Edit Entry",
          ),

          content: TextField(

            controller: editController,

            maxLines: null,

            decoration:
            const InputDecoration(
              hintText: "Edit your entry",
            ),
          ),

          actions: [

            TextButton(

              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("Cancel"),
            ),

            ElevatedButton(

              onPressed: () async {

                entries[index]['content'] =
                    editController.text.trim();

                await saveEntry();

                setState(() {});

                Navigator.pop(context);
              },

              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void deleteEntry(int index) async {

    entries.removeAt(index);

    await saveEntry();

    setState(() {});
  }

  void previousDay() async {

    await saveEntry();

    selectedDate =
        selectedDate.subtract(
          const Duration(days: 1),
        );

    loadEntry();
  }

  void nextDay() async {

    await saveEntry();

    selectedDate =
        selectedDate.add(
          const Duration(days: 1),
        );

    loadEntry();
  }

  Future generateSummary() async {

    if (entries.isEmpty) {
      return;
    }

    setState(() {
      isLoadingSummary = true;
    });

    try {

      final combinedText =
      entries.map((e) {

        return
          "${e['time']} - ${e['content']}";

      }).join("\n");

      final response =
      await AIService.summarizeDay(
        combinedText,
      );

      setState(() {
        aiResponse = response;
      });

    } catch (e) {

      print("ERROR: $e");

      ScaffoldMessenger.of(context)
          .showSnackBar(

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

    final picked =
    await showDatePicker(

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

        title: const Text(
          "EchoMind",
        ),

        actions: [

          IconButton(

            icon: const Icon(
              Icons.calendar_month,
            ),

            onPressed: pickDate,
          )
        ],
      ),

      body: Padding(

        padding:
        const EdgeInsets.all(16),

        child: Column(

          children: [

            Row(

              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,

              children: [

                IconButton(

                  onPressed:
                  previousDay,

                  icon: const Icon(
                    Icons.arrow_left,
                  ),
                ),

                Text(

                  displayDate,

                  style:
                  const TextStyle(

                    fontSize: 18,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                IconButton(

                  onPressed:
                  nextDay,

                  icon: const Icon(
                    Icons.arrow_right,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(

              child: Column(

                children: [

                  Expanded(

                    child:
                    ListView.builder(

                      itemCount:
                      entries.length,

                      itemBuilder:
                          (context, index) {

                        final entry =
                        entries[index];

                        return GestureDetector(

                          onLongPress: () {

                            showModalBottomSheet(

                              context: context,

                              builder: (context) {

                                return SafeArea(

                                  child: Column(

                                    mainAxisSize:
                                    MainAxisSize.min,

                                    children: [

                                      ListTile(

                                        leading:
                                        const Icon(
                                          Icons.edit,
                                        ),

                                        title:
                                        const Text(
                                          "Edit Entry",
                                        ),

                                        onTap: () {

                                          Navigator.pop(
                                            context,
                                          );

                                          editEntry(
                                            index,
                                          );
                                        },
                                      ),

                                      ListTile(

                                        leading:
                                        const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),

                                        title:
                                        const Text(

                                          "Delete Entry",

                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),

                                        onTap: () {

                                          Navigator.pop(
                                            context,
                                          );

                                          deleteEntry(
                                            index,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },

                          child: Container(

                            width:
                            double.infinity,

                            margin:
                            const EdgeInsets.only(
                              bottom: 12,
                            ),

                            padding:
                            const EdgeInsets.all(16),

                            decoration:
                            BoxDecoration(

                              color:
                              Colors.white10,

                              borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                            ),

                            child: Column(

                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                              children: [

                                Text(

                                  entry['time'],

                                  style:
                                  TextStyle(

                                    fontSize: 11,

                                    color:
                                    Colors.white
                                        .withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 6,
                                ),

                                Text(

                                  entry['content'],

                                  style:
                                  const TextStyle(

                                    fontSize: 16,

                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(

                    controller:
                    controller,

                    minLines: 1,
                    maxLines: 5,

                    decoration:
                    InputDecoration(

                      hintText:
                      "Write a quick thought...",

                      border:
                      OutlineInputBorder(

                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),
                      ),

                      contentPadding:
                      const EdgeInsets.all(
                        16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(

                    width:
                    double.infinity,

                    child:
                    ElevatedButton.icon(

                      onPressed:
                      addEntry,

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

            const SizedBox(height: 20),

            SizedBox(

              width: double.infinity,

              child:
              ElevatedButton.icon(

                onPressed:
                isLoadingSummary
                    ? null
                    : generateSummary,

                icon: const Icon(
                  Icons.auto_awesome,
                ),

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

                padding:
                const EdgeInsets.all(16),

                decoration:
                BoxDecoration(

                  color: Colors.white10,

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(

                      aiResponse!.title,

                      style:
                      const TextStyle(

                        fontSize: 22,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(

                      "Mood: ${aiResponse!.mood}",

                      style:
                      const TextStyle(

                        fontSize: 14,

                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(

                      aiResponse!.summary,

                      style:
                      const TextStyle(

                        fontSize: 16,

                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(

                      "Highlights",

                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    ...aiResponse!
                        .highlights
                        .map(

                          (highlight) {

                        return Padding(

                          padding:
                          const EdgeInsets.only(
                            bottom: 4,
                          ),

                          child: Text(
                            "• $highlight",
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    const Text(

                      "Suggestion",

                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
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