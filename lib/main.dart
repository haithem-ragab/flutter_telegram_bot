import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitcoin Update',
      home: BitcoinTelegramBot(),
    );
  }
}

class BitcoinTelegramBot extends StatefulWidget {
  @override
  _BitcoinTelegramBotState createState() => _BitcoinTelegramBotState();
}

class _BitcoinTelegramBotState extends State<BitcoinTelegramBot> {
  bool isStart;
  List result = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  setState(() => isStart = true);
                  double changes = 0.0;
                  double currentValueUSD = 0.0;
                  double currentValueEUR = 0.0;
                  double prevValue = 0.0;


                  var teledart =
                  TeleDart(Telegram('Please use your Telegram BOT Token')
                      , Event());

                  var url =
                      'https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD,EUR&=Your api key';
                  print('Date, BTC-USD, BTC-EUR');

                  while (isStart) {
                    DateTime currentTime = DateTime.now();
                    var response = await http.get(url);
                    var jsonResponse = convert.jsonDecode(response.body);

                    currentValueUSD = jsonResponse["USD"];
                    currentValueEUR = jsonResponse["USD"];

                    result.add(
                        '${currentTime.year}-${currentTime.month}-${currentTime.day} ${currentTime.hour}:${currentTime.minute}, $currentValueUSD : $currentValueEUR');
                    print(result.last);

                    changes = currentValueUSD - prevValue;
                    prevValue = currentValueUSD;


                    teledart.telegram.sendMessage('Please use your Telegram Chat ID',
                        'Bithumb-BTC-USD : \$${currentValueUSD.toString()} UP ${changes.toStringAsFixed(2)}');
                    await Future.delayed(Duration(minutes: 1));
                  }
                },
                child: Text('Start'),
              ),
              SizedBox(height: 10),
              RaisedButton(
                onPressed: () {
                  setState(() => isStart = false);
                  print('Stop');
                },
                child: Text('Stop'),
              ),
              SizedBox(height: 10),
              RaisedButton(
                onPressed: () async {
                  try {
                    final CollectionReference bitcoin =
                    FirebaseFirestore.instance.collection('bitcoin');

                    DocumentReference bitcoinPrice = bitcoin.doc('price');
                    print(result);
                    await bitcoinPrice.set({'Date, BTC-USD, BTC-EUR': result});
                  } catch (e) {
                    print(e.toString());
                  }
                },
                child: Text('Store in firebase'),
              ),
            ],
          ),
        ));
  }
}