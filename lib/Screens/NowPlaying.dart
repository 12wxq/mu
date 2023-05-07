import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'dart:math';
import 'package:mu/song_page.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
//mport 'package:audioplayer/audioplayer.dart';
import 'package:mu/Screens/AllSongs.dart';
import 'package:mu/themeData.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'AllSongs.dart';
import '../provider/song_model_provider.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying(
      {Key? key,
      required this.songModelList,
      required this.Index,
      required this.audioPlayer})
      : super(key: key);
  final List<SongModel> songModelList;
  final AudioPlayer audioPlayer;
  final int Index;

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying>  with SingleTickerProviderStateMixin{
  // Define the playlist
  late AnimationController _controller;
  AudioPlayer audioPlugin = AudioPlayer();

  bool _menu=true;
  bool _shu=false;
  bool _repeat=false;


  Duration _duration = const Duration();
  Duration _position = const Duration();
  bool _isPlaying = false;
  List<AudioSource> songList = [];
   late int currentIndex;

  void popBack() {
    Navigator.pop(context);
  }

  void seekToSecond(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);


  }








  @override
  void initState() {
    super.initState();



    _controller = AnimationController(
        duration: const Duration(seconds: 5),
        lowerBound: 0.0,
        upperBound: 1.0,
        vsync: this);
    // _controller1 = AnimationController(
    //     duration: Duration(seconds: 5),
    //     lowerBound: 0.7,
    //     upperBound: 1.0,
    //     vsync: this);
    currentIndex=widget.Index;
    parseSong();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
   // widget.audioPlayer.dispose();

  }
  void parseSong() {
    try {
      listenToSongIndex();
      for (var element in widget.songModelList) {
        songList.add(
          AudioSource.uri(
            Uri.parse(element.uri!),
            tag: MediaItem(
              id: element.id.toString(),
              album: element.album ?? "没有音乐",
              title: element.displayNameWOExt,
              artUri: Uri.parse('https://example.com/albumart.jpg'),
            ),
          ),
        );
      }
      // widget.audioPlayer
      //     .setAudioSource(ConcatenatingAudioSource(children: songList));

      widget.audioPlayer.setAudioSource( ConcatenatingAudioSource(
          shuffleOrder: DefaultShuffleOrder(),
          children: songList), initialIndex:currentIndex, initialPosition: Duration.zero);

      widget.audioPlayer.play();


      _controller.repeat();
      _isPlaying = true;

      widget.audioPlayer.durationStream.listen((d) {
        if (d != null) {
          setState(() {
            _duration = d;
          });
        }
      });
      widget.audioPlayer.positionStream.listen((p) {
        setState(() {
          _position = p;
        });
      });
      listenToEvent();
    } on Exception catch (_) {
      popBack();
    }
  }

  // void playSong() {
  //   try {
  //     widget.audioPlayer
  //         .setAudioSource(AudioSource.uri(Uri.parse(widget.songModel.uri!)));
  //     widget.audioPlayer.play();
  //     _isPlaying = true;
  //   } on Exception {
  //     log('bb');
  //   }
  //   widget.audioPlayer.durationStream.listen((d) {
  //     setState(() {
  //       _duration = d!;
  //     });
  //   });
  //   widget.audioPlayer.positionStream.listen((p) {
  //     setState(() {
  //       _position = p;
  //     });
  //   });
  // }

  void listenToEvent() {
    widget.audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        setState(() {
          _isPlaying = true;
        });
      } else {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void listenToSongIndex() {
    widget.audioPlayer.currentIndexStream.listen((indexevent) {
      setState(() {
       if(indexevent!=null){
         currentIndex=indexevent;
       }

        context
            .read<SongModelProvider>()
            .setId(widget.songModelList[currentIndex].id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child:Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          child:
              Column( children:[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children:
              [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: NeuBox(
                    child: IconButton(
                      onPressed: () {
                        popBack();
                      },
                      icon: Icon(Icons.arrow_back_ios_new)),



                  ),

                ),

                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(widget.songModelList[currentIndex].displayNameWOExt) ),

                        SizedBox(
                  height: 60,
                  width: 60,
                  child: NeuBox(child: IconButton(icon:Icon(Icons.menu),onPressed: (){

                  },),



                  ),

                ),



              ]
                  ),
                SizedBox(height: 25,),
                // NeuBox(child: Column(
                //     children:[ClipRRect(
                //         borderRadius: BorderRadius.circular(8),
                //         child: Image.asset('')),
                //
                //       Padding(
                //         padding: EdgeInsets.all(8.0),
                //         child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children:[ Column(
                //                 crossAxisAlignment: CrossAxisAlignment.center,
                //                 children:[Text('AAA',style: TextStyle(fontWeight: FontWeight.bold,
                //                     fontSize: 18,color: Colors.grey.shade700),),
                //                   Text('AAA',style: TextStyle(fontWeight: FontWeight.bold,
                //                       fontSize: 22),),
                //                 ]),
                //               Icon(Icons.favorite,color: Colors.red,
                //                 size: 32,
                //               )
                //             ]
                //         ),
                //       ),
                //
                //
                //
                //     ]
                // )),


             NeuBox(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child:
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                            radius:100.0,
                            child:  RotationTransition(
                                turns: _controller,
                                child:  ArtWorkWidget())),

                     ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      widget.songModelList[currentIndex].displayNameWOExt,
                      textAlign: TextAlign.center,
                      // overflow: TextOverflow.fade,
                      // maxLines: 1,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                    ),
                  ])),

            const SizedBox(
              height: 15.0,
            ),
            // Text(
            //   widget.songModel.artist.toString() == "<unknown>"
            //       ? '未知歌手'
            //       : widget.songModel.artist.toString(),
            //   overflow: TextOverflow.fade,
            //   maxLines: 1,
            //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
            // ),

            Slider(
              activeColor: Colors.green,
              inactiveColor: Colors.blueAccent,
              thumbColor: Color(0xffD5A099),
              min: 0.0,
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble() + 1.0,
              onChanged: (value) {
                setState(() {
                  seekToSecond(value.toInt());
                  value = value;
                });
              },
            ),
                SizedBox(height: 25,),
            Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(_position.toString().split('.')[0]),
                Text(_duration.toString().split('.')[0]),
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NeuBox(
                  child: IconButton(
                      onPressed: () async {
                       setState(() {
                         if(_menu){
                           widget.audioPlayer.setLoopMode(LoopMode.one);
                           _menu=false;
                           _repeat=true;
                         }
                         if(_repeat){
                           widget.audioPlayer.setShuffleModeEnabled(true);
                           _repeat=false;
                           _shu=true;
                         }
                         if(_shu){
                           widget.audioPlayer.setLoopMode(LoopMode.all);
                           _shu=false;
                           _menu=true;
                         }
                       });
                      },
                      icon:  Icon(
                    _menu?Icons.menu:_repeat?Icons.repeat:_shu?Icons.shuffle:Icons.menu,
                        size: 24.0,
                      )),
                ),

                NeuBox(
                  child: IconButton(
                      onPressed: () async {
                        if (widget.audioPlayer.hasPrevious) {
                          await widget.audioPlayer.seekToPrevious();
                        }
                      },
                      icon: Icon(
                        Icons.skip_previous,
                        size: 24.0,
                      )),
                ),
                NeuBox(
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          if (_isPlaying) {
                            widget.audioPlayer.pause();
                            _controller.stop();
                           // _controller1.stop();
                          } else {
                            if (_position >= _duration) {
                              seekToSecond(0);
                            } else {
                              widget.audioPlayer.play();
                              _controller.repeat();


                            }
                          }


                          _isPlaying = !_isPlaying;
                        });
                      },
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 40.0,
                        color: Colors.pink[200],
                      )),
                ),
                NeuBox(

                  child: IconButton(
                      onPressed: () async {
                        if (widget.audioPlayer.hasNext) {
                          await widget.audioPlayer.seekToNext();
                        }
                      },
                      icon: Icon(
                        Icons.skip_next,
                        size: 24.0,
                      )),
                ),
              ],
            )
   ]),
        ),
      ),
    );
  }

  void changeToSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }
}

class ArtWorkWidget extends StatelessWidget {
  const ArtWorkWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
        id: context.watch<SongModelProvider>().id,
        type: ArtworkType.AUDIO,
        artworkBorder: BorderRadius.circular(300),
        artworkHeight: 200,
        artworkWidth: 200,
        artworkFit: BoxFit.fill,
        nullArtworkWidget: const Icon(
          Icons.music_note,
          size: 200,
        ),
      );

  }
}
