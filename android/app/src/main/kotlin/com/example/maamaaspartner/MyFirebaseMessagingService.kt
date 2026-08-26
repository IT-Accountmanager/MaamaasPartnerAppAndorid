


package com.maamaas.partner

import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {

    companion object {
        private const val TAG = "MyFirebaseMessagingService"
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        Log.e(TAG, "========== FCM RECEIVED ==========")
        Log.e(TAG, "messageId = ${remoteMessage.messageId}")
        Log.e(TAG, "from = ${remoteMessage.from}")
        Log.e(TAG, "data = ${remoteMessage.data}")
        Log.e(TAG, "notification = ${remoteMessage.notification}")

        val data = remoteMessage.data

        if (data.isEmpty()) {
            Log.e(TAG, "❌ FCM data is empty")
            return
        }

        val eventType = data["eventType"] ?: ""
        val notificationType = data["notificationType"] ?: ""
        val orderId = data["orderId"] ?: ""
        val vendorId = data["vendorId"] ?: ""
        val amount = data["amount"] ?: ""

        Log.e(TAG, "eventType = $eventType")
        Log.e(TAG, "notificationType = $notificationType")
        Log.e(TAG, "orderId = $orderId")
        Log.e(TAG, "vendorId = $vendorId")
        Log.e(TAG, "amount = $amount")

        val isNewOrder =
            eventType == "VENDOR_NEW_ORDER" &&
                    notificationType == "VENDOR_ORDER"

        Log.e(TAG, "isNewOrder = $isNewOrder")

        if (!isNewOrder) {
            Log.e(TAG, "❌ Not a vendor new-order event")
            Log.e(TAG, "========== FCM PROCESSING COMPLETE ==========")
            return
        }

        Log.e(TAG, "🚨🚨 NEW ORDER DETECTED 🚨🚨")
        Log.e(TAG, "Order #$orderId")
        Log.e(TAG, "Vendor #$vendorId")
        Log.e(TAG, "Amount = ₹$amount")

        try {
            // Start the ring service
            OrderRingService.start(this)
            Log.e(TAG, "✅ OrderRingService.start() called successfully")
        } catch (e: Throwable) {
            Log.e(TAG, "❌ FAILED TO START OrderRingService", e)
        }

        Log.e(TAG, "========== FCM PROCESSING COMPLETE ==========")
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.e(TAG, "🔥 FCM TOKEN REFRESHED")
        Log.e(TAG, "Token length = ${token.length}")
        // Send token to backend
    }
}