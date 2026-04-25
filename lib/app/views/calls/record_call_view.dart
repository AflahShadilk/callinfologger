// ignore_for_file: deprecated_member_use

import 'package:callinfologger/app/controllers/call_controller.dart';
import 'package:callinfologger/app/controllers/contact_controller.dart';
import 'package:callinfologger/app/data/models/call_log_model.dart';
import 'package:callinfologger/app/data/models/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class RecordCallView extends GetView<CallController> {
  const RecordCallView({super.key});

  @override
  Widget build(BuildContext context) {
    final ContactController contactController =
        Get.find<ContactController>();

    final Rx<ContactModel?> selectedContact =
        Rx<ContactModel?>(Get.arguments as ContactModel?);
    final Rx<CallType> selectedType = CallType.outgoing.obs;
    final TextEditingController notesCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Call'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            const Text(
              'Call Type',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Obx(() => Row(
              children: [
                _typeChip(
                  label: 'Incoming',
                  type: CallType.incoming,
                  icon: Icons.call_received,
                  color: Colors.green,
                  selected: selectedType,
                ),
                const SizedBox(width: 12),
                _typeChip(
                  label: 'Outgoing',
                  type: CallType.outgoing,
                  icon: Icons.call_made,
                  color: Colors.blue,
                  selected: selectedType,
                ),
              ],
            )),
            const SizedBox(height: 24),

            // Contact selector
            const Text(
              'Select Contact',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Obx(() => GestureDetector(
              onTap: controller.isRecording.value
                  ? null
                  : () => _showContactPicker(
                      context, contactController, selectedContact),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.indigo.shade100,
                      child: Text(
                        selectedContact.value != null
                            ? selectedContact.value!.name[0]
                                .toUpperCase()
                            : '?',
                        style:
                            const TextStyle(color: Colors.indigo),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedContact.value?.name ??
                            'Tap to select contact',
                        style: TextStyle(
                          color: selectedContact.value != null
                              ? Colors.black87
                              : Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down,
                        color: Colors.grey),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 20),

            // Notes
            TextField(
              controller: notesCtrl,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 36),

            // Timer
            Center(
              child: Obx(() => Text(
                controller.formattedTimer,
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                  color: Colors.indigo,
                ),
              )),
            ),
            const SizedBox(height: 8),

            // Recording indicator
            Obx(() => controller.isRecording.value
                ? Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.circle,
                            color: Colors.red, size: 10),
                        const SizedBox(width: 6),
                        Text(
                          'Recording...',
                          style: TextStyle(
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(height: 20)),
            const SizedBox(height: 24),

            // Record button
            Center(
              child: Obx(() => GestureDetector(
                onTap: () async {
                  if (controller.isRecording.value) {
                    if (selectedContact.value == null) {
                      Get.snackbar(
                        'Select Contact',
                        'Please select a contact before saving',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    await controller.stopRecordingAndSave(
                      contact: selectedContact.value!,
                      calltype: selectedType.value,
                      notes: notesCtrl.text.trim().isEmpty
                          ? null
                          : notesCtrl.text.trim(),
                    );
                    notesCtrl.clear();
                  } else {
                    await controller.startRecording();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: controller.isRecording.value
                        ? Colors.red
                        : Colors.indigo,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (controller.isRecording.value
                                ? Colors.red
                                : Colors.indigo)
                            .withOpacity(0.35),
                        blurRadius: 24,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    controller.isRecording.value
                        ? Icons.stop_rounded
                        : Icons.mic,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              )),
            ),
            const SizedBox(height: 14),
            Center(
              child: Obx(() => Text(
                controller.isRecording.value
                    ? 'Tap to stop & save recording'
                    : 'Tap mic to start recording',
                style: const TextStyle(
                    color: Colors.grey, fontSize: 13),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip({
    required String label,
    required CallType type,
    required IconData icon,
    required Color color,
    required Rx<CallType> selected,
  }) {
    final bool isSelected = selected.value == type;
    return GestureDetector(
      onTap: () => selected.value = type,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactPicker(
    BuildContext context,
    ContactController contactController,
    Rx<ContactModel?> selectedContact,
  ) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Contact',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Obx(() => contactController.contacts.isEmpty
                  ? const Center(
                      child: Text('No contacts found',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount:
                          contactController.contacts.length,
                      itemBuilder: (_, i) {
                        final c = contactController.contacts[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Colors.indigo.shade50,
                            child: Text(
                              c.name[0].toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.indigo),
                            ),
                          ),
                          title: Text(c.name),
                          subtitle: Text(c.phone),
                          onTap: () {
                            selectedContact.value = c;
                            Get.back();
                          },
                        );
                      },
                    )),
            ),
          ],
        ),
      ),
    );
  }
}