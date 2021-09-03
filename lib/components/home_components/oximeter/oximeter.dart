import 'package:device/components/home_components/oximeter/oscilloscope.dart';

import '../../../widgets/home/custom_card.dart';
import '../../../blocs/health_device_data_bloc.dart';
import 'package:flutter/material.dart';

class OximeterMonitor extends StatefulWidget {
  OximeterMonitor(this._deviceBloc);
  final HealthDeviceDataBloc _deviceBloc;
  @override
  State<StatefulWidget> createState() => _OximeterState();
}

class _OximeterState extends State<OximeterMonitor> {
  double _heartRate = 0.0;
  int _spo2 = 0;

  Stream<double> _oximeterDataStream;
  var dataList = <double>[];
  @override
  void initState() {
    _oximeterDataStream = widget._deviceBloc.oximeterStream;
    _oximeterDataStream.listen((event) {
      setState(() {
        dataList.add(event);
      });
    });

    widget._deviceBloc.heartRateStream.listen((event) {
      setState(() {
        _heartRate = event;
      });
    });

    widget._deviceBloc.spo2Stream.listen((event) {
      setState(() {
        _spo2 = event;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => CustomCard(
      title: "Oximeter",
      child: Column(children: [
        Expanded(
          flex: 3,
          child: Oscilloscope(
            dataSet: dataList,
            backgroundColor: Color(0x00000000),
            traceColor: Colors.white,
            yAxisMin: -160,
            yAxisMax: 220,
          ),
        ),
        Expanded(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDataWidget(context, "BMP", _heartRate),
            _buildDataWidget(context, "SPO2", _spo2, true)
          ],
        )),
      ]));

  Container _buildDataWidget(BuildContext context, String label, num value,
          [bool isSpo2 = false]) =>
      Container(
        width: MediaQuery.of(context).size.width * (isSpo2 ? 0.5 : 0.4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(label,
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                )),
            Text("$value${isSpo2 ? "%" : ""}",
                style: TextStyle(fontSize: 30, color: Colors.white))
          ],
        ),
      );
}
