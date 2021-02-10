import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:predixinote/pages/plant_view.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/services/google_map.dart';
import 'package:predixinote/types/aquanote.dart';
import 'package:predixinote/types/constants.dart';
import 'package:predixinote/types/plant.dart';
import 'package:predixinote/types/plant_group.dart';
import 'package:predixinote/types/project.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class PlantMapView extends StatefulWidget {
  final Plant plant;

  const PlantMapView({Key key, this.plant}) : super(key: key);

  @override
  _PlantMapViewState createState() => _PlantMapViewState();
}

class _PlantMapViewState extends State<PlantMapView> {
  Completer<GoogleMapController> _controller = Completer();

  CameraPosition _kGooglePlex;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _kGooglePlex = CameraPosition(
      target: LatLng(widget.plant.locationData.latitude,
          widget.plant.locationData.longitude),
      zoom: 7,
    );
  }

  Future confirmLocationChangeDialog(LatLng newLoc) async {
    return showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text('Onaylıyor musunuz?'),
          content: Container(
            padding: EdgeInsets.all(10),
            child: RichText(
              text: TextSpan(children: [
                TextSpan(text: "Bu noktaya ait konum bilgisi güncellenecektir.")
              ]),
            ),
          ),
          contentPadding: EdgeInsets.all(10),
          actions: [
            OutlineButton.icon(
              borderSide: BorderSide.none,
              icon: Icon(Icons.done),
              label: Text("Onayla"),
              onPressed: () {
                _controller.future.then((value) => value.animateCamera(CameraUpdate.newLatLng(newLoc)));
                widget.plant.locationData.latitude = newLoc.latitude;
                widget.plant.locationData.longitude = newLoc.longitude;
                widget.plant.locationData.altitude = 0.0;
                widget.plant.locationData.accuracy = 0.0;
                DatabaseService().updatePlant(widget.plant);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
            OutlineButton.icon(
              borderSide: BorderSide.none,
              icon: Icon(Icons.cancel_outlined),
              label: Text("Vazgeç"),
              onPressed: () {

                _controller.future.then((value) => value.animateCamera(CameraUpdate.newLatLng(LatLng(widget.plant.locationData.latitude,widget.plant.locationData.longitude))));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "${widget.plant.name}",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                goback();
              }),
          elevation: 2,
          backgroundColor: appBarBackgroundColor,
        ),
        body: Stack(
          children: [
            GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.hybrid,
              initialCameraPosition: _kGooglePlex,
              markers: <Marker>{
                Marker(
                  markerId: MarkerId(widget.plant.uid),
                  position: LatLng(widget.plant.locationData.latitude,
                      widget.plant.locationData.longitude),
                  infoWindow: InfoWindow(
                      title: "${widget.plant.name} (${widget.plant.type})",
                      snippet: widget.plant.additionalInfo,
                      onTap: () => print("clicked")),
                  draggable: true,
                  onDragEnd: (value) => confirmLocationChangeDialog(value),
                ),
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onLongPress: (argument) => confirmLocationChangeDialog(argument),
            ),
            MapSearchBar(
              onLocationSelected: (place) =>
                  confirmLocationChangeDialog(place.location),
            )
          ],
        ));
  }
/*
  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

 */
}

class GroupMapView extends StatefulWidget {
  final PlantGroup plantGroup;

  const GroupMapView({Key key, this.plantGroup}) : super(key: key);
  @override
  _GroupMapViewState createState() => _GroupMapViewState();
}

class _GroupMapViewState extends State<GroupMapView> {
  Completer<GoogleMapController> _controller = Completer();

  CameraPosition _kGooglePlex;

  final plants = <Plant>[];
  final markers = <Marker>[];
  bool loading = false;

