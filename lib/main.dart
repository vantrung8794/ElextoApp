import 'dart:ui';
import 'package:flutter/material.dart';

late AnimationController _animationController;
late Animation<double> _animation;

const initalHeightOfPopup = 780.0;
const hidingHeightOfPopup = 120.0;

bool isHide = false;
double otherOpacity = 1.0;

double deltaBlur = 20.0;
double bgOpacity = 0.3;

double popupOpacity = 0.65;
double popupRadius = 20.0;
double marginPopup = 20.0;
double bottomPopup = 0.0;

double diskHeight = 300.0;
Offset diskTranslateOffset = Offset.zero;

double titleTopTranslate = 0.0;
double titleFontSize = 28.0;

double sliderTopTranslate = 0.0;
double sliderScale = 1.0;

double buttonPadding = 24.0;
Offset buttonTranslateOffset = Offset.zero;

double? widthOfScreen;
double verticalDrag = 0.0;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));

    _animationController.addListener(() {
      final value = _animation.value;
      updateUI(value: value);
    });

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOutCubic));
  }

  void updateUI({required double value}) {
    setState(() {
      // Background
      bgOpacity = (value * 0.3).clamp(0.001, 1.0);
      deltaBlur = value * 20.0;

      //Popup
      popupOpacity = 1.0 - value.clamp(0.001, 1.0 - 0.65);
      otherOpacity = (value * 1.0).clamp(0.001, 1.0);
      bottomPopup = -(1 - value) * (initalHeightOfPopup - hidingHeightOfPopup);
      marginPopup = (value * 20.0).clamp(0.001, 20.0);
      popupRadius = value * 20.0;

      // Disk
      diskHeight = (value * 300.0).clamp(60.0, 300.0);
      // Disk offset change zero to (-10, 24 from left)
      double widthScreen = widthOfScreen ?? 0.0;
      diskTranslateOffset = Offset(
          (-widthScreen / 2 + 50.0) * (1.0 - value), -20.0 * (1.0 - value));

      //Title
      titleTopTranslate = (1.0 - value) * 110.0;
      titleFontSize = (value * 28.0).clamp(22.0, 28.0);

      // Slider
      sliderTopTranslate = (1.0 - value) * 280.0;
      sliderScale = value.clamp(0.55, 1.0);

      // Pause button
      buttonPadding = (value * 24.0).clamp(12.0, 24.0);
      buttonTranslateOffset = Offset(
          (widthScreen / 2 - 50) * (1.0 - value), (-390.0 * (1.0 - value)));
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        // Drag listeners.
        onDragUpdate: (details) {
          verticalDrag += details.delta.dy;

          final value =
              1 - (verticalDrag / initalHeightOfPopup).abs().clamp(0.01, 1.0);
          updateUI(value: value);
        },
        onDragEnd: (_) {
          final value = verticalDrag / initalHeightOfPopup;
          if (value >= 0.5) {
            isHide = true;
            _animationController.forward(from: value);
          } else {
            isHide = false;
            _animationController.reverse(from: value);
          }
        },
        onStart: () {
          verticalDrag = isHide ? initalHeightOfPopup : 0.0;
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final Function onDragUpdate;
  final Function onDragEnd;
  final Function onStart;

  MyHomePage(
      {required this.onDragUpdate,
      required this.onDragEnd,
      required this.onStart});

  @override
  Widget build(BuildContext context) {
    widthOfScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (BuildContext context, Widget? child) {
          return Stack(
            fit: StackFit.expand,
            children: [buildBackground(), buildBlurBackground(), buildPopup()],
          );
        },
      ),
    );
  }

  Widget buildPopup() {
    return Positioned(
      bottom: bottomPopup,
      left: 0.0,
      right: 0.0,
      child: Stack(
        children: [
          GestureDetector(
            onVerticalDragUpdate: (details) {
              onDragUpdate(details);
            },
            onVerticalDragEnd: (details) {
              onDragEnd(details);
            },
            onVerticalDragStart: (details) {
              onStart();
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: marginPopup),
              height: initalHeightOfPopup,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(popupRadius),
                  color: Colors.white.withOpacity(popupOpacity)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40.0,
                  ),
                  buildStackDisk(),
                  buildTextInfo(),
                  Opacity(opacity: otherOpacity, child: buildSubActions()),
                  SizedBox(
                    height: 12.0,
                  ),
                  buildSlider(),
                  buildControlActions()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildControlActions() {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, top: 24.0, right: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Opacity(
            opacity: otherOpacity,
            child: Image(
              image: AssetImage("images/icon_shuffle.png"),
              height: 30.0,
            ),
          ),
          Opacity(
            opacity: otherOpacity,
            child: Image(
              image: AssetImage("images/icon_back.png"),
              height: 30.0,
            ),
          ),
          Transform.translate(
            offset: buttonTranslateOffset,
            child: ClipOval(
              child: Container(
                  color: Color(0xFFFF5753),
                  child: Padding(
                    padding: EdgeInsets.all(buttonPadding),
                    child: Image(
                      image: AssetImage("images/icon_play.png"),
                      height: 32,
                    ),
                  )),
            ),
          ),
          Opacity(
            opacity: otherOpacity,
            child: Image(
              image: AssetImage("images/icon_next.png"),
              height: 30.0,
            ),
          ),
          Opacity(
            opacity: otherOpacity,
            child: Image(
              image: AssetImage("images/icon_repeat.png"),
              height: 30.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSlider() {
    return Transform.translate(
      offset: Offset(0.0, -sliderTopTranslate),
      child: Transform.scale(
        scale: sliderScale,
        child: Container(
          height: 60.0,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2.0,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                      activeColor: Color(0xFFFF5753),
                      inactiveColor: Color(0xFF262345),
                      value: 60,
                      min: 0,
                      max: 100,
                      onChanged: (double value) {}),
                ),
              ),
              buildTimer()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTimer() {
    return Positioned(
        top: 32.0,
        left: 24.0,
        right: 24.0,
        child: Opacity(
          opacity: otherOpacity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "3:12",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              Text(
                "5:43",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              )
            ],
          ),
        ));
  }

  Padding buildSubActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset("images/icon_share.png"),
          Image.asset("images/icon_add.png"),
          Image.asset("images/icon_music.png"),
          Image.asset("images/icon_download.png"),
        ],
      ),
    );
  }

  Padding buildTextInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 35.0),
      child: Column(
        children: [
          Transform.translate(
            offset: Offset(0.0, -titleTopTranslate),
            child: Text(
              "Someone You Live",
              style: TextStyle(
                  fontSize: titleFontSize, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Opacity(
            opacity: otherOpacity,
            child: Text(
              "Arian Grande",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.redAccent),
            ),
          ),
          SizedBox(
            height: 24.0,
          ),
          Opacity(
            opacity: otherOpacity,
            child: Text(
              "It is a long established fact that a reader",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          )
        ],
      ),
    );
  }

  Widget buildStackDisk() {
    return Transform.translate(
        offset: diskTranslateOffset,
        child: InkWell(
          onTap: () {
            isHide = !isHide;
            if (isHide) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
          },
          child: Stack(children: [
            Container(
              child: Image(
                image: AssetImage("images/song_avatar.png"),
                width: diskHeight,
                height: diskHeight,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
                child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: otherOpacity,
                child: CircleAvatar(
                  radius: 26.0,
                  backgroundColor: Colors.white.withOpacity(0.6),
                ),
              ),
            ))
          ]),
        ));
  }

  Widget buildBlurBackground() {
    return Positioned.fill(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: deltaBlur, sigmaY: deltaBlur),
            child: Container(color: Colors.black.withOpacity(bgOpacity))));
  }

  Widget buildBackground() {
    return Positioned.fill(
        child: Image(
      image: AssetImage('images/bg.png'),
      fit: BoxFit.cover,
    ));
  }
}
