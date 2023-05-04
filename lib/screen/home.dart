import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:polly_line_test/provide/provider.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  LatLng? liveLL;
  List<Widget> addLocation = [];

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "plase keep your location on");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Permission is denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: 'Permission is denied forever');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("*********************************************");
    print(position.toString());
    setState(() {
      liveLL = LatLng(position.latitude, position.longitude);
      _kGooglePlex = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14.4746,
      );
    });
  }

  TextEditingController _pickupCon = TextEditingController();
  TextEditingController _disCon = TextEditingController();
  TextEditingController _addMoreCon = TextEditingController();
  List<Marker> _marker = [];
  List<LatLng> _points = <LatLng>[];
  bool addmoreLocation = false;
  List moreLocationdata = [];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProController>(context);
    // log(_points.toString());

    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height / 1,
        // width: double.infinity,
        child: liveLL == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 1.4,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      compassEnabled: true,
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: true,
                      buildingsEnabled: false,
                      initialCameraPosition: _kGooglePlex,
                      // initialCameraPosition: CameraPosition(
                      //   target: liveLL!,
                      //   zoom: 14.4746,
                      // ),
                      markers: Set<Marker>.of(_marker),

                      polylines: {
                        Polyline(
                            polylineId: PolylineId('route'),
                            color: Colors.blue,
                            width: 3,
                            points: _points)
                      },

                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  ),
                  Positioned(
                    // top: 10,
                    bottom: 0,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        // width: double.maxFinite,
                        height: MediaQuery.of(context).size.height / 2.4,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 20),
                          child: ListView(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Pick-Up".toUpperCase(),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextField(
                                controller: _pickupCon,
                                // obscureText: true,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'My Current Location',
                                ),

                                onEditingComplete: () async {
                                  if (_pickupCon.text.isNotEmpty) {
                                    List<Location> locations =
                                        await locationFromAddress(
                                            _pickupCon.text);
                                    if (locations.isNotEmpty) {
                                      _marker.add(Marker(
                                        markerId: MarkerId('Pick-up'),
                                        position: LatLng(locations[0].latitude,
                                            locations[0].longitude),
                                      ));
                                      _points.add(LatLng(locations[0].latitude,
                                          locations[0].longitude));
                                      GoogleMapController controller =
                                          await _controller.future;
                                      controller.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                              // on below line we have given positions of Location 5
                                              CameraPosition(
                                        target: LatLng(locations[0].latitude,
                                            locations[0].longitude),
                                        zoom: 14,
                                      )));

                                      // setState(() {});

                                      liveLL = LatLng(locations[0].latitude,
                                          locations[0].longitude);
                                      setState(() {});
                                    }
                                    log(locations.toString());
                                  }
                                },

                                onChanged: (val) {
                                  // if (val.isNotEmpty || val != null)

                                  //   provider.autoCompleteSearch(val);
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Drop-off".toUpperCase(),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              TextField(
                                controller: _disCon,
                                // obscureText: true,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Choose Location',
                                ),
                                onEditingComplete: () async {
                                  if (_disCon.text.isNotEmpty) {
                                    List<Location> locations =
                                        await locationFromAddress(_disCon.text);
                                    if (locations.isNotEmpty) {
                                      _marker.add(Marker(
                                        markerId: MarkerId('Drop'),
                                        position: LatLng(locations[0].latitude,
                                            locations[0].longitude),
                                      ));
                                      _points.add(LatLng(locations[0].latitude,
                                          locations[0].longitude));
                                      GoogleMapController controller =
                                          await _controller.future;
                                      controller.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                              // on below line we have given positions of Location 5
                                              CameraPosition(
                                        target: LatLng(locations[0].latitude,
                                            locations[0].longitude),
                                        zoom: 14,
                                      )));
                                      // setState(() {});

                                      setState(() {});
                                    }
                                    log(locations.toString());
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (addmoreLocation)
                                SizedBox(
                                  height: 10,
                                ),
                              if (addmoreLocation)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          1.3,
                                      child: TextField(
                                        controller: _addMoreCon,
                                        // obscureText: true,
                                        decoration: const InputDecoration(
                                          label: Text("Location"),
                                          border: OutlineInputBorder(),
                                        ),
                                        onSubmitted: (val) async {
                                          if (val.isNotEmpty || val != null) {
                                            List<Location> locations =
                                                await locationFromAddress(
                                                    _addMoreCon.text);
                                            if (locations.isNotEmpty) {
                                              _points.add(LatLng(
                                                  locations[0].latitude,
                                                  locations[0].longitude));

                                              moreLocationdata.add(val);
                                              // setState(() {});
                                              _addMoreCon.clear();
                                              setState(() {});
                                            }
                                            log(locations.toString());
                                          }
                                        },
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          addmoreLocation = false;
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.black,
                                      ),
                                    )
                                  ],
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (moreLocationdata.isNotEmpty)
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 5,
                                  child: ListView(
                                    children: List.generate(
                                        moreLocationdata.length,
                                        (index) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            1.3,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            color:
                                                                Colors.black)),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10,
                                                          vertical: 15),
                                                      child: Text(
                                                          moreLocationdata[
                                                              index]),
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.close,
                                                    color: Colors.black,
                                                  )
                                                ],
                                              ),
                                            )),
                                  ),
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      addmoreLocation = true;
                                      setState(() {});
                                    },
                                    child: const Icon(
                                      Icons.add_circle_outline_outlined,
                                      color: Colors.black,
                                      size: 28,
                                    ),
                                  ),
                                  const Text(
                                    "Add Location",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width - 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Center(
                                  child: Text(
                                    "Next",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )),
                  )
                ],
              ),
      ),
    );
  }
}
