
package com.example.maamaaspartner

import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {

    companion object {
        private const val TAG = "MyFirebaseMessagingService"
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        Log.d(TAG, "══════════════════════════════════════")
        Log.d(TAG, "📩 FCM MESSAGE RECEIVED")
        Log.d(TAG, "📦 Message ID = ${remoteMessage.messageId}")
        Log.d(TAG, "📦 DATA = ${remoteMessage.data}")

        val data = remoteMessage.data

        if (data.isEmpty()) {
            Log.d(TAG, "⚠️ FCM message contains no data")
            Log.d(TAG, "══════════════════════════════════════")
            return
        }

        val eventType = data["eventType"] ?: ""
        val notificationType = data["notificationType"] ?: ""
        val orderId = data["orderId"] ?: ""
        val vendorId = data["vendorId"] ?: ""
        val amount = data["amount"] ?: ""

        Log.d(TAG, "➡️ eventType = $eventType")
        Log.d(TAG, "➡️ notificationType = $notificationType")
        Log.d(TAG, "➡️ orderId = $orderId")
        Log.d(TAG, "➡️ vendorId = $vendorId")
        Log.d(TAG, "➡️ amount = $amount")

        val isNewOrder =
            eventType == "VENDOR_NEW_ORDER" && notificationType == "VENDOR_ORDER"

        Log.d(TAG, "🔍 isNewOrder = $isNewOrder")

        if (!isNewOrder) {
            Log.d(TAG, "ℹ️ Not a vendor new-order event. Ringtone will NOT start.")
            Log.d(TAG, "══════════════════════════════════════")
            return
        }

        Log.d(TAG, "🚨🚨 NEW ORDER DETECTED — Order #$orderId, Vendor #$vendorId, ₹$amount")
        Log.d(TAG, "🔊 Starting OrderRingService...")

        try {
            OrderRingService.start(this)
            Log.d(TAG, "✅ OrderRingService.start() requested")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to start OrderRingService", e)
        }

        Log.d(TAG, "══════════════════════════════════════")
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d(TAG, "🔥 FCM token refreshed. Length=${token.length}")
        // TODO: send the refreshed token to your backend here so pushes
        // keep reaching this device (e.g. via your ApiClient).
    }
}