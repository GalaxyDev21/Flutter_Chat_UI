import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:organizer/icons_icons.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/views/chat/chat_components/chat_screen/chat_screen.dart';
import 'package:organizer/controllers/option.dart';
import 'package:organizer/views/components/modal_bottom_sheet_header.dart';
import 'package:organizer/views/components/switch_tile.dart';
import 'package:organizer/views/components/tile.dart';
import 'package:organizer/views/components/dialogs.dart';

class ChatSelf extends ChatScreen {
    ChatSelf({
        Key key,
        String channelSid
    }) : super(
        key: key,
        channelSid: channelSid,
    );
    
    @override
    State createState() => ChatSelfState();
}

class ChatSelfState extends ChatScreenState<ChatScreen> {
    
    @override
    List<Option> get floatingActions => <Option>[];
    
    @override
    void initState() {
        chatListController = ChatListController();
        
        isPinned = chatListController.pinnedChannels.contains(widget.channelSid);
        
        super.initState();
    }
    
    @override
    void dispose() {
        super.dispose();
    }
    bool isPinned = false;
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: globals.Colors.multiTab,
            appBar: AppBar(
                elevation: 0,
                leading: IconButton(
                    icon: Icon(
                        Icons.arrow_back,
                        color: globals.Colors.brownGray
                    ),
                    onPressed: () {
                        Navigator.of(context).maybePop();
                    },
                ),
                centerTitle: false,
                titleSpacing: 0,
                title: Row(
                    children: <Widget>[
                        Expanded(
                            child: Text(allTranslations.text('chat_welcome_self_title'), 
                                style: TextStyle(
                                    color: globals.Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700
                                ),
                            ),
                        )
                    ],
                ),
                actions: <Widget>[
                    IconButton(
                        icon: Icon(
                            Icons.more_vert, color: globals.Colors.brownGray
                        ),
                        onPressed: () async {
                            showMyModalBottomSheet<void>(
                                context: context,
                                child: StatefulBuilder(
                                    builder: (BuildContext context, StateSetter stateSetter) {
                                        return Column(
                                            children: <Widget>[
                                                MyModalBottomSheetHeader(
                                                    child: MyTile(
                                                        option: Option(title: 'chat_welcome_self_title', icon: MdiIcons.noteText)
                                                    )
                                                ),
                                                MySwitchTile(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                    option: const Option(title: 'library_pin_to_top', icon: MyIcons.pin),
                                                    value: isPinned,
                                                    onChanged: (bool value) {
                                                        stateSetter(() {
                                                            isPinned = !isPinned;
                                                            if (value)
                                                                userController.addPinnedChannels(UserController.currentUser.uid, channel.info.sid);
                                                            else
                                                                userController.removePinnedChannels(UserController.currentUser.uid, channel.info.sid);
                                                        });
                                                    },
                                                )
                                            ],
                                        );
                                    },
                                )
                            );
                        }
                    )
                ],
            ), 
            body: chatWidget()
        );
    }
}