package comclearassist.clearassistapp

//import classes 
import android.telephony.SmsManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine

//The following class will allow communications between the application and Andorid and sends the SMS when SOS is pressed.

class MainActivity: FlutterActivity() {
    private val CHANNEL = "smsChannel" 
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendSms") {
                val phoneNumber = call.argument<String>("phoneNumber")
                val message = call.argument<String>("message")
                if (phoneNumber != null && message != null) {
                    sendSms(phoneNumber, message)
                    result.success("SMS Sent")
                } else {
                    result.error("INVALID_INPUT", "Phone number or message is empty", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun sendSms(phoneNumber: String, message: String) {
        val smsManager = SmsManager.getDefault()
        smsManager.sendTextMessage(phoneNumber, null, message, null, null)
    }
}