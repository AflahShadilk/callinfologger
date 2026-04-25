// ignore_for_file: deprecated_member_use

import 'package:callinfologger/app/controllers/call_controller.dart';
import 'package:callinfologger/app/data/models/call_log_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CallLogCard extends StatelessWidget {
  final CallLogModel log;
  final VoidCallback? onDelete;

  const CallLogCard({
    super.key,
    required this.log,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final CallController callController = Get.find<CallController>();

    final Color typeColor;
    final IconData typeIcon;
    final String typeLabel;

    switch (log.callType) {
      case CallType.incoming:
        typeColor = Colors.green;
        typeIcon = Icons.call_received;
        typeLabel = 'Incoming';
        break;
      case CallType.outgoing:
        typeColor = Colors.blue;
        typeIcon = Icons.call_made;
        typeLabel = 'Outgoing';
        break;
      case CallType.missed:
        typeColor = Colors.red;
        typeIcon = Icons.call_missed;
        typeLabel = 'Missed';
        break;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Call icon
            CircleAvatar(
              radius: 22,
              backgroundColor: typeColor.withOpacity(0.12),
              child: Icon(typeIcon, color: typeColor, size: 20),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name 
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          log.contactName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log.phoneNumber,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMM yyyy  hh:mm a')
                        .format(log.calledAt),
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        log.formattedDuration,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Play + Delete 
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (log.recordingPath != null)
                  Obx(() {
                    final isThisPlaying =
                        callController.currentPlayingId.value == log.id &&
                            callController.isPlaying.value;
                    return IconButton(
                      icon: Icon(
                        isThisPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: Colors.indigo,
                        size: 34,
                      ),
                      onPressed: () => callController.playRecording(
                        log.id,
                        log.recordingPath!,
                      ),
                    );
                  }),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}