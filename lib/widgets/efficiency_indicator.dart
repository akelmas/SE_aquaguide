import 'package:flutter/material.dart';

class EfficiencyIndicator extends StatefulWidget  {
  final int value;

  const EfficiencyIndicator({Key key, this.value}) : super(key: key);

  @override
  _EfficiencyIndicatorState createState() => _EfficiencyIndicatorState();
}

class _EfficiencyIndicatorState extends State<EfficiencyIndicator> with TickerProviderStateMixin{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}