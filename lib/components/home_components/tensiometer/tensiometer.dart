import 'package:device/blocs/health_device_data_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../widgets/home/custom_card.dart';
import 'package:flutter/material.dart';

class TensiometerMonitor extends StatefulWidget {
  TensiometerMonitor(this._deviceBloc);
  HealthDeviceDataBloc _deviceBloc;
  @override
  State<StatefulWidget> createState() => _TensiometerMonitorState();
}

class _TensiometerMonitorState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) => CustomCard(
        title: "Tensiometer",
        child: Stack(alignment: Alignment.center, children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: _buildDataWidget(context, "DIA", 36.6),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: _buildDataWidget(context, "SYS", 97.8),
              )
            ],
          ),
          SvgPicture.asset("assets/images/tensiometer_data_spliter.svg")
        ]),
      );

  Container _buildDataWidget(
          BuildContext context, String label, double value) =>
      Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(label,
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.white,
                )),
            Text("${value.toInt()}",
                style: TextStyle(fontSize: 50, color: Colors.white))
          ],
        ),
      );
}
