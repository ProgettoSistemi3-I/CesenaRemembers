package it.cesenaremembers.app

import android.content.Intent
import android.os.Build
import android.app.NotificationManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            TOUR_TRACKING_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startOrUpdate" -> {
                    try {
                        val arguments = call.arguments as? Map<*, *>
                            ?: throw IllegalArgumentException("Missing tour notification data")
                        val serviceIntent = Intent(this, TourTrackingService::class.java).apply {
                            action = TourTrackingService.ACTION_START_OR_UPDATE
                            putExtra(
                                TourTrackingService.EXTRA_TITLE,
                                arguments["notificationTitle"] as? String,
                            )
                            putExtra(
                                TourTrackingService.EXTRA_CHANNEL_NAME,
                                arguments["notificationChannelName"] as? String,
                            )
                            putExtra(
                                TourTrackingService.EXTRA_NEXT_STOP_LABEL,
                                arguments["nextStopLabel"] as? String,
                            )
                            putExtra(
                                TourTrackingService.EXTRA_ELAPSED_LABEL,
                                arguments["elapsedLabel"] as? String,
                            )
                            putExtra(
                                TourTrackingService.EXTRA_DISTANCE_LABEL,
                                arguments["distanceLabel"] as? String,
                            )
                            putExtra(
                                TourTrackingService.EXTRA_OPEN_LABEL,
                                arguments["openMapLabel"] as? String,
                            )
                            putExtra(
                                TourTrackingService.EXTRA_STOP_NAME,
                                arguments["stopName"] as? String,
                            )
                            putExtra(
                                TourTrackingService.EXTRA_STOP_LATITUDE,
                                (arguments["latitude"] as? Number)?.toDouble() ?: 0.0,
                            )
                            putExtra(
                                TourTrackingService.EXTRA_STOP_LONGITUDE,
                                (arguments["longitude"] as? Number)?.toDouble() ?: 0.0,
                            )
                            putExtra(
                                TourTrackingService.EXTRA_STARTED_AT,
                                (arguments["startedAtEpochMs"] as? Number)?.toLong()
                                    ?: System.currentTimeMillis(),
                            )
                        }

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(serviceIntent)
                        } else {
                            startService(serviceIntent)
                        }
                        result.success(null)
                    } catch (error: Exception) {
                        result.error(
                            "TOUR_SERVICE_START_FAILED",
                            error.message ?: "Unable to start the tour foreground service",
                            null,
                        )
                    }
                }

                "getStatus" -> {
                    val preferences = getSharedPreferences(
                        TourTrackingService.PREFERENCES_NAME,
                        MODE_PRIVATE,
                    )
                    val notificationsManager =
                        getSystemService(NOTIFICATION_SERVICE) as NotificationManager
                    val channelImportance = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        notificationsManager.getNotificationChannel("tour_tracking_v2")?.importance
                            ?: NotificationManager.IMPORTANCE_UNSPECIFIED
                    } else {
                        NotificationManager.IMPORTANCE_DEFAULT
                    }
                    val notificationsEnabled =
                        notificationsManager.areNotificationsEnabled() &&
                            channelImportance != NotificationManager.IMPORTANCE_NONE
                    result.success(
                        mapOf(
                            "isForeground" to preferences.getBoolean(
                                TourTrackingService.KEY_IS_FOREGROUND,
                                false,
                            ),
                            "lastError" to preferences.getString(
                                TourTrackingService.KEY_LAST_ERROR,
                                "",
                            ),
                            "notificationsVisible" to notificationsEnabled,
                            "channelImportance" to channelImportance,
                        ),
                    )
                }

                "stop" -> {
                    try {
                        getSharedPreferences(
                            TourTrackingService.PREFERENCES_NAME,
                            MODE_PRIVATE,
                        ).edit()
                            .putBoolean(TourTrackingService.KEY_ACTIVE, false)
                            .apply()
                        stopService(Intent(this, TourTrackingService::class.java))
                        result.success(null)
                    } catch (error: Exception) {
                        result.error(
                            "TOUR_SERVICE_STOP_FAILED",
                            error.message ?: "Unable to stop the tour foreground service",
                            null,
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    companion object {
        private const val TOUR_TRACKING_CHANNEL =
            "it.cesenaremembers.app/tour_tracking"
    }
}
