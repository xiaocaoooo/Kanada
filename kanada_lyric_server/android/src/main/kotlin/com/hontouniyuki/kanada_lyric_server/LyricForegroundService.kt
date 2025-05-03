package com.hontouniyuki.kanada_lyric_server

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import android.util.Log

class LyricForegroundService : Service() {
  private lateinit var flutterEngine: FlutterEngine
  private lateinit var methodChannel: MethodChannel
  private val channelId = "com.hontouniyuki.kanada.channel.lyric"
  private val notificationId = 12345
  private var periodicJob: Job? = null

  override fun onBind(intent: Intent?): IBinder? = null

  override fun onCreate() {
    super.onCreate()
    Log.i("LyricForegroundService", "Miraiku LyricForegroundService onCreate")
    // 初始化Flutter引擎
    flutterEngine = FlutterEngine(this)
    flutterEngine.dartExecutor.executeDartEntrypoint(
      DartExecutor.DartEntrypoint.createDefault()
    )
    // 初始化通信通道
    methodChannel = MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      "kanada_lyric_server/background"
    )
    // 创建通知并启动前台服务
    createNotificationChannel()
    startForeground(notificationId, createNotification())
    // 启动定时任务（每隔0.1秒触发）
    startPeriodicTask()
  }

  private fun createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val channel = NotificationChannel(
        channelId,
        "歌词服务通道",
        NotificationManager.IMPORTANCE_LOW
      )
      val manager = getSystemService(NotificationManager::class.java)
      manager.createNotificationChannel(channel)
    }
  }

  private fun createNotification(): Notification {
    return NotificationCompat.Builder(this, channelId)
      .setContentTitle("歌词服务运行中")
      .setContentText("正在同步歌词...")
      .setSmallIcon(android.R.drawable.ic_media_play) // 替换为你的通知图标
      .setPriority(NotificationCompat.PRIORITY_LOW)
      .build()
  }

  private fun startPeriodicTask() {
    val scope = CoroutineScope(Dispatchers.Default)
    periodicJob = scope.launch {
      while (isActive) {
        Log.i("LyricForegroundService", "Miraiku Periodic task running")
        // 发送消息到Flutter端
        withContext(Dispatchers.Main) {
          methodChannel.invokeMethod("onLyricUpdate", null)
        }
        delay(1000)
      }
    }
  }

  override fun onDestroy() {
    periodicJob?.cancel()
    flutterEngine.destroy()
    super.onDestroy()
  }
}