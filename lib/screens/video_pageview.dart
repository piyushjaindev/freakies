import 'package:flutter/material.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/post_modal.dart';
import 'package:freakies/widgets/video_player_widget.dart';
import 'package:provider/provider.dart';

class VideoPageView extends StatefulWidget {
  final List<PostModal> postLists;
  final int currentIndex;
  final bool isOwner;
  VideoPageView({this.postLists, this.currentIndex = 0, this.isOwner = false});

  @override
  _VideoPageViewState createState() => _VideoPageViewState();
}

class _VideoPageViewState extends State<VideoPageView> {
  PageController _pageController;
  List<PostModal> postLists;

  @override
  void initState() {
    // postLists = widget.postLists;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    postLists = widget.isOwner
        ? Provider.of<CurrentUser>(context).posts
        : widget.postLists;
    if (widget.isOwner && postLists.length < 1) Navigator.pop(context);
    _pageController = PageController(
        initialPage: postLists.length > widget.currentIndex
            ? widget.currentIndex
            : postLists.length - 1,
        keepPage: true);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        //physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        itemCount: postLists.length, // - widget.currentIndex,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, int i) {
          return ChangeNotifierProvider.value(
            value: postLists[i],
            child: VideoPlayerWidget(),
          );
        });
  }
}
