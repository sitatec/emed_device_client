import 'package:device/blocs/health_device_data_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../widgets/home/custom_card.dart';
import 'package:flutter/material.dart';

class ThermometerMonitor extends StatefulWidget {
  final HealthDeviceDataBloc _deviceBloc;
  ThermometerMonitor(this._deviceBloc);
  @override
  State<StatefulWidget> createState() => _ThermometerMonitorState();
}

class _ThermometerMonitorState extends State<ThermometerMonitor> {
  double temperatureInCelsuis = 0.0;
  double _celsuisTofahrenheit() => ((temperatureInCelsuis * 1.8) + 32);

  @override
  void initState() {
    widget._deviceBloc.thermometerStream.listen((tempData) {
      setState(() {
        temperatureInCelsuis = tempData;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => CustomCard(
        title: "Thermometer",
        child: Stack(alignment: Alignment.center, children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: _buildDataWidget(context, temperatureInCelsuis, "°C"),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: _buildDataWidget(context, _celsuisTofahrenheit(), "°F"),
              )
            ],
          ),
          SvgPicture.asset(
            "assets/images/temperature_data_spliter.svg",
            fit: BoxFit.fitWidth,
          )
        ]),
      );
  Container _buildDataWidget(
          BuildContext context, double value, String symbol) =>
      Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("$value$symbol",
                style: TextStyle(fontSize: 44, color: Colors.white))
          ],
        ),
      );
}