  Future calculateMeanPositionAndSetMarkers() async {
    await DatabaseService()
        .plantsCollection
        .where("groupId", isEqualTo: widget.plantGroup.uid)
        .get()
        .then((snapshot) => snapshot.docs.forEach((doc) {
              plants.add(Plant.fromJson(doc.data()));
            }));
    double lat = 0, long = 0;
    double minLat = 180, maxLat = -180, minLong = 90, maxLong = -90;
    double zoom;

    plants.forEach((plant) {
      if (minLat > plant.locationData.latitude) {
        minLat = 1.0 * plant.locationData.latitude;
      }
      if (maxLat < plant.locationData.latitude) {
        maxLat = 1.0 * plant.locationData.latitude;
      }
      if (minLong > plant.locationData.longitude) {
        minLong = 1.0 * plant.locationData.longitude;
      }
      if (maxLong < plant.locationData.longitude) {
        maxLong = 1.0 * plant.locationData.longitude;
      }

      lat += plant.locationData.latitude / plants.length;
      long += plant.locationData.longitude / plants.length;
      markers.add(
        new Marker(
          markerId: MarkerId(plant.uid),
          position: LatLng(plant.locationData.latitude * 1.0,
              plant.locationData.longitude * 1.0),
          infoWindow: InfoWindow(
              title: "${plant.name} (${plant.type})",
              snippet: plant.additionalInfo,
              onTap: () => goto(PlantView(plant: plant))),
        ),
      );
    });
    double dist = sqrt(pow(maxLat - minLat, 2) + pow(maxLong - minLong, 2));

    print("DIST $dist");
    zoom = -(log(dist + 0.000001) / log(2) - 6);
    print("ZOOOOOOOM" + zoom.toString());
    _kGooglePlex = CameraPosition(target: LatLng(lat, long), zoom: zoom);
  }

  @override
  void initState() {
    loading = true;
    calculateMeanPositionAndSetMarkers().then((value) {
      loading = false;
      if (mounted) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.satellite,
            initialCameraPosition:
                _kGooglePlex ?? CameraPosition(target: LatLng(39, 35), zoom: 7),
            markers: Set.from(markers),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onLongPress: (latLng) async {
              await addPlantDialogOverMap(latLng);
            },
          );
  }

  Future addPlantDialogOverMap(LatLng latLng) async {
    print(latLng);
    String name;

    String error;
    bool progress = false;
    return showDialog<void>(
      barrierDismissible: true, // us
      context: context, // er must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            title: Text('Yeni ölçüm'),
            contentPadding: EdgeInsets.all(10),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      child: TextFormField(
                        initialValue: name,
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: 20),
                        onChanged: (value) {
                          name = value;
                        },
                        decoration: InputDecoration(
                          errorText: error,
                          labelText: "Ölçüm adı",
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black54,
                                  width: 2.0,
                                  style: BorderStyle.solid)),
                          hintStyle: TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      elevation: 0,
                    ),
                    progress
                        ? Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(),
                          )
                        : ButtonTheme(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            colorScheme: ColorScheme.light(
                                primary: Colors.white,
                                secondary: Colors.black87),
                            child: ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                RaisedButton(
                                  child: Text(
                                    "Kuyu",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  onPressed: () async {
                                    if (["", null, false].contains(name)) {
                                      error = "Ölçüm adı boş bırakılamaz";
                                      setDialogState(() {});
                                      return;
                                    }
                                    progress = true;
                                    setDialogState(() {});

                                    final Plant plant = new Plant.kuyu(
                                        uid: Uuid().v1(),
                                        name: name,
                                        groupId: widget.plantGroup.uid);

                                    plant.locationData.latitude =
                                        latLng.latitude;
                                    plant.locationData.longitude =
                                        latLng.longitude;
                                    await DatabaseService()
                                        .addPlant(plant)
                                        .then((value) {
                                      Navigator.of(context).pop();
                                      goto(PlantView(plant: plant));
                                    }).catchError((err) {
                                      print(err);
                                      error = err.message;
                                      progress = false;
                                      setDialogState(() {});
                                    }).whenComplete(() => print("completed"));
                                  },
                                ),
                                RaisedButton(
                                  child: Text(
                                    "Terfi",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  onPressed: () async {
                                    if (["", null, false].contains(name)) {
                                      error = "Ölçüm adı boş bırakılamaz";
                                      setDialogState(() {});
                                      return;
                                    }
                                    progress = true;
                                    setDialogState(() {});

                                    final Plant plant = new Plant.terfi(
                                        uid: Uuid().v1(),
                                        name: name,
                                        groupId: widget.plantGroup.uid);
                                    print(plant.toJson());
                                    await DatabaseService()
                                        .addPlant(plant)
                                        .then((value) {
                                      Navigator.of(context).pop();
                                      goto(PlantView(plant: plant));
                                    }).catchError((err) {
                                      print(err);
                                      error = err.message;
                                      progress = false;
                                      setDialogState(() {});
                                    }).whenComplete(() => print("completed"));
                                  },
                                ),
                                RaisedButton(
                                  child: Text(
                                    "Depo",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  onPressed: () async {
                                    if (["", null, false].contains(name)) {
                                      error = "Ölçüm adı boş bırakılamaz";
                                      setDialogState(() {});
                                      return;
                                    }
                                    progress = true;
                                    setDialogState(() {});

                                    final Plant plant = new Plant.depo(
                                        uid: Uuid().v1(),
                                        name: name,
                                        groupId: widget.plantGroup.uid);
                                    print(plant.toJson());
                                    await DatabaseService()
                                        .addPlant(plant)
                                        .then((value) {
                                      Navigator.of(context).pop();
                                      goto(PlantView(plant: plant));
                                    }).catchError((err) {
                                      print(err);
                                      error = err.message;
                                      progress = false;
                                      setDialogState(() {});
                                    }).whenComplete(() => print("completed"));
                                  },
                                )
                              ],
                            ),
                          )
                  ],
                ),
              );
            }));
      },
    );
  }
}

