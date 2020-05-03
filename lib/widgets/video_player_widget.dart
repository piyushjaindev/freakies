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
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  VideoPlayerController _controller;
  AnimationController _animationController;
  Animation animation;
  bool isInitialized = false;
  PostModal post;

  @override
  void initState() {
//    _visibilityController = VisibilityDetectorController();
//    _visibilityController.updateInterval = Duration.zero;
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    post = Provider.of<PostModal>(context, listen: false);
    _animationController = AnimationController(
      vsync: this,
      value: 0,
      //upperBound: 300,
      duration: Duration(milliseconds: 1200),
    );
    animation =
        CurveTween(curve: Curves.bounceOut).animate(_animationController);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _animationController.value = 0;
    });
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
              key: Key('vsds'),
              onVisibilityChanged: (info) {
                if (info.visibleFraction == 0 && this.mounted) {
                  setState(() {
                    _controller.pause();
                  });
                }
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
                      _animationController.forward(from: 0.6);
                      //_animationController.value = 0;
                    },
                    child: Center(
                      child: _controller.value.aspectRatio > 1
                          ? AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            )
                          : Container(
                              height: double.infinity,
                              width: double.infinity,
                              child: VideoPlayer(_controller),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 30.0,
                    width: MediaQuery.of(context).size.width,
                    height: 400,
                    child: VideoIcons(),
                  ),
                  if (post.ownerID == user.id)
                    (Positioned(
                      top: 20.0,
                      right: 20.0,
                      child: IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return DeleteConfirmationDialog(post);
                              });
                        },
                        icon: Icon(Icons.delete),
                        iconSize: 40.0,
                      ),
                    )),
                  if (!_controller.value.isPlaying)
                    (Center(
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
                    )),
                  Center(
                    child: AnimatedBuilder(
                      animation: animation,
                      //animation: _animationController.view,
                      builder: (_, __) {
                        return Icon(
                          Icons.favorite,
                          size: animation.value * 300,
                        );
                      },
                      // ),
                    ),
                  ),
                ],
              ))
          : Loader(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class DeleteConfirmationDialog extends StatelessWidget {
  final PostModal post;
  DeleteConfirmationDialog(this.post);

  @override
  Widget build(BuildContext context) {
    CurrentUser user = Provider.of<CurrentUser>(context, listen: false);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      title: Text(
        'Are you sure?',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
      ),
      content: Text(
        'This video will be permanently deleted.',
        style: TextStyle(fontWeight: FontWeight.w400),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
        FlatButton(
          onPressed: () async {
            await user.deleteVideo(post);
            Navigator.pop(context);
          },
          child: Text(
            'Delete',
            style: TextStyle(
              fontSize: 20.0,
              color: Color(0xFFE64926),
            ),
          ),
        )
      ],
    );
  }
}
