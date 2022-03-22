package com.nebuia.nebuia_plugin.delegate

import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import com.distbit.nebuia_plugin.NebuIA
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import android.R.attr.bitmap
import android.R.attr.bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapFactory.*
import com.distbit.nebuia_plugin.model.Side
import com.distbit.nebuia_plugin.model.ui.Theme
import java.nio.ByteBuffer
import android.R.attr.bitmap
import com.distbit.nebuia_plugin.model.Fingers
import java.io.ByteArrayOutputStream


class ActivityDelegate internal constructor(
        private val activity: Activity
) : PluginRegistry.ActivityResultListener {

    private var nebuIA: NebuIA = NebuIA(this.activity)

    init {
        NebuIA.theme = Theme(
                primaryColor = 0xff2886de.toInt(),
                secondaryColor = 0xffffffff.toInt(),
                primaryTextButtonColor = 0xffffffff.toInt(),
                secondaryTextButtonColor = 0xff904afa.toInt(),
                //boldFont = ResourcesCompat.getFont(this, R.font.gilroy_bold),
                //normalFont = ResourcesCompat.getFont(this, R.font.gilroy_medium),
                //thinFont = ResourcesCompat.getFont(this, R.font.gilroy_light)
        )
    }

    fun setClientURI(uri: String) {
        nebuIA.setClientURI(uri)
    }

    fun setReport(report: String) {
        nebuIA.setReport(report)
    }

    fun setTemporalCode(code: String) {
        nebuIA.setTemporalCode(code)
    }

    fun createReport(result: MethodChannel.Result) {
        nebuIA.createReport {
            result.success(it)
        }
    }

    fun faceLiveDetection(result: MethodChannel.Result) {
        var response = false
        nebuIA.faceLiveDetection {
            if(!response) {
                result.success(true)
                response = true
            }
        }
    }

    fun fingerDetection(hand: Int, result: MethodChannel.Result) {
        nebuIA.fingerDetection(hand, onFingerDetectionComplete = { index, middle, ring, little: Fingers ->
            val fingers:HashMap<String, HashMap<String, Any>> = HashMap()
            fingers["index"] = hashMapOf(
                    "score" to index.score,
                    "image" to index.image.convertToByteArray()
            )
            fingers["middle"] = hashMapOf(
                    "score" to middle.score,
                    "image" to middle.image.convertToByteArray()
            )
            fingers["ring"] = hashMapOf(
                    "score" to ring.score,
                    "image" to ring.image.convertToByteArray()
            )
            fingers["little"] = hashMapOf(
                    "score" to little.score,
                    "image" to little.image.convertToByteArray()
            )
            result.success(fingers)
        }, onSkip = {
            result.success("skip")
        })
    }

    fun generateWSQFingerprint(image: ByteArray, result: MethodChannel.Result) {
        nebuIA.generateWSQFingerprint(image.toBitMap()) {
            result.success(it)
        }
    }

    fun recordActivity(text: ArrayList<String>, result: MethodChannel.Result) {
        nebuIA.recordActivity(text) {
            result.success(it.absolutePath)
        }
    }

    fun documentDetection(result: MethodChannel.Result) {
        nebuIA.documentDetection(onIDComplete = {
            result.success(true)
        }, onIDError = {
            result.success(false)
        })
    }

    fun captureAddressProof(result: MethodChannel.Result) {
        nebuIA.captureAddress {
            result.success(it)
        }
    }

    fun saveAddress(address: String, result: MethodChannel.Result) {
        nebuIA.saveAddress(address) {
            result.success(it)
        }
    }

    fun saveEmail(email: String, result: MethodChannel.Result) {
        nebuIA.saveEmail(email) {
            result.success(it)
        }
    }

    fun savePhone(phone: String, result: MethodChannel.Result) {
        nebuIA.saveEmail(phone) {
            result.success(it)
        }
    }

    fun generateOTPEmail(result: MethodChannel.Result) {
        nebuIA.generateOTPEmail{
            result.success(it)
        }
    }

    fun generateOTPPhone(result: MethodChannel.Result) {
        nebuIA.generateOTPPhone{
            result.success(it)
        }
    }

    fun verifyOTPEmail(code: String, result: MethodChannel.Result) {
        nebuIA.verifyOTPEmail(code) {
            result.success(it)
        }
    }

    fun verifyOTPPhone(code: String, result: MethodChannel.Result) {
        nebuIA.verifyOTPPhone(code) {
            result.success(it)
        }
    }

    fun getFaceImage(result: MethodChannel.Result) {
        nebuIA.getFaceImage {
            if(it != null)
                result.success(it.convertToByteArray())
            else result.error("not face found", null, null)
        }
    }

    fun getIDFrontImage(result: MethodChannel.Result) {
        nebuIA.getIDImage(side = Side.FRONT) {
            if(it != null)
                result.success(it.convertToByteArray())
            else result.error("not image found", null, null)
        }
    }

    fun getIDBackImage(result: MethodChannel.Result) {
        nebuIA.getIDImage(side = Side.BACK) {
            if(it != null)
                result.success(it.convertToByteArray())
            else result.error("not image found", null, null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return true
    }

    private fun Bitmap.convertToByteArray(): ByteArray {
        val stream = ByteArrayOutputStream()
        this.compress(Bitmap.CompressFormat.JPEG, 100, stream)
        val byteArray: ByteArray = stream.toByteArray()
        this.recycle()
        return byteArray
    }

    private fun ByteArray.toBitMap(): Bitmap {
        return decodeByteArray(this, 0, this.size)
    }

}