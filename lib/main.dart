import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:geolocator/geolocator.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WayWise',
      debugShowCheckedModeBanner:false,
      home: const MyHomePage(title: 'WayWise'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  var map_type = MapType.normal;
  var user_lat=0;
  var user_lng=0;
  int selectedIndex = 1;
  bool show_locations_container =false;
  late LocationPermission permission;
  late Position position;
  bool location_gotten=false;
  var search_value="";
  var data;
  bool side_nav_collapsed=true;
  var search_list=[];
  var myController = TextEditingController();
  final mapsWidgetController = GlobalKey<GoogleMapsWidgetState>();




  void listener(){
    var search_value=myController.value;
    if(search_value!=""){
      setState(() {
        show_locations_container=true;
      });
      setState(() {
        search_list=[];
      });
      for(var i=0;i<data.length;i++){
        setState(() {
          var temp_search_value=search_value.toString().toLowerCase();
          var current  = data[i]["name"].toLowerCase();
          if(current.contains(temp_search_value)){
            setState(() {
              search_list.add(data[i]);
              print("-------------------------------------");
              print(search_list);
            });
          }else{
            print("-------- not -----------");
          }

        });
      }
    }else{
      setState(() {
        show_locations_container=false;
      });
    }
  }






  Future<void> get_location() async {
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("location denied by the user");
      }
    }
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("position is ${position}");
    setState(() {
      location_gotten=true;
    });

  }
  void load_data() async{
    print('about to load data');
    final String response = await rootBundle.loadString('assets/locations.json');
    final temp_data = await json.decode(response);
    print("----------------------------------------------------------");
    setState((){
      data = temp_data["data"];
    });
    print(data);
    print("----------------------------------------------------------");

  }


  @override
  void initState(){
    get_location();
    load_data();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body:location_gotten?Stack(
        children: [
          GoogleMapsWidget(
            apiKey: "AIzaSyAdrgehIe5zzL9xCdPIFd0pJP2hhxhuISE",
            key:mapsWidgetController,
            sourceLatLng: LatLng(7.1010567, 3.328491),
            destinationLatLng: LatLng(40.48017307700204, -3.3618026599287987),
            zoomControlsEnabled:true,
            compassEnabled:true,
            routeWidth:2,
            mapType:map_type,
            routeColor:Colors.deepPurple,
            zoomGesturesEnabled:true,
            updatePolylinesOnDriverLocUpdate: true,
            onPolylineUpdate: (_) {
              print(position);
            },
            sourceMarkerIconInfo: MarkerIconInfo(
              infoWindowTitle: "This is source name",
              onTapInfoWindow: (_) {
                print("Tapped on source info window");
              },
              assetPath: "assets/pin.png",
            ),
            destinationMarkerIconInfo: MarkerIconInfo(
              assetPath: "assets/destination.png",
            ),
          ),
          if (side_nav_collapsed==true) Container(
            height:show_locations_container?MediaQuery.of(context).size.height*0.45:MediaQuery.of(context).size.height*0.15,
            padding:EdgeInsets.only(left:20,right:20,top:45),
            width:double.infinity,
            color:Colors.transparent,
            child:Column(
              children: [
                Row(
                  mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment:CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap:(){
                        setState(() {
                          side_nav_collapsed=false;
                        });
                      },
                        child: Icon(
                          Icons.menu,
                          size:35,
                          color:Colors.deepPurple,
                          shadows: <Shadow>[Shadow(color: Colors.grey, blurRadius: 3.0)],
                        )
                    ),
                    SizedBox(width:10),
                    Container(
                      height:MediaQuery.of(context).size.height*0.07,
                      width:MediaQuery.of(context).size.width*0.7,
                      padding:EdgeInsets.only(left:10,right:10),
                      decoration:BoxDecoration(
                        color:Colors.white,
                        border: Border.all(
                            color: Colors.deepPurple,
                            width: 1.5,
                            style: BorderStyle.solid
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child:TextField(
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search'
                        ),
                        controller:myController,
                        style:GoogleFonts.montserrat(color:Colors.black,fontWeight:FontWeight.w500),
                        keyboardType:TextInputType.text,
                        onChanged:(value){
                          print(value);
                          setState(() {
                            search_value=value;
                            if(search_value.length>1){
                              setState(() {
                                show_locations_container=true;
                              });
                              setState(() {
                                search_list=[];
                              });
                              for(var i=0;i<data.length;i++){
                                setState(() {
                                  var temp_search_value=search_value.toLowerCase();
                                  var current  = data[i]["name"].toLowerCase();
                                  if(current.contains(temp_search_value)){
                                    setState(() {
                                      search_list.add(data[i]);
                                      print("-------------------------------------");
                                      print(search_list);
                                    });
                                  }else{
                                    print("-------- not -----------");
                                  }

                                });
                              }
                            }else{
                              setState(() {
                                show_locations_container=false;
                              });
                            }
                          });
                        },
                      ),
                    )
                  ],
                ),
                show_locations_container?Expanded(
                  child: Container(
                    margin:EdgeInsets.only(top:5),
                    color:Colors.transparent,
                    child:Align(
                      alignment:Alignment.topRight,
                      child:Container(
                        margin:EdgeInsets.only(right:10),
                        decoration:BoxDecoration(
                            color:Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ]
                        ),
                        width:MediaQuery.of(context).size.width*0.7,
                        padding:EdgeInsets.all(20),
                        child:SingleChildScrollView(
                          child:search_list.length<1==false?Column(
                            crossAxisAlignment:CrossAxisAlignment.start,
                            children: [
                              for(var i=0;i<search_list.length;i++) GestureDetector(
                                onTap:(){
                                  print(search_list[i]["lat-lng"]);

// call like this to update source or destination, this will also rebuild the route.
                                  mapsWidgetController.currentState!.setDestinationLatLng(
                                    LatLng(
                                      search_list[i]["lat-lng"][0],
                                      search_list[i]["lat-lng"][1],
                                    ),
                                  );
                                  setState(() {
                                    search_value="";
                                    myController.text=search_list[i]["name"];
                                    show_locations_container=false;
                                  });
                                },
                                  child: location_container(text:search_list[i]["name"])
                              )
                            ],
                          ):Center(
                            child:Text("Not found",style:GoogleFonts.montserrat(),),
                          ),
                        ),
                      ),
                    ),
                  ),
                ):SizedBox()
              ],
            ),
          ) else SizedBox(),
          Container(
            width:side_nav_collapsed==false?MediaQuery.of(context).size.width*0.55:0,
            height:double.infinity,
            padding:EdgeInsets.only(top:55),
            margin:side_nav_collapsed?EdgeInsets.only(right:0):EdgeInsets.only(right:10),
            decoration:BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 5.0),
                BoxShadow(color: Colors.white, offset: Offset(0, -16)),
                BoxShadow(color: Colors.white, offset: Offset(0, 16)),
                BoxShadow(color: Colors.white, offset: Offset(-16, -16)),
                BoxShadow(color: Colors.white, offset: Offset(-16, 16)),
              ],
            ),
            child:Column(
              crossAxisAlignment:CrossAxisAlignment.center,
              children: [
                Row(mainAxisAlignment:MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap:(){
                          setState(() {
                            side_nav_collapsed=true;
                          });
                        },
                        child: Icon(Icons.arrow_back_ios,color:Colors.deepPurple,)
                    ),
                    Center(child: Text("WayWise",style:GoogleFonts.montserrat(color:Colors.deepPurple,fontSize:25,fontWeight:FontWeight.w600),)),
                  ],
                ),
                SizedBox(height:MediaQuery.of(context).size.height*0.08,),
                GestureDetector(
                  onTap:(){
                    setState(() {
                      selectedIndex=1;
                      map_type = MapType.normal;
                    });
                  },
                    child: side_nav_container(icon_name:Icons.map_outlined, text:"ROAD MAP",selected:selectedIndex==1,)
                ),
                GestureDetector(
                  onTap:(){
                    setState(() {
                      selectedIndex=2;
                      map_type = MapType.satellite;
                    });
                  },
                    child: side_nav_container(icon_name:Icons.image, text:"HYBRID MAP",selected:selectedIndex==2,)
                ),
                side_nav_container(icon_name:Icons.help, text:"HELP",selected:selectedIndex==3,),
                side_nav_container(icon_name:Icons.pin_drop, text:"ABOUT APP",selected:selectedIndex==4,)


              ],
            ),
          ),
        ]
      ):Container(

      ),

    );
  }
}


