import 'package:flutter/material.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/post_modal.dart';
import 'package:freakies/widgets/loader.dart';
import 'package:freakies/widgets/video_icons.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerWidget extends StatefulWidget {
  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with AutomaticKeepAliveClientMixin<VideoPlayerWidget> {
  VideoPlayerController _controller;
  bool isInitialized = false;
  PostModal post;

  @override
  void initState() {
    post = Provider.of<PostModal>(context, listen: false);
    super.initState();
    if (_controller == null) {
      try {
        _controller = VideoPlayerController.network(post.videoURL)
          ..initialize().then((_) {
            setState(() {
              isInitialized = true;
              _controller.setLooping(true);
              _controller.play();
            });
          });
      } catch (e) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Video playback error'),
        ));
      }
    }
  }

  @override
  void dispose() {
    //_timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    CurrentUser user = Provider.of<CurrentUser>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black,
      body: isInitialized
          ? VisibilityDetector(
              onVisibilityChanged: (info) {
                if (info.visibleFraction == 0) _controller.pause();
              },
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _controller.pause();
                      });
                    },
                    onDoubleTap: () {
                      post.updateLike(user.id);
                    },
                    child: Center(
                        child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
//                    child: _controller.value.aspectRatio > 1
//                        ? AspectRatio(
//                            aspectRatio: _controller.value.aspectRatio,
//                            child: VideoPlayer(_controller),
//                          )
//                        : Container(
//                            height: double.infinity,
//                            width: double.infinity,
//                            child: VideoPlayer(_controller),
//                          ),
                        ),
                  ),
                  Positioned(
                    bottom: 30.0,
                    child: VideoIcons(),
                  ),
                  !_controller.value.isPlaying
                      ? Center(
                          child: IconButton(
                            icon: Icon(Icons.play_arrow),
                            iconSize: 100.0,
                            color: Colors.white.withOpacity(0.5),
                            onPressed: () {
                              setState(() {
                                _controller.play();
                              });
                            },
                          ),
                        )
                      : Text('')
                ],
              ),
            )
          : Loader(),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
