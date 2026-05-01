#!/bin/bash
# ════════════════════════════════════════════════════════════
# DEPLOY SCRIPT - staging-webmobile-rrfx.techcrm.net
# ════════════════════════════════════════════════════════════

echo "🚀 Starting deployment to staging..."

# 1. Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean
rm -rf build/web

# 2. Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# 3. Build for web (production mode)
echo "🏗️ Building Flutter Web (production)..."
flutter build web --release --web-renderer canvaskit --base-href /

# Check if build succeeded
if [ ! -d "build/web" ]; then
    echo "❌ Build failed! Directory build/web not found."
    exit 1
fi

echo "✅ Build completed successfully!"
echo ""
echo "📁 Build output location: build/web/"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🚢 NEXT STEPS TO DEPLOY:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "1. Upload build/web/ folder ke server staging:"
echo "   scp -r build/web/* root@YOUR_SERVER_IP:/www/wwwroot/staging-webmobile-rrfx.techcrm.net/"
echo ""
echo "2. Atau gunakan FileZilla/FTP untuk upload ke:"
echo "   /www/wwwroot/staging-webmobile-rrfx.techcrm.net/"
echo ""
echo "3. Configure nginx dengan file: nginx-staging.conf"
echo "   (Lihat instruksi di dalam file tersebut)"
echo ""
echo "4. Test di browser:"
echo "   https://staging-webmobile-rrfx.techcrm.net/"
echo ""
echo "═══════════════════════════════════════════════════════════"
