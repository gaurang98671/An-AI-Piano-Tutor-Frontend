// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:orientation/orientation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:piano_tutor/detail.dart';

// The home screen.
// Get the song list from server.
Future<SongList> fetchSongs() async {
  print("Making request");
  final response = await http.get(Uri.http('20.204.171.206:8000', 'music/songs'));
  print(response);

  if (response.statusCode == 200) {
    var decoded = json.decode(response.body);
    return SongList.fromJson(decoded);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load songs');
  }
}

// Construct the song list.
class SongList {
  final List<Song> songs;

  SongList({
    this.songs
  });

  factory SongList.fromJson(List<dynamic> parsedJson) {
    List<Song> songs = parsedJson.map((i)=>Song.fromJson(i)).toList();
    return new SongList(
      songs: songs,
    );
  }
}

// Define and process the song object.
class Song {
  final int id;
  final String name;
  final String pic;
  final String audio;

  Song({this.id, this.name, this.pic, this.audio});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['pk'],
      name: json['fields']['name'],
      pic: json['fields']['pic'],
      audio: json['fields']['audio']
    );
  }
}

// Home screen.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  OrientationPlugin.forceOrientation(DeviceOrientation.landscapeLeft);
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<SongList> futureSongs;

  @override
  void initState(){
    super.initState();
    print("Fetching songs");
    futureSongs = fetchSongs();
  }
  @override
  Widget build(BuildContext context) {
    final List<String> entries = <String>['Ode an die Freude'];
    final List<String> imgs = <String>['graphics/beethoven.jpg', 'graphics/bach.jpeg'];

    return MaterialApp(
      title: 'Welcome to Flutter',
      theme: ThemeData(fontFamily: 'Poppins'),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
              'Choose your music',
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
              )),
          backgroundColor: Color(0xFF26c6da),
        ),
        body: Center(
          child: FutureBuilder<SongList>(
            future: futureSongs,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.separated(
                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data.songs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Detail(song: snapshot.data.songs[index]),
                          ),
                        );
                      },
                      child: Container(
                        width: 220,
                        margin: EdgeInsets.all(20.0),
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: Image.asset('${imgs[index]}',
                                    fit: BoxFit.fitHeight
                                )
                            ),
                            Container(
                                color: Color(0xFF102027),
                                height: 80,
                                width: 220,
                                alignment: Alignment.center,
                                child: Text(
                                    '${snapshot.data.songs[index].name}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFFffffff),
                                    )
                                )
                            )
                          ],
                        )
                    )
                    );
                  }
                );
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return Text("error encountered",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFffffff),
                  )
                );
            }
              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          )
        )
      ),
    );
  }
}