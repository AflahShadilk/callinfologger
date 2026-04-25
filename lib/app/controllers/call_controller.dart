import 'dart:async';

import 'package:callinfologger/app/data/database/db_helper.dart';
import 'package:callinfologger/app/data/models/call_log_model.dart';
import 'package:callinfologger/app/data/models/contact_model.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class CallController extends GetxController{
  final DBHelper _db=DBHelper.instance;
  final AudioRecorder _recorder=AudioRecorder();
  final AudioPlayer _player=AudioPlayer();
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
  _player.dispose();
 _recorder.dispose();
  super.onClose();
 }

 Future<void>loadCallLogs()async{
  callLogs.value=await _db.getAllCallLogs();
 }

 Future<List<CallLogModel>>getLogsForContact(String contactId)async{
  return await _db.getCallLogsByContact(contactId);
 }

//dail number
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
  final micStatus=await Permission.microphone.request();
  if(!micStatus.isGranted){
    Get.snackbar('Permission Denied', 'Microphone permission is required to record calls',
    snackPosition: SnackPosition.BOTTOM);
    return;
  }
  final dir=await getApplicationDocumentsDirectory();
  final fileName='call_${DateTime.now().millisecondsSinceEpoch}.m4a';
  final path='${dir.path}/$fileName';
  await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
  recordingPath.value=path;
  _callStartTime=DateTime.now();  
  isRecording.value=true;
  recordingSeconds.value=0;
  _timer=Timer.periodic(const Duration(seconds: 1), (_){
    recordingSeconds.value++;
  });
 }
 
 //stop recording and saving
 Future<void>stopRecordingAndSave({required ContactModel contact,required CallType calltype,String ? notes})async{
   if(!isRecording.value)return ;
   await _recorder.stop();
   _timer?.cancel();
   isRecording.value=false; 
    
    final log=CallLogModel(id: _uuid.v4(), contactId:contact.id, contactName: contact.name, 
    phoneNumber: contact.phone, callType: calltype, calledAt: _callStartTime??DateTime.now(),
     durationSeconds: recordingSeconds.value,recordingPath: recordingPath.value,notes: notes);
     await _db.insertCallLog(log);
     await loadCallLogs();
     recordingSeconds.value=0;  
     Get.snackbar('Saved', 'Call recording saded for ${contact.name}',snackPosition: SnackPosition.BOTTOM);
 }
  
  //playback
  Future<void>playRecording(String id,String path)async{
      if(currentPlayingId.value==id&&isPlaying.value){
        await _player.pause(); 
        isPlaying.value=false;
        currentPlayingId.value='';
        return;

      }
      await _player.setFilePath(path);
      await _player.play();
      currentPlayingId.value=id;
      isPlaying.value=true;
      _player.playerStateStream.listen((state){
        if(state.processingState==ProcessingState.completed){
          isPlaying.value=false;
          currentPlayingId.value='';
        }
      });
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