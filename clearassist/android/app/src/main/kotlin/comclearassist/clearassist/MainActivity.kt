package comclearassist.clearassistapp

//import classes 
import android.provider.ContactsContract
import android.telephony.SmsManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private val CHANNEL = "smsChannel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSms" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")
                    if (!phoneNumber.isNullOrEmpty() && !message.isNullOrEmpty()) {
                        sendSms(phoneNumber, message)
                        result.success("SMS Sent")
                    } else {
                        result.error("INVALID_INPUT", "Phone number or message is empty", null)
                    }
                }
                "getEmergencyContacts" -> {
                    val emergencyContacts = getEmergencyContacts()
                    result.success(emergencyContacts)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun sendSms(phoneNumber: String, message: String) {
        val smsManager = SmsManager.getDefault()
        smsManager.sendTextMessage(phoneNumber, null, message, null, null)
    }

    private fun getEmergencyContacts(): List<String> {
        val emergencyContacts = mutableListOf<String>()
        val projection = arrayOf(
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
            ContactsContract.CommonDataKinds.Phone.NUMBER
        )

        val cursor = contentResolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            projection,
            null,
            null,
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME + " ASC"
        )

        cursor?.use {
            while (it.moveToNext()) {
                val name = it.getString(it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)) ?: ""
                val phoneNumber = it.getString(it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)) ?: ""

                if (name.contains("Emergency", ignoreCase = true)) {
                    emergencyContacts.add("$name: $phoneNumber")
                }
            }
        }
        return emergencyContacts
    }
}
