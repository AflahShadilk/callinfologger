import 'package:callinfologger/app/views/calls/call_log_view.dart';
import 'package:callinfologger/app/views/calls/record_call_view.dart';
import 'package:callinfologger/app/views/contacts/contact_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final RxInt selectedIndex = 0.obs;

    final List<Widget> pages = const [
      ContactView(),
      CallLogView(),
      RecordCallView(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: selectedIndex.value,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex.value,
          onDestinationSelected: (i) => selectedIndex.value = i,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.contacts_outlined),
              selectedIcon: Icon(Icons.contacts),
              label: 'Contacts',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'Call Logs',
            ),
            NavigationDestination(
              icon: Icon(Icons.mic_none_outlined),
              selectedIcon: Icon(Icons.mic),
              label: 'Record',
            ),
          ],
        ),
      ),
    );
  }
}