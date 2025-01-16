import 'dart:async';
import 'package:flip_board/flip_clock.dart';
import 'package:flutter/material.dart';
import 'package:flip_board/flip_board.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int twentyFiveMinutes = 1500; // 25분 (1500초)
  int totalSeconds = twentyFiveMinutes;
  bool isRunning = false;
  bool isPaused = false;
  int totalPomodoros = 0;
  int round = 0;
  Timer? timer;

  void onTick(Timer timer) {
    if (totalSeconds <= 0) {
      setState(() {
        totalSeconds = twentyFiveMinutes;
        totalPomodoros++;
        if (totalPomodoros == 12) {
          round++;
          totalPomodoros = 0;
        }
        isRunning = false;
        isPaused = false;
      });
      timer.cancel();
    } else {
      setState(() {
        totalSeconds--;
      });
    }
  }

  void onStartPressed() {
    if (!isRunning && !isPaused) {
      setState(() {
        isRunning = true;
      });
      timer = Timer.periodic(
        const Duration(seconds: 1),
        onTick,
      );
    } else if (isPaused) {
      setState(() {
        isRunning = true;
        isPaused = false;
      });
      timer = Timer.periodic(
        const Duration(seconds: 1),
        onTick,
      );
    } else {
      onPausePressed();
    }
  }

  void onPausePressed() {
    if (isRunning) {
      timer?.cancel();
      setState(() {
        isRunning = false;
        isPaused = true;
      });
    }
  }

  void onResetPressed() {
    timer?.cancel();
    setState(() {
      totalSeconds = twentyFiveMinutes;
      isRunning = false;
      isPaused = false;
    });
  }

  Widget _flipCountdown() => FlipCountdownClock(
        duration: Duration(seconds: totalSeconds),
        digitSize: 70.0,
        width: 70.0,
        height: 100.0,
        digitColor: const Color(0xFFE64D3D), // 오렌지 레드 글자 색상
        backgroundColor: Colors.white, // 흰색 배경
        separatorColor: const Color(0xFFE64D3D), // 오렌지 레드 구분자 색상
        borderColor: Colors.white, // 흰색 경계선
        hingeColor: const Color(0xFFE64D3D), // 오렌지 레드 힌지 색상
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        onDone: () {
          setState(() {
            totalPomodoros++;
            totalSeconds = twentyFiveMinutes;
            isRunning = false;
            isPaused = false;
          });
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE64D3D), // 배경 색상을 오렌지 레드로 설정
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              children: [
                Text(
                  "POMOTIMER",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Flexible(
            flex: 1,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // 흰색 배경
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(24.0),
                child: isRunning
                    ? _flipCountdown() // 타이머가 작동 중일 때만 플립 카운트다운 표시
                    : Text(
                        formatTime(totalSeconds), // 일시정지 상태에서는 텍스트로 시간 표시
                        style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE64D3D),
                          letterSpacing: 28.0,
                        ),
                      ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 100,
                    color: Colors.white,
                    onPressed: onStartPressed,
                    icon: Icon(
                      isRunning
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                    ),
                  ),
                  if (isPaused) // 일시정지 상태에서만 정지 버튼 표시
                    IconButton(
                      iconSize: 100,
                      color: Colors.white,
                      onPressed: onResetPressed,
                      icon: const Icon(Icons.stop_circle_outlined),
                    ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$round/4",
                              style: const TextStyle(
                                fontSize: 27,
                                color: Colors.white54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              "ROUND",
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$totalPomodoros/12",
                              style: const TextStyle(
                                fontSize: 27,
                                color: Colors.white54, // 오렌지 레드 글자 색상
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              "GOAL",
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white, // 오렌지 레드 글자 색상
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(int seconds) {
    var minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    var secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }
}
