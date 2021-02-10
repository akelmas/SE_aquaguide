import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:predixinote/pages/map_view.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/aquanote.dart';
import 'package:predixinote/types/plant.dart';
import 'package:url_launcher/url_launcher.dart';

class GpsInfo extends StatefulWidget {
  final Plant plant;
  final bool readonly;

  const GpsInfo({Key key, this.plant, this.readonly}) : super(key: key);

  @override
  _GpsInfoState createState() => _GpsInfoState();
}

class _GpsInfoState extends State<GpsInfo> {
  Location _location = new Location();
  bool permissionGranted = true;
  bool serviceEnabled = true;

  Future<void> checkPermission() async {
    PermissionStatus _permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        permissionGranted = false;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted != PermissionStatus.GRANTED) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        permissionGranted = false;
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _location.changeSettings(interval: 1000, accuracy: LocationAccuracy.HIGH);
    initTextControllers();
    updateParams();
  }

  void initTextControllers() {
    latController.addListener(() {
      widget.plant.locationData.latitude = double.parse(latController.text);
    });

    longController.addListener(() {
      widget.plant.locationData.longitude = double.parse(longController.text);
    });

    altController.addListener(() {
      widget.plant.locationData.altitude = double.parse(altController.text);
    });

    accController.addListener(() {
      widget.plant.locationData.accuracy = double.parse(accController.text);
    });
  }

  void disposeTextControllers() {
    latController.dispose();
    longController.dispose();
    altController.dispose();
    accController.dispose();
  }

  void updateParams() {
    latController.text = widget.plant.locationData.latitude.toStringAsFixed(5);
    longController.text = widget.plant.locationData.longitude.toStringAsFixed(5);
    altController.text = widget.plant.locationData.altitude.toStringAsFixed(2);
    accController.text = widget.plant.locationData.accuracy.toStringAsFixed(2);
  }


  void getLocationUsingGPS() {
    _location.getLocation().then((value) {
      widget.plant.locationData.latitude = value.latitude;
      widget.plant.locationData.longitude = value.longitude;
      widget.plant.locationData.altitude = value.altitude;
      widget.plant.locationData.accuracy = value.accuracy;
      updateParams();
    });
  }


  void setPlantLocation(LocationData value){
    widget.plant.locationData.latitude = value.latitude;
    widget.plant.locationData.longitude = value.longitude;
    widget.plant.locationData.altitude = value.altitude;
    widget.plant.locationData.accuracy = value.accuracy;
  }

  var latController = TextEditingController();
  var longController = TextEditingController();
  var altController = TextEditingController();
  var accController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!permissionGranted) {
      return Container(
          margin: EdgeInsets.only(left: 13, right: 13, top: 19),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("GPS izni bekleniyor"),
              CircularProgressIndicator(              )
            ],
          ));
    } else if (!serviceEnabled) {
      return Container(
          margin: EdgeInsets.only(left: 13, right: 13, top: 19),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("GPS servisi bekleniyor"),
              CircularProgressIndicator()
            ],
          ));
    }

    // TODO: implement build
    return GridView.count(
      shrinkWrap: true,
      padding: EdgeInsets.all(10),
      physics: new NeverScrollableScrollPhysics(),
      childAspectRatio:
          MediaQuery.of(context).orientation == Orientation.portrait ? 3 : 5,
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: <Widget>[
        TextFormField(
          controller: latController,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 0),
            border: OutlineInputBorder(),
            labelText: "Enlem",
            labelStyle: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        TextFormField(
          controller: altController,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          autocorrect: false,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 0),
            border: OutlineInputBorder(),
            labelText: "Rakım",
            labelStyle: TextStyle(fontSize: 16),
          ),
        ),
        TextFormField(
          controller: longController,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          autocorrect: false,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 0),
            border: OutlineInputBorder(),
            labelText: "Boylam",
            labelStyle: TextStyle(fontSize: 16,),
          ),
        ),
        TextFormField(
          controller: accController,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          autocorrect: false,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 0),
            border: OutlineInputBorder(),
            labelText: "Doğruluk",
            labelStyle: TextStyle(fontSize: 16),
          ),
        ),


        Card(
          child: ListTile(
            leading: SizedBox(
              height: 24,
              width: 24,
              child: Icon(Icons.gps_fixed,color: Colors.blue,),
            ),
            title: Text("Mevcut konum"),
            onTap: displayGpsSyncDialog
          ),
        ),
        Card(
          child: ListTile(
              leading: SizedBox(
                height: 24,
                width: 24,
                child: Icon(Icons.map_sharp,color: Colors.green,),
              ),
              title: Text("Haritadan seç"),
              onTap: ()=>goto(PlantMapView(plant: widget.plant,))
          ),
        ),
      ],
    );
  }

  Future<void> displayGpsSyncDialog() async {
    await checkPermission();
    LocationData _result;
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          contentPadding: EdgeInsets.all(10),
          title: Text(
            "Canlı GPS",
          ),

          content: StreamBuilder<LocationData>(
            stream: _location.onLocationChanged(),
            builder: (context, AsyncSnapshot<LocationData> snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text("GPS verisi alınıyor")
                  ],
                );
              }
              _result = snapshot.data;
              return Container(
                padding: EdgeInsets.all(10),
                child: Table(


                  children: [
                    TableRow(
                        children: [
                          TableCell(child: Text("Enlem")),
                          TableCell(
                            child: Text("${(_result.latitude*100000).floor()/100000}"),
                          ),
                        ]),
                    TableRow(children: [
                      TableCell(child: Text("Boylam")),
                      TableCell(
                        child: Text("${(_result.longitude*100000).floor()/100000}"),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Text("Rakım")),
                      TableCell(
                        child: Text("${(_result.altitude*100).floor()/100}"),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Text("Doğruluk")),
                      TableCell(
                        child: Text("${(_result.accuracy*100).floor()/100}"),
                      ),
                    ]),
                  ],
                ),
              );
            },
          ),
          actions: [
            OutlineButton.icon(onPressed: (){setPlantLocation(_result);Navigator.of(context).pop();updateParams();}, icon: Icon(Icons.done), label: Text("Uygula"),borderSide: BorderSide.none,),
            OutlineButton.icon(onPressed: ()=>Navigator.of(context).pop(), icon: Icon(Icons.cancel), label: Text("Vazgeç"),borderSide: BorderSide.none),
          ],


        );
      },
    );
  }

  Future<LocationData> getLocationUsingGps() async {
    LocationData res;
    _location.onLocationChanged().listen((event) {
      res = event;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    disposeTextControllers();
    DatabaseService().updatePlant(widget.plant);
  }
}
