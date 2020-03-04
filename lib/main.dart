import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

bool notificationLaunched = false;
final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  notificationLaunched =
      (await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails())
          .didNotificationLaunchApp;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      routes: {
        '/second': (_) => SecondScreen('routeCall'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: title != null ? Text(title) : null,
        content: body != null ? Text(body) : null,
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SecondScreen(payload),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Future<void> _scheduleNotification() async {
    var scheduleTime = DateTime.now().add(Duration(seconds: 5));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channe',
      'channe',
      'descrip',
      ticker: 'ticker',
      importance: Importance.Max,
      priority: Priority.Max,
      playSound: true,
      sound: "sound",
      category: "call",
      onlyAlertOnce: false,
      enableVibration: true,
      ongoing: true,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
      0,
      'Alarm Channel',
      'Alarm',
      scheduleTime,
      platformChannelSpecifics,
      payload: 'alarm with sound',
      androidAllowWhileIdle: true,
    );
  }

  @override
  void initState() {
    var initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initIos = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initSettings = InitializationSettings(initAndroid, initIos);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: (String payload) async {
      debugPrint('onSelectNotification');
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SecondScreen(payload)),
          ModalRoute.withName('/'));
    }).then((x) => debugPrint('InitState and initialised called'));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Screen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('First normal Screen'),
          FlatButton(
            onPressed: _scheduleNotification,
            child: Text('Schedule Notification'),
          )
        ],
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  final String pay;
  SecondScreen(this.pay);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Notification call'),
        ),
        body: Center(
            child: RaisedButton(
          child: Text(pay),
          onPressed: () => Navigator.of(context).pop(),
        )));
  }
}
