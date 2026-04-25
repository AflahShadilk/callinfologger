import 'package:callinfologger/app/controllers/call_controller.dart';
import 'package:callinfologger/app/data/models/call_log_model.dart';
import 'package:callinfologger/app/views/widgets/call_log_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CallLogView extends GetView<CallController> {
  const CallLogView({super.key});

  @override
  Widget build(BuildContext context) {
    final Rx<CallType?> filterType = Rx<CallType?>(null);

    return Scaffold(
      appBar: AppBar(
  title: const Text('Call Logs'),
  centerTitle: true,
  actions: [
    PopupMenuButton<CallType?>(
      icon: const Icon(Icons.filter_list),
      onSelected: (type) => filterType.value = type,
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: null,
          child: Row(children: [
            Icon(Icons.all_inclusive, color: Colors.grey),
            SizedBox(width: 8),
            Text('All'),
          ]),
        ),
        const PopupMenuItem(
          value: CallType.incoming,
          child: Row(children: [
            Icon(Icons.call_received, color: Colors.green),
            SizedBox(width: 8),
            Text('Incoming'),
          ]),
        ),
        const PopupMenuItem(
          value: CallType.outgoing,
          child: Row(children: [
            Icon(Icons.call_made, color: Colors.blue),
            SizedBox(width: 8),
            Text('Outgoing'),
          ]),
        ),
        const PopupMenuItem(
          value: CallType.missed,
          child: Row(children: [
            Icon(Icons.call_missed, color: Colors.red),
            SizedBox(width: 8),
            Text('Missed'),
          ]),
        ),
      ],
    ),
  ],
),
      body: Obx(() {
        final logs = filterType.value == null
            ? controller.callLogs
            : controller.callLogs
                .where((l) => l.callType == filterType.value)
                .toList();

        if (logs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 72, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'No call logs yet',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Recorded calls will appear here',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (_, i) => CallLogCard(
            log: logs[i],
            onDelete: () => _confirmDelete(logs[i].id),
          ),
        );
      }),
    );
  }

  void _confirmDelete(String id) {
    Get.defaultDialog(
      title: 'Delete Recording',
      middleText: 'Delete this call log and recording?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteCallLog(id);
        Get.back();
      },
    );
  }
}