package it.cesenaremembers.app

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.graphics.Typeface
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.style.StyleSpan
import android.util.Log
import java.util.Locale

/**
 * Keeps the user-started walking tour visible and tracks the current stop while
 * the Flutter activity is in the background. The tour itself is persisted by
 * TourSessionStore; this service independently maintains its notification and
 * latest distance if Android recreates the app process.
 */
class TourTrackingService : Service() {
    private lateinit var notificationManager: NotificationManager
    private lateinit var locationManager: LocationManager
    private val handler = Handler(Looper.getMainLooper())

    private var isForeground = false
    private var lastLocation: Location? = null
    private var locationUpdatesRequested = false

    private val notificationTicker = object : Runnable {
        override fun run() {
            if (!isTrackingActive()) return
            if (!hasLocationPermission()) {
                stopForMissingLocationPermission()
                return
            }
            updateOngoingNotification()
            handler.postDelayed(this, NOTIFICATION_REFRESH_MS)
        }
    }

    private val locationListener = object : LocationListener {
        override fun onLocationChanged(location: Location) {
            lastLocation = location
            persistLastLocation(location)
            updateOngoingNotification()
        }

        override fun onProviderEnabled(provider: String) {
            requestLocationUpdates()
        }

        override fun onProviderDisabled(provider: String) {
            updateOngoingNotification()
        }

        @Suppress("DEPRECATION")
        override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) = Unit
    }

    override fun onCreate() {
        super.onCreate()
        notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        lastLocation = restoreLastLocation()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            clearTrackingState()
            stopSelf()
            return START_NOT_STICKY
        }

        // START_STICKY may restart this service with a null Intent. Always
        // re-check permission before restoring a visible foreground session.
        if (!hasLocationPermission()) {
            stopForMissingLocationPermission()
            return START_NOT_STICKY
        }

        if (intent != null) {
            persistTrackingArguments(intent)
        }

        if (!isTrackingActive()) {
            stopSelf()
            return START_NOT_STICKY
        }

        // The localized channel name arrives with the first start/update request.
        try {
            createNotificationChannel()
            startOrUpdateForegroundNotification()
            requestLocationUpdates()
            handler.removeCallbacks(notificationTicker)
            handler.postDelayed(notificationTicker, NOTIFICATION_REFRESH_MS)
            trackingPreferences().edit()
                .putBoolean(KEY_IS_FOREGROUND, true)
                .putString(KEY_LAST_ERROR, "")
                .apply()
            Log.i(
                LOG_TAG,
                "Tour foreground service started; notificationsEnabled=${notificationManager.areNotificationsEnabled()}, " +
                    "channelImportance=${notificationChannelImportance()}",
            )
        } catch (error: Exception) {
            trackingPreferences().edit()
                .putBoolean(KEY_IS_FOREGROUND, false)
                .putString(KEY_LAST_ERROR, error.message ?: error.javaClass.simpleName)
                .apply()
            Log.e(LOG_TAG, "Unable to enter foreground for active tour", error)
            stopSelf()
            return START_NOT_STICKY
        }

        // Android may recreate this service after reclaiming the app process.
        // The notification and destination data are restored from native prefs.
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        handler.removeCallbacks(notificationTicker)
        stopLocationUpdates()
        if (!isTrackingActive()) {
            // An explicit stop/completion clears the cached coordinates too.
            trackingPreferences().edit().clear().apply()
            notificationManager.cancel(NOTIFICATION_ID)
        }
        if (isForeground) {
            removeForegroundNotification()
            isForeground = false
        }
        trackingPreferences().edit()
            .putBoolean(KEY_IS_FOREGROUND, false)
            .apply()
        super.onDestroy()
    }

    private fun persistTrackingArguments(intent: Intent) {
        val editor = trackingPreferences().edit()
            .putBoolean(KEY_ACTIVE, true)

        intent.getStringExtra(EXTRA_TITLE)?.let { editor.putString(KEY_TITLE, it) }
        intent.getStringExtra(EXTRA_CHANNEL_NAME)?.let {
            editor.putString(KEY_CHANNEL_NAME, it)
        }
        intent.getStringExtra(EXTRA_NEXT_STOP_LABEL)?.let {
            editor.putString(KEY_NEXT_STOP_LABEL, it)
        }
        intent.getStringExtra(EXTRA_ELAPSED_LABEL)?.let {
            editor.putString(KEY_ELAPSED_LABEL, it)
        }
        intent.getStringExtra(EXTRA_DISTANCE_LABEL)?.let {
            editor.putString(KEY_DISTANCE_LABEL, it)
        }
        intent.getStringExtra(EXTRA_OPEN_LABEL)?.let {
            editor.putString(KEY_OPEN_LABEL, it)
        }
        intent.getStringExtra(EXTRA_STOP_NAME)?.let {
            editor.putString(KEY_STOP_NAME, it)
        }
        if (intent.hasExtra(EXTRA_STOP_LATITUDE)) {
            editor.putFloat(
                KEY_STOP_LATITUDE,
                intent.getDoubleExtra(EXTRA_STOP_LATITUDE, 0.0).toFloat(),
            )
        }
        if (intent.hasExtra(EXTRA_STOP_LONGITUDE)) {
            editor.putFloat(
                KEY_STOP_LONGITUDE,
                intent.getDoubleExtra(EXTRA_STOP_LONGITUDE, 0.0).toFloat(),
            )
        }
        if (intent.hasExtra(EXTRA_LEG_STARTED_AT)) {
            editor.putLong(
                KEY_LEG_STARTED_AT,
                intent.getLongExtra(EXTRA_LEG_STARTED_AT, System.currentTimeMillis()),
            )
        }
        if (intent.hasExtra(EXTRA_ELAPSED_SECONDS)) {
            editor.putLong(
                KEY_ELAPSED_SECONDS,
                intent.getLongExtra(EXTRA_ELAPSED_SECONDS, 0L).coerceAtLeast(0L),
            )
        }
        if (intent.hasExtra(EXTRA_ELAPSED_RUNNING)) {
            editor.putBoolean(
                KEY_ELAPSED_RUNNING,
                intent.getBooleanExtra(EXTRA_ELAPSED_RUNNING, true),
            )
        }
        editor.apply()
    }

    private fun startOrUpdateForegroundNotification() {
        val notification = buildNotification()
        if (isForeground) {
            notificationManager.notify(NOTIFICATION_ID, notification)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
        isForeground = true
    }

    private fun updateOngoingNotification() {
        if (!isForeground || !isTrackingActive()) return
        notificationManager.notify(NOTIFICATION_ID, buildNotification())
    }

    private fun buildNotification(): Notification {
        val preferences = trackingPreferences()
        val nextStopLabel =
            preferences.getString(KEY_NEXT_STOP_LABEL, DEFAULT_NEXT_STOP_LABEL)
                ?: DEFAULT_NEXT_STOP_LABEL
        val elapsedLabel =
            preferences.getString(KEY_ELAPSED_LABEL, DEFAULT_ELAPSED_LABEL)
                ?: DEFAULT_ELAPSED_LABEL
        val distanceLabel =
            preferences.getString(KEY_DISTANCE_LABEL, DEFAULT_DISTANCE_LABEL)
                ?: DEFAULT_DISTANCE_LABEL
        val stopName = preferences.getString(KEY_STOP_NAME, "") ?: ""
        val displayedStopName = if (stopName.isBlank()) "—" else stopName
        val legStartedAt = preferences.getLong(
            KEY_LEG_STARTED_AT,
            System.currentTimeMillis(),
        )
        val elapsedRunning = preferences.getBoolean(KEY_ELAPSED_RUNNING, true)
        val elapsedSeconds = if (elapsedRunning) {
            ((System.currentTimeMillis() - legStartedAt) / 1000L).coerceAtLeast(0L)
        } else {
            preferences.getLong(KEY_ELAPSED_SECONDS, 0L).coerceAtLeast(0L)
        }
        val elapsedText = formatElapsed(elapsedSeconds)
        val distanceText = currentDistanceText(preferences)

        val metrics = SpannableStringBuilder().apply {
            appendBoldMetric(this, elapsedLabel, elapsedText)
            append("\n")
            appendBoldMetric(this, distanceLabel, distanceText)
        }

        val openAppIntent = packageManager.getLaunchIntentForPackage(packageName)
            ?.apply {
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
        val contentIntent = openAppIntent?.let {
            PendingIntent.getActivity(
                this,
                REQUEST_CODE_OPEN_APP,
                it,
                PendingIntent.FLAG_UPDATE_CURRENT or immutablePendingIntentFlag(),
            )
        }

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        // Use the platform template: MIUI 14 reliably displays it, unlike the
        // RemoteViews layout tested on this device. Android already shows the
        // app name in the notification header, so the content is kept focused.
        builder
            .setSmallIcon(R.drawable.ic_stat_notification)
            .setContentTitle(nextStopLabel)
            .setContentText(displayedStopName)
            .setStyle(
                Notification.BigTextStyle()
                    .setBigContentTitle(displayedStopName)
                    .bigText(metrics),
            )
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setCategory(Notification.CATEGORY_SERVICE)
            .setVisibility(Notification.VISIBILITY_PRIVATE)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setForegroundServiceBehavior(
                Notification.FOREGROUND_SERVICE_IMMEDIATE,
            )
        } else if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            @Suppress("DEPRECATION")
            builder.setPriority(Notification.PRIORITY_LOW)
        }

        if (contentIntent != null) {
            builder.setContentIntent(contentIntent)
        }

        return builder.build()
    }

    private fun appendBoldMetric(
        target: SpannableStringBuilder,
        label: String,
        value: String,
    ) {
        target.append(label).append(": ")
        val valueStart = target.length
        target.append(value)
        target.setSpan(
            StyleSpan(Typeface.BOLD),
            valueStart,
            target.length,
            Spannable.SPAN_EXCLUSIVE_EXCLUSIVE,
        )
    }

    private fun currentDistanceText(preferences: android.content.SharedPreferences): String {
        val targetLatitude = preferences.getFloat(KEY_STOP_LATITUDE, Float.NaN)
        val targetLongitude = preferences.getFloat(KEY_STOP_LONGITUDE, Float.NaN)
        val location = lastLocation
        if (targetLatitude.isNaN() || targetLongitude.isNaN() || location == null) {
            return "—"
        }

        val result = FloatArray(1)
        Location.distanceBetween(
            location.latitude,
            location.longitude,
            targetLatitude.toDouble(),
            targetLongitude.toDouble(),
            result,
        )
        val meters = result[0].toDouble().coerceAtLeast(0.0)
        return if (meters >= 1000.0) {
            String.format(Locale.getDefault(), "%.1f km", meters / 1000.0)
        } else {
            String.format(Locale.getDefault(), "%.0f m", meters)
        }
    }

    private fun formatElapsed(seconds: Long): String {
        val hours = seconds / 3600L
        val minutes = (seconds % 3600L) / 60L
        val remainingSeconds = seconds % 60L
        return if (hours > 0L) {
            String.format(
                Locale.getDefault(),
                "%d:%02d:%02d",
                hours,
                minutes,
                remainingSeconds,
            )
        } else {
            String.format(
                Locale.getDefault(),
                "%02d:%02d",
                minutes,
                remainingSeconds,
            )
        }
    }

    private fun hasLocationPermission(): Boolean {
        val hasFinePermission = checkCallingOrSelfPermission(
            Manifest.permission.ACCESS_FINE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED
        val hasCoarsePermission = checkCallingOrSelfPermission(
            Manifest.permission.ACCESS_COARSE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED
        return hasFinePermission || hasCoarsePermission
    }

    private fun stopForMissingLocationPermission() {
        Log.i(LOG_TAG, "Stopping tour service because location permission is unavailable")
        clearTrackingState()
        stopSelf()
    }

    private fun requestLocationUpdates() {
        if (locationUpdatesRequested) return
        if (!hasLocationPermission()) {
            stopForMissingLocationPermission()
            return
        }

        val hasFinePermission = checkCallingOrSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED
        val hasCoarsePermission = checkCallingOrSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED

        val providers = if (hasFinePermission) {
            listOf(LocationManager.GPS_PROVIDER, LocationManager.NETWORK_PROVIDER)
        } else {
            listOf(LocationManager.NETWORK_PROVIDER)
        }

        var requested = false
        for (provider in providers) {
            try {
                if (!locationManager.isProviderEnabled(provider)) continue
                locationManager.requestLocationUpdates(
                    provider,
                    LOCATION_UPDATE_INTERVAL_MS,
                    LOCATION_UPDATE_DISTANCE_METERS,
                    locationListener,
                    Looper.getMainLooper(),
                )
                requested = true
            } catch (_: SecurityException) {
                // Permission can be revoked while the activity is in background.
            } catch (_: IllegalArgumentException) {
                // Some devices do not expose one of the location providers.
            }
        }
        locationUpdatesRequested = requested
    }

    private fun stopLocationUpdates() {
        if (!locationUpdatesRequested) return
        try {
            locationManager.removeUpdates(locationListener)
        } catch (_: SecurityException) {
            // The user may have revoked location permission.
        }
        locationUpdatesRequested = false
    }

    private fun persistLastLocation(location: Location) {
        trackingPreferences().edit()
            .putBoolean(KEY_HAS_LOCATION, true)
            .putFloat(KEY_LAST_LATITUDE, location.latitude.toFloat())
            .putFloat(KEY_LAST_LONGITUDE, location.longitude.toFloat())
            .apply()
    }

    private fun restoreLastLocation(): Location? {
        val preferences = trackingPreferences()
        if (!preferences.getBoolean(KEY_HAS_LOCATION, false)) return null
        val latitude = preferences.getFloat(KEY_LAST_LATITUDE, Float.NaN)
        val longitude = preferences.getFloat(KEY_LAST_LONGITUDE, Float.NaN)
        if (latitude.isNaN() || longitude.isNaN()) return null
        return Location("persisted-tour-location").apply {
            this.latitude = latitude.toDouble()
            this.longitude = longitude.toDouble()
        }
    }

    private fun notificationChannelImportance(): Int {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return NotificationManager.IMPORTANCE_DEFAULT
        }
        return notificationManager.getNotificationChannel(CHANNEL_ID)?.importance
            ?: NotificationManager.IMPORTANCE_UNSPECIFIED
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channelName = trackingPreferences().getString(
            KEY_CHANNEL_NAME,
            DEFAULT_CHANNEL_NAME,
        ) ?: DEFAULT_CHANNEL_NAME
        val channel = NotificationChannel(
            CHANNEL_ID,
            channelName,
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = DEFAULT_CHANNEL_DESCRIPTION
            setShowBadge(false)
            lockscreenVisibility = Notification.VISIBILITY_PRIVATE
        }
        notificationManager.createNotificationChannel(channel)
    }

    private fun isTrackingActive(): Boolean =
        trackingPreferences().getBoolean(KEY_ACTIVE, false)

    private fun trackingPreferences() =
        getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)

    private fun clearTrackingState() {
        trackingPreferences().edit().clear().apply()
        handler.removeCallbacks(notificationTicker)
        stopLocationUpdates()
        notificationManager.cancel(NOTIFICATION_ID)
        if (isForeground) {
            removeForegroundNotification()
            isForeground = false
        }
    }

    private fun removeForegroundNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
    }

    private fun immutablePendingIntentFlag(): Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE
        } else {
            0
        }

    companion object {
        const val PREFERENCES_NAME = "tour_tracking_native"
        const val ACTION_START_OR_UPDATE = "it.cesenaremembers.app.tour.START_OR_UPDATE"
        const val ACTION_STOP = "it.cesenaremembers.app.tour.STOP"

        const val EXTRA_TITLE = "notificationTitle"
        const val EXTRA_CHANNEL_NAME = "notificationChannelName"
        const val EXTRA_NEXT_STOP_LABEL = "nextStopLabel"
        const val EXTRA_ELAPSED_LABEL = "elapsedLabel"
        const val EXTRA_DISTANCE_LABEL = "distanceLabel"
        const val EXTRA_OPEN_LABEL = "openMapLabel"
        const val EXTRA_STOP_NAME = "stopName"
        const val EXTRA_STOP_LATITUDE = "latitude"
        const val EXTRA_STOP_LONGITUDE = "longitude"
        const val EXTRA_LEG_STARTED_AT = "legStartedAtEpochMs"
        const val EXTRA_ELAPSED_SECONDS = "elapsedSeconds"
        const val EXTRA_ELAPSED_RUNNING = "elapsedRunning"

        const val KEY_ACTIVE = "active"
        private const val KEY_TITLE = "title"
        private const val KEY_CHANNEL_NAME = "channelName"
        private const val KEY_NEXT_STOP_LABEL = "nextStopLabel"
        private const val KEY_ELAPSED_LABEL = "elapsedLabel"
        private const val KEY_DISTANCE_LABEL = "distanceLabel"
        private const val KEY_OPEN_LABEL = "openMapLabel"
        private const val KEY_STOP_NAME = "stopName"
        private const val KEY_STOP_LATITUDE = "stopLatitude"
        private const val KEY_STOP_LONGITUDE = "stopLongitude"
        private const val KEY_LEG_STARTED_AT = "legStartedAt"
        private const val KEY_ELAPSED_SECONDS = "elapsedSeconds"
        private const val KEY_ELAPSED_RUNNING = "elapsedRunning"
        private const val KEY_HAS_LOCATION = "hasLocation"
        private const val KEY_LAST_LATITUDE = "lastLatitude"
        private const val KEY_LAST_LONGITUDE = "lastLongitude"

        // A fresh channel avoids inheriting a previously disabled/broken channel
        // created by earlier test builds. Android preserves user settings per ID.
        private const val CHANNEL_ID = "tour_tracking_v2"
        const val KEY_IS_FOREGROUND = "isForeground"
        const val KEY_LAST_ERROR = "lastStartError"
        const val LOG_TAG = "TourTrackingService"
        private const val DEFAULT_TITLE = "Cesena Remembers · Tour"
        private const val DEFAULT_CHANNEL_NAME = "Tour in corso"
        private const val DEFAULT_CHANNEL_DESCRIPTION =
            "Notifica persistente durante un tour guidato"
        private const val DEFAULT_NEXT_STOP_LABEL = "Prossima tappa"
        private const val DEFAULT_ELAPSED_LABEL = "Tempo"
        private const val DEFAULT_DISTANCE_LABEL = "Distanza"
        private const val DEFAULT_OPEN_LABEL = "Apri"

        private const val NOTIFICATION_ID = 1945
        private const val REQUEST_CODE_OPEN_APP = 1946
        private const val LOCATION_UPDATE_INTERVAL_MS = 5000L
        private const val LOCATION_UPDATE_DISTANCE_METERS = 10f
        private const val NOTIFICATION_REFRESH_MS = 10000L
    }
}