class side_nav_container extends StatefulWidget {
  side_nav_container({required this.icon_name , required this.text,required this.selected});


  var icon_name;
  var text;
  bool selected;

  @override
  State<side_nav_container> createState() => _side_nav_containerState();
}

class _side_nav_containerState extends State<side_nav_container> {

  @override
  Widget build(BuildContext context) {
    return   Container(
      padding:EdgeInsets.only(left:20),
      height:50,
      width:MediaQuery.of(context).size.width*0.5,
      color:widget.selected?Colors.grey[100]:Colors.white,
      margin:EdgeInsets.only(bottom:25),
      child:Row(
        mainAxisAlignment:MainAxisAlignment.start,
        children: [
          Icon(widget.icon_name as IconData?,color:Colors.deepPurple,),
          SizedBox(width:10,),
          Text(widget.text,style:GoogleFonts.montserrat(color:Colors.deepPurple,fontWeight:FontWeight.w600),)
        ],
      ),
    );
  }
}

class location_container extends StatefulWidget {
  location_container({required this.text});

  String text;
  @override
  State<location_container> createState() => _location_containerState();
}

class _location_containerState extends State<location_container> {
  @override
  Widget build(BuildContext context) {
    return   Container(
      height:40,
      width:double.infinity,
      color:Colors.transparent,
      margin:EdgeInsets.only(bottom:7),
      child: Align(
        alignment:Alignment.centerLeft,
          child: Text(widget.text,style:GoogleFonts.montserrat(color:Colors.deepPurple,fontWeight:FontWeight.w600),))
    );
  }
}

