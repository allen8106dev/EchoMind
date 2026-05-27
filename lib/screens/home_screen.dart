import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
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

  bool aiNeedsRefresh = false;

  bool isLoadingSummary = false;

  DateTime selectedDate = DateTime.now();

  final TextEditingController controller =
  TextEditingController();

  final FocusNode entryFocusNode =
  FocusNode();

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

    aiNeedsRefresh =
        entry?.aiNeedsRefresh ?? false;

    if (entry?.aiReflection != null) {

      aiResponse = AIResponse.fromJson(
        entry!.aiReflection!,
      );

    } else {

      aiResponse = null;
    }

    setState(() {});
  }

  Future saveEntry() async {

    final entry = DiaryEntry(

      date: formattedDate,

      entries: entries,

      aiReflection:
      aiResponse?.toJson(),

      aiNeedsRefresh:
      aiNeedsRefresh,
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

    aiNeedsRefresh = true;

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

                aiNeedsRefresh = true;

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

    aiNeedsRefresh = true;

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

    if (aiResponse != null &&
        aiNeedsRefresh == false) {

      showSummarySheet();

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

      aiResponse = response;

      aiNeedsRefresh = false;

      await saveEntry();

      setState(() {});

      showSummarySheet();

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

  void showSummarySheet() {

    FocusScope.of(context).unfocus();

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor:
      const Color(0xFF111827),

      shape:
      const RoundedRectangleBorder(

        borderRadius:
        BorderRadius.vertical(

          top: Radius.circular(30),
        ),
      ),

      builder: (context) {

        return DraggableScrollableSheet(

          expand: false,

          initialChildSize: 0.8,

          minChildSize: 0.5,

          maxChildSize: 0.95,

          builder: (context, scrollController) {

            return Padding(

              padding:
              const EdgeInsets.all(20),

              child: SingleChildScrollView(

                controller:
                scrollController,

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Center(

                      child: Container(

                        width: 50,
                        height: 5,

                        decoration:
                        BoxDecoration(

                          color:
                          Colors.white24,

                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(

                      aiResponse!.title,

                      style:
                      const TextStyle(

                        fontSize: 26,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(

                      "Mood: ${aiResponse!.mood}",

                      style:
                      const TextStyle(

                        fontSize: 15,

                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(

                      aiResponse!.summary,

                      style:
                      const TextStyle(

                        fontSize: 17,

                        height: 1.7,
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(

                      "Highlights",

                      style: TextStyle(

                        fontSize: 18,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...aiResponse!
                        .highlights
                        .map(

                          (highlight) {

                        return Padding(

                          padding:
                          const EdgeInsets.only(
                            bottom: 10,
                          ),

                          child: Text(

                            "• $highlight",

                            style:
                            const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    const Text(

                      "Suggestion",

                      style: TextStyle(

                        fontSize: 18,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(

                      aiResponse!.suggestion,

                      style:
                      const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {

      FocusScope.of(context).unfocus();
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

    final keyboardOpen =
        MediaQuery.of(context)
            .viewInsets.bottom > 0;

    return Scaffold(

      resizeToAvoidBottomInset: false,

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

      body: SafeArea(

        child: Padding(

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

                child:
                ListView.builder(

                  itemCount:
                  entries.length,

                  itemBuilder:
                      (context, index) {

                    final entry =
                    entries[index];

                    return GestureDetector(

                      onLongPress: () async {

                        // HAPTIC FEEDBACK
                        await HapticFeedback.mediumImpact();

                        if (!context.mounted) return;

                        showModalBottomSheet(

                          context: context,

                          backgroundColor: const Color(0xFF1E293B),

                          shape: const RoundedRectangleBorder(

                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),

                          transitionAnimationController:
                          AnimationController(

                            vsync: Navigator.of(context),

                            duration: const Duration(
                              milliseconds: 280,
                            ),
                          ),

                          builder: (context) {

                            return SafeArea(

                              child: Padding(

                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 12,
                                ),

                                child: Column(

                                  mainAxisSize:
                                  MainAxisSize.min,

                                  children: [

                                    Container(

                                      width: 40,
                                      height: 4,

                                      decoration: BoxDecoration(

                                        color: Colors.white
                                            .withValues(alpha: 0.25),

                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    ListTile(

                                      leading: const Icon(
                                        Icons.edit_rounded,
                                      ),

                                      title: const Text(
                                        "Edit Entry",
                                      ),

                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(16),
                                      ),

                                      onTap: () {

                                        Navigator.pop(context);

                                        editEntry(index);
                                      },
                                    ),

                                    ListTile(

                                      leading: const Icon(
                                        Icons.delete_rounded,
                                        color: Colors.red,
                                      ),

                                      title: const Text(

                                        "Delete Entry",

                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),

                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(16),
                                      ),

                                      onTap: () {

                                        Navigator.pop(context);

                                        deleteEntry(index);
                                      },
                                    ),
                                  ],
                                ),
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
                                    .withValues(
                                  alpha:0.6,
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

              AnimatedPadding(

                duration:
                const Duration(
                  milliseconds: 200,
                ),

                padding: EdgeInsets.only(

                  bottom:
                  MediaQuery.of(context)
                      .viewInsets.bottom,
                ),

                child: Column(

                  children: [

                    TextField(

                      focusNode:
                      entryFocusNode,

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

                    if (!keyboardOpen) ...[

                      const SizedBox(
                        height: 10,
                      ),

                      SizedBox(

                        width:
                        double.infinity,

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
                                : aiResponse == null
                                ? "Generate Summary"
                                : aiNeedsRefresh
                                ? "Regenerate Summary"
                                : "View Summary",
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}