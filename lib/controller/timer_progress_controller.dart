import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class TimerProgressController {
  void Function({double beginValue, double endValue}) animateToProgress;
  void Function() resetProgress;
}

class TimerProgressLoader extends StatefulWidget {
  TimerProgressLoader({this.controller});
  final TimerProgressController controller;

  @override
  _TimerProgressLoaderState createState() =>
      _TimerProgressLoaderState(controller);
}

class _TimerProgressLoaderState extends State<TimerProgressLoader>
    with SingleTickerProviderStateMixin {
  _TimerProgressLoaderState(TimerProgressController _controller) {
    _controller.animateToProgress = animateToProgress;
    _controller.resetProgress = resetProgress;
  }

  Animation<double> _animation;
  AnimationController _animationController;

  double _animationValue = 0;
  double _beginValue = 0;
  double _endValue = 1;

  // Dimens
  double _loaderSize = 300;

  // Rive
  final _animationFileRive = "assets/timer-loader.riv";
  Artboard _riveArtboard;

  void animateToProgress({double beginValue, double endValue}) {
    _beginValue = beginValue;
    _endValue = endValue;

    _animationController.reset();
    _assignAnimation();
    _animationController.forward();
  }

  void resetProgress() {}

  void _loadAnimationFile() async {
    final bytes = await rootBundle.load(_animationFileRive);
    final file = RiveFile();

    if (file.import(bytes)) {
      setState(() {
        _riveArtboard = file.mainArtboard
          ..addController(
            SimpleAnimation('loading-animation'),
          );
      });
    }
  }

  @override
  void initState() {
    _loadAnimationFile();

    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _assignAnimation();

    _animationController.forward();
  }

  @override
  void dispose() {
    widget.controller.resetProgress();
    _animationController?.dispose();
    super.dispose();
  }

  void _assignAnimation() {
    _animation = Tween<double>(begin: _beginValue, end: _endValue)
        .animate(_animationController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {});
  }

  @override
  Widget build(BuildContext context) {
    _animationValue = _animation.value;

    // Loading Wrapper
    return RotatedBox(
      quarterTurns: 3,
      child: Container(
        width: _loaderSize,
        height: _loaderSize,
        child: ShaderMask(
          shaderCallback: (rect) {
            return SweepGradient(
              stops: [_animationValue, _animationValue],
              center: Alignment.center,
              colors: [
                Colors.blue,
                Colors.white.withAlpha(10),
              ],
            ).createShader(rect);
          },
          child: Container(
            width: _loaderSize,
            height: _loaderSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: _riveArtboard != null
                ? Rive(
                    artboard: _riveArtboard,
                    fit: BoxFit.cover,
                  )
                : Container(),
          ),
        ),
      ),
    );
  }
}
