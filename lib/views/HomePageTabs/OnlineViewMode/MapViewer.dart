import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:groupproject/constants.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MapViewer extends StatefulWidget {
  final String address;
  const MapViewer({Key? key, required this.address}) : super(key: key);

  @override
  State<MapViewer> createState() => _MapViewer(this.address);
}

class _MapViewer extends State<MapViewer> with TickerProviderStateMixin {
  int selectedIndex = 0;
  final pageController = PageController();
  late MapController mapController;
  String address;
  _MapViewer(this.address);

  // A function that takes a post location of city + provnince or equivalent and returns the address
  // in coordinates
  getLocation() async {
    final List<Location> locations = await locationFromAddress(address);
    return LatLng(locations[0].latitude, locations[0].longitude);
  }

  @override
  void initState() {
    mapController = MapController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
      ),
      // Futurerbuilder that waits for getLocation() function to finish calculating the coordinates
      // before building. Builds a map view that is centered on the post's location.
      body: FutureBuilder(
        future: getLocation(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: TextStyle(fontSize: 18),
                  ),
                );
            }
            else if (snapshot.hasData) {
              return Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                    options: MapOptions(
                      minZoom: 5,
                      maxZoom: 18,
                      zoom: 13,
                      center: snapshot.data
                    ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate: AppConstants.mapBoxStyleId,
                    ),
                  ],
                ),
              ],
            ); 
            }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },)
    );
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
    CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }
}