import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/model/mapModel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapView extends StatelessWidget {
  MapView({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<MapModel>(
      builder: (context, value, child) => Scaffold(
        bottomSheet: BottomSheet(
            onClosing: () {},
            builder: (context) => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: value.pickController,
                                onTap: () {
                                  print('object');
                                  value.searchPlace(context);
                                },
                                onSubmitted: value.onsubmit,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.location_on_rounded),
                                    hintText: 'Enter PickUp Location',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            BorderSide(color: Colors.grey))),
                              ),
                            ),
                            IconButton(
                                icon: Icon(Icons.location_searching),
                                onPressed: () {
                                  value.getUserLocation();
                                }),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        TextField(
                          onTap: () => value.searchPlace(context),
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.location_on_rounded),
                              hintText: 'Enter DropOff Location',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey))),
                        ),
                      ],
                    ),
                  ),
                )),
        body: GoogleMap(
          mapType: MapType.terrain,
          markers: Set.of((value.marker != null) ? [value.marker] : []),
          circles: Set.of((value.circle != null) ? [value.circle] : []),
          onMapCreated:(controller)=> value.createmap(controller),
          zoomControlsEnabled: false,
          initialCameraPosition:
              CameraPosition(target: value.center, zoom: 14.0),
        ),
      ),
    );
  }
}
