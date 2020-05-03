import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:freakies/db/postservice.dart';
import 'package:freakies/db/storageservice.dart';
import 'package:freakies/modals/currentuser.dart';
import 'package:freakies/modals/size_config.dart';
import 'package:freakies/modals/user_modal.dart';
import 'package:freakies/widgets/loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as PATH;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class UploadVideo extends StatefulWidget {
  final User currentUser;
  UploadVideo({this.currentUser});

  @override
  _UploadVideoState createState() => _UploadVideoState();
}

class _UploadVideoState extends State<UploadVideo> {
  File _file;
  File outputFile;
  File thumbnailFile;
  int index = 0;
  double duration = 0;
  String randomID = Uuid().v4();
  String postDescription;
  List<String> tags;
  RangeValues _values, _valuesTracker;
  final FlutterFFprobe _flutterFFprobe = FlutterFFprobe();
  final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  VideoPlayerController _controller;
  TextEditingController _postController = TextEditingController();
  TextEditingController _tagsController = TextEditingController();
  bool isProcessing = false;
  StorageService storageService = StorageService();
  CurrentUser user;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    user = Provider.of<CurrentUser>(context);
    super.initState();
  }

  trimVideo(outputPath) async {
    String startTime =
        '${(_values.start ~/ 60)}:${(_values.start % 60).toInt()}';
    return await _flutterFFmpeg.execute(
        "-ss $startTime -i ${_file.path} -t ${_values.end - _values.start} -c:v libx264 $outputPath");
  }

  captureThumbnail(outputPath) async {
    return await _flutterFFmpeg
        .execute("-i ${outputFile.path} -vframes 1 -an -ss 02 $outputPath");
  }

  prepareToUpload() async {
    setState(() {
      isProcessing = true;
    });
    try {
      final appDir = await PATH.getExternalStorageDirectory();
      final appDirPath = appDir.path;
      outputFile = File('$appDirPath/post_$randomID.mp4');
      thumbnailFile = File('$appDirPath/post_${randomID}_thumbnail.jpg');
      int rcv = await trimVideo(outputFile.path);
      int rct = await captureThumbnail(thumbnailFile.path);
      if (rcv == 0 && rct == 0) {
        tags = [];
        postDescription = _postController.text.trim();
        _tagsController.text.split(',').forEach((tag) {
          tags.add(tag.trim());
        });
        await createPostMethod();
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Unable to process video'),
        ));
      }
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Something went wrong'),
      ));
    }
    setState(() {
      isProcessing = false;
    });
    randomID = Uuid().v4();
    _file.deleteSync();
    outputFile.deleteSync();
    thumbnailFile.deleteSync();
  }

  createPostMethod() async {
    try {
      String videoURL =
          await storageService.uploadFile('post_$randomID.mp4', outputFile);
      String thumbnailURL = await storageService.uploadFile(
          'post_${randomID}_thumbnail.jpg', thumbnailFile);

      Map postMap = {
        'caption': postDescription,
        'thumbnailURL': thumbnailURL,
        'videoURL': videoURL,
        'tags': tags
      };
      await PostService().createPostDocument(user.id, randomID, postMap);
      //Navigator.pop(context);
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Something went wrong'),
      ));
    }
  }

  getMediaInfo() {
    _flutterFFprobe.getMediaInformation(_file.path).then((info) {
//      print(info);
//      print("Duration: ${info['duration']}");
      setState(() {
        duration = info['duration'] / 1000;
        _values = RangeValues(0, duration > 60 ? 60 : duration);
        _valuesTracker = RangeValues(0, duration > 60 ? 60 : duration);
      });
    });
  }

  videoFromCamera() async {
    //Navigator.pop(context);
    File file = await ImagePicker.pickVideo(source: ImageSource.camera);
    if (file != null) {
      //Navigator.push(context, MaterialPageRoute(builder: (context) => Upload(file: file, currentUser: widget.currentUser,)));
      setState(() {
        _file = file;
      });
      getMediaInfo();
      _controller = VideoPlayerController.file(_file)..initialize();
    }
  }

  videoFromGallery() async {
    //Navigator.pop(context);
    File file = await ImagePicker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      //Navigator.push(context, MaterialPageRoute(builder: (context) => Upload(file: file, currentUser: widget.currentUser,)));
      setState(() {
        _file = file;
      });
      getMediaInfo();
      _controller = VideoPlayerController.file(_file)..initialize();
    }
  }

  stepStateChecker(int stepIndex) {
    if (stepIndex < index)
      return StepState.complete;
    else if (stepIndex == index)
      return StepState.editing;
    else
      return StepState.disabled;
  }

  nextStep() async {
    switch (index) {
      case 0:
        if (await _file.exists())
          setState(() {
            index++;
          });
        break;
      case 1:
        if ((_values.end - _values.start) <= 60)
          setState(() {
            index++;
          });
        break;
      case 2:
      case 3:
        setState(() {
          index++;
        });
        break;
      case 4:
        prepareToUpload();
        break;
      default:
        break;
    }
  }

  goBack() {
    switch (index) {
      case 1:
      case 2:
      case 3:
      case 4:
        setState(() {
          index--;
        });
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isProcessing)
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('You can\'t leave while video is uploading'),
          ));
        return await !isProcessing;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(children: [
            Stepper(
              onStepContinue: nextStep,
              onStepCancel: goBack,
              controlsBuilder: (context, {onStepContinue, onStepCancel}) {
                switch (index) {
                  case 0:
                    return ButtonBar(
                      alignment: MainAxisAlignment.start,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: onStepContinue,
                          child: Text('Next'),
                        ),
                      ],
                    );
                    break;
                  case 1:
                  case 2:
                  case 3:
                    return ButtonBar(
                      alignment: MainAxisAlignment.start,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: onStepContinue,
                          child: Text('Next'),
                        ),
                        RaisedButton(
                          onPressed: onStepCancel,
                          child: Text('Back'),
                        )
                      ],
                    );
                    break;
                  case 4:
                    return ButtonBar(
                      alignment: MainAxisAlignment.start,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: onStepContinue,
                          child: Text('Upload'),
                        ),
                        RaisedButton(
                          onPressed: onStepCancel,
                          child: Text('Back'),
                        )
                      ],
                    );
                    break;
                  default:
                    return Container();
                    break;
                }
              },
              currentStep: index,
              steps: [
                Step(
                    title: Text(
                      'Select a video to upload',
                      style: Theme.of(context).textTheme.subtitle,
                    ),
                    state: stepStateChecker(0),
                    isActive: (index >= 0),
                    content: Column(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FlatButton(
                              onPressed: videoFromCamera,
                              child: Text('Camera'),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            FlatButton(
                              onPressed: videoFromGallery,
                              child: Text('Gallery'),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        _file != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Selected File: '),
                                  Text(
                                    _file.path,
                                    maxLines: 3,
                                    style: TextStyle(fontSize: 15.0),
                                  )
                                ],
                              )
                            : Container()
                      ],
                    )
                    /*content: Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    width: SizeConfig.mainWidth ,
                    height: SizeConfig.mainHeight * 0.4,
                    child: RaisedButton(
                      onPressed: (){},
                      child: Text('Select'),
                    ),
                  )*/
                    ),
                Step(
                    title: Text('Cut your video',
                        style: Theme.of(context).textTheme.subtitle),
                    subtitle: Text('Maximum duration: 60 seconds'),
                    state: stepStateChecker(1),
                    isActive: (index >= 1),
                    content: Column(
                      children: <Widget>[
                        Container(
                            alignment: Alignment.center,
                            color: Colors.white,
                            width: SizeConfig.mainWidth * 0.6,
                            height: SizeConfig.mainHeight * 0.3,
                            child: _file == null
                                ? Text(
                                    'Please go back and select a file first.')
                                : GestureDetector(
                                    onTap: () {
                                      _controller.value.isPlaying
                                          ? _controller.pause()
                                          : _controller.play();
                                    },
                                    child: VideoPlayer(_controller))),
                        Row(
                          children: <Widget>[
                            Text('00:00'),
                            Expanded(
                              child: RangeSlider(
                                onChanged: (RangeValues newValues) {
                                  setState(() {
                                    _values = newValues;
                                    _controller.seekTo(Duration(
                                        seconds: newValues.start.toInt()));
                                  });
                                },
                                onChangeEnd: (RangeValues newValues) {
                                  if ((newValues.end - newValues.start) > 60) {
                                    if (_valuesTracker.end != newValues.end) {
                                      setState(() {
                                        _values = _valuesTracker = RangeValues(
                                            newValues.end - 60, newValues.end);
                                      });
                                    } else if (_valuesTracker.start !=
                                        newValues.start) {
                                      setState(() {
                                        _values = _valuesTracker = RangeValues(
                                            newValues.start,
                                            newValues.start + 60);
                                      });
                                    }
                                  }
                                },
                                labels: _values == null
                                    ? RangeLabels('0', '0')
                                    : RangeLabels(
                                        '${(_values.start ~/ 60)}:${(_values.start % 60).toInt()}',
                                        '${(_values.end ~/ 60)}:${(_values.end % 60).toInt()}'),
                                min: 0,
                                max: duration,
                                values: _values == null
                                    ? RangeValues(0, 0)
                                    : _values,
                              ),
                            ),
                            Text(
                                '${(duration ~/ 60)}:${(duration % 60).toInt()}')
                          ],
                        )
                      ],
                    )),
                Step(
                  title: Text('Write a description \(optional\)',
                      style: Theme.of(context).textTheme.subtitle),
                  state: stepStateChecker(2),
                  isActive: (index >= 2),
                  content: Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: TextField(
                      controller: _postController,
                      maxLines: 4,
                      maxLength: 50,
                      decoration: InputDecoration(
                        labelText: 'Post Description',
                        hintText: 'What\'s on your mind?',
                      ),
                    ),
                  ),
                ),
                Step(
                  title: Text('Add tags \(optional\)',
                      style: Theme.of(context).textTheme.subtitle),
                  subtitle: Text('Separated by comma'),
                  state: stepStateChecker(3),
                  isActive: (index >= 3),
                  content: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: TextField(
                      controller: _tagsController,
                      maxLines: 2,
                      maxLength: 20,
                      decoration: InputDecoration(
                        labelText: 'Tags',
                        hintText: '#holi, #viral',
                      ),
                    ),
                  ),
                ),
                Step(
                    title: Text('All set! Ready to upload',
                        style: Theme.of(context).textTheme.subtitle),
                    state: stepStateChecker(4),
                    isActive: (index >= 4),
                    content: Container(
//                  alignment: Alignment.center,
//                  width: SizeConfig.mainWidth * 0.6,
//                  height: SizeConfig.mainHeight * 0.3,
//                  child: RaisedButton(
//                    onPressed: () {},
//                    child: Text('Upload'),
//                  ),
                        ))
              ],
            ),
            if (isProcessing)
              (Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.8),
                child: Loader(),
              ))
          ]),
        ),
      ),
    );
  }
}