class Place {
  final String name;
  final String formatted_address;
  final LatLng location;

  Place(this.name, this.formatted_address, this.location);
  Place.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        formatted_address = json["formatted_address"],
        location = LatLng(json["geometry"]["location"]["lat"],
            json["geometry"]["location"]["lng"]);
}

class MapSearchQueryResult {
  final List<Place> candidates;
  final String status;

  MapSearchQueryResult(this.candidates, this.status);
  MapSearchQueryResult.fromJson(Map<String, dynamic> json)
      : candidates = (json["candidates"] as List)
            .map((obj) => Place.fromJson(obj))
            .toList(),
        status = json["status"];
}

class MapSearchBar extends StatefulWidget {
  final Function(Place place) onLocationSelected;
  const MapSearchBar({Key key, this.onLocationSelected}) : super(key: key);
  @override
  _MapSearchBarState createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  TextEditingController controller = new TextEditingController();
  StreamController<Place> searchController = BehaviorSubject();
  bool minimized = true;

  Widget toggleVisibility() {
    return IconButton(
        icon: Icon(
          Icons.search,
          size: 24,
        ),
        onPressed: () => setState(() {
              minimized = !minimized;
            }));
  }

  @override
  void initState() {
    controller.addListener(() {
      searchByQuery(controller.text)
          .then((place) => searchController.add(place));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return minimized
        ? toggleVisibility()
        : Wrap(
      children: [
        Container(
            decoration: BoxDecoration(
              border: Border(),
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).backgroundColor,
            ),
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        size: 24,
                      ),
                      hintText: "Haritada ara",
                    ),
                  ),
                  StreamBuilder(
                    stream: searchController.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox(
                          height: 0,
                        );
                      }
                      final Place place = snapshot.data;
                      return ListTile(
                        title: Text(place.name),
                        subtitle: Text(place.formatted_address),
                        onTap: ()  {widget.onLocationSelected(place);setState(() {
                          minimized=true;
                        });},
                      );
                    },
                  )
                ],
              ),
            ))
      ],
    );
  }
}
