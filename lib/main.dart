import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geodesy/geodesy.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toast/toast.dart';
import 'package:location_permissions/location_permissions.dart';

void main() => runApp(Map());

class Map extends StatelessWidget {
  const Map({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapLauncherDemo(),
    );
  }
}

class MapLauncherDemo extends StatefulWidget {
  MapLauncherDemo({Key key}) : super(key: key);

  @override
  _MapLauncherDemoState createState() => _MapLauncherDemoState();
}

class _MapLauncherDemoState extends State<MapLauncherDemo> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController controller = ScrollController();
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String lat, long, full, your, yourLat, yourLong, location, distances;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller.text = "";
    lat = "3.091773";
    long = "101.689125";
    full = "";
    yourLat = "";
    yourLong = "";
    your = "";
    distances = "";
    status();
    super.initState();
  }

  void _distance() async {
    try {
      Geodesy geodesy = Geodesy();
      print(lat);
      print(long);
      print(yourLat);
      print(yourLong);
      LatLng l1 = LatLng(double.parse(lat), double.parse(long));
      LatLng l2 = LatLng(double.parse(yourLat), double.parse(yourLong));
      num distance = (geodesy.distanceBetweenTwoGeoPoints(l1, l2)) * 1.6;
      double km = distance / 1000;
      km = num.parse(km.toStringAsFixed(2));
      setState(() {
        distances = km.toString() + " KM";
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            40,
          ),
          child: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            elevation: 1,
            centerTitle: true,
            title: Text(
              "Map Finder",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: SingleChildScrollView(
          controller: controller,
          child: Container(
            margin: EdgeInsets.all(10),
            // decoration: BoxDecoration(
            //   border: Border(
            //     left: BorderSide(width: 1, color: Colors.grey.shade500),
            //     top: BorderSide(width: 1, color: Colors.grey.shade500),
            //     right: BorderSide(width: 1, color: Colors.grey.shade500),
            //     bottom: BorderSide(width: 1, color: Colors.grey.shade500),
            //   ),
            // ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Key in your target location: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TextField(
                  controller: _controller,
                  style: TextStyle(height: 1, fontSize: 14),
                  keyboardType: TextInputType.text,
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Target Latitude: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(lat),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Target Longtitude: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(long),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Target full Address shown below: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(child: Text(full)),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Your latitude: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(yourLat),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Your longtitude: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(yourLong),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Your full Address shown below: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(child: Text(your)),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[Text("Distance: ", style: TextStyle(fontWeight: FontWeight.bold),), Text(distances)],
                ),
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    MaterialButton(
                      color: Colors.blue,
                      onPressed: () => check(),
                      child: Text('Show target full address'),
                    ),
                    MaterialButton(
                      color: Colors.blue,
                      onPressed: () => openMapsSheet(),
                      child: Text('Show Maps'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void status() async {
    ServiceStatus serviceStatus = await LocationPermissions().checkServiceStatus();
    String status = serviceStatus.toString();
    if (status == "ServiceStatus.enabled"){
      _getCurrentLocation();
    } else {
      LocationPermissions().openAppSettings();
    }
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    return Future.value(false);
  }

  void openMapsSheet() async {
    try {
        final availableMaps = await MapLauncher.installedMaps;
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  child: Wrap(
                    children: <Widget>[
                      for (var map in availableMaps)
                        ListTile(
                          onTap: () => map.showMarker(
                            coords:
                                Coords(double.parse(lat), double.parse(long)),
                            title: "The Mines",
                            description: "Your Location",
                          ),
                          title: Text(map.mapName),
                          leading: Image(
                            image: map.icon,
                            height: 30.0,
                            width: 30.0,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      } catch (e) {
        Navigator.of(context).pop();
        Toast.show("Can't find the location", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
      }
  }

  _getCurrentLocation() async {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
    setState(() {
      location = _currentPosition.toString();
    });
    // if (_currentPosition == null) {
    //   try {
    //     await AccessSettingsMenu.openSettings(
    //         settingsType: 'ACTION_LOCATION_SOURCE_SETTINGS');
    //   } catch (e) {}
    // }
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        yourLat = _currentPosition.latitude.toString();
        yourLong = _currentPosition.longitude.toString();
        your =
            "${place.name}, ${place.thoroughfare}, ${place.subLocality},${place.postalCode} ${place.locality}, ${place.administrativeArea}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  void check() async {
    try {
      final query = _controller.text;
      var addresses = await Geocoder.local.findAddressesFromQuery(query);
      var first = addresses.first;
      List latlongList = first.coordinates.toString().split(",");
      String latatitude = latlongList[0].toString().substring(1);
      String longtitude =
          latlongList[1].toString().substring(0, latlongList[1].length - 1);
      setState(() {
        lat = latatitude;
        long = longtitude;
      });

      final coordinates =
          new Coordinates(double.parse(lat), double.parse(long));
      addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      first = addresses.first;
      setState(() {
        full = first.addressLine;
      });
       _distance();
    } catch (err) {
      Toast.show("Can't find the location", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }
}
