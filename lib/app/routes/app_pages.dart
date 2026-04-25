import 'package:callinfologger/app/controllers/call_controller.dart';
import 'package:callinfologger/app/controllers/contact_controller.dart';
import 'package:callinfologger/app/data/models/call_log_model.dart';
import 'package:callinfologger/app/routes/app_routes.dart';
import 'package:callinfologger/app/views/calls/call_log_view.dart';
import 'package:callinfologger/app/views/calls/record_call_view.dart';
import 'package:callinfologger/app/views/contacts/add_contact_view.dart';
import 'package:callinfologger/app/views/contacts/contact_detail_view.dart';
import 'package:callinfologger/app/views/contacts/contact_view.dart';
import 'package:callinfologger/app/views/home/home_view.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages=[
    GetPage(name: AppRoutes.home, page:()=>const HomeView(),binding: BindingsBuilder((){
      Get.lazyPut(()=>ContactController());
      Get.lazyPut(()=>CallController());
    }),
    
    ),
    GetPage(name: AppRoutes.contact, page: ()=>const ContactView()),
    GetPage(name: AppRoutes.addContact, page: ()=>const AddContactView()),
    GetPage(name: AppRoutes.contactDetails, page: ()=>const ContactDetailView()),
    GetPage(name: AppRoutes.recordCall, page: ()=>const RecordCallView()),
    GetPage(name: AppRoutes.callLogs, page: ()=>const CallLogView()),
  ];
}