package com.nebuia.nebuia_plugin

import android.app.Activity
import androidx.annotation.NonNull
import com.nebuia.nebuia_plugin.delegate.ActivityDelegate

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** NebuiaPlugin */
class NebuiaPlugin: MethodCallHandler, ActivityAware, FlutterPlugin {

  private lateinit var channel : MethodChannel
  private lateinit var plugin: ActivityDelegate
  private var activity: Activity? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "nebuia_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    plugin = ActivityDelegate(activity!!)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val data = (call.arguments as HashMap<String, Any>);
    when(call.method) {
      "setReport" -> {
        val report: String = data["report"] as String
        plugin.setReport(report)
        result.success(true)
      }
      "setClientURI" -> {
        val uri: String = data["uri"] as String
        plugin.setClientURI(uri)
        result.success(true)
      }
      "setTemporalCode" -> {
        val code: String = data["code"] as String
        plugin.setTemporalCode(code)
        result.success(true)
      }
      "createReport" -> plugin.createReport(result)
      "faceLiveDetection" -> {
        val showID: Boolean = data["showID"] as Boolean
        plugin.faceLiveDetection(showID, result)
      }
      "fingerDetection" -> {
        val hand: Int = data["hand"] as Int
        val quality: Double = data["quality"] as Double
        val skip: Boolean = data["skip"] as Boolean
        plugin.fingerDetection(hand, skip, quality, result)
      }
      "generateWSQFingerprint" -> {
        val image: ByteArray = data["image"] as ByteArray
        plugin.generateWSQFingerprint(image, result)
      }
      "recordActivity" -> {
        val text: ArrayList<String> = data["text"] as ArrayList<String>
        val getNameFromId: Boolean = data["getNameFromId"] as Boolean
        plugin.recordActivity(text, getNameFromId, result)
      }
      "documentDetection" -> plugin.documentDetection(result)
      "captureAddressProof" -> plugin.captureAddressProof(result)
      "saveAddress" -> {
        val address: String = data["address"] as String
        plugin.saveAddress(address, result)
      }
      "saveEmail" -> {
        val email: String = data["email"] as String
        plugin.saveEmail(email, result)
      }
      "savePhone" -> {
        val phone: String = data["phone"] as String
        plugin.savePhone(phone, result)
      }
      "generateOTPEmail" -> plugin.generateOTPEmail(result)
      "generateOTPPhone" -> plugin.generateOTPPhone(result)
      "verifyOTPEmail" -> {
        val code: String = data["code"] as String
        plugin.verifyOTPEmail(code, result)
      }
      "verifyOTPPhone" -> {
        val code: String = data["code"] as String
        plugin.verifyOTPPhone(code, result)
      }
      "getFaceImage" -> plugin.getFaceImage(result)
      "getIDFrontImage" -> plugin.getIDFrontImage(result)
      "getIDBackImage" -> plugin.getIDBackImage(result)
      "getReportData" -> plugin.getReportData(result)
      else -> result.notImplemented()
    }
  }
}
