import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:google_maps_webservice/places.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/places_controller.dart';

class ShareLocation extends StatefulWidget {
  ShareLocation({this.onComplete});

  Function(LatLng) onComplete;

  @override
  _ShareLocationState createState() => _ShareLocationState();
}

class _ShareLocationState extends State<ShareLocation> {
  GoogleMapController _controller;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: const LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final LocationManager.Location _locationManager = LocationManager.Location();

  LatLng _currentLocation;

  StreamSubscription<LocationManager.LocationData> _streamSubscription;
  PlacesController _placesController;

  @override
  void initState() {
    super.initState();

    _placesController = PlacesController();

    _locationManager.hasPermission().then((bool status) {
      if (status == true) {

      } else {
        _locationManager.requestPermission().then((bool status) {
          if (status == true) {

          }
        });
      }
    });
  }

  @override
  void dispose() {
    if (_streamSubscription != null) {
      _streamSubscription.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
            ),
          ),
          Expanded(
              child: StreamBuilder<LocationManager.LocationData>(
                  stream: _locationManager.onLocationChanged(),
                  builder: (BuildContext context, AsyncSnapshot<LocationManager.LocationData> data) {
                    if (!data.hasData)
                      return Container();
                    _currentLocation = LatLng(data.data.latitude, data.data.longitude);
                    _controller.moveCamera(
                        CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(_currentLocation.latitude, _currentLocation.longitude),
                              zoom: 14.4746,
                            )
                        )
                    );
                    return ListView(
                      children: <Widget>[
                        _currentLocation != null
                            ? FlatButton(
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.adjust, color: Colors.blue,
                                    ),
                                    Container(width: 10),
                                    Text(
                                      allTranslations.text('chat_share_location'),
                                      style: TextStyle(
                                          color: Colors.blue
                                      ),
                                    )
                                  ],
                                ),
                                onPressed: () {
                                  Navigator.maybePop(context);
                                  if (widget.onComplete != null) {
                                    widget.onComplete(_currentLocation);
                                  }
                                },
                              )
                            : Container(),
                        FutureBuilder<PlacesSearchResponse>(
                          future: _placesController.searchNearbyWithRadius(Location(_currentLocation.latitude, _currentLocation.longitude), 2500),
                          builder: (BuildContext context, AsyncSnapshot<PlacesSearchResponse> response) {
                            if (!response.hasData) {
                              return Container();
                            }
                            final List<PlacesSearchResult> places = response.data.results;
                            return ListView.builder(
                                itemCount: places.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return FlatButton(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.location_on, color: Colors.grey,
                                        ),
                                        Container(width: 10),
                                        Text(
                                          places[index].name,
                                          style: TextStyle(
                                              color: Colors.blue
                                          ),
                                        )
                                      ],
                                    ),
                                    onPressed: () {
                                      Navigator.maybePop(context);
                                      if (widget.onComplete != null) {
                                        widget.onComplete(LatLng(places[index].geometry.location.lat, places[index].geometry.location.lng));
                                      }
                                    },
                                  );
                                }
                            );
                          },
                        )
                      ],
                    );
                  }
              )
          )
        ],
      ),
    );
  }
}