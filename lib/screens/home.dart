import 'package:device/blocs/health_device_data_bloc.dart';
import 'package:device/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/home_components/oximeter/oximeter.dart';
import '../components/home_components/tensiometer/tensiometer.dart';
import '../components/home_components/thermometer/thermometer.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget _widgetToBringOut;
  final _deviceBloc = HealthDeviceDataBloc();
  @override
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final bottomAppBar = Container(
      height: screenSize.height * 0.088,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(blurRadius: 9, offset: Offset(2, 7))]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: SvgPicture.asset("assets/images/pulse.svg"),
                  onPressed: () {
                    setState(() {
                      _widgetToBringOut =
                          _bringOut(OximeterMonitor(_deviceBloc), screenSize);
                    });
                  },
                ),
                IconButton(
                  icon: SvgPicture.asset("assets/images/thermometer.svg"),
                  onPressed: () {},
                ),
                Container(
                  width: 40,
                ),
                IconButton(
                  icon: SvgPicture.asset("assets/images/tensiometer.svg"),
                  onPressed: () {},
                ),
                IconButton(
                  icon: SvgPicture.asset("assets/images/history.svg"),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          InkWell(
            onTap: null,
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: Colors.white),
                child: SvgPicture.asset("assets/images/logo.svg")),
          ),
        ],
      ),
    );

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Health Device", style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: gradient)),
      ),
      bottomNavigationBar: bottomAppBar,
      body: Stack(alignment: Alignment.center, children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.038),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: screenSize.height * 0.3,
                child: OximeterMonitor(_deviceBloc),
              ),
              Container(
                height: screenSize.height * 0.22,
                child: ThermometerMonitor(_deviceBloc),
              ),
              Container(
                height: screenSize.height * 0.22,
                child: TensiometerMonitor(_deviceBloc),
              )
            ],
          ),
        ),
        (_widgetToBringOut != null) ? _widgetToBringOut : Container()
      ]),
    ));
  }

  Container _bringOut(Widget child, Size bodySize) => Container(
        height: bodySize.height * 0.5,
        child: child,
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 20, offset: Offset(4, 30))]),
      );
}
