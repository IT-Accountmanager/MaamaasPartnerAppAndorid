


package com.example.maamaaspartner

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat

class OrderRingService : Service() {

    companion object {

        private const val TAG = "OrderRingService"

        private const val CHANNEL_ID = "vendor_order_ring_service_v2"
        private const val NOTIFICATION_ID = 9991

        // Ring for 15 seconds
        private const val RING_DURATION = 15_000L

        private var mediaPlayer: MediaPlayer? = null

        private var stopHandler: Handler? = null
        private var stopRunnable: Runnable? = null

        fun start(context: Context) {

            Log.d(TAG, "🚀 Starting OrderRingService")

            try {

                val intent = Intent(context, OrderRingService::class.java)

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    ContextCompat.startForegroundService(context, intent)
                } else {
                    context.startService(intent)
                }

            } catch (e: Exception) {
                Log.e(TAG, "❌ Failed to start OrderRingService", e)
            }
        }

        fun stop(context: Context) {

            Log.d(TAG, "🛑 Stopping OrderRingService")

            try {
                val intent = Intent(context, OrderRingService::class.java)
                context.stopService(intent)
            } catch (e: Exception) {
                Log.e(TAG, "❌ Failed to stop OrderRingService", e)
            }
        }
    }

    // Wake lock keeps the CPU alive long enough to prepare + start playback
    // even if the screen is off / device is dozing when the service is created.
    private var wakeLock: PowerManager.WakeLock? = null

    // The alarm stream is very commonly muted/low on test devices even though
    // the media/ringtone volume is fine — USAGE_ALARM plays through THIS
    // stream, not the ringtone stream, so we force it up while ringing.
    private var previousAlarmVolume: Int = -1

    override fun onCreate() {
        super.onCreate()

        Log.d(TAG, "✅ OrderRingService created")

        acquireWakeLock()
        boostAlarmVolume()
        createNotificationChannel()

        // IMPORTANT: startForeground must happen immediately (within a few
        // seconds of the service being created) or Android will kill it.
        startForeground(NOTIFICATION_ID, createForegroundNotification())

        Log.d(TAG, "✅ Foreground service started")

        startOrderSound()
    }

    private fun acquireWakeLock() {
        try {
            val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = pm.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "$TAG::RingWakeLock"
            )
            wakeLock?.acquire(RING_DURATION + 5_000L) // safety timeout
            Log.d(TAG, "🔓 Wake lock acquired")
        } catch (e: Exception) {
            Log.e(TAG, "⚠️ Failed to acquire wake lock", e)
        }
    }

    private fun releaseWakeLock() {
        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
                Log.d(TAG, "🔒 Wake lock released")
            }
        } catch (e: Exception) {
            Log.e(TAG, "⚠️ Failed to release wake lock", e)
        }
        wakeLock = null
    }

    private fun boostAlarmVolume() {
        try {
            val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            previousAlarmVolume = am.getStreamVolume(AudioManager.STREAM_ALARM)
            val maxVolume = am.getStreamMaxVolume(AudioManager.STREAM_ALARM)

            Log.d(TAG, "🔈 Alarm stream volume before boost = $previousAlarmVolume / $maxVolume")

            if (previousAlarmVolume < maxVolume) {
                am.setStreamVolume(
                    AudioManager.STREAM_ALARM,
                    maxVolume,
                    0 // no UI flags, don't show the volume slider to the vendor
                )
                Log.d(TAG, "🔊 Alarm stream volume boosted to max for ringing")
            }
        } catch (e: Exception) {
            Log.e(TAG, "⚠️ Failed to boost alarm volume", e)
        }
    }

    private fun restoreAlarmVolume() {
        try {
            if (previousAlarmVolume >= 0) {
                val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                am.setStreamVolume(AudioManager.STREAM_ALARM, previousAlarmVolume, 0)
                Log.d(TAG, "🔉 Alarm stream volume restored to $previousAlarmVolume")
            }
        } catch (e: Exception) {
            Log.e(TAG, "⚠️ Failed to restore alarm volume", e)
        }
        previousAlarmVolume = -1
    }

    private fun startOrderSound() {

        Log.d(TAG, "🔊 Starting order ringtone")

        try {
            stopOrderSound()

            val player = MediaPlayer()
            mediaPlayer = player

            val afd = resources.openRawResourceFd(R.raw.zomato_order_ringtone)

            if (afd == null) {
                Log.e(TAG, "❌ Ringtone resource not found (check res/raw/zomato_order_ringtone.mp3)")
                stopSelf()
                return
            }

            player.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
            afd.close()

            player.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )

            player.isLooping = true

            player.setOnPreparedListener {
                try {
                    Log.d(TAG, "🎵 MediaPlayer prepared")
                    it.start()
                    Log.d(TAG, "🔔 ORDER RINGTONE STARTED")
                    scheduleStop()
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Failed to start MediaPlayer", e)
                    stopSelf()
                }
            }

            player.setOnErrorListener { _, what, extra ->
                Log.e(TAG, "❌ MediaPlayer error what=$what extra=$extra")
                stopOrderSound()
                stopSelf()
                true
            }

            player.prepareAsync()

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error while playing ringtone", e)
            stopOrderSound()
            stopSelf()
        }
    }

    private fun scheduleStop() {

        stopHandler?.removeCallbacksAndMessages(null)
        stopHandler = Handler(Looper.getMainLooper())

        stopRunnable = Runnable {
            Log.d(TAG, "⏰ Ring duration completed")
            stopOrderSound()
            stopSelf()
        }

        stopHandler?.postDelayed(stopRunnable!!, RING_DURATION)
    }

    private fun stopOrderSound() {

        try {
            stopHandler?.removeCallbacksAndMessages(null)
            stopHandler = null
            stopRunnable = null

            mediaPlayer?.let { player ->
                try {
                    if (player.isPlaying) player.stop()
                } catch (_: Exception) {}
                try {
                    player.reset()
                } catch (_: Exception) {}
                try {
                    player.release()
                } catch (_: Exception) {}
            }

            mediaPlayer = null

            Log.d(TAG, "🔇 Ringtone stopped")

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error stopping ringtone", e)
        }
    }

    private fun createNotificationChannel() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            val channel = NotificationChannel(
                CHANNEL_ID,
                "Vendor Order Ring",
                NotificationManager.IMPORTANCE_HIGH
            )

            channel.description = "New vendor order ringtone"
            channel.setSound(null, null)
            channel.enableVibration(true)

            manager.createNotificationChannel(channel)

            Log.d(TAG, "✅ Order service notification channel created")
        }
    }

    private fun createForegroundNotification(): Notification {

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("🚚 New Order")
            .setContentText("You have received a new order")
            .setOngoing(true)
            .setAutoCancel(false)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .build()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "📩 OrderRingService onStartCommand")
        // If Android kills the service, don't automatically restart it
        // without a fresh FCM event.
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        Log.d(TAG, "🛑 OrderRingService destroyed")
        stopOrderSound()
        restoreAlarmVolume()
        releaseWakeLock()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}