import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
// import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
// import 'package:google_maps_webservice/src/places.dart';
import 'package:http/http.dart' as http;
import 'package:google_place/google_place.dart';

class ProController extends ChangeNotifier {
  Placemark _pickplacemark = Placemark();
  Placemark get pickplacemark => _pickplacemark;
  List<AutocompletePrediction> _predictions = [];
  List<AutocompletePrediction> get predictions => [..._predictions];
  // List<AutocompletePrediction> _predictionList = [];

  getAddressFromLatLng(context, double lat, double lng) async {
    String _host = 'https://maps.google.com/maps/api/geocode/json';
    final url =
        '$_host?key=AIzaSyDtK4FdlXwQsZylC05oVnd8ko2Vs2b_9yE&language=en&latlng=$lat,$lng';
    if (lat != null && lng != null) {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        // String _formattedAddress = data["results"][0]["formatted_address"];
        print("response ==== $data");
        return data;
      } else
        return null;
    } else
      return null;
  }

  // autoCompleteSearch(String value) async {
  //   final places =
  //       FlutterGooglePlacesSdk('AIzaSyDtK4FdlXwQsZylC05oVnd8ko2Vs2b_9yE');

  //   var result = await places.findAutocompletePredictions('bik');
  //   ;
  //   if (result != null && result.predictions != null) {
  //     // print(result.predictions!.first.description);
  //     // setState(() {
  //     _predictionList = result.predictions;
  //     // });
  //   }
  // }

  autoCompleteSearch(String value) async {
    GooglePlace googleplace =
        GooglePlace("AIzaSyDtK4FdlXwQsZylC05oVnd8ko2Vs2b_9yE'");
    var result = await googleplace.autocomplete.get(value);
    log(result!.predictions.toString());
    if (result != null && result.predictions != null) {
      _predictions = result.predictions!;
    }
  }

  // Future<List<Prediction>> searchLocation(
  //     BuildContext context, String text) async {
  //   if (text != null && text.isNotEmpty) {
  //     // http.Response response = await getLocationData(text);
  //     var response = await http.get(
  //       Uri.parse(
  //           "http://mvs.bslmeiyu.com/api/v1/config/place-api-autocomplete?search_text=$text"),
  //       headers: {"Content-Type": "application/json"},
  //     );
  //     var data = jsonDecode(response.body.toString());
  //     print("my status is " + data["status"]);
  //     if (data['status'] == 'OK') {
  //       _predictionList = [];
  //       data['predictions'].forEach((prediction) =>
  //           _predictionList.add(Prediction.fromJson(prediction)));
  //     } else {
  //       // ApiChecker.checkApi(response);
  //     }
  //   }
  //   return _predictionList;
  // }
}
