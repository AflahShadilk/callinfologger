import 'package:callinfologger/app/data/models/contact_model.dart';
import 'package:flutter/material.dart';


class ContactCard extends StatelessWidget {
  final ContactModel contact;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          child: Text(
            contact.name.isNotEmpty
                ? contact.name[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          contact.phone,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              )
            : const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}