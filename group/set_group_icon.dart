import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:organizer/controllers/chat/channel_controller.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/option.dart';
import 'package:organizer/models/chat/channel_info_model.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/views/chat/group/group_created.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet_wrapper.dart';
import 'package:organizer/views/components/modal_bottom_sheet_navbar.dart';
import 'package:organizer/views/components/option_tile.dart';
import 'package:organizer/views/components/image_cropper.dart';
import 'package:organizer/views/components/progress_indicator.dart';
import 'package:organizer/views/library/image_delegate.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:organizer/globals.dart' as globals;

class SetGroupIcon extends StatelessWidget {

    SetGroupIcon(
        this.context, 
        {
            @required this.name,
            this.about = '',
        }
    );
    final ChatListController _chatListController = ChatListController();
    final ChannelController _channelController = ChannelController();
    BuildContext context;
    String name;
    String about;

    Future<void> _createChannelWithPhoto({
        @required BuildContext context,
        @required ImageSource imageSource
    }) async {
        try {
            final String path = await ImageDelegate().pickImage(imageSource);
            if (path == null)
                throw 'path not chosen';
            final String cropped = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                    return ImageCropper(filePath: path);
                }
            );
            if (cropped == null)
                throw 'not cropped well';
            showActivityIndicator(isTransparent: true);
            final String channelFriendlyName = name.replaceAll(' ', '') + '${DateTime.now().millisecondsSinceEpoch}';
            final Channel newChannel = await _chatListController.createChannel(
                channelFriendlyName: channelFriendlyName,
                name: name,
                description: about,
                type: ChannelType.ORGANIZATION,
                avatar: cropped
            );
            if (newChannel == null)
                throw 'newChannel issue';
            final tuple = _channelController.uploadChannelPhoto(newChannel.info, File(cropped));
            final Stream<StorageTaskEvent> events = tuple.item1;
            final String avatarPath = tuple.item2;
            events.listen((StorageTaskEvent event) {
                if (event.type == StorageTaskEventType.success) {
                    final DefaultCacheManager manager = DefaultCacheManager();
                    manager.emptyCache();
                    hideActivityIndicator();
                    Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) => GroupCreated(
                                channel: newChannel
                            )
                        )
                    );
                } else if (event.type == StorageTaskEventType.failure) {
                    hideActivityIndicator();
                }
            });
        }
        catch (err) {
            hideActivityIndicator();
            print('createChannelWithPhoto failed: ' + err);
            return;
        }
    }

    @override
    Widget build(BuildContext context) {
        return MyFullscreenBottomSheetWrapper(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    MyModalSheetNavBar(
                        rightButton: <Widget>[
                            FlatButton(
                                key: const Key('chat_skip'),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                    allTranslations.text('chat_skip'),
                                    style: TextStyle(
                                        color: globals.Colors.orange,
                                        fontWeight: FontWeight.w600
                                    )
                                ),
                                onPressed: () async {
                                    showActivityIndicator(isTransparent: true);
                                    final String channelFriendlyName = name.replaceAll(' ', '') + '${DateTime.now().millisecondsSinceEpoch}';
                                    final Channel newChannel = await _chatListController.createChannel(
                                        channelFriendlyName: channelFriendlyName,
                                        name: name,
                                        description: about,
                                        type: ChannelType.ORGANIZATION,
                                        avatar: null
                                    );
                                    if (newChannel != null) {
                                        hideActivityIndicator();
                                        Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute<void>(
                                                builder: (BuildContext context) => GroupCreated(
                                                    channel: newChannel
                                                )
                                            ),
                                            (Route<dynamic> route) => route.isFirst
                                        );
                                    }
                                },
                            )
                        ]
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Text(
                                        allTranslations.text('chat_select_group_profile'),
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                        )
                                    ),
                                ),
                                MyOptionTile(
                                    option: const Option(title: 'library_choose_from', icon: Icons.phone_iphone),
                                    onPressed: () async {
                                        _createChannelWithPhoto(context: context, imageSource: ImageSource.gallery);
                                    },
                                ),
                                MyOptionTile(
                                    option: const Option(title: 'library_take_photo', icon: Icons.camera_alt),
                                    onPressed: () async {
                                        _createChannelWithPhoto(context: context, imageSource: ImageSource.camera);
                                    },
                                ),
                            ],
                        )
                    )
                ]
            )
        );
    }
}