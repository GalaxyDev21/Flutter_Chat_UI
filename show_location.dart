import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geocoder/geocoder.dart';

class ShowLocation extends StatefulWidget {
  ShowLocation({this.location});
  LatLng location;

  @override
  _ShowLocationState createState() => _ShowLocationState();
}

class _ShowLocationState extends State<ShowLocation> {
  GoogleMapController _controller;

  String _locality = '';
  String _address = '';
  final List<MapType> _mapTypes = [MapType.normal, MapType.hybrid, MapType.satellite];
  int _mapIndex = 0;

  @override
  void initState() {
    super.initState();

    Geocoder.local.findAddressesFromCoordinates(Coordinates(widget.location.latitude, widget.location.longitude))
        .then((List<Address> addresses) {
      if (addresses != null && addresses.isNotEmpty) {
        setState(() {
          _locality = addresses.first.locality;
          _address = addresses.first.featureName;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _address,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18
              ),
            ),
            Text(
              _locality,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 15
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: GoogleMap(
                  mapType: _mapTypes[_mapIndex],
                  initialCameraPosition: CameraPosition(
                    target: widget.location,
                    zoom: 14.4746,
                  ),
                  markers: Set<Marker>.of([Marker(
                      markerId: MarkerId('location'),
                      position: widget.location
                  )]),
                  myLocationEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    color: _mapIndex == 0 ? Colors.blue : Colors.white,
                    child: Text(
                      'Map',
                      style: TextStyle(
                          color: _mapIndex == 0 ? Colors.white : Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _mapIndex = 0;
                      });
                    },
                  ),
                  FlatButton(
                    color: _mapIndex == 1 ? Colors.blue : Colors.white,
                    child: Text(
                      'Hybrid',
                      style: TextStyle(
                          color: _mapIndex == 1 ? Colors.white : Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _mapIndex = 1;
                      });
                    },
                  ),
                  FlatButton(
                    color: _mapIndex == 2 ? Colors.blue : Colors.white,
                    child: Text(
                      'Satellite',
                      style: TextStyle(
                          color: _mapIndex == 2 ? Colors.white : Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _mapIndex = 2;
                      });
                    },
                  )
                ],
              )
            ],
          )
      ),
    );
  }
}