import 'package:flutter/material.dart';
import 'package:infowindow/model/pin_data.dart';
//import 'package:infowindow/util/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  GoogleMapController _controller;
  Position pinPosition;

  Widget _child = Center(
    child: Text('Loading...'),
  );

  BitmapDescriptor _pinIcon;

  double _pinPillPosition = -100;

  PinData _currentPinData = PinData(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);

  PinData _sourcePinInfo;



  void _setPinIcon() async {
    _pinIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/pin.png');
  }





  Future<void> getPermission() async {

    // Ask for permission
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.location);

    // check returned permission Status
    if (permission == PermissionStatus.denied) {
      await PermissionHandler()
          .requestPermissions([PermissionGroup.locationAlways]);
    }

    
    var geolocator = Geolocator();

    GeolocationStatus geolocationStatus =
    await geolocator.checkGeolocationPermissionStatus();

    switch (geolocationStatus) {
      case GeolocationStatus.denied:
        showToast('Access denied');
        break;
      case GeolocationStatus.disabled:
        showToast('Disabled');
        break;
      case GeolocationStatus.restricted:
        showToast('restricted');
        break;
      case GeolocationStatus.unknown:
        showToast('Unknown');
        break;
      case GeolocationStatus.granted:
        showToast('Accesss Granted');
        // If granted, get current location
        _getCurrentLocation();
    }
  }

  
  void _getCurrentLocation() async {
    Position res = await Geolocator().getCurrentPosition();
    setState(() {

      // pinPosition = current position
      pinPosition = res;

      // child is Center widget
      // now assigned to GoogleMap widget with markers on
      _child = _mapWidget();
    });
  }

  void _setStyle(GoogleMapController controller) async {
    String value = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');

    controller.setMapStyle(value);
  }




  Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('home'),
          position: LatLng(pinPosition.latitude, pinPosition.longitude),
          icon: _pinIcon,
          onTap: () {
            setState(() {
              _currentPinData = _sourcePinInfo;
              _pinPillPosition = 0;
            });
          })
    ].toSet();
  }

  void showToast(message) {
    Fluttertoast.showToast(

      // messages are granted, denied, unknown etc...
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }





  @override
  void initState() {
    getPermission();
    _setPinIcon();
    super.initState();
  }






  Widget _mapWidget() {
    return GoogleMap(
      //mapType: MapType.normal,

      // create markers on the map
      markers: _createMarker(),

      // initial camera position = over the current position with zoom 12
      initialCameraPosition: CameraPosition(
          target: LatLng(pinPosition.latitude, pinPosition.longitude), zoom: 12.0),


      // onMapCreated
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;

        //
        _setMapPins();
      },

      // on tap on the map will make the info windows disappear.
      onTap: (LatLng location) {
        setState(() {
          _pinPillPosition = -100;
        });
      },
    );
  }




  void _setMapPins() {

    // set sourcePinInfo into given data
    _sourcePinInfo = PinData(
        pinPath: 'assets/pin.png',
        locationName: "My Location",
        location: LatLng(pinPosition.latitude, pinPosition.longitude),
        avatarPath: "assets/driver.png",
        labelColor: Colors.blue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            _child,
            AnimatedPositioned(
              bottom: _pinPillPosition,
              right: 0,
              left: 0,
              duration: Duration(milliseconds: 200),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.all(20),
                  height: 70,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          blurRadius: 20,
                          offset: Offset.zero,
                          color: Colors.grey.withOpacity(0.5),
                        )
                      ]),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildAvatar(),
                      _buildLocationInfo(),
                      _buildMarkerType()
                    ],
                  ),
                ),
              ),
            )
          ],
        )
    );
  }

  Widget _buildAvatar() {
    return Container(
      margin: EdgeInsets.only(left: 10),
      width: 50,
      height: 50,
      child: ClipOval(
        child: Image.asset(
          _currentPinData.avatarPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _currentPinData.locationName,
            ),
            Text(
              'Latitude : ${_currentPinData.location.latitude}',
            ),
            Text(
              'Longitude : ${_currentPinData.location.longitude}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkerType() {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Image.asset(
        _currentPinData.pinPath,
        width: 50,
        height: 50,
      ),
    );
  }
}