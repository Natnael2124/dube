import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dube/l10n/app_localizations.dart';

class LocalSponsor {
  const LocalSponsor({
    required this.name,
    required this.subtitle,
    required this.phone,
    required this.badge,
    this.icon = Icons.storefront_outlined,
  });

  final String name;
  final String subtitle;
  final String phone;
  final String badge;
  final IconData icon;
}

const List<LocalSponsor> _kLocalSponsors = [
  LocalSponsor(
    name: 'Addis Wholesale Goods',
    subtitle: 'Bulk Teff, Sugar & Cooking Oil at wholesale prices',
    phone: '+251911223344',
    badge: 'Wholesale · ጅምላ',
    icon: Icons.inventory_2_outlined,
  ),
  LocalSponsor(
    name: 'Ethio Distribution PLC',
    subtitle: 'Fast FMCG & packaged food delivery for retail shops',
    phone: '+251922334455',
    badge: 'Distribution · አከፋፋይ',
    icon: Icons.local_shipping_outlined,
  ),
  LocalSponsor(
    name: 'Habesha Soft Drink Depot',
    subtitle: 'Daily crates delivery of Soda, Juice & Bottled Water',
    phone: '+251933445566',
    badge: 'Beverages · መጠጦች',
    icon: Icons.liquor_outlined,
  ),
  LocalSponsor(
    name: 'Awash Grain & Flour Mills',
    subtitle: 'Direct mill prices for bakery flour, grains & spices',
    phone: '+251944556677',
    badge: 'Grain Supply · እህል',
    icon: Icons.grain_outlined,
  ),
];

/// Hybrid monetization banner rotating between Google AdMob test banner
/// and local business sponsor cards.
class AdBannerBar extends StatefulWidget {
  const AdBannerBar({super.key});

  /// Google official Android Banner Test Ad Unit ID
  static const String testAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  @override
  State<AdBannerBar> createState() => _AdBannerBarState();
}

class _AdBannerBarState extends State<AdBannerBar> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _showingAdMob = false;
  int _sponsorIndex = 0;
  Timer? _rotationTimer;

  static const Duration _rotationInterval = Duration(seconds: 45);

  @override
  void initState() {
    super.initState();
    _initAdMobBanner();
    _startRotationTimer();
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _startRotationTimer() {
    _rotationTimer = Timer.periodic(_rotationInterval, (_) {
      if (!mounted) return;
      setState(() {
        if (_isAdLoaded) {
          _showingAdMob = !_showingAdMob;
          if (!_showingAdMob) {
            _sponsorIndex = (_sponsorIndex + 1) % _kLocalSponsors.length;
          }
        } else {
          _showingAdMob = false;
          _sponsorIndex = (_sponsorIndex + 1) % _kLocalSponsors.length;
        }
      });
    });
  }

  void _initAdMobBanner() {
    // Only attempt AdMob on supported mobile devices
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }

    try {
      final ad = BannerAd(
        adUnitId: AdBannerBar.testAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted) {
              ad.dispose();
              return;
            }
            setState(() {
              _bannerAd = ad as BannerAd;
              _isAdLoaded = true;
              _showingAdMob = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (!mounted) return;
            setState(() {
              _bannerAd = null;
              _isAdLoaded = false;
              _showingAdMob = false;
            });
          },
        ),
      );

      ad.load();
    } catch (_) {
      // Fallback 100% to local sponsor cards on any exception
      _isAdLoaded = false;
      _showingAdMob = false;
    }
  }

  Future<void> _callSponsor(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s-]'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open phone dialer for $phone')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dialer error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _showingAdMob && _isAdLoaded && _bannerAd != null
          ? Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
                Positioned(
                  top: 2,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'AD · ማስታወቂያ',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : _LocalSponsorCard(
              sponsor: _kLocalSponsors[_sponsorIndex],
              onTap: () => _callSponsor(_kLocalSponsors[_sponsorIndex].phone),
            ),
    );
  }
}

class _LocalSponsorCard extends StatelessWidget {
  const _LocalSponsorCard({
    required this.sponsor,
    required this.onTap,
  });

  final LocalSponsor sponsor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                sponsor.icon,
                size: 20,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          sponsor.name,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          sponsor.badge,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    sponsor.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, size: 12, color: scheme.onPrimary),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.call,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
