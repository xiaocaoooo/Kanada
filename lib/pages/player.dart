import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada_volume/kanada_volume.dart';
import '../../global.dart';
import '../metadata.dart';

class PlayerPage extends StatefulWidget {
  static final GlobalKey pictureKey = GlobalKey();

  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  static const double width = 350;
  static const double iconSize = 64;
  String? path;
  Metadata? metadata;
  StreamSubscription<int?>? _currentIndexSub;
  StreamSubscription<SequenceState?>? _sequenceSub;
  StreamSubscription<Duration>? _positionSub;
  Duration pos = Duration.zero;
  bool isDragging = false;
  double? volume;
  double maxVolume = 100;
  bool isDraggingVolume = false;

  @override
  void initState() {
    super.initState();
    _init();

    KanadaVolumePlugin.getMaxVolume().then((value) {
      maxVolume = value?.toDouble() ?? 100;
      if (mounted) setState(() {});
    });

    // 监听 currentIndex 变化
    _currentIndexSub = Global.player.currentIndexStream.listen((index) {
      _fresh();
    });

    // 监听播放列表元数据变化（包括 setAudioSource）
    _sequenceSub = Global.player.sequenceStateStream.listen((state) {
      if (state?.currentIndex != null) {
        _fresh(); // 主动刷新
      }
    });

    // 初始化位置监听
    _positionSub = Global.player.positionStream.listen((position) {
      if (!isDragging) pos = position;
      if (!isDraggingVolume) {
        KanadaVolumePlugin.getVolume().then((value) {
          volume = value?.toDouble();
          if (mounted) setState(() {});
        });
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _currentIndexSub?.cancel();
    _sequenceSub?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    _fresh();
  }

  Future<void> _fresh() async {
    final playlist = Global.player.audioSource;
    final currentIndex = Global.player.currentIndex;

    // 防御性检查：确保播放列表和索引有效
    if (playlist is! ConcatenatingAudioSource ||
        currentIndex == null ||
        currentIndex >= playlist.children.length) {
      return;
    }

    dynamic current = playlist.children[currentIndex];
    final MediaItem tag =current.tag;
    // 获取新路径
    final newPath = tag.id;

    // 路径未变化时跳过
    if (newPath == metadata?.path) return;

    // 更新元数据
    path = newPath;
    metadata = Metadata(path!);

    metadata!.title = tag.title;
    metadata!.artist = tag.artist;
    metadata!.album = tag.album;
    metadata!.duration = tag.duration;
    metadata!.picturePath = tag.extras?['picture'] as String?;

    // 并行加载元数据（带缓存）
    await Future.wait([metadata!.getMetadata(), metadata!.getPicture()]);
    if (mounted) setState(() {});

    // 并行加载最新数据（无缓存）
    await Future.wait([
      metadata!.getMetadata(cache: false),
      metadata!.getPicture(cache: false),
    ]);
    if (mounted) setState(() {});
    Global.pictureCache = metadata!.picturePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Picture
            SizedBox(
              width: width,
              height: width,
              child: Center(
                child: Card(
                  elevation: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    key: PlayerPage.pictureKey,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: width * (Global.player.playing ? 1 : 0.8),
                      height: width * (Global.player.playing ? 1 : 0.8),
                      child:
                          metadata?.picture != null
                              ? Image.memory(metadata!.picture!)
                              : (metadata?.pictureCache != null
                                  ? Image.file(File(metadata!.pictureCache!))
                                  : (Global.pictureCache != null
                                      ? Image.file(File(Global.pictureCache!))
                                      : Icon(Icons.music_note))),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            // Title and Artist
            SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metadata?.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    metadata?.artist ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: .6),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Slider
            SizedBox(
              width: width,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: SliderComponentShape.noThumb,
                  // 完全移除滑块
                  overlayShape: SliderComponentShape.noOverlay,
                  // 完全移除覆盖层
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: .2),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: pos.inMilliseconds.toDouble(),
                  max: Global.player.duration?.inMilliseconds.toDouble() ?? 1,
                  onChangeStart: (value) {
                    isDragging = true;
                  },
                  onChanged: (value) {
                    pos = Duration(milliseconds: value.toInt());
                    if (mounted) setState(() {});
                  },
                  onChangeEnd: (value) {
                    Global.player.seek(Duration(milliseconds: value.toInt()));
                    isDragging = false;
                  },
                ),
              ),
            ),
            SizedBox(height: 8),
            // Time
            SizedBox(
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${Global.player.position.inMinutes.toString().padLeft(2, '0')}:${Global.player.position.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: .6),
                    ),
                  ),
                  Text(
                    '${Global.player.duration?.inMinutes.toString().padLeft(2, '0')}:${Global.player.duration?.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: .6),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous, size: iconSize),
                  onPressed:
                      Global.player.hasPrevious
                          ? Global.player.seekToPrevious
                          : null,
                ),
                IconButton(
                  icon: Icon(
                    Global.player.playing ? Icons.pause : Icons.play_arrow,
                    size: iconSize,
                  ),
                  onPressed:
                      Global.player.playing
                          ? Global.player.pause
                          : Global.player.play,
                ),
                IconButton(
                  icon: Icon(Icons.skip_next, size: iconSize),
                  onPressed:
                      Global.player.hasNext ? Global.player.seekToNext : null,
                ),
              ],
            ),
            SizedBox(height: 24),
            //   Volume
            SizedBox(
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volume_down, size: iconSize / 2),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: SliderComponentShape.noThumb,
                        overlayShape: SliderComponentShape.noOverlay,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        inactiveTrackColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: .2),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: volume?.toDouble() ?? 100,
                        max: maxVolume,
                        onChangeStart: (value) {
                          isDraggingVolume = true;
                        },
                        onChanged: (value) {
                          volume = value;
                          KanadaVolumePlugin.setVolume(value.toInt());
                          if (mounted) setState(() {});
                        },
                        onChangeEnd: (value) {
                          isDraggingVolume = false;
                          KanadaVolumePlugin.setVolume(value.toInt());
                        },
                      ),
                    ),
                  ),
                  Icon(Icons.volume_up, size: iconSize / 2),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
