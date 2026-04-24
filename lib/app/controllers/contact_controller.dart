import 'package:callinfologger/app/data/database/db_helper.dart';
import 'package:callinfologger/app/data/models/contact_model.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class ContactController extends GetxController {
  final DBHelper _db = DBHelper.instance;
  final _uuid = const Uuid();
  final RxList<ContactModel> contacts = <ContactModel>[].obs;
  final RxList<ContactModel> filteredContacts = <ContactModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
    ever(searchQuery, (_) {
      filterContacts();
    });
  }

  Future<void> loadContacts() async {
    isLoading.value = true;
    contacts.value = await _db.getAllContacts();
    filteredContacts.value = contacts;
    isLoading.value = false;
  }

  void filterContacts() {
    if (searchQuery.value.isEmpty) {
      filteredContacts.value = contacts;
    } else {
      filteredContacts.value = contacts
          .where((c) =>
              c.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              c.phone.contains(searchQuery.value))
          .toList();
    }
  }

  Future<void> addContact(
      {required String name,
      required String phone,
      String? email,
      String? notes}) async {
    final contact = ContactModel(
        id: _uuid.v4(),
        name: name,
        phone: phone,
        email: email,
        notes: notes,
        createdAt: DateTime.now());
    await _db.insertContact(contact);
    await loadContacts();
    Get.snackbar('Success', '$name added to contacts',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> updateContact(ContactModel contact) async {
    await _db.updateContact(contact);
    await loadContacts();
    Get.snackbar('Updated', '${contact.name} updated',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> deletecontact(String id) async {
    await _db.deleteContact(id);
    await loadContacts();
    Get.snackbar('Deleted', 'Contact deleted',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> importFromPhone() async {
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      Get.snackbar(
          'Permission Denied', 'Contacts permission is required to import',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    final phoneContacts = await ContactsService.getContacts();
    for (final c in phoneContacts) {
      if (c.phones != null && c.phones!.isNotEmpty) {
        await _db.insertContact(ContactModel(
            id: _uuid.v4(),
            name: c.displayName ?? 'Unknown',
            phone: c.phones!.first.value ?? '',
            email: c.emails?.isNotEmpty == true ? c.emails!.first.value : null,
            createdAt: DateTime.now()));
      }
    }
    await loadContacts();
    Get.snackbar('Import Complete', 'Contacts imported from phone',
        snackPosition: SnackPosition.BOTTOM);
  }
}
