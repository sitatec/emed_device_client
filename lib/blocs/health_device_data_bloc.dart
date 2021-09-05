import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audio_cache.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

class HealthDeviceDataBloc {
  StreamController<double> _oximeterStreamController;
  StreamController<int> _spo2StreamController;
  StreamController<double> _heartRateStreamController;
  StreamController<double> _thermometerStreamController;
  StreamController<double> _tensiometerStreamController;
  StreamSink<double> _oximeterSink,
      _thermometerSink,
      _tensiometerSink,
      _heartRateSink;
  StreamSink<int> _spo2Sink;
  Stream<double> get oximeterStream => _oximeterStreamController.stream;
  Stream<double> get thermometerStream => _thermometerStreamController.stream;
  Stream<double> get tensiometerStream => _tensiometerStreamController.stream;
  Stream<int> get spo2Stream => _spo2StreamController.stream;
  Stream<double> get heartRateStream => _heartRateStreamController.stream;
  final _soundPlayer = AudioCache();

  String _oximeterDataBuffer = "";
  bool _thermometerStreamIsListened = false;
  final _bleManager = BleManager();
  BleManager get bleManager => _bleManager;
  bool _deviceIsConnected = false;
  Peripheral _healthDevice;

  HealthDeviceDataBloc() {
    _oximeterStreamController =
        StreamController<double>(onListen: _startOximeterDataStream);
    _thermometerStreamController = StreamController<double>(
        onListen: () => _thermometerStreamIsListened = true);
    _tensiometerStreamController = StreamController<double>();
    _spo2StreamController = StreamController<int>();
    _heartRateStreamController = StreamController<double>();

    _oximeterSink = _oximeterStreamController.sink;
    _thermometerSink = _thermometerStreamController.sink;
    _tensiometerSink = _tensiometerStreamController.sink;
    _heartRateSink = _heartRateStreamController.sink;
    _spo2Sink = _spo2StreamController.sink;
    _initBle();
  }

  Future<void> _startOximeterDataStream() async {
    await _startStream(_monitorOximeterData);
  }

  Future<void> _startStream(void Function() onListen) async {
    if (_deviceIsConnected)
      onListen();
    else
      await _connectDevice(onListen);
  }

  Future<void> _monitorOximeterData() async {
    await _handleReceivedData((value) {
      //    print("\n____ Data before parsing : $value ____\n");
      var oximeterIrLedValue = double.tryParse(value);
      //  print("\n____ Parsed data : $oximeterIrLedValue ____\n");
      if (oximeterIrLedValue != null)
        _oximeterSink.add(oximeterIrLedValue);
      else
        _checkDataType(value);
    });
  }

  Future<void> _handleReceivedData(void Function(dynamic) _process) async {
    final characteristicsList = await _healthDevice?.characteristics(
      "FFE0",
    );
    characteristicsList.first.monitor().listen((value) {
      _splitData(utf8.decode(value)).forEach(_process);
    });
  }

/*
  Future<void> _startThermometerStream() async {
    await _startStream(_monitorThermometerData);
  }

  Future<void> _monitorThermometerData() async {
    _handleReceivedData((temperatureValue) {
      var temperature = double.tryParse(temperatureValue);
      if (temperature != null) _temperatureSink.add(temperature);
    });
  }
*/
  void _checkDataType(String data) {
    if (data == "B") {
      _playSound();
    } else if (data.startsWith("D")) {
      _handleHeartRateAndSpo2Data(data);
    } else if (_thermometerStreamIsListened && data.startsWith("T")) {
      _handleTemperatureData(data);
    }
  }

  void _handleHeartRateAndSpo2Data(String data) {
    final cleanedData = data.substring(1, data.length - 1);
    final temp = cleanedData.split("_");
    final heartRateValue = double.tryParse(temp.first);
    final spo2Value = int.tryParse(temp.last);
    print("\n HEART RATE: $heartRateValue \n SPO2: $spo2Value\n");
    if (heartRateValue != null) _heartRateSink.add(heartRateValue);
    if (spo2Value != null) _spo2Sink.add(spo2Value);
  }

  void _handleTemperatureData(String data) {
    print("----____Temperature Value === $data ____--- ");
    var temperature = double.tryParse(data.substring(1));
    print("----____Parsed Temperature Value === $temperature ____--- ");
    if (temperature != null) _thermometerSink.add(temperature);
  }

  List<String> _splitData(String data) {
    if (data.isEmpty)
      return <String>[];
    else {
      if (data.endsWith("/")) {
        if (_oximeterDataBuffer.isEmpty) {
          return data.split("/");
        } else {
          var temp = (_oximeterDataBuffer + data).split("/");
          _oximeterDataBuffer = "";
          return temp;
        }
      } else if (_oximeterDataBuffer.isEmpty) {
        var tempList = data.split("/");
        _oximeterDataBuffer = tempList.last;
        tempList?.removeLast();
        return tempList;
      } else {
        var tempData = (_oximeterDataBuffer + data).split("/");
        _oximeterDataBuffer = tempData.last;
        tempData.removeLast();
        return tempData;
      }
    }
  }

  void _playSound() async {
    print('\n\n ---- playing sound ----- \n\n');
    _soundPlayer.play("sounds/beep.mp3");
    print("\n\n ----- finished ----- \n\n");
  }

  Future<void> _connectDevice(void Function() onConnected) async {
    _bleManager.startPeripheralScan(uuids: ["FFE0"]).listen((scanResult) async {
      if (scanResult.advertisementData.localName != null &&
          _healthDevice == null) {
        _healthDevice = scanResult.peripheral;
        await _bleManager.stopPeripheralScan();

        await _healthDevice.connect();
        await _healthDevice.discoverAllServicesAndCharacteristics();
        _deviceIsConnected = await _healthDevice.isConnected();
        if (_deviceIsConnected) onConnected();
      }
    });
  }

  void _initBle() async {
    await _bleManager.createClient();
    await _checkPermissions();
    _bleManager.bluetoothState().then((state) async {
      if (state == BluetoothState.POWERED_OFF && Platform.isAndroid)
        await _bleManager.enableRadio();
    });
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      var permissionStatus = await Permission.location.request();

      if (!permissionStatus.isGranted) {
        return Future.error(Exception("Location permission not granted"));
      }
    }
  }
}
