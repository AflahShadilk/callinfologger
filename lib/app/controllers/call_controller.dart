import 'dart:async';

import 'package:callinfologger/app/data/database/db_helper.dart';
import 'package:callinfologger/app/data/models/call_log_model.dart';
import 'package:callinfologger/app/data/models/contact_model.dart';
import 'package:get/get.dart';
import 'package:phone_state/phone_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class CallController extends GetxController {
  final DBHelper _db = DBHelper.instance;
  final _uuid = const Uuid();

  final RxList<CallLogModel> callLogs = <CallLogModel>[].obs;
  final RxBool isRecording = false.obs;
  final RxBool isPlaying = false.obs;
  final RxInt recordingSeconds = 0.obs;
  final RxString currentPlayingId = ''.obs;
  final RxString recordingPath = ''.obs;

  Timer? _timer;
  DateTime? _callStartTime;
  StreamSubscription<PhoneState>? _phoneStateSubscription;
  String? _lastDialedNumber;
  bool _isAutoLogging = false;
  CallType _currentCallType = CallType.outgoing;

  @override
  void onInit() {
    super.onInit();
    loadCallLogs();
    _requestPermissions();
    _initPhoneStateListener();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _phoneStateSubscription?.cancel();
    super.onClose();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.phone,
      Permission.contacts,
    ].request();
  }

  void _initPhoneStateListener() {
    _phoneStateSubscription = PhoneState.stream.listen((event) {
      _handlePhoneState(event);
    });
  }

  Future<void> _handlePhoneState(PhoneState event) async {
    switch (event.status) {
      case PhoneStateStatus.CALL_INCOMING:
        _currentCallType = CallType.incoming;
        break;

      case PhoneStateStatus.CALL_STARTED:
        _callStartTime = DateTime.now();
        _isAutoLogging = true;
        if (_currentCallType != CallType.incoming) {
          _currentCallType = CallType.outgoing;
        }
        break;

      case PhoneStateStatus.CALL_ENDED:
        if (_isAutoLogging && _callStartTime != null) {
          final DateTime startTime = _callStartTime!;
          final duration = DateTime.now().difference(startTime).inSeconds;
          final phoneNumber = event.number ?? _lastDialedNumber ?? "Unknown";

          final contact = await _db.getContactByPhone(phoneNumber);

          final log = CallLogModel(
            id: _uuid.v4(),
            contactId: contact?.id ?? "unknown_contact",
            contactName: contact?.name ?? "Unknown",
            phoneNumber: phoneNumber,
            callType: _currentCallType,
            calledAt: startTime,
            durationSeconds: duration,
            notes: "Automatically logged",
          );

          await _db.insertCallLog(log);
          await loadCallLogs();
          _isAutoLogging = false;
          _callStartTime = null;
          _lastDialedNumber = null;
          _currentCallType = CallType.outgoing;
        }
        break;

      case PhoneStateStatus.NOTHING:
        _isAutoLogging = false;
        _currentCallType = CallType.outgoing;
        break;
    }
  }

  Future<void> loadCallLogs() async {
    callLogs.value = await _db.getAllCallLogs();
  }

  Future<List<CallLogModel>> getLogsForContact(String contactId) async {
    return await _db.getCallLogsByContact(contactId);
  }

  Future<void> dialNumber(String phoneNumber) async {
    _lastDialedNumber = phoneNumber;
    _currentCallType = CallType.outgoing;
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Could not launch dialer',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> startRecording() async {
    recordingPath.value = '';
    _callStartTime = DateTime.now();
    isRecording.value = true;
    recordingSeconds.value = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      recordingSeconds.value++;
    });
  }

  Future<void> stopRecordingAndSave(
      {required ContactModel contact,
      required CallType calltype,
      String? notes}) async {
    if (!isRecording.value) return;
    _timer?.cancel();
    isRecording.value = false;

    final log = CallLogModel(
      id: _uuid.v4(),
      contactId: contact.id,
      contactName: contact.name,
      phoneNumber: contact.phone,
      callType: calltype,
      calledAt: _callStartTime ?? DateTime.now(),
      durationSeconds: recordingSeconds.value,
      recordingPath: recordingPath.value,
      notes: notes,
    );
    await _db.insertCallLog(log);
    await loadCallLogs();
    recordingSeconds.value = 0;
    Get.snackbar('Saved', 'Call log saved for ${contact.name}',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> deleteCallLog(String id) async {
    await _db.deleteCallLog(id);
    await loadCallLogs();
    Get.snackbar('Deleted', 'Call log deleted',
        snackPosition: SnackPosition.BOTTOM);
  }

  String get formattedTimer {
    final m = recordingSeconds.value ~/ 60;
    final s = recordingSeconds.value % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
