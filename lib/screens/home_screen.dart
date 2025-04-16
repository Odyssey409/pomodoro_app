import 'dart:async';
import 'package:flip_board/flip_clock.dart';
import 'package:flutter/material.dart';
import 'package:timed_widget_slider/timed_widget_slider.dart';

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
  final List<int> timeOptions = [15, 20, 25, 30, 35];

  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController = ScrollController(
        initialScrollOffset: _calculateInitialScrollOffset(),
      );
      setState(() {}); // 상태 갱신
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  double _calculateInitialScrollOffset() {
    final selectedIndex =
        timeOptions.indexOf(totalSeconds ~/ 60); // 현재 선택된 값의 인덱스
    const itemWidth = 80.0; // 각 항목의 가로 크기 (마진 포함)
    final screenWidth = MediaQuery.of(context).size.width; // 화면 너비
    return (selectedIndex * itemWidth) - (screenWidth / 2 - itemWidth / 2);
  }

  void _scrollToIndex(int index) {
    const itemWidth = 80.0; // 각 항목의 가로 크기 (마진 포함)
    final screenWidth = MediaQuery.of(context).size.width; // 화면 너비
    final offset = (index * itemWidth) - (screenWidth / 2 - itemWidth / 2);

    _scrollController?.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

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
            padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
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
              child: SizedBox(
                height: 60,
                child: _scrollController == null
                    ? const CircularProgressIndicator(
                        color: Colors.white) // 로딩 화면
                    : ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: timeOptions.length,
                        itemBuilder: (context, index) {
                          final time = timeOptions[index];
                          final isSelected = (totalSeconds ~/ 60) == time;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                totalSeconds = time * 60; // 선택된 시간을 업데이트
                              });
                              _scrollToIndex(index); // 선택된 항목을 중앙으로 이동
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                "$time",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? const Color(0xFFE64D3D)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
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
