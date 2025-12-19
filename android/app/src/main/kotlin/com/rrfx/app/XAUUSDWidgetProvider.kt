package com.rrfx.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.*

class XAUUSDWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        if (intent.action == ACTION_REFRESH) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, XAUUSDWidgetProvider::class.java)
            )
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }

    companion object {
        private const val ACTION_REFRESH = "com.rrfx.app.REFRESH_WIDGET"

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.xauusd_widget)

            // Get data from SharedPreferences
            val symbol = widgetData.getString("widget_symbol", "XAUUSD")
            val price = widgetData.getString("widget_price", "0.00")
            val change = widgetData.getString("widget_change", "0.00")
            val changePercent = widgetData.getString("widget_change_percent", "0.00")
            val bid = widgetData.getString("widget_bid", "0.00")
            val ask = widgetData.getString("widget_ask", "0.00")
            val high = widgetData.getString("widget_high", "0.00")
            val low = widgetData.getString("widget_low", "0.00")
            val lastUpdate = widgetData.getString("widget_last_update", "")

            // Update UI
            views.setTextViewText(R.id.widget_symbol, symbol)
            views.setTextViewText(R.id.widget_price, "$$price")
            views.setTextViewText(R.id.widget_bid, bid)
            views.setTextViewText(R.id.widget_ask, ask)
            views.setTextViewText(R.id.widget_high, high)
            views.setTextViewText(R.id.widget_low, low)

            // Format change and change percent
            val changeValue = change?.toDoubleOrNull() ?: 0.0
            val changePercentValue = changePercent?.toDoubleOrNull() ?: 0.0
            val isPositive = changeValue >= 0

            val changeText = if (isPositive) "+${change ?: "0.00"}" else (change ?: "0.00")
            val changePercentText = if (isPositive) "(+${changePercent ?: "0.00"}%)" else "(${changePercent ?: "0.00"}%)"
            
            val changeColor = if (isPositive) Color.parseColor("#4CAF50") else Color.parseColor("#F44336")
            
            views.setTextViewText(R.id.widget_change, changeText)
            views.setTextViewText(R.id.widget_change_percent, changePercentText)
            views.setTextColor(R.id.widget_change, changeColor)
            views.setTextColor(R.id.widget_change_percent, changeColor)

            // Format last update time
            val updateText = formatLastUpdate(lastUpdate ?: "")
            views.setTextViewText(R.id.widget_last_update, "Updated: $updateText")

            // Setup refresh button click
            val refreshIntent = Intent(context, XAUUSDWidgetProvider::class.java).apply {
                action = ACTION_REFRESH
            }
            val refreshPendingIntent = android.app.PendingIntent.getBroadcast(
                context, 0, refreshIntent, 
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.refresh_button, refreshPendingIntent)

            // Setup widget click to open app
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val launchPendingIntent = android.app.PendingIntent.getActivity(
                context, 0, launchIntent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.header_layout, launchPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun formatLastUpdate(isoDate: String?): String {
            if (isoDate.isNullOrEmpty()) return "never"
            
            return try {
                val date = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault()).parse(isoDate)
                val now = Date()
                val diff = now.time - (date?.time ?: 0)
                
                when {
                    diff < 60000 -> "just now"
                    diff < 3600000 -> "${diff / 60000}m ago"
                    diff < 86400000 -> "${diff / 3600000}h ago"
                    else -> date?.let { SimpleDateFormat("MMM dd, HH:mm", Locale.getDefault()).format(it) } ?: "unknown"
                }
            } catch (e: Exception) {
                "unknown"
            }
        }
    }
}
