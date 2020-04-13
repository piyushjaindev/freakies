import 'package:flutter/material.dart';
import 'package:freakies/modals/post_modal.dart';
import 'package:freakies/widgets/video_player_widget.dart';
import 'package:provider/provider.dart';

class VideoPageView extends StatefulWidget {
  final List<PostModal> postLists;
  final int currentIndex;
  VideoPageView({this.postLists, this.currentIndex = 0});

  @override
  _VideoPageViewState createState() => _VideoPageViewState();
}

class _VideoPageViewState extends State<VideoPageView> {
  PageController _pageController;
  int index;

  @override
  void initState() {
    // TODO: implement initState
    index = widget.currentIndex;
    super.initState();
    _pageController = PageController(initialPage: index);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        //physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        itemCount: widget.postLists.length, // - widget.currentIndex,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, int i) {
          return ChangeNotifierProvider.value(
            value: widget.postLists[i],
            child: VideoPlayerWidget(),
          );
        });
  }
}
