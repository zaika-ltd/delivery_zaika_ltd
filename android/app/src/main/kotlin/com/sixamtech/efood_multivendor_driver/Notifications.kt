package com.zaika.delivery

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.media.AudioAttributes
import androidx.core.app.NotificationCompat

object Notifications {
    const val NOTIFICATION_ID_BACKGROUND_SERVICE = 1
    private const val CHANNEL_ID_BACKGROUND_SERVICE = "background_service"

    // 🔹 New channel for FCM push notifications
    const val CHANNEL_ID_DELIVERY = "zaika_delivery_partner"

    fun createNotificationChannels(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // Background Service channel
            val serviceChannel = NotificationChannel(
                CHANNEL_ID_BACKGROUND_SERVICE,
                "Background Service",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            manager.createNotificationChannel(serviceChannel)

            // 🔹 Custom sound setup
            val soundUri =
                android.net.Uri.parse("android.resource://" + context.packageName + "/" + R.raw.notification)

            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()

            // 🔹 Delivery FCM channel
            val deliveryChannel = NotificationChannel(
                CHANNEL_ID_DELIVERY,
                "Zaika Delivery Orders",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for Zaika Delivery app"
                setSound(soundUri, audioAttributes)
            }
            manager.createNotificationChannel(deliveryChannel)
        }
    }

    fun buildForegroundNotification(context: Context): Notification {
        return NotificationCompat
            .Builder(context, CHANNEL_ID_BACKGROUND_SERVICE)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Background Service")
            .setContentText("Keeps app process on foreground.")
            .build()
    }
}
