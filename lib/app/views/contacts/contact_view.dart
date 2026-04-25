import 'package:callinfologger/app/controllers/contact_controller.dart';
import 'package:callinfologger/app/routes/app_routes.dart';
import 'package:callinfologger/app/views/widgets/contact_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ContactsView extends GetView<ContactController> {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_android),
            tooltip: 'Import from Phone',
            onPressed: controller.importFromPhone,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search 
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: InputDecoration(
                hintText: 'Search by name or number...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Contact list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredContacts.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.contacts_outlined,
                          size: 72, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No contacts yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap + to add or import from phone',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: controller.filteredContacts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (_, i) {
                  final contact = controller.filteredContacts[i];
                  return ContactCard(
                    contact: contact,
                    onTap: () => Get.toNamed(
                      AppRoutes.contactDetails,
                      arguments: contact,
                    ),
                    onDelete: () => _confirmDelete(contact.id, contact.name),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addContact),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Contact'),
      ),
    );
  }

  void _confirmDelete(String id, String name) {
    Get.defaultDialog(
      title: 'Delete Contact',
      middleText: 'Delete $name? This cannot be undone.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deletecontact(id);
        Get.back();
      },
    );
  }
}