import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada/pages/app.dart';
import 'package:kanada/pages/folders.dart';
import 'package:kanada/pages/home.dart';
import 'package:kanada/pages/more.dart';
import 'package:kanada/pages/more/debug.dart';
import 'package:kanada/pages/more/debug/color_diffusion.dart';
import 'package:kanada/pages/more/debug/current_lyric.dart';
import 'package:kanada/pages/more/debug/file_choose.dart';
import 'package:kanada/pages/more/debug/link.dart';
import 'package:kanada/pages/more/debug/lyric.dart';
import 'package:kanada/pages/more/debug/lyric_sender.dart';
import 'package:kanada/pages/more/debug/pick_color.dart';
import 'package:kanada/pages/more/debug/player.dart';
import 'package:kanada/pages/more/debug/toast.dart';
import 'package:kanada/pages/more/settings.dart';
import 'package:kanada/pages/more/settings/folders.dart';
import 'package:kanada/pages/playing.dart';
import 'package:kanada/pages/search.dart';

import 'metadata.dart';

class Global {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const AppPage(),
    '/home': (context) => const HomePage(),
    '/search': (context) => const SearchPage(),
    '/folders': (context) => const FoldersPage(),
    '/more': (context) => const MorePage(),
    '/more/debug': (context) => const DebugPage(),
    '/more/debug/link': (context) => const LinkDebug(),
    '/more/debug/player': (context) => const PlayerDebug(),
    '/more/debug/toast': (context) => const ToastDebug(),
    '/more/debug/file_choose': (context) => const FileChooseDebug(),
    '/more/debug/lyric_sender': (context) => const LyricSenderDebug(),
    '/more/debug/lyric': (context) => const LyricDebug(),
    '/more/debug/pick_color': (context) => const PickColorDebug(),
    '/more/debug/color_diffusion': (context) => const ColorDiffusionDebug(),
    '/more/debug/current_lyric': (context) => const CurrentLyricDebug(),
    '/more/settings': (context) => const SettingsPage(),
    '/more/settings/folders': (context) => const FoldersSettings(),
    '/player': (context) => const PlayingPage(),
  };
  static late AudioPlayer player;
  static bool init = false;
  static String path = '';
  static List<String> playlist = [];
  static Metadata? metadataCache;
  static ThemeData playerTheme = ThemeData();
  static bool lyricSenderInit = false;
}
