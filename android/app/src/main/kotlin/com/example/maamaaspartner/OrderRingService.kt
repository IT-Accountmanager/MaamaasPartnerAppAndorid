

package com.maamaas.partner

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
        private const val RING_DURATION = 20_000L
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

    private var wakeLock: PowerManager.WakeLock? = null
    private var previousAlarmVolume: Int = -1

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "✅ OrderRingService created")
        acquireWakeLock()
        boostAlarmVolume()
        createNotificationChannel()
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
            wakeLock?.acquire(RING_DURATION + 5_000L)
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

            Log.d(TAG, "🔈 Alarm stream: $previousAlarmVolume / $maxVolume")

            if (previousAlarmVolume < maxVolume) {
                am.setStreamVolume(
                    AudioManager.STREAM_ALARM,
                    maxVolume,
                    0
                )
                Log.d(TAG, "🔊 Alarm volume boosted to MAX")
            }

            // Also ensure media volume is up (fallback)
            val mediaVol = am.getStreamVolume(AudioManager.STREAM_MUSIC)
            val maxMediaVol = am.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
            Log.d(TAG, "🎵 Media stream: $mediaVol / $maxMediaVol")

        } catch (e: Exception) {
            Log.e(TAG, "⚠️ Failed to boost volume", e)
        }
    }

    private fun restoreAlarmVolume() {
        try {
            if (previousAlarmVolume >= 0) {
                val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                am.setStreamVolume(AudioManager.STREAM_ALARM, previousAlarmVolume, 0)
                Log.d(TAG, "🔉 Alarm volume restored to $previousAlarmVolume")
            }
        } catch (e: Exception) {
            Log.e(TAG, "⚠️ Failed to restore volume", e)
        }
        previousAlarmVolume = -1
    }

    private fun startOrderSound() {
        Log.d(TAG, "🔊 Starting order ringtone")

        try {
            stopOrderSound()

            val player = MediaPlayer()
            mediaPlayer = player

            // Try to get the resource
            val resourceId = resources.getIdentifier(
                "zomato_order_ringtones",
                "raw",
                packageName
            )

            Log.d(TAG, "📁 Resource ID: $resourceId")

            if (resourceId == 0) {
                Log.e(TAG, "❌ Ringtone resource NOT FOUND!")
                Log.e(TAG, "❌ Check: android/app/src/main/res/raw/zomato_order_ringtone.mp3")
                stopSelf()
                return
            }

            val afd = resources.openRawResourceFd(resourceId)

            if (afd == null) {
                Log.e(TAG, "❌ Failed to open resource file descriptor")
                stopSelf()
                return
            }

            player.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
            afd.close()

            Log.d(TAG, "✅ Audio data source set")

            // Try ALARM stream first
            player.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            Log.d(TAG, "🎵 Audio attributes set to ALARM")

            // Explicitly set volume to max
            player.setVolume(1.0f, 1.0f)
            Log.d(TAG, "🔊 Volume set to MAX")

            player.isLooping = true

            player.setOnPreparedListener {
                try {
                    Log.d(TAG, "🎵 MediaPlayer PREPARED")
                    it.start()
                    Log.d(TAG, "🔔🔔🔔 ORDER RINGTONE STARTED 🔔🔔🔔")
                    scheduleStop()
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Failed to start MediaPlayer", e)
                    stopSelf()
                }
            }

            player.setOnErrorListener { _, what, extra ->
                Log.e(TAG, "❌ MediaPlayer ERROR: what=$what, extra=$extra")

                // Try fallback with MUSIC stream
                try {
                    Log.d(TAG, "🔄 Trying fallback with MUSIC stream")
                    player.setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .build()
                    )
                    player.prepareAsync()
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Fallback also failed", e)
                    stopOrderSound()
                    stopSelf()
                }
                true
            }

            player.prepareAsync()
            Log.d(TAG, "⏳ MediaPlayer preparing...")

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error while playing ringtone", e)
            e.printStackTrace()
            stopOrderSound()
            stopSelf()
        }
    }

    private fun scheduleStop() {
        stopHandler?.removeCallbacksAndMessages(null)
        stopHandler = Handler(Looper.getMainLooper())
        stopRunnable = Runnable {
            Log.d(TAG, "⏰ 20 seconds completed - stopping ringtone")
            stopOrderSound()
            stopSelf()
        }
        stopHandler?.postDelayed(stopRunnable!!, RING_DURATION)
        Log.d(TAG, "⏰ Auto-stop scheduled in ${RING_DURATION/1000} seconds")
    }

    private fun stopOrderSound() {
        try {
            stopHandler?.removeCallbacksAndMessages(null)
            stopHandler = null
            stopRunnable = null

            mediaPlayer?.let { player ->
                try {
                    if (player.isPlaying) {
                        player.stop()
                        Log.d(TAG, "🔇 Player stopped")
                    }
                } catch (_: Exception) {}
                try {
                    player.reset()
                } catch (_: Exception) {}
                try {
                    player.release()
                    Log.d(TAG, "🔇 Player released")
                } catch (_: Exception) {}
            }
            mediaPlayer = null
            Log.d(TAG, "🔇 Ringtone fully stopped")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error stopping ringtone", e)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // Check if channel already exists
            val channel = manager.getNotificationChannel(CHANNEL_ID)
            if (channel != null) {
                Log.d(TAG, "✅ Channel already exists: ${channel.id}")
                return
            }

            val newChannel = NotificationChannel(
                CHANNEL_ID,
                "Vendor Order Ring",
                NotificationManager.IMPORTANCE_HIGH
            )
            newChannel.description = "New vendor order ringtone"
            // DO NOT set sound to null
            newChannel.enableVibration(true)
            newChannel.enableLights(true)

            manager.createNotificationChannel(newChannel)
            Log.d(TAG, "✅ Notification channel created: $CHANNEL_ID")
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









