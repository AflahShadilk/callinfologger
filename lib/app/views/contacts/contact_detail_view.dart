// ignore_for_file: deprecated_member_use

import 'package:callinfologger/app/controllers/call_controller.dart';
import 'package:callinfologger/app/controllers/contact_controller.dart';
import 'package:callinfologger/app/data/models/call_log_model.dart';
import 'package:callinfologger/app/data/models/contact_model.dart';
import 'package:callinfologger/app/routes/app_routes.dart';
import 'package:callinfologger/app/views/widgets/call_log_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class ContactDetailView extends GetView<ContactController> {
  const ContactDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final ContactModel contact = Get.arguments as ContactModel;
    final CallController callController = Get.find<CallController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Detail'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Get.toNamed(
              AppRoutes.addContact,
              arguments: contact,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(contact),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo.shade100,
                    child: Text(
                      contact.name[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 42, color: Colors.indigo),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    contact.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact.phone,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 15),
                  ),
                  if (contact.email != null && contact.email!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        contact.email!,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Added ${DateFormat('dd MMM yyyy').format(contact.createdAt)}',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  icon: Icons.call,
                  label: 'Call',
                  color: Colors.green,
                  onTap: () => callController.dialNumber(contact.phone),
                ),
                _actionButton(
                  icon: Icons.mic,
                  label: 'Record',
                  color: Colors.red,
                  onTap: () => Get.toNamed(
                    AppRoutes.recordCall,
                    arguments: contact,
                  ),
                ),
                _actionButton(
                  icon: Icons.edit,
                  label: 'Edit',
                  color: Colors.indigo,
                  onTap: () => Get.toNamed(
                    AppRoutes.addContact,
                    arguments: contact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            
            if (contact.notes != null && contact.notes!.isNotEmpty) ...[
              const Text(
                'Notes',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(contact.notes!),
              ),
              const SizedBox(height: 24),
            ],

            // history
            const Text(
              'Call History',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            FutureBuilder<List<CallLogModel>>(
              future: callController.getLogsForContact(contact.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final logs = snapshot.data ?? [];
                if (logs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Center(
                      child: Text(
                        'No call history yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 6),
                  itemBuilder: (_, i) => CallLogCard(log: logs[i]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _confirmDelete(ContactModel contact) {
    Get.defaultDialog(
      title: 'Delete Contact',
      middleText:
          'Delete ${contact.name}? All call logs will remain.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.find<ContactController>().deletecontact(contact.id);
        Get.back();
        Get.back();
      },
    );
  }
}