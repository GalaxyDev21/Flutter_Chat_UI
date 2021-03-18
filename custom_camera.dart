import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:organizer/views/library/image_delegate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as VideoThumbnail;


class CustomCamera extends StatefulWidget {
    
    CustomCamera({this.onComplete});
    
    Function(bool isImage, String path, double ratio, {String thumb, int period}) onComplete;
    
    @override
    _CustomCameraState createState() {
        return _CustomCameraState();
    }
}

class _CustomCameraState extends State<CustomCamera>
    with WidgetsBindingObserver {
    CameraController controller;
    String imagePath;
    String videoPath;
    List<CameraDescription> cameras;
    
    VideoPlayerController videoController;
    VoidCallback videoPlayerListener;
    
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    
    @override
    void initState() {
        super.initState();
        WidgetsBinding.instance.addObserver(this);
        
        availableCameras().then((List<CameraDescription> cams) {
            setState(() {
                cameras = cams;
            });
            if (cameras != null && cameras.isNotEmpty) {
                _onNewCameraSelected(cameras.first);
            }
        });
    }
    
    @override
    void dispose() {
        WidgetsBinding.instance.removeObserver(this);
        if (controller != null) {
            controller.dispose();
        }
        if (videoController != null) {
            videoController.dispose();
        }
        super.dispose();
    }
    
    @override
    void didChangeAppLifecycleState(AppLifecycleState state) {
        if (state == AppLifecycleState.inactive) {
            controller?.dispose();
        } else if (state == AppLifecycleState.resumed) {
            if (controller != null) {
                _onNewCameraSelected(controller.description);
            }
        }
    }
    
    Future<void> _onNewCameraSelected(CameraDescription cameraDescription) async {
        if (controller != null) {
            await controller.dispose();
        }
        controller = CameraController(
            cameraDescription,
            ResolutionPreset.high,
            enableAudio: true,
        );
        
        controller.addListener(() {
            if (mounted) setState(() {});
        });
        
        try {
            await controller.initialize();
        } on CameraException catch (e) {
            print(e.toString());
        }
        
        if (mounted) {
            setState(() {});
        }
    }
    
    void _previewImage(String path) {
        ImageGallerySaver.saveImage(File(path).readAsBytesSync())
            .then((dynamic result) {
            print(result);
        }).catchError((Object error) {
            print(error.toString());
        });
    }
    
    void _previewVideo(String path) {
        ImageGallerySaver.saveVideo(path).then((dynamic result) {
            print(result);
        }).catchError((Object error) {
            print(error.toString());
        });
    }
    
    void _onTakePictureButtonPressed() {
        _takePicture().then((String filePath) {
            if (mounted) {
                setState(() {
                    imagePath = filePath;
                    if (videoController != null) {
                        videoController.dispose();
                        videoController = null;
                    }
                });

//        if (Platform.isIOS) {
//          _previewImage(filePath);
//        } else {
//          Utilities.checkPermission(PermissionGroup.storage).then((granted) {
//            if (granted) {
//              _previewImage(filePath);
//            }
//          });
//        }
            }
        });
    }
    
    void _onVideoRecordButtonPressed() {
        _startVideoRecording().then((String filePath) {
            if (mounted)
                setState(() {});
        });
    }
    
    void _onStopButtonPressed() {
        _stopVideoRecording().then((_) {
            if (mounted)
                setState(() {});
        });
    }
    
    Future<String> _startVideoRecording() async {
        if (videoController != null) {
            setState(() {
                videoController.dispose();
                videoController = null;
            });
        }
        if (!controller.value.isInitialized) {
            return null;
        }
        
        final Directory extDir = await getApplicationDocumentsDirectory();
        final String dirPath = '${extDir.path}/Videos';
        await Directory(dirPath).create(recursive: true);
        final String filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch.toString()}.mp4';
        
        if (controller.value.isRecordingVideo) {
            return null;
        }
        
        try {
            videoPath = filePath;
            await controller.startVideoRecording(filePath);
        } on CameraException catch (e) {
            print(e.toString());
            return null;
        }
        return filePath;
    }
    
    Future<void> _stopVideoRecording() async {
        if (!controller.value.isRecordingVideo) {
            return;
        }
        
        try {
            await controller.stopVideoRecording();
        } on CameraException catch (e) {
            print(e.toString());
            return;
        }
        
        _startVideoPlayer();

//    if (Platform.isIOS) {
//      _previewVideo(videoPath);
//    } else {
//      Utilities.checkPermission(PermissionGroup.storage).then((granted) {
//        if (granted) {
//          _previewVideo(videoPath);
//        }
//      });
//    }
    }
    
    Future<String> _takePicture() async {
        if (!controller.value.isInitialized) {
            return null;
        }
        final Directory extDir = await getApplicationDocumentsDirectory();
        final String dirPath = '${extDir.path}/Pictures';
        await Directory(dirPath).create(recursive: true);
        final String filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
        
        if (controller.value.isTakingPicture) {
            return null;
        }
        
        try {
            await controller.takePicture(filePath);
        } on CameraException catch (e) {
            print(e.toString());
            return null;
        }
        return filePath;
    }
    
    Future<void> _startVideoPlayer() async {
        final VideoPlayerController vcontroller = VideoPlayerController.file(File(videoPath));
        vcontroller.setLooping(true);
        videoPlayerListener = () {
            if (videoController != null && videoController.value.size != null) {
                // Refreshing the state to update video player with the correct ratio.
                if (mounted)
                    setState(() {});
                videoController.removeListener(videoPlayerListener);
            }
        };
        vcontroller.addListener(videoPlayerListener);
        await vcontroller.initialize();
        if (mounted) {
            setState(() {
                imagePath = null;
                videoController = vcontroller;
            });
        }
        
        await vcontroller.play();
    }
    
    Future<void> _getImage() async {
        final String path = await ImageDelegate().pickImage(ImageSource.gallery);
        
        if (path != null) {
            setState(() {
                imagePath = path;
            });
        }
    }
    
    Widget _cameraPreviewWidget() {
        if (controller == null || !controller.value.isInitialized) {
            return Container();
        } else {
            return AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
            );
        }
    }
    
    Widget _thumbnailWidget() {
        return videoController == null && imagePath == null
            ? Container()
            : Container(
            child: Container(
                child: Center(
                    child: (videoController == null)
                        ? Image.file(File(imagePath))
                        : AspectRatio(
                        aspectRatio:
                        videoController.value.size != null
                            ? videoController.value.aspectRatio
                            : 1.0,
                        child: VideoPlayer(videoController)
                    ),
                ),
            ),
        );
    }
    
    Widget _captureControlRowWidget() {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
                FlatButton(
                    child: const Icon(Icons.image, color: Colors.white, size: 30,),
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                        _getImage();
                    },
                ),
                GestureDetector(
                    child: const Icon(Icons.radio_button_unchecked, size: 60, color: Colors.white,),
                    onTap: () {
                        if (controller != null && controller.value.isInitialized && !controller.value.isRecordingVideo) {
                            _onTakePictureButtonPressed();
                        }
                    },
                    onLongPressStart: (_) {
                        if (controller != null && controller.value.isInitialized && !controller.value.isRecordingVideo) {
                            _onVideoRecordButtonPressed();
                        }
                    },
                    onLongPressEnd: (_) {
                        if (controller != null && controller.value.isInitialized && controller.value.isRecordingVideo) {
                            _onStopButtonPressed();
                        }
                    },
                ),
                FlatButton(
                    child: const Icon(Icons.cached, size: 30, color: Colors.white,),
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                        if (cameras != null && cameras.isNotEmpty) {
                            for (CameraDescription description in cameras) {
                                if (description != controller.description) {
                                    _onNewCameraSelected(description);
                                }
                            }
                        }
                    }
                )
            ],
        );
    }
    
    Widget _acceptControlRowWidget() {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
                FlatButton(
                    child: const Icon(Icons.close, color: Colors.white, size: 30,),
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                        setState(() {
                            imagePath = null;
                            videoController?.dispose();
                            videoController = null;
                        });
                    },
                ),
                FlatButton(
                    child: const Icon(Icons.check, size: 30, color: Colors.white,),
                    padding: const EdgeInsets.all(0),
                    onPressed: () async {
                        if (widget.onComplete != null) {
                            if (imagePath != null) {
                                final Image image = Image.file(File(imagePath));
                                image.image
                                    .resolve(const ImageConfiguration())
                                    .addListener(ImageStreamListener((ImageInfo info, bool _) {
                                    widget.onComplete(true, imagePath, info.image.width / info.image.height);
                                    Navigator.maybePop(context);
                                }));
                            } else if (videoController != null) {
                                final Directory appDocDir = await getTemporaryDirectory();
                                final String thumb = await VideoThumbnail.VideoThumbnail.thumbnailFile(
                                    video: videoPath,
                                    thumbnailPath: appDocDir.path,
                                    imageFormat: VideoThumbnail.ImageFormat.JPEG,
                                    maxHeight: 300,
                                    maxWidth: 300,
                                    quality: 30,
                                );
                                widget.onComplete(false, videoPath, MediaQuery.of(context).size.aspectRatio, thumb: thumb, period: videoController.value.duration.inSeconds);
                                Navigator.maybePop(context);
                            }
                        }
                    }
                )
            ],
        );
    }
    
    @override
    Widget build(BuildContext context) {
        return Stack(
            children: <Widget>[
                (videoController == null && imagePath == null)
                    ? _cameraPreviewWidget()
                    : _thumbnailWidget(),
                Scaffold(
                    key: _scaffoldKey,
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                    ),
                    body: SafeArea(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                                (videoController == null && imagePath == null)
                                    ? _captureControlRowWidget()
                                    : _acceptControlRowWidget(),
                                Container(height: 40)
                            ],
                        )
                    ),
                )
            ],
        );
    }
}