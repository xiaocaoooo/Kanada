import 'package:flutter/material.dart';
import '../settings.dart';
import '../widgets/link_list.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    List<List<dynamic>> settings = <List<dynamic>>[
      [Icons.settings, 'Settings', '/more/settings'],
      [Icons.file_copy, 'Cache', '/more/cache'],
      if (Settings.debug) [Icons.bug_report, 'Debug', '/more/debug'],
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: LinkList(links: settings, onTapAfter: () => setState(() {})),
    );
  }
}
