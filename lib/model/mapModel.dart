import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:google_maps_webservice/places.dart' as place;


class MapModel extends ChangeNotifier {
  GoogleMapController googleMapController;
  place.GoogleMapsPlaces _places = place.GoogleMapsPlaces(apiKey: APIKEY);
  Location _location = Location();
  Marker marker;
  Circle circle;
  String pickValue;
  StreamSubscription locationSub;
  TextEditingController pickController = TextEditingController();
  TextEditingController dropController = TextEditingController();
  final LatLng center = LatLng(6.5244, 3.3792);
  static const String APIKEY = "AIzaSyBT9ewvHS1cAYWM1ETEzDUmwatXFTDdpJ4";
  void createmap(GoogleMapController controller) {
    googleMapController = controller;
  }
  void dispose() {
    if (locationSub != null) {
      locationSub.cancel();
    }
    super.dispose();
  }
  Future<Uint8List> getMaker(context) async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load('assets/bike.png');
    return byteData.buffer.asUint8List();
  }
  void updateMakerAndCircle(LocationData location, Uint8List imgData) {
    LatLng latLng = LatLng(location.latitude, location.longitude);
    marker = Marker(
      markerId: MarkerId(latLng.toString()),
      position: latLng,
      rotation: location.heading,
      draggable: false,
      flat: false,
      zIndex: 5,
      anchor: Offset(0.5, 0.5),
      icon: BitmapDescriptor.fromBytes(imgData),
    );
    circle = Circle(
        circleId: CircleId('bike'),
        radius: location.accuracy,
        zIndex: 1,
        strokeColor: Colors.teal,
        center: latLng,
        fillColor: Colors.teal.withOpacity(0.2));
    notifyListeners();
  }
  void getUserLocation() async {
    try {
      Uint8List imgData = await getMaker(BuildContext);
      var location = await _location.getLocation();
      updateMakerAndCircle(location, imgData);
      if (locationSub != null) {
        locationSub.cancel();
      }
      locationSub = _location.onLocationChanged.listen((location) {
        if (googleMapController != null) {
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                bearing: 192.8334901395799,
                tilt: 0,
                zoom: 18.0,
                target: LatLng(location.latitude, location.longitude),
              ),
            ),
          );
          updateMakerAndCircle(location, imgData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMIssION_DENIED') {
        print('permission why');
      }
    }
  }
  void searchPlace(context) async {
    Uint8List imgData = await getMaker(context);
    var location = await _location.getLocation();
    var placePredict = await PlacesAutocomplete.show(
      apiKey: APIKEY,
      context: context,
      language: 'en',
      mode: Mode.fullscreen,
      components: [place.Component(place.Component.country, 'NG')],
    );
    updateMakerAndCircle(location, imgData);
    if (placePredict != null) {
      pickController.text = placePredict.description;
      notifyListeners();
      displayPredication(placePredict);
    }
  }
  Future<Null> displayPredication(place.Prediction predict) async {
    if (predict != null) {
      place.PlacesDetailsResponse details =
          await _places.getDetailsByPlaceId(predict.placeId);
      locationSub = _location.onLocationChanged.listen((location) {
        if (googleMapController != null) {
          final lat = details.result.geometry.location.lat;
          final lng = details.result.geometry.location.lng;
          googleMapController
              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(lat, lng),
            bearing: 192.8334901395799,
            tilt: 0,
            zoom: 18.0,
          )));
        }
      });
    }
  }
  void onsubmit(String value) {
    pickValue = value;
    notifyListeners();
  }
}
