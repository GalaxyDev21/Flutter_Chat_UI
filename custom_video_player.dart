import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:organizer/controllers/library/child_library_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/views/components/progress_indicator.dart';

class CustomVideoPlayer extends StatefulWidget {
    
    CustomVideoPlayer({this.url, this.path});
    
    String url;
    String path;
    
    @override
    _CustomVideoPlayerState createState() {
        return _CustomVideoPlayerState();
    }
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
    
    final ChildLibraryController _childLibraryController = ChildLibraryController();
    
    VideoPlayerController _videoPlayerController;
    ChewieController _chewieController;
    
    @override
    void initState() {
        super.initState();
        if (widget.url != null) {
            _videoPlayerController = VideoPlayerController.network(widget.url);
            _videoPlayerController.initialize().then((_) {
                setState(() {
                    _chewieController = ChewieController(
                        videoPlayerController: _videoPlayerController,
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        autoPlay: true,
                    );
                });
            });
        } else {
            _childLibraryController.getVideoUrl(Uri.https(globals.apiUrl, '/api/uploaded', <String, String>{ 'path': widget.path }).toString()).then((String path) {
                _videoPlayerController = VideoPlayerController.network(path);
                _videoPlayerController.initialize().then((_) {
                    setState(() {
                        _chewieController = ChewieController(
                            videoPlayerController: _videoPlayerController,
                            aspectRatio: _videoPlayerController.value.aspectRatio,
                            autoPlay: true,
                        );
                    });
                });
            });
        }
    }
    
    @override
    void dispose() {
        _videoPlayerController.dispose();
        super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: globals.Colors.white),
                    onPressed: () {
                        Navigator.maybePop(context);
                    },
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
            ),
            backgroundColor: Colors.black,
            body: SafeArea(
                child: _chewieController != null
                    ? Chewie(
                        controller: _chewieController,
                    )
                    : MyProgressIndicator()
            ),
        );
    }
}