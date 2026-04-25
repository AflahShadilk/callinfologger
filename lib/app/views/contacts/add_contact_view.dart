import 'package:callinfologger/app/controllers/contact_controller.dart';
import 'package:callinfologger/app/data/models/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddContactView extends GetView<ContactController> {
  const AddContactView({super.key});

  @override
  Widget build(BuildContext context) {
    final ContactModel? existing = Get.arguments as ContactModel?;
    final bool isEditing = existing != null;

    final TextEditingController nameCtrl =
        TextEditingController(text: existing?.name);
    final TextEditingController phoneCtrl =
        TextEditingController(text: existing?.phone);
    final TextEditingController emailCtrl =
        TextEditingController(text: existing?.email ?? '');
    final TextEditingController notesCtrl =
        TextEditingController(text: existing?.notes ?? '');
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Contact' : 'Add Contact'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.indigo.shade100,
                child: Text(
                  existing?.name.isNotEmpty == true
                      ? existing!.name[0].toUpperCase()
                      : '+',
                  style: const TextStyle(fontSize: 36, color: Colors.indigo),
                ),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: _dec('Full Name', Icons.person),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: _dec('Phone Number', Icons.phone),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Phone is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _dec('Email (optional)', Icons.email),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: notesCtrl,
                maxLines: 3,
                decoration: _dec('Notes (optional)', Icons.notes),
              ),
              const SizedBox(height: 32),

              // Save
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: Icon(isEditing ? Icons.save : Icons.person_add),
                  label: Text(
                    isEditing ? 'Save Changes' : 'Add Contact',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    if (isEditing) {
                      await controller.updateContact(
                        ContactModel(
                          id: existing.id,
                          name: nameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          email: emailCtrl.text.trim().isEmpty
                              ? null
                              : emailCtrl.text.trim(),
                          notes: notesCtrl.text.trim().isEmpty
                              ? null
                              : notesCtrl.text.trim(),
                          createdAt: existing.createdAt,
                        ),
                      );
                    } else {
                      await controller.addContact(
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        email: emailCtrl.text.trim().isEmpty
                            ? null
                            : emailCtrl.text.trim(),
                        notes: notesCtrl.text.trim().isEmpty
                            ? null
                            : notesCtrl.text.trim(),
                      );
                    }
                    nameCtrl.clear();
                    phoneCtrl.clear();
                    emailCtrl.clear();
                    notesCtrl.clear();

                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      );
}
