import 'dart:developer';
import 'dart:ffi';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mu/themeData.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../provider/song_model_provider.dart';
import 'NowPlaying.dart';

class AllSongs extends StatefulWidget {
  const AllSongs({Key? key}) : super(key: key);

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  final _aduioQuery = new OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<SongModel> allSongs = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();
  }

  playSong(String? uri) {
    try {
      _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
      _audioPlayer.play();

    } on Exception {
      log('error parsing song');
    }
  }

  requestPermission() async {
    if (Platform.isAndroid) {
      bool permissionStatus = await _aduioQuery.permissionsStatus();

      if (!permissionStatus) {
        await _aduioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            '音乐播放器',
            style: TextStyle(color: primary),
          ),
          elevation: 2,
        ),
        body: FutureBuilder<List<SongModel>>(
            future: _aduioQuery.querySongs(
                sortType: null,
                orderType: OrderType.ASC_OR_SMALLER,
                uriType: UriType.EXTERNAL,
                ignoreCase: true),
            builder: (context, item) {
              if (item.data == null) {
                return Center(
                    child: Column(
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text('加载中'),
                  ],
                ));
              }
              if (item.data!.isEmpty) {
                return Center(
                  child: Text(
                    '抱歉主人，没有找到可以播放的音乐!',
                    style: TextStyle(color: Colors.pink[200], fontSize: 22),
                  ),
                );
              }
              return Stack(children: [
                ListView.builder(
                    itemCount: item.data!.length,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 60),
                    itemBuilder: (context, index) {
                      allSongs.addAll(item.data!);
                      int nt = index;
                      // .addAll(item.data!);
                      return GestureDetector(
                        onTap: () {
                          context
                              .read<SongModelProvider>()
                              .setId(item.data![index].id);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NowPlaying(
                                        Index: nt,
                                        songModelList: allSongs,
                                        audioPlayer: _audioPlayer,
                                      )),);
                        },
                        child: MusicTile(
                          songModel: item.data![index],
                        ),
                      );
                      //   onTap: () {
                      //     // playSong(item.data![index].uri);
                      //     Navigator.push(context, MaterialPageRoute(builder: (context)=>NowPlaying ( songModelList:_allSongs,
                      //     audioPlayer: _audioPlayer,)));
                      //   },
                      //   title: Text(item.data![index].title),
                      //   subtitle: Text('${item.data![index].artist}'),
                      //   trailing: Icon(Icons.more_horiz),
                      // ),}
                    }

                    // padding: EdgeInsets.fromLTRB(0, 0, 0, 60),

                    // title: Text(item.data![index].title),
                    // subtitle: Text(item.data![index].artist ?? "没有作者"),
                    // trailing: const Icon(Icons.more_horiz),
                    // leading: const CircleAvatar(
                    //   child: Icon(Icons.music_note),
                    // ),

                    //playSong(item.data![index].uri);

                    ),
              ]);

              //   onTap: () {
              //     // playSong(item.data![index].uri);
              //     Navigator.push(context, MaterialPageRoute(builder: (context)=>NowPlaying ( songModelList:_allSongs,
              //     audioPlayer: _audioPlayer,)));
              //   },
              //   title: Text(item.data![index].title),
              //   subtitle: Text('${item.data![index].artist}'),
              //   trailing: Icon(Icons.more_horiz),
              // ),}
            }

            // padding: EdgeInsets.fromLTRB(0, 0, 0, 60),

            // title: Text(item.data![index].title),
            // subtitle: Text(item.data![index].artist ?? "没有作者"),
            // trailing: const Icon(Icons.more_horiz),
            // leading: const CircleAvatar(
            //   child: Icon(Icons.music_note),
            // ),

            //playSong(item.data![index].uri);

            //
            // Align(
            //   alignment: Alignment.bottomRight,
            //   child: GestureDetector(
            //       onTap: () {
            //         Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //                 builder: (context) => NowPlaying(
            //                       songModelList: allSongs,
            //                       audioPlayer: _audioPlayer,
            //                     )));
            //       },
            //       child: Container(
            //         margin: EdgeInsets.fromLTRB(0, 0, 15, 15),
            //         child: const CircleAvatar(
            //           radius: 30,
            //           child: Icon(
            //             Icons.play_arrow,
            //           ),
            //         ),
            //       )
            //       ),
            // ),
            ));
  }
}

class MusicTile extends StatefulWidget {
  const MusicTile({super.key, required this.songModel});
  final SongModel songModel;

  @override
  State<MusicTile> createState() => _MusicTileState();
}

class _MusicTileState extends State<MusicTile> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return ListTile(
      leading: const Icon(Icons.music_note),
      title: Text(widget.songModel.displayNameWOExt),
      subtitle: Text('${widget.songModel.artist}'),
      trailing: IconButton(icon:Icon(Icons.more_horiz), onPressed: () {
        setState(() {

        });

      },),
    );
  }
}
