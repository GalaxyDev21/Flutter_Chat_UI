
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/option.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/user/user_model.dart';
import 'package:organizer/views/chat/group/display_group_qr.dart';
import 'package:organizer/views/components/chat_button.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet_wrapper.dart';
import 'package:organizer/views/components/future_builder.dart';
import 'package:organizer/views/components/modal_bottom_sheet_navbar.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/views/components/option_tile.dart';
import 'package:organizer/views/components/oval_avatar.dart';
import 'package:organizer/views/components/user_name_view.dart';

class GroupCreated extends StatefulWidget {

    GroupCreated({
        @required this.channel
    });

    Channel channel;
    
    @override
    State<GroupCreated> createState() => GroupCreatedState();
}

class GroupCreatedState extends State<GroupCreated> {
    
    final UserController _userController = UserController();
    final ChatListController _chatListController = ChatListController();
    Future<Contact> _getContacts;
    List<bool> _sentInviteList = <bool>[];

    @override
    void initState() {
        super.initState();
        _getContacts = _userController.getContacts();
    }

    Widget _invitePeopleInContactList(User user, int index) {
        return UserListItem(
            user.uid,
            padding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: (String name) => MySendButton(
                text: _sentInviteList[index] ? allTranslations.text('library_done') : allTranslations.text('chat_send'),
                disabled: _sentInviteList[index],
                onTap: () async {
                    if (!_sentInviteList[index]) {
                        await _chatListController.sendInviteUserToGroup(widget.channel.info.sid, user.uid);
                        setState(() {
                            _sentInviteList[index] = true;
                        });
                    }
                },
            )
        );
    }

    @override
    Widget build(BuildContext context) {
        return MyFullscreenBottomSheetWrapper(
            child: Column(
                children: <Widget>[
                    MyModalSheetNavBar(
                        leftButton: Container(),
                        rightButton: <Widget>[
                            FlatButton(
                                key: const Key('library_done'),
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                    allTranslations.text('library_done'),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: globals.Colors.orange,
                                    )
                                ),
                                onPressed: () async {
                                    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
                                },
                            )
                        ]
                    ),
                    Expanded(
                        child: ListView(
                            padding: const EdgeInsets.all(12),
                            children: <Widget>[
                                Center(
                                    child: MyOvalAvatar.ofChannel(widget.channel.avatar, iconRadius: 80),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 16, bottom: 6),
                                    child: Text(
                                        widget.channel.name ?? '',
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                    ),
                                ),
                                Text(
                                    allTranslations.text('chat_is_created'),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(top: 24, bottom: 12),
                                    child: Text(
                                        allTranslations.text('chat_invite_members'),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                        ),
                                    ),
                                ),
                                MyOptionTile(
                                    option: Option(title: 'chat_invite_qr', icon: MdiIcons.qrcode),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                                    onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                                builder: (BuildContext context) {
                                                    return DisplayGroupQR(
                                                        channel: widget.channel
                                                    );
                                                }
                                            )
                                        );
                                    }
                                ),
                                MyFutureBuilder<Contact>.bounce(
                                    future: _getContacts,
                                    builder: (BuildContext context, Contact contacts) {
                                        final List<User> connected = contacts.connected;
                                        if (_sentInviteList.length != connected.length)
                                            _sentInviteList = List<bool>.generate(connected.length, (int index) => false);
                                        return ListView.builder(
                                            itemCount: connected.length,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemBuilder: (BuildContext context, int index) => _invitePeopleInContactList(connected[index], index)
                                        );
                                    }
                                )
                            ]
                        )
                    )
                ],
            )
        );
    }    
}