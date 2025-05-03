package com.hontouniyuki.kanada_lyric_server

import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import android.util.Log

class KanadaLyricServerPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private var applicationContext: Context? = null

  // 添加前台服务的控制逻辑
  private var foregroundServiceIntent: Intent? = null
  private var periodicJob: Job? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "kanada_lyric_server")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "startForegroundService" -> {
        Log.i("LyricForegroundService", "Miraiku startForegroundServiceKT")
        // 启动前台服务
        foregroundServiceIntent = Intent(applicationContext, LyricForegroundService::class.java)
        applicationContext?.startService(foregroundServiceIntent)
        result.success(true)
      }
      "stopForegroundService" -> {
        // 停止前台服务
        foregroundServiceIntent?.let {
          applicationContext?.stopService(it)
          periodicJob?.cancel() // 停止定时任务
        }
        result.success(true)
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    applicationContext = null
  }
}