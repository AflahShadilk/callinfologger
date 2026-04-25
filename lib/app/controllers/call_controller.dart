import 'dart:async';

import 'package:callinfologger/app/data/database/db_helper.dart';
import 'package:callinfologger/app/data/models/call_log_model.dart';
import 'package:callinfologger/app/data/models/contact_model.dart';
import 'package:get/get.dart';


import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class CallController extends GetxController{
  final DBHelper _db=DBHelper.instance;
  final _uuid=const Uuid();

  final RxList<CallLogModel>callLogs=<CallLogModel>[].obs;
  final RxBool isRecording=false.obs;
  final RxBool isPlaying=false.obs;
  final RxInt recordingSeconds=0.obs;
  final RxString currentPlayingId=''.obs;
  final RxString recordingPath=''.obs; 

  Timer?_timer;
  DateTime? _callStartTime;

  @override
  void onInit(){
    super.onInit();
    loadCallLogs();
  }
 
  @override
  void onClose(){
    _timer?.cancel();
    super.onClose();
  }

  Future<void>loadCallLogs()async{
    callLogs.value=await _db.getAllCallLogs();
  }

  Future<List<CallLogModel>>getLogsForContact(String contactId)async{
    return await _db.getCallLogsByContact(contactId);
  }

  Future<void>dialNumber(String phoneNumber)async{
    final uri=Uri.parse('tel:$phoneNumber');
    if(await canLaunchUrl(uri)){
      await launchUrl(uri);
    }else{
      Get.snackbar('Error', 'Could not launch dialer',
      snackPosition: SnackPosition.BOTTOM);
    }
  }

  
  Future<void>startRecording()async{
    recordingPath.value='';
    _callStartTime=DateTime.now();  
    isRecording.value=true;
    recordingSeconds.value=0;
    _timer=Timer.periodic(const Duration(seconds: 1), (_){
      recordingSeconds.value++;
    });
  }

  Future<void>stopRecordingAndSave({required ContactModel contact,required CallType calltype,String ? notes})async{
    if(!isRecording.value)return;
    _timer?.cancel();
    isRecording.value=false; 
    
    final log=CallLogModel(
      id: _uuid.v4(),
      contactId: contact.id,
      contactName: contact.name, 
      phoneNumber: contact.phone,
      callType: calltype,
      calledAt: _callStartTime??DateTime.now(),
      durationSeconds: recordingSeconds.value,
      recordingPath: recordingPath.value,
      notes: notes,
    );
    await _db.insertCallLog(log);
    await loadCallLogs();
    recordingSeconds.value=0;  
    Get.snackbar('Saved', 'Call log saved for ${contact.name}',snackPosition: SnackPosition.BOTTOM);
  }

  Future<void>deleteCallLog(String id)async{
    await _db.deleteCallLog(id);
    await loadCallLogs();
    Get.snackbar('Deleted', 'Call log deleted',snackPosition: SnackPosition.BOTTOM);
  }

  String get formattedTimer{
    final m=recordingSeconds.value~/60;
    final s=recordingSeconds.value%60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }
}