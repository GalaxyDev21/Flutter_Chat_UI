
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/library/file_controller.dart';
import 'package:organizer/controllers/library/library_controller.dart';
import 'package:organizer/controllers/upload_controller.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/handlers/chat_insert_handler.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/pojo/folder.dart';
import 'package:organizer/pojo/media_file.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet_wrapper.dart';
import 'package:organizer/views/components/library_snapshot.dart';
import 'package:organizer/views/components/modal_bottom_sheet_navbar.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/views/components/option_tile.dart';
import 'package:organizer/views/components/progress_indicator.dart';
import 'package:organizer/views/library/image_delegate.dart';
import 'package:organizer/views/library/video_delegate.dart';

class InsertItem extends StatelessWidget {

    InsertItem({
        @required this.channel,
        @required this.insertHandler
    });

    Channel channel;
    ChatInsertHandler insertHandler;

    @override
    Widget build(BuildContext context) {
        return MyFullscreenBottomSheetWrapper(
            child: Column(
                children: <Widget>[
                    MyModalSheetNavBar(
                        mainTitle: allTranslations.text('library_add_photo_video'),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                MyOptionTile(
                                    option: FileShareOptions.chooseFrom,
                                    onPressed: () async {
                                        final Map<String, dynamic> video = await VideoDelegate().pickBoth(ImageSource.gallery, generateThumb: false);
                                        if (video != null) {
                                            showActivityIndicator(isTransparent: true);
                                            final MediaFile mediaFile = await UploadController().uploadFileToChat(channel, DateTime.now().toIso8601String(), File(video['source']));
                                            hideActivityIndicator();
                                            if (insertHandler != null)
                                                insertHandler.onSendFile(
                                                    mediaFile.id,
                                                    mediaFile.type.contains('video') ? MessageTypes.video : MessageTypes.image,
                                                    mediaFile.name
                                                );
                                            Navigator.of(context).pop(true);
                                        }
                                    }
                                ),
                                MyOptionTile(
                                    option: FileShareOptions.takePhoto,
                                    onPressed: () async {
                                        final String path = await ImageDelegate().pickImage(ImageSource.camera);
                                        if (path != null) {
                                            showActivityIndicator(isTransparent: true);
                                            final MediaFile image = await UploadController().uploadFileToChat(channel, DateTime.now().toIso8601String(), File(path));
                                            hideActivityIndicator();
                                            if (insertHandler != null)
                                                insertHandler.onSendFile(
                                                    image.id,
                                                    MessageTypes.image,
                                                    image.name
                                                );
                                            Navigator.of(context).pop(true);
                                        }
                                    }
                                ),
                                MyOptionTile(
                                    option: FileShareOptions.takeVideo,
                                    onPressed: () async {
                                        final VideoDelegate delegate = VideoDelegate();
                                        final Map<String, dynamic> video = await delegate.pickVideo(ImageSource.camera, generateThumb: false);
                                        if (video != null) {
                                            showActivityIndicator(isTransparent: true);
                                            final MediaFile videoFile = await UploadController().uploadFileToChat(channel, DateTime.now().toIso8601String(), File(video['source']));
                                            hideActivityIndicator();
                                            if (insertHandler != null)
                                                insertHandler.onSendFile(
                                                    videoFile.id,
                                                    MessageTypes.video,
                                                    videoFile.name
                                                );
                                            Navigator.of(context).pop(true);
                                        }
                                    }
                                ),
                            ],
                        )
                    ),
                    const Divider(height: 2, color: globals.Colors.veryLightGray),
                    Expanded(
                        child: MyLibrarySnapshot(
                            types: const <String>['image', 'video'],
                            onTap: (MediaFile file) async {
                                showActivityIndicator();
                                try {
                                    final MediaController fileController = MediaController(file, outChannelSid: channel.isOutsidePublisher ? channel.info.sid : null);
                                    final MediaFile existing = (await fileController.getChannelMirror(channel.info.sid)) as MediaFile;
                                    if (existing != null) {
                                        if (insertHandler != null)
                                            insertHandler.onSendFile(
                                                existing.id,
                                                existing.mainType,
                                                existing.name
                                            );
                                        hideActivityIndicator();
                                        Navigator.of(context).pop(true);
                                        return;
                                    }
                                    final Folder destinationFolder = await LibraryController(outChannelSid: channel.isOutsidePublisher ? channel.info.sid : null).getDefaultUploadFolder(channel.info.sid);
                                    if (destinationFolder == null)
                                        return null;
                                    final MediaFile mirror = await fileController.publish(channel.info.sid, destinationFolder.id);
                                    if (insertHandler != null)
                                        insertHandler.onSendFile(
                                            mirror.id,
                                            mirror.mainType,
                                            mirror.name
                                        );
                                    hideActivityIndicator();
                                    Navigator.of(context).pop(true);
                                }
                                catch (e) {
                                    print(e);
                                }
                            }
                        )
                    )
                ],
            )
        );
    }
    
}