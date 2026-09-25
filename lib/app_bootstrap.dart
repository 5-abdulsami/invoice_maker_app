import 'dart:async';

import 'package:flutter/material.dart';
import 'package:invoicemaker/app.dart';
import 'package:invoicemaker/data/repositories/app_repositories.dart';
import 'package:invoicemaker/presentation/splash/splash_screen.dart';

/// Starts the app behind the splash.
///
/// Storage opens while the splash plays, so launch time is spent on
/// something the user can see. The app is mounted only once both the intro
/// has finished and the data is ready; the splash then fades away over it.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({
    super.key,
    this.initialize = AppRepositories.initialize,
  });

  /// Opens storage. Injectable so tests can start the app on memory.
  final Future<AppRepositories> Function() initialize;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap>
    with SingleTickerProviderStateMixin {
  static const Duration _exitDuration = Duration(milliseconds: 420);

  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: _exitDuration,
  );

  late final Animation<double> _exitCurve = CurvedAnimation(
    parent: _exit,
    curve: Curves.easeInOutCubic,
  );

  AppRepositories? _repositories;
  bool _introFinished = false;
  bool _appMounted = false;
  bool _splashRemoved = false;
  bool _firstFrameReleased = false;

  @override
  void initState() {
    super.initState();
    // Holds Android's launch screen until the splash logo is decoded, so the
    // first Flutter frame already shows it rather than a blank teal screen.
    WidgetsBinding.instance.deferFirstFrame();
    unawaited(_openStorage());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstFrameReleased) return;
    unawaited(
      precacheImage(SplashScreen.logo, context)
          .whenComplete(_releaseFirstFrame),
    );
  }

  void _releaseFirstFrame() {
    if (_firstFrameReleased) return;
    _firstFrameReleased = true;
    WidgetsBinding.instance.allowFirstFrame();
  }

  Future<void> _openStorage() async {
    final repositories = await widget.initialize();
    if (!mounted) return;
    _repositories = repositories;
    _handOverWhenReady();
  }

  void _onIntroFinished() {
    _introFinished = true;
    _handOverWhenReady();
  }

  /// Mounts the app beneath the splash and fades the splash out.
  ///
  /// The app's first, heaviest build happens while the splash is still fully
  /// opaque and resting, so no dropped frame is ever visible.
  void _handOverWhenReady() {
    if (_appMounted || !_introFinished || _repositories == null) return;
    setState(() => _appMounted = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Read from the view: this widget sits above any MediaQuery.
      final reduceMotion =
          MediaQueryData.fromView(View.of(context)).disableAnimations;
      final exit =
          reduceMotion ? Future<void>.value() : _exit.forward().orCancel;
      unawaited(
        exit.catchError((_) {}).whenComplete(() {
          if (mounted) setState(() => _splashRemoved = true);
        }),
      );
    });
  }

  @override
  void dispose() {
    // A widget test may tear the tree down before the logo decodes.
    _releaseFirstFrame();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repositories = _repositories;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_appMounted && repositories != null)
            InvoiceMakerApp(repositories: repositories),
          if (!_splashRemoved)
            // The splash sits outside MaterialApp, so it reads the screen
            // metrics straight from the view.
            MediaQuery.fromView(
              view: View.of(context),
              // Taps wait until the splash has gone, so nothing beneath is
              // pressed mid-fade.
              child: AbsorbPointer(
                child: FadeTransition(
                  opacity: ReverseAnimation(_exitCurve),
                  child: ScaleTransition(
                    scale:
                        Tween<double>(begin: 1, end: 1.06).animate(_exitCurve),
                    child: SplashScreen(onIntroFinished: _onIntroFinished),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
