import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timer/controller/timer_progress_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  TextEditingController _timerEditingController = TextEditingController();
  TimerProgressController _progressController = TimerProgressController();

  Timer _timer;

  int _startTime = 0;
  int _currentTime = 0;
  int _progress = 100;

  bool _isTimerRunning = false;
  bool _isTextEnable = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  void _setTimerStart() {
    _isTimerRunning = true;
    _isTextEnable = false;
  }

  void _setTimerStop() {
    if (_timerEditingController.text.isEmpty) {
      _timerEditingController.clear();
    } else
      _isTimerRunning = false;
    _isTextEnable = true;

    _animationController.reset();
    _timer.cancel();
  }

  void _startTimer() {
    _setTimerStart();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTime > 0) {
        _currentTime--;
        _timerEditingController.text = _currentTime.toString();
        _progressController.animateToProgress(
          beginValue: _calcProgress(_currentTime + 1) / 100,
          endValue: _calcProgress(_currentTime) / 100,
        );
      } else if (_currentTime == 0) {
        _timerEditingController.clear();
        _setTimerStop();
      } else {
        _setTimerStop();
      }
    });
  }

  int _calcProgress(int number) {
    _progress = ((number / _startTime) * 100).round();
    return _progress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(builder: (context, constrains) {
        return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: constrains.maxWidth,
                height: constrains.maxHeight,
                child: ListView(
                  children: [
                    Stack(
                      children: [
                        if (_isTimerRunning)
                          Center(
                            child: TimerProgressLoader(
                              controller: _progressController,
                            ),
                          ),
                        Center(
                          child: Container(
                            height: 300,
                            width: 300,
                            alignment: Alignment.center,
                            child: TextField(
                              enabled: _isTextEnable,
                              controller: _timerEditingController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "0",
                                hintStyle: TextStyle(
                                  color: Colors.white.withAlpha(90),
                                ),
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 56,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 56,
                    ),
                    CupertinoButton(
                      onPressed: () {
                        if (!_isTimerRunning) {
                          String timerTextValue =
                              _timerEditingController.text.toString();
                          if (timerTextValue.isNotEmpty) {
                            int time = int.parse(timerTextValue);

                            _startTime = time;
                            _currentTime = time;
                            _animationController.forward();
                            _startTimer();
                          }
                        } else {
                          _setTimerStop();
                          _animationController.reset();
                        }
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AnimatedIcon(
                            size: 80,
                            icon: AnimatedIcons.play_pause,
                            progress: _animationController,
                          )),
                    ),
                  ],
                ),
              );
            });
      }),
    );
  }
}
