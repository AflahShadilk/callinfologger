class ContactModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? notes;
  final DateTime createdAt;

  ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.notes,
    required this.createdAt,
  });
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
        id: map['id'],
        name: map['name'],
        phone: map['phone'],
        email: map['email'],
        notes: map['notes'],
        createdAt: DateTime.parse(map['createdAt']));
  }
}
