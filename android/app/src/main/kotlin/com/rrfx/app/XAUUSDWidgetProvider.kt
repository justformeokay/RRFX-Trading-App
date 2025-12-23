package com.rrfx.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.LinearLayout
import android.widget.RemoteViews
import android.widget.TextView
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject
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
            val views = RemoteViews(context.packageName, R.layout.market_card_widget)

            // Get markets data from SharedPreferences
            val marketsJson = widgetData.getString("widget_markets_data", "[]")
            val marketsCount = widgetData.getString("widget_markets_count", "0")?.toIntOrNull() ?: 0
            val lastUpdate = widgetData.getString("widget_last_update", "")

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

            // Parse dan render market cards
            try {
                val marketsArray = JSONArray(marketsJson)
                
                // Clear container
                views.removeAllViews(R.id.markets_container)
                
                // Add market cards
                for (i in 0 until minOf(marketsArray.length(), 5)) { // Max 5 cards untuk fit
                    val market = marketsArray.getJSONObject(i)
                    val cardView = createMarketCard(context, market)
                    views.addView(R.id.markets_container, cardView)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

            // Format last update time
            val updateText = formatLastUpdate(lastUpdate ?: "")
            views.setTextViewText(R.id.widget_last_update, "Updated: $updateText")

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun createMarketCard(context: Context, market: JSONObject): RemoteViews {
            val cardView = RemoteViews(context.packageName, R.layout.market_card_item)
            
            val symbol = market.optString("symbol", "N/A")
            val bid = market.optString("bid", "0")
            val ask = market.optString("ask", "0")
            val rsi = market.optString("rsi", "0")
            val trend = market.optString("ma_trend", "neutral")
            val recommendation = market.optString("recommendation", "neutral")

            // Set symbol
            cardView.setTextViewText(R.id.card_symbol, symbol)
            
            // Set bid/ask
            cardView.setTextViewText(R.id.card_bid, bid)
            cardView.setTextViewText(R.id.card_ask, ask)
            
            // Set RSI with color
            cardView.setTextViewText(R.id.card_rsi, rsi)
            val rsiValue = rsi.toDoubleOrNull() ?: 50.0
            val rsiColor = when {
                rsiValue > 70 -> "#F44336" // Overbought - red
                rsiValue < 30 -> "#4CAF50" // Oversold - green
                else -> "#FFEB3B"          // Neutral - yellow
            }
            cardView.setTextColor(R.id.card_rsi, Color.parseColor(rsiColor))
            
            // Set trend with color
            cardView.setTextViewText(R.id.card_trend, trend)
            val trendColor = when (trend.lowercase()) {
                "bullish" -> "#4CAF50"
                "bearish" -> "#F44336"
                else -> "#FF9800"
            }
            cardView.setTextColor(R.id.card_trend, Color.parseColor(trendColor))
            
            // Set recommendation with color
            cardView.setTextViewText(R.id.card_recommendation, recommendation)
            val recColor = when (recommendation.lowercase()) {
                "buy" -> "#4CAF50"
                "sell" -> "#F44336"
                else -> "#FF9800"
            }
            cardView.setTextColor(R.id.card_recommendation, Color.parseColor(recColor))
            
            return cardView
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
