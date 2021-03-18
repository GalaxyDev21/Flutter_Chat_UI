import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/services/notification_service.dart';
import 'package:organizer/services/router_service.dart';
import 'package:organizer/views/components/user_name_view.dart';
import 'package:organizer/views/chat/chat_components/chat_screen/chat_screen.dart';
import 'package:organizer/controllers/option.dart';
import 'package:organizer/views/library/resource_library.dart';
import 'package:organizer/views/profile/user_profile/user_profile_route.dart';

class ChatPrivate extends ChatScreen {
    ChatPrivate({
        Key key,
        String channelSid
    }) : super(
        key: key,
        channelSid: channelSid,
    );
    
    @override
    State createState() => ChatPrivateState();
}

class ChatPrivateState extends ChatScreenState<ChatScreen> {
    
    String otherUid;

    @override
    List<Option> get floatingActions => <Option>[];
    
    @override
    void initState() {
        NotificationService.instance.configure(
            onResume: (Map<String, dynamic> message) async {
                print('on resume: $message');
                final String channelType = message['channelType'] ?? message['data']['channelType'];
                final String channelSid = message['channelSid'] ?? message['data']['channelSid'];
                if (!ModalRoute.of(context).settings.name.contains(channelSid)) {
                    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
                    handleNotification(channelType, channelSid);
                } else {
                    Navigator.of(context).popUntil((Route<dynamic> route) => route.settings.name.contains(channelSid));
                }
            }
        );
        super.initState();
        final List<String> uids = channel.info.friendlyName.split('_');
        otherUid = uids.first == UserController.currentUser.uid ? uids.last : uids.first;
    }
    
    @override
    void dispose() {
        NotificationService.instance.configure();
        super.dispose();
    }
    
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
                            child: InkWell(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                        UserNameView(
                                            otherUid ?? '',
                                            textStyle: TextStyle(
                                                color: globals.Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700
                                            ),
                                        ),
                                    ],
                                ),
                                onTap: () async {
                                    await RouterService.instance.navigateTo(UserProfileRoute.buildPath(otherUid), context: context);
                                    if (!chatListController.channels.contains(channel))
                                        Navigator.of(context).maybePop();
                                },
                            ),
                        )
                    ],
                ),
                actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.folder, color: globals.Colors.brownGray),
                        onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute<bool>(
                                    builder: (BuildContext context) => ResourceLibraryLoader(channel: channel)
                                ),
                            );
                        }
                    ),
                    IconButton(
                        icon: Icon(Icons.info_outline, color: globals.Colors.brownGray),
                        onPressed: () async {
                            await RouterService.instance.navigateTo(UserProfileRoute.buildPath(otherUid), context: context);
                            if (!chatListController.channels.contains(channel))
                                Navigator.of(context).maybePop();
                        }
                    )
                ],
            ),
            body: chatWidget()
        );
    }
}