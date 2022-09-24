import 'dart:async';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

int level = 8;
int matchesWon = 0;

class MemoryCardGameScreen extends StatefulWidget {
  final int size;

  const MemoryCardGameScreen({Key? key, this.size = 8}) : super(key: key);

  @override
  _MemoryCardGameScreenState createState() => _MemoryCardGameScreenState();
}

class _MemoryCardGameScreenState extends State<MemoryCardGameScreen> {
  List<bool> cardFlips = [];
  List<String> data = [];
  int lastIndex = -1;
  int attempts = 0;
  bool isCardFlip = false;
  List<GlobalKey<FlipCardState>> cardStateKeys = [];

  int time = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 16; i++) {
      cardStateKeys.add(GlobalKey<FlipCardState>());
      cardFlips.add(true);
    }
    data = [
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H"
    ];
    startTimer();
    data.shuffle();
  }

  startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        time = time + 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(width / 10),
                child: Text(
                  "Time: $time",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(width / 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  itemBuilder: (context, index) => FlipCard(
                    key: cardStateKeys[index],
                    onFlip: () {
                      if (!isCardFlip) {
                        attempts += 1;
                        isCardFlip = true;
                        lastIndex = index;
                      } else {
                        isCardFlip = false;
                        if (lastIndex != index) {
                          if (data[lastIndex] != data[index]) {
                            cardStateKeys[lastIndex].currentState?.toggleCard();
                            lastIndex = index;
                          } else {
                            matchesWon += 1;
                            cardFlips[lastIndex] = false;
                            cardFlips[index] = false;

                            print(cardFlips);
                            showCustomDialog();

                            /*if (cardFlips.every((t) => t == false)) {
                              showResult();
                            }*/
                          }
                        }
                      }
                    },
                    direction: FlipDirection.HORIZONTAL,
                    flipOnTouch: cardFlips[index] = !cardFlips[index],
                    front: Container(
                      margin: EdgeInsets.all(4.0),
                      color: Colors.blue.withOpacity(0.3),
                    ),
                    back: Container(
                      margin: EdgeInsets.all(4.0),
                      color: Colors.blue,
                      child: Center(
                        child: Text(
                          "${data[index]}",
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                    ),
                  ),
                  itemCount: data.length,
                ),
              ),
              Text(
                "Matches Completed:\n$matchesWon",
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              Text(
                "Attempts:\n$attempts",
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  showCustomDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Won!!!"),
        content: Text(
          "Time Taken: $time",
          style: Theme.of(context).textTheme.headline4,
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MemoryCardGameScreen(
                    size: level,
                  ),
                ),
              );
              level *= 2;
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }
}
