import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier {
  MQTTAppConnectionState _appConnectionState =
      MQTTAppConnectionState.disconnected;
  String _receivedText = '';
  String _historyText = '';

  void setReceivedText(String text) {
    _receivedText = text;
    _historyText = '$_historyText\n$_receivedText';
    notifyListeners();
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get getReceivedText => _receivedText;
  String get getHistoryText => _historyText;
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    Widget titleSection = Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(30),
      decoration: BoxDecoration(
          border: Border.all(width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(20.0))),
      child: Row(children: [
        /* Change to Picture later */
        Icon(
          Icons.star,
          color: Colors.amber[100],
        ),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                padding: const EdgeInsets.all(8),
                child: RichText(
                    text: TextSpan(
                  text: 'Xin chào, ',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Huy Hoàng',
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black))
                  ],
                ))),
          ]),
        )
      ]),
    );
    Color color = Theme.of(context).primaryColor;
    Widget sensorValue = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 33,
                left: 21,
                bottom: 14,
              ),
              child: Text(
                'Thiết bị',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSensorColumn(color, Icons.water_drop, '10 Lit'),
            _buildSensorColumn(color, Icons.battery_4_bar_rounded, '80%'),
            _buildSensorColumn(
                color, Icons.signal_cellular_4_bar_rounded, 'Good'),
          ],
        )
      ],
    );
    Widget homeProfile = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSensorColumn(color, Icons.home, 'Home'),
        _buildSensorColumn(color, Icons.person, 'Profile'),
      ],
    );
    Widget image = Image.asset(
      'images/smartcity.jpg',
      width: 360,
      height: 197,
      fit: BoxFit.cover,
    );

    Widget monthCost = Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 34,
                left: 21,
                bottom: 8,
              ),
              child: Text(
                'Giá tiền theo tháng',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(10),
          width: 300,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1.0,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Text(
            'Tháng 3: 200k',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
    return MaterialApp(
      title: "Water Meter Monitor",
      home: Scaffold(
          appBar: AppBar(
            title: const Text("Water Meter Monitor"),
          ),
          body: Column(
            children: [
              image,
              titleSection,
              sensorValue,
              monthCost,
              homeProfile,
            ],
          )),
    );
  }

  Column _buildSensorColumn(Color color, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: color,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
