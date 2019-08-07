import 'package:flutter/material.dart';
import 'dart:async';

final _myListKey = GlobalKey<AnimatedListState>();

class PageModel {
  Timer timer;
  bool started = false;
  int currentPersonTalking = 0;
  int totalElapsedMiliseconds = 0;
  bool shouldRestart = true;
  Map<int, int> peopleStanDupTimes = new Map();
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Skram Master: Faster'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final PageModel pageModel = new PageModel();
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState(pageModel: pageModel);
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState({this.pageModel});
  final PageModel pageModel;

  void resetTimer() {
    setState(() {
      if (pageModel.shouldRestart) {
        pageModel.shouldRestart = false;
        pageModel.started = true;
        for (var i = 0; i <= pageModel.peopleStanDupTimes.length - 1; i++) {
          _myListKey.currentState.removeItem(
            0,
            (BuildContext context, Animation<double> animation) => Container(),
          );
        }
        pageModel.peopleStanDupTimes.clear();
        pageModel.totalElapsedMiliseconds = 0;
        pageModel.currentPersonTalking = 0;
        Future.delayed(const Duration(milliseconds: 200), addNewPerson);
      } else {
        addNewPerson();
      }
      if (pageModel.timer != null) {
        pageModel.timer.cancel();
        pageModel.timer = null;
      }

      pageModel.timer =
          new Timer.periodic(new Duration(seconds: 1), timerCallback);
    });
  }

  void addNewPerson() {
    pageModel.peopleStanDupTimes[pageModel.currentPersonTalking++] = 0;
    _myListKey.currentState.insertItem(pageModel.currentPersonTalking - 1,
        duration: const Duration(milliseconds: 200));
  }

  void timerCallback(Timer timer) {
    setState(() {
      pageModel.started = true;
      int currentIndex = pageModel.currentPersonTalking - 1;
      int currentTime = pageModel.peopleStanDupTimes[currentIndex];
      pageModel.peopleStanDupTimes[currentIndex] = ++currentTime;
      pageModel.totalElapsedMiliseconds++;
    });
  }

  void stop() {
    setState(() {
      if (pageModel.timer != null) {
        pageModel.timer.cancel();
        pageModel.timer = null;
      }
      pageModel.shouldRestart = true;
      pageModel.started = false;
    });
  }

  Widget buildItem(
      BuildContext context, int index, Animation<double> animation) {
    if (index >= pageModel.peopleStanDupTimes.length) {
      return null;
    }
    int value = pageModel.peopleStanDupTimes[index];
    String mood = (value < 61) ? ":)" : (value < 121) ? ":|" : ":(";
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: ListTile(
        dense: true,
        title: Text(
          "${index + 1}. ${getFormattedTime(value)}",
          style: new TextStyle(fontSize: 13 + value.toDouble() / 10),
        ),
        subtitle: Text(
          mood,
          style: new TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TimerText(pageModel: pageModel),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  child: RaisedButton(
                    onPressed: pageModel.started ? stop : resetTimer,
                    child: Text(pageModel.started ? "Koniec" : "Start"),
                  ),
                )
              ],
            ),
            Expanded(
              child: new AnimatedList(
                  key: _myListKey,
                  initialItemCount: pageModel.currentPersonTalking,
                  itemBuilder: buildItem),
            )
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: resetTimer,
          tooltip: 'Increment',
          child: pageModel.started ? Icon(Icons.person_add) : Icon(Icons.add),
        ),
      ),
    );
  }
}

class TimerText extends StatefulWidget {
  TimerText({this.pageModel});
  final PageModel pageModel;
  TimerTextState createState() => new TimerTextState(pageModel: pageModel);
}

class TimerTextState extends State<TimerText> {
  TimerTextState({this.pageModel});
  final PageModel pageModel;

  @override
  Widget build(BuildContext context) {
    TextStyle timerTextStyle =
        const TextStyle(fontSize: 20, color: Colors.black87);
    return new Text(
        "Czas standupu: ${getFormattedTime(pageModel.totalElapsedMiliseconds)}",
        style: timerTextStyle,
        textAlign: TextAlign.center);
  }
}

String getFormattedTime(elapsedMilisceconds) {
  String minutes =
      (elapsedMilisceconds / 60).floor().toString().padLeft(2, "0");
  String seconds = (elapsedMilisceconds % 60).toString().padLeft(2, "0");
  return "$minutes:$seconds";
}
