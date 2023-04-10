import 'package:flutter/material.dart';
import 'package:flutter_learn_the_basics/api/notification_api.dart';
import 'package:provider/provider.dart';
import 'package:flutter_learn_the_basics/mqtt/state/MQTTAppState.dart';
import 'package:flutter_learn_the_basics/mqtt/MQTTManager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MQTTView extends StatefulWidget {
  const MQTTView({super.key});
  @override
  State<StatefulWidget> createState() {
    return _MQTTViewState();
  }
}

class _MQTTViewState extends State<MQTTView> {
  late MQTTAppState currentAppState;
  late MQTTManager manager;
  late NotificationService notificationService;
  @override
  void initState() {
    notificationService = NotificationService();
    notificationService.initializePlatformNotifications();
    super.initState();

    /*
    _hostTextController.addListener(_printLatestValue);
    _messageTextController.addListener(_printLatestValue);
    _topicTextController.addListener(_printLatestValue);

     */
  }

  /*
  _printLatestValue() {
    print("Second text field: ${_hostTextController.text}");
    print("Second text field: ${_messageTextController.text}");
    print("Second text field: ${_topicTextController.text}");
  }

   */

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;
    final Scaffold scaffold = Scaffold(body: _buildColumn());
    return scaffold;
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Water Meter Monitor'),
      backgroundColor: Colors.greenAccent,
    );
  }

  Widget _buildColumn() {
    return Column(
      children: <Widget>[
        image,
        titleSection,
        _buildConnectionStateText(
            _prepareStateMessageFrom(currentAppState.getAppConnectionState)),
        _buildSensorValueDisplay(currentAppState.getReceivedText),
        _buildEditableColumn(),
        const Spacer(
          flex: 1,
        ),
        homeProfile(),
      ],
    );
  }

  Widget _buildEditableColumn() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          _buildConnecteButtonFrom(currentAppState.getAppConnectionState),
        ],
      ),
    );
  }

  Widget _buildConnectionStateText(String status) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              color: Colors.deepOrangeAccent,
              child: Text(status, textAlign: TextAlign.center)),
        ),
      ],
    );
  }

  Widget _buildConnecteButtonFrom(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
          // ignore: deprecated_member_use
          child: ElevatedButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            onPressed: state == MQTTAppConnectionState.disconnected
                ? _configureAndConnect
                : null, //
            child: const Text('Connect'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          // ignore: deprecated_member_use
          child: ElevatedButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: state == MQTTAppConnectionState.connected
                ? _disconnect
                : null, //
            child: const Text('Disconnect'),
          ),
        ),
      ],
    );
  }

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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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

  Widget homeProfile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildSensorColumn(Colors.blue, Icons.home, 'Home'),
        _buildSensorColumn(Colors.blue, Icons.person, 'Profile'),
      ],
    );
  }

  Widget _buildSensorColumn(Color color, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
          size: 40,
        ),
        Container(
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

  Widget _buildSensorValueDisplay([String text = "bat:0,vol:0,sig:0,leak:0"]) {
    late List pairs = text.split(",");
    late IconData batteryIcon, signalIcon, leakIcon;
    // print(pairs);
    late String battery, volume, signal, leak;

    if (pairs.length < 4) {
      battery = volume = signal = leak = "0";
    } else {
      battery = pairs[0];
      int idxBattery = battery.indexOf(":");
      battery = battery.substring(idxBattery + 1).trim();

      volume = pairs[1];
      int idxVolume = volume.indexOf(":");
      volume = volume.substring(idxVolume + 1).trim();

      signal = pairs[2];
      int idxSignal = signal.indexOf(":");
      signal = signal.substring(idxSignal + 1).trim();

      leak = pairs[3];
      int idxLeak = leak.indexOf(":");
      leak = leak.substring(idxLeak + 1).trim();
    }

    double money = double.parse(volume);

    double batteryInt = double.parse(battery);
    int signalInt = int.parse(signal);
    int leakInt = int.parse(leak);
    String batteryString, signalString, leakString;
    if (batteryInt > 2.8) {
      if (batteryInt > 3.1) {
        batteryIcon = Icons.battery_6_bar_rounded;
        batteryString = "Tuyệt vời";
      } else {
        batteryIcon = Icons.battery_4_bar_rounded;
        batteryString = "Tốt";
      }
    } else {
      if (batteryInt < 2.6) {
        batteryIcon = Icons.battery_2_bar_rounded;
        batteryString = "Trung bình";
      } else {
        batteryIcon = Icons.battery_1_bar_rounded;
        batteryString = "Kém";
      }
    }

    if (signalInt > 10) {
      if (signalInt > 20) {
        signalIcon = Icons.signal_cellular_alt_rounded;
        signalString = "Tuyệt vời";
      } else {
        signalIcon = Icons.signal_cellular_alt_2_bar_rounded;
        signalString = "Tốt";
      }
    } else {
      if (signalInt > 5) {
        signalIcon = Icons.signal_cellular_alt_1_bar_rounded;
        signalString = "Trung bình";
      } else {
        signalIcon = Icons.signal_cellular_0_bar;
        signalString = "Kém";
      }
    }

    if (leakInt == 1) {
      leakIcon = Icons.water_damage_rounded;
      leakString = "Rò rỉ";
      NotificationService().showLocalNotification(
          id: 0,
          title: "Drink Water",
          body: "Time to drink some water!",
          payload: "You just took water! Huurray!");
    } else {
      leakIcon = Icons.house;
      leakString = "Bình thường";
    }

    if (money < 10) {
      money = money * 5.937;
    } else if (money < 20) {
      money = 10 * 5.937 + (money - 10) * 7.052;
    } else if (money < 30) {
      money = 10 * 5.937 + 10 * 7.052 + (money - 20) * 8.669;
    } else {
      money = 10 * 5.937 + 10 * 7.052 + 10 * 8.669 + (money - 30) * 15.925;
    }
    String inString = money.toStringAsFixed(4);
    double indouble = double.parse(inString);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss').format(now);
    return Column(
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
            _buildSensorColumn(Colors.blue, Icons.water_drop, volume),
            _buildSensorColumn(Colors.blue, batteryIcon, batteryString),
            _buildSensorColumn(Colors.blue, signalIcon, signalString),
            _buildSensorColumn(Colors.blue, leakIcon, leakString),
            _buildSensorColumn(Colors.blue, Icons.timer, formattedDate),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 34,
                left: 21,
                bottom: 8,
              ),
              child: Text(
                'Giá tiền theo tháng: $indouble',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget image = Image.asset(
    'images/smartcity.jpg',
    width: 360,
    height: 197,
    fit: BoxFit.cover,
  );

  // Widget monthCost(String volume) {
  //   int usedWater = int.parse(volume);
  //   return Column(
  //     children: [
  //       Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.only(
  //               top: 34,
  //               left: 21,
  //               bottom: 8,
  //             ),
  //             child: Text(
  //               'Giá tiền theo tháng: $money',
  //               style: GoogleFonts.inter(
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // Utility functions
  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  void _configureAndConnect() {
    // ignore: flutter_style_todos
    // TODO: Use UUID
    manager = MQTTManager(
        host: "171.244.173.204",
        topic: "watermeter1/messages",
        identifier: "User",
        state: currentAppState);
    manager.initializeMQTTClient();
    manager.connect();
  }

  void _disconnect() {
    manager.disconnect();
  }
}
