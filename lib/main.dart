import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: Main(),
    theme: ThemeData.dark(),
  ));
}

class Main extends StatefulWidget {
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  double posY = 0; 
  double posX = 0;
  double gravity = 20; //Decrease this value to make the game easier
  int score = 0;
  double jump = 400;
  bool isBallVisible = true;
  bool isPlaying = false;
  double height;
  double width;
  int best;
  SharedPreferences pref;
  Timer time;

  @override
  void initState() {
    super.initState();
    _getBest();
    time = Timer.periodic(Duration(milliseconds: 20), (Timer t) {
      _putBest(score);
      setState(() {
        if (isPlaying) {
          if (posY + 500 >= height) {
            isPlaying = false;
            isBallVisible = false;
          } else {
            posY = posY + gravity;
          }
          if (posX - 75 <= -width / 2) {
            posX = posX + 100;
          }
          if (posX + 75 >= width / 2) {
            posX = posX - 100;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(seconds: 1),
          ),
          isBallVisible
              ? Container(
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.only(top: 200),
                  child: Text(
                    '$score',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 50,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : Container(
                  width: 0,
                  height: 0,
                ),
          Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                width: 150,
                height: 150,
                transform: Matrix4.translationValues(posX, posY, 0),
                duration: Duration(milliseconds: 100),
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: ExactAssetImage('asset/football.png')),
                          shape: BoxShape.circle),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            child: GestureDetector(
                          onTap: () {
                            //left
                            setState(() {
                              score = score + 1;
                              if (!isPlaying) {
                                isPlaying = true;
                              }
                              posX = posX - 100;
                              posY = posY - jump;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                          ),
                        )),
                        Expanded(
                            child: GestureDetector(
                          onTap: () {
                            //right
                            setState(() {
                              score = score + 1;
                              if (!isPlaying) {
                                isPlaying = true;
                              }
                              posX = posX + 100;
                              posY = posY - jump;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                          ),
                        )),
                      ],
                    )
                  ],
                ),
              )),
          isBallVisible
              ? Container(
                  width: 0,
                  height: 0,
                )
              : Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isBallVisible = true;
                        isPlaying = false;
                        posY = 0;
                        posX = 0;
                        score = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Best: $best',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.refresh, color: Colors.black, size: 50)
                      ],
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Future<int> _getBest() async {
    pref = await SharedPreferences.getInstance();
    best = pref.getInt('BEST') ?? 0;
    return best;
  }

  _putBest(int b) async {
    pref = await SharedPreferences.getInstance();
    int a = await _getBest();
    if (b > a) {
      pref.setInt('BEST', b);
    }
  }
}
