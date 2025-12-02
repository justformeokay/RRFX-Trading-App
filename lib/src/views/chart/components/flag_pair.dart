import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 

// =============================
//      MAPPING CURRENCY
// =============================
const Map<String, String> _currencyToFlagCode = {
  'EUR': 'eu',
  'GBP': 'gb',
  'USD': 'us',
  'JPY': 'jp',
  'AUD': 'au',
  'CAD': 'ca',
  'CHF': 'ch',
  'NZD': 'nz',
};

// =============================
//     LIST SAHAM DUNIA
// =============================
const Set<String> worldStocks = {
  'HKK',
  'UNK',
  'USK',
  'JPK',
  'UPK',
};

// =============================
//  ASSET FLAG HANDLER (PNG/SVG)
// =============================
String _getFlagAssetPath(String currencyCode) {
  final upper = currencyCode.toUpperCase();

  if (upper == 'XAU') return 'assets/images/xau.png';
  if (upper == 'USK') return 'assets/images/usk.png';

  final flagCode = _currencyToFlagCode[upper];
  if (flagCode != null) {
    return 'assets/svgs/$flagCode.svg';
  }

  return 'assets/svgs/placeholder.svg';
}

// =============================
//   EXTRACT FOREX CURRENCIES
// =============================
List<String> _extractCurrencies(String marketName) {
  final clean = marketName.split('.').first;
  if (clean.length >= 6) {
    return [
      clean.substring(0, 3),
      clean.substring(3, 6),
    ];
  }
  return ['', ''];
}

// =============================
//        FLAGPAIR WIDGET
// =============================
class FlagPair extends StatelessWidget {
  final String marketName;
  final double size;

  /// URL logo khusus saham dunia (SVG)
  final String? logoUrl; 

  const FlagPair({
    super.key,
    required this.marketName,
    this.size = 36.0,
    this.logoUrl,
  });

  bool get isWorldStock => worldStocks.contains(marketName.toUpperCase());

  @override
  Widget build(BuildContext context) {
    final market = marketName.toUpperCase();

    // =========================================
    // CASE 1: SAHAM DUNIA → hanya 1 logo SVG URL
    // =========================================
    if (isWorldStock) {
      return _buildSingleLogo();
    }

    // =========================================
    // CASE 2: FOREX → tampilkan 2 bendera
    // =========================================
    final currencies = _extractCurrencies(market);
    return _buildTwoFlags(currencies);
  }

  // ============================================================
  //                RENDER 1 LOGO (SAHAM DUNIA)
  // ============================================================
  Widget _buildSingleLogo() {
    if (logoUrl == null) {
      return const Icon(Icons.broken_image, size: 32);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: ClipOval(
        child: SvgPicture.network(
          logoUrl!,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  // ============================================================
  //                RENDER 2 BENDERA FOREX
  // ============================================================
  Widget _buildTwoFlags(List<String> currencies) {
    final base = currencies[0];
    final quote = currencies[1];
    final offsetDistance = size * 0.5;

    return SizedBox(
      width: size + offsetDistance,
      height: size,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: offsetDistance,
            child: _buildFlagCircle(quote),
          ),
          Positioned(
            left: 0,
            child: _buildFlagCircle(base),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //           RENDER 1 BENDERA DALAM CIRCLE
  // ============================================================
  Widget _buildFlagCircle(String currencyCode) {
    final path = _getFlagAssetPath(currencyCode);
    final isPng = path.endsWith('.png');

    final Widget img = isPng
        ? Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Center(child: Icon(Icons.error, color: Colors.red)),
          )
        : SvgPicture.asset(
            path,
            fit: BoxFit.cover,
            placeholderBuilder: (_) => Container(
              color: Colors.black,
              child: const Center(
                child: Icon(Icons.error_outline, color: Colors.white),
              ),
            ),
          );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: ClipOval(child: img),
    );
  }
}
