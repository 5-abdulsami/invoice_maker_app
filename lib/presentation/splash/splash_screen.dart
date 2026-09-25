import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoicemaker/core/constants/app_strings.dart';
import 'package:invoicemaker/core/design/brand_colors.dart';
import 'package:invoicemaker/core/design/typography.dart';

/// The brand splash shown while the app starts.
///
/// It opens exactly where the native launch screen leaves off, a 144dp logo
/// centred on brand teal, so the hand-over from Android is invisible. The
/// logo then settles to a size that suits the screen while a soft glow and a
/// fading ring bloom behind it, and the name and tagline rise in beneath.
///
/// The screen only plays the intro and reports when it is done; deciding
/// when to leave belongs to the caller, which also waits for storage.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onIntroFinished});

  /// Called once, when the intro animation has played to the end.
  final VoidCallback onIntroFinished;

  /// The logo, decoded before the first frame so it never pops in late.
  static const AssetImage logo = AssetImage('assets/images/app_logo.png');

  /// Size of the logo on the native launch screen, in logical pixels. Must
  /// match the 144dp bitmap in `drawable-xxxhdpi/splash_logo.png`.
  static const double nativeLogoSize = 144;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _introDuration = Duration(milliseconds: 1300);

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: _introDuration,
  );

  // Each element plays over its own slice of the timeline, so the intro
  // reads as one gesture rather than everything moving at once.
  late final Animation<double> _settle = _curve(0, 0.5, Curves.easeInOutCubic);
  late final Animation<double> _glow = _curve(0.1, 0.65, Curves.easeOut);
  late final Animation<double> _ring = _curve(0.15, 0.8, Curves.easeOutCubic);
  late final Animation<double> _title = _curve(0.35, 0.75, Curves.easeOutCubic);
  late final Animation<double> _tagline = _curve(0.5, 0.9, Curves.easeOutCubic);

  bool _started = false;

  Animation<double> _curve(double begin, double end, Curve curve) {
    return CurvedAnimation(
      parent: _intro,
      curve: Interval(begin, end, curve: curve),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    // With animations turned off in the system settings, the splash shows
    // its final state and hands over straight away.
    if (MediaQuery.disableAnimationsOf(context)) {
      _intro.value = 1;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onIntroFinished(),
      );
    } else {
      _intro.forward().whenCompleteOrCancel(() {
        if (mounted) widget.onIntroFinished();
      });
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Semantics(
        label: AppStrings.appName,
        container: true,
        // A Material, not a bare colour: the splash sits outside the app's
        // MaterialApp, and text needs a Material ancestor for its defaults.
        child: Material(
          color: BrandColors.splashBackground,
          child: LayoutBuilder(
            builder: (context, constraints) => AnimatedBuilder(
              animation: _intro,
              builder: (context, _) => _layout(context, constraints),
            ),
          ),
        ),
      ),
    );
  }

  Widget _layout(BuildContext context, BoxConstraints constraints) {
    final metrics =
        _SplashMetrics.of(constraints, MediaQuery.paddingOf(context));
    final logoSize = metrics.logoStart +
        (metrics.logoEnd - metrics.logoStart) * _settle.value;
    final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);

    return Stack(
      fit: StackFit.expand,
      children: [
        // A soft light behind the logo, blooming as it settles.
        Opacity(
          opacity: _glow.value,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 0.75,
                colors: [
                  BrandColors.splashGlow.withValues(alpha: 0.55),
                  BrandColors.splashGlow.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        // One ring ripples outwards from the logo and fades.
        CustomPaint(
          painter: _RingPainter(
            center: center,
            radius: logoSize * (0.62 + 0.55 * _ring.value),
            opacity: 0.32 * (1 - _ring.value),
          ),
        ),
        Center(child: _Logo(size: logoSize)),
        Positioned(
          top: center.dy + metrics.logoEnd / 2 + metrics.gap,
          left: metrics.sideInset,
          right: metrics.sideInset,
          bottom: metrics.bottomInset,
          child: _Wordmark(
            title: _title.value,
            tagline: _tagline.value,
            width: constraints.maxWidth - metrics.sideInset * 2,
          ),
        ),
      ],
    );
  }
}

/// Sizes for one screen, so the splash fits anything from a small phone in
/// landscape to a tablet without overflowing.
class _SplashMetrics {
  const _SplashMetrics({
    required this.logoStart,
    required this.logoEnd,
    required this.gap,
    required this.sideInset,
    required this.bottomInset,
  });

  factory _SplashMetrics.of(BoxConstraints constraints, EdgeInsets padding) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final shortest = math.min(width, height);

    // Never larger than half the width or a third of the height, so even a
    // tiny window keeps room for the name beneath.
    final fit = math.min(width * 0.5, height / 3);
    final logoEnd = (shortest * 0.3).clamp(72.0, 128.0).clamp(0.0, fit);
    final logoStart = math.min(SplashScreen.nativeLogoSize, fit);

    return _SplashMetrics(
      logoStart: logoStart,
      logoEnd: logoEnd,
      gap: (shortest * 0.06).clamp(16.0, 28.0),
      sideInset: math.max(24, width * 0.08),
      bottomInset: padding.bottom + 16,
    );
  }

  /// The logo's size on the first frame, matching the native launch screen.
  final double logoStart;

  /// The logo's settled size.
  final double logoEnd;

  /// Space between the logo and the name.
  final double gap;

  final double sideInset;
  final double bottomInset;
}

class _Logo extends StatelessWidget {
  const _Logo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    // Decoded once at the largest size the logo is drawn, not at the
    // source file's full resolution.
    final cacheSize =
        (SplashScreen.nativeLogoSize * MediaQuery.devicePixelRatioOf(context))
            .round();

    return DecoratedBox(
      decoration: BoxDecoration(
        // Follows the icon's own rounded corners.
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: size * 0.28,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Image(
        image: ResizeImage.resizeIfNeeded(cacheSize, null, SplashScreen.logo),
        width: size,
        height: size,
        excludeFromSemantics: true,
      ),
    );
  }
}

/// The app name and tagline, fading and rising in on their own beats.
///
/// Scales down rather than overflowing when a very short screen leaves
/// little room beneath the logo.
class _Wordmark extends StatelessWidget {
  const _Wordmark({
    required this.title,
    required this.tagline,
    required this.width,
  });

  /// Progress of each line's entrance, from 0 to 1.
  final double title;
  final double tagline;

  final double width;

  @override
  Widget build(BuildContext context) {
    // The splash is a brand moment rather than reading matter; very large
    // system text is capped so the name still fits on one line.
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);

    return Align(
      alignment: Alignment.topCenter,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Rise(
                progress: title,
                child: Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  textScaler: scaler,
                  style: const TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 26,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: BrandColors.onSplash,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _Rise(
                progress: tagline,
                child: Text(
                  AppStrings.tagline,
                  textAlign: TextAlign.center,
                  textScaler: scaler,
                  style: const TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 14,
                    height: 1.4,
                    color: BrandColors.onSplashMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades [child] in while lifting it the last few pixels into place.
class _Rise extends StatelessWidget {
  const _Rise({required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: progress,
      child: Transform.translate(
        offset: Offset(0, 14 * (1 - progress)),
        child: child,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.center,
    required this.radius,
    required this.opacity,
  });

  final Offset center;
  final double radius;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = BrandColors.onSplash.withValues(alpha: opacity),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.center != center || old.radius != radius || old.opacity != opacity;
}
