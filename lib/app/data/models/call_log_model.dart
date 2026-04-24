enum CallType { incoming, outgoing, missed }

class CallLogModel {
  final String id;
  final String contactId;
  final String contactName;
  final String phoneNumber;
  final CallType callType;
  final DateTime calledAt;
  final int durationSeconds;
  final String? recordingPath;
  final String? notes;

  CallLogModel({
    required this.id,
    required this.contactId,
    required this.contactName,
    required this.phoneNumber,
    required this.callType,
    required this.calledAt,
    required this.durationSeconds,
    this.recordingPath,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'contactId': contactId,
    'contactName': contactName,
    'phoneNumber': phoneNumber,
    'callType': callType.name,
    'calledAt': calledAt.toIso8601String(),
    'durationSeconds': durationSeconds,
    'recordingPath': recordingPath,
    'notes': notes,
  };

  factory CallLogModel.fromMap(Map<String, dynamic> map) => CallLogModel(
    id: map['id'],
    contactId: map['contactId'],
    contactName: map['contactName'],
    phoneNumber: map['phoneNumber'],
    callType: CallType.values.byName(map['callType']),
    calledAt: DateTime.parse(map['calledAt']),
    durationSeconds: map['durationSeconds'],
    recordingPath: map['recordingPath'],
    notes: map['notes'],
  );

  String get formattedDuration {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}