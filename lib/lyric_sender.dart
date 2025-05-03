import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada/global.dart';
import 'package:kanada/lyric.dart';
import 'package:kanada_lyric_sender/kanada_lyric_sender.dart';

import 'metadata.dart';

Future<void> sendLyrics() async {
  print('Miraiku sendLyrics');
  // KanadaLyricSenderPlugin.sendLyric(
  //   DateTime.now().toIso8601String(),
  //   1000,
  // );
  print('Mriaiku Global.player.playing ${Global.player.playing}');
  print('Mriaiku Global.playlist ${Global.playlist}');
  // if (!Global.player.playing) return;
  final playlist = Global.player.audioSource;
  final currentIndex = Global.player.currentIndex;

  // 防御性检查：确保播放列表和索引有效
  if (playlist is! ConcatenatingAudioSource ||
      currentIndex == null ||
      currentIndex >= playlist.children.length) {
    return;
  }
  dynamic current = playlist.children[currentIndex];
  final MediaItem tag = current.tag;
  final path = tag.id;
  print('Miraiku path $path');
  final position = Global.player.position;
  final metadata = Metadata(path);
  metadata.getLyric();
  if (metadata.lyric != null) {
    final lyric = metadata.lyric!;
    final lyrics = Lyrics(lyric);
    await lyrics.parse();
    for (var l in lyrics.lyrics) {
      if (l["startTime"] <= position.inMilliseconds &&
          l["endTime"] >= position.inMilliseconds) {
        print('Miraiku sendLyric ${l["content"]}');
        KanadaLyricSenderPlugin.sendLyric(
          l["content"],
          l["endTime"] - l["startTime"],
        );
        break;
      }
    }
  }
}
