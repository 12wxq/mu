import 'dart:developer';

import 'Screens/AllSongs.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mu/Screens/NowPlaying.dart';
import 'package:mu/provider/song_model_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'themeData.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(ChangeNotifierProvider(
    create: (context) => SongModelProvider(),
    child: MyApp(),
  ));
}

// void main(List<String> args) {
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '音乐',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: primary,
        tabBarTheme: tabBarTheme,
      ),
      home: const AllSongs(),
    );
  }
}
