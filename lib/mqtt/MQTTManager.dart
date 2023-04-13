import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter_learn_the_basics/mqtt/state/MQTTAppState.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_learn_the_basics/api/notification_api.dart';
import 'package:intl/intl.dart';

class MQTTManager {
  // Private instance of client
  final MQTTAppState _currentState;
  late MqttServerClient _client;
  final String _identifier;
  final String _host;
  final String _topic;

  // Constructor
  // ignore: sort_constructors_first
  MQTTManager(
      {required String host,
      required String topic,
      required String identifier,
      required MQTTAppState state})
      : _identifier = identifier,
        _host = host,
        _topic = topic,
        _currentState = state;

  void initializeMQTTClient() {
    _client = MqttServerClient(_host, _identifier);
    _client.port = 1884;
    _client.keepAlivePeriod = 20;
    _client.onDisconnected = onDisconnected;
    _client.secure = false;
    _client.logging(on: true);

    /// Add the successful connection callback
    _client.onConnected = onConnected;
    _client.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    //print('Client connecting....');
    _client.connectionMessage = connMess;
    late NotificationService notificationService = NotificationService();
    notificationService.initializePlatformNotifications();
  }

  // Connect to the host
  // ignore: avoid_void_async
  void connect() async {
    assert(_client != null);
    try {
      //print('Client start connecting....');
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await _client.connect();
    } on Exception catch (e) {
      //('Client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    //print('Disconnected');
    _client.disconnect();
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    //print('Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    //print('OnDisconnected client callback - Client disconnection');
    if (_client.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      //print('OnDisconnected callback is solicited, this is correct');
    }
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  /// The successful connect callback
  void onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    //print('Client connected....');
    _client.subscribe(_topic, MqttQos.atLeastOnce);
    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      // final MqttPublishMessage recMess = c![0].payload;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _currentState.setReceivedText(pt);
      List pairs = pt.split(",");

      // print(pairs);
      String leak;

      if (pairs.length < 4) {
        leak = "0";
      } else {
        leak = pairs[3];
        int idxLeak = leak.indexOf(":");
        leak = leak.substring(idxLeak + 1).trim();
      }
      if (leak == "1") {
        NotificationService().showLocalNotification(
            id: 0,
            title: "Cảnh báo!",
            body: "Phát hiện rò rỉ nước!",
            payload: "detected",
            seconds: 1);
      }
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('kk:mm:ss').format(now);
      _currentState.setDate(formattedDate);
      print("$formattedDate");
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });
    // print(
    //     'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }
}
