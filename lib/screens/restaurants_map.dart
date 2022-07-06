import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:track/constants/restaurants.dart';
import 'package:track/helpers/commons.dart';
import 'package:track/helpers/shared_prefs.dart';
import 'package:track/widgets/carousel_card.dart';

class RestaurantsMap extends StatefulWidget {
  const RestaurantsMap({Key? key}) : super(key: key);

  @override
  State<RestaurantsMap> createState() => _RestaurantsMapState();
}

class _RestaurantsMapState extends State<RestaurantsMap> {
  // Mapbox related

  LatLng latLng = getLatLngFromSharedPrefs();
  late CameraPosition initialCameraPosition;
  late MapboxMapController controller;
  List<Map> carouselData = [];
  int pageIndex = 0;
  late List<CameraPosition> kRestaurantsList;
  late List<Widget> carouselItems;

  // Carousel related

  @override
  void initState() {
    super.initState();
    initialCameraPosition = CameraPosition(target: latLng, zoom: 15);
    
     
     

    // Calculate the distance and time from data in SharedPreferences

    for (int i = 0; i < restaurants.length; i++) {
      num distance = getDistanceFromSharedPrefs(i) / 1000;
      num duration = getDurationFromSharedPrefs(i) / 60;
      carouselData
          .add({'index': i, 'distance': distance, 'duration': duration});
    }

    carouselData.sort((a, b) => a['duration'] < b['duration'] ? 0 : 1);

    // Generate the list of carousel widgets

    carouselItems = List<Widget>.generate(
        restaurants.length,
        (index) => carouselCard(carouselData[index]['index'],
            carouselData[index]['distance'], carouselData[index]['duration']));

    // initialize map symbols in the same order as carousel widgets
    kRestaurantsList = List<CameraPosition>.generate(restaurants.length, (index) => CameraPosition(target: getLatLngFromRestaurantData(carouselData[index]['index']),zoom: 15));
  }

  _addSourceAndLineLayer(int index, bool removeLayer) async {
    // Can animate camera to focus on the item

    controller.animateCamera(CameraUpdate.newCameraPosition(kRestaurantsList[index]));

    // Add a polyLine between source and destination

   Map geometry = getGeometryFromSharedPrefs(carouselData[index]['index']);
    
    final fills = {
      "type" : "FeatureCollection",
      "features" : [
        {
          "type" : "Feature",
          "id" : 0,
          "properties" : <String,dynamic>{},
          "geometry" : geometry,
        }
      ]
    };

    print("geometry : ${geometry}");

    // Remove lineLayer and source if it exists

    if(removeLayer == true){
      await controller.removeLayer("lines");
      await controller.removeSource("fills");
    }

    // Add new source and lineLayer

    await controller.addSource("fills", GeojsonSourceProperties(data: fills));
    await controller.addLineLayer("fills", "lines", LineLayerProperties(
      lineColor: Colors.green.toHexStringRGB(),
      lineCap: "round",
      lineJoin: "round",
      lineWidth: 2
    ));
  }

  _onMapCreated(MapboxMapController controller) async {
  
    this.controller = controller;
     await  controller.addSymbol(SymbolOptions(
        geometry: getLatLngFromSharedPrefs(),
        iconSize: 0.2,
        iconImage: "assets/icon/mapbox.png"
      )); 
   
  }

  _onStyleLoadedCallback() async {
    for(CameraPosition kRestaurant in kRestaurantsList){
      await controller.addSymbol(SymbolOptions(
        geometry: kRestaurant.target,
        iconSize: 0.2,
        iconImage: "assets/icon/food.png"
      ));
    }

    _addSourceAndLineLayer(0, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Restaurants Map'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            controller.animateCamera(
                CameraUpdate.newCameraPosition(initialCameraPosition));
              
          },
          child: const Icon(Icons.my_location),
        ),
        body: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.80,
              child: MapboxMap(
                accessToken:
                    "sk.eyJ1IjoicmFqYXQta3VtYXIiLCJhIjoiY2w1NnBpZzNuMDVxMjNjcWw0b3ViZm9teSJ9.8QISqxOsgTu8Jc6NRhkSmw",
                initialCameraPosition: initialCameraPosition,
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoadedCallback,
                myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
              ),
            ),
            CarouselSlider(items: carouselItems ,  options: CarouselOptions(
              height : 100,
              viewportFraction: 0.6,
              initialPage: 0,
              enableInfiniteScroll: false,
              scrollDirection: Axis.horizontal,
              onPageChanged: (int index , CarouselPageChangedReason reason){
                setState(() {
                  pageIndex = index;
                });
                _addSourceAndLineLayer(index, true);
              }
            ))
          ],
        ));
  }
}
