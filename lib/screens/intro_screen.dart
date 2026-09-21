import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Fullscreen Intro Screen playing the Farm Trading introductory video.
///
/// Features:
/// - Full-screen responsive video playback (BoxFit.cover)
/// - Hidden video controls & automatic single-play
/// - Clean branded loading indicator while initializing
/// - Fail-safe error handling to never block the user
/// - "Skip" button with comfortable touch target and sleek styling
/// - Smooth fade page transition to the Home / Role Selection screen
/// - Lifecycle-aware (handles app pause/resume)
/// - Respects reduced-motion accessibility settings
class IntroScreen extends StatefulWidget {
  final Widget? nextScreen;

  const IntroScreen({super.key, this.nextScreen});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasNavigated = false;

  static const String _videoAssetPath = 'assets/videos/farm-trading-intro.mp4';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeVideo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Respect accessibility / reduced-motion preferences
      if (MediaQuery.of(context).disableAnimations) {
        _navigateToHome();
      }
    });
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset(_videoAssetPath)
      ..initialize()
          .then((_) {
            if (!mounted) return;
            _controller.setLooping(false);
            setState(() {
              _isInitialized = true;
            });
            _controller.play();
          })
          .catchError((error) {
            debugPrint('Intro video initialization error: $error');
            // Graceful fallback: do not leave the user stuck on error
            _navigateToHome();
          });

    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (_hasNavigated || !mounted) return;

    if (_controller.value.hasError) {
      debugPrint(
        'Intro video playback error: ${_controller.value.errorDescription}',
      );
      _navigateToHome();
      return;
    }

    final duration = _controller.value.duration;
    final position = _controller.value.position;

    // Check if video completed playback
    if (_controller.value.isCompleted ||
        (duration > Duration.zero && position >= duration)) {
      _navigateToHome();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_hasNavigated || !_isInitialized) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_controller.value.isPlaying) {
        _controller.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!_controller.value.isPlaying && !_hasNavigated) {
        _controller.play();
      }
    }
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final targetScreen = widget.nextScreen;
    if (targetScreen == null) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player Layer
          if (_isInitialized && _controller.value.isInitialized)
            Center(
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width > 0
                        ? _controller.value.size.width
                        : 1920,
                    height: _controller.value.size.height > 0
                        ? _controller.value.size.height
                        : 1080,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            )
          else
            _buildBrandedLoading(),

          // Skip Button in Bottom-Right Corner
          if (!_hasNavigated)
            Positioned(
              bottom: 28,
              right: 24,
              child: SafeArea(child: _buildSkipButton()),
            ),
        ],
      ),
    );
  }

  Widget _buildBrandedLoading() {
    return Container(
      color: const Color(0xFF1B5E20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.agriculture,
                size: 50,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Farm Trading',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Direct farm-to-market trading',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _navigateToHome,
        borderRadius: BorderRadius.circular(22),
        splashColor: Colors.white24,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
