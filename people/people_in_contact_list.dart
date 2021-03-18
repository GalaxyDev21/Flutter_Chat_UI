
import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/user/user_model.dart';
import 'package:organizer/views/components/thumbnail.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/views/components/buttons.dart';
import 'package:organizer/views/components/shadow_view.dart';

class PeopleInContactList extends StatelessWidget {

    PeopleInContactList({
        @required this.user
    });

    User user;
    
    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
                children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: MyThumbnail.ovalAvatar(
                            path: user.avatar,
                            radius: 21.5,
                            icon: Icons.person,
                        ),
                    ),
                    Expanded(
                        child: Text(
                            user.displayName ?? user.uid,
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: globals.Colors.black,
                            )
                        ),
                    ),
                    ShadowView(
                        width: 75, height: 36,
                        offset: const Offset(1, 1), blurRadius: 2, borderRadius: 2,
                        child: gradientButton(
                            width: 75, height: 36, borderRadius: 2,
                            child: Center(
                                child: Text(
                                    allTranslations.text('chat_chat_bold'),
                                    style: TextStyle(
                                        color: globals.Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600
                                    ),
                                ),
                            ),
                            onPressed: () {
                                final String channelId = ChatListController.generateChannelFriendlyName(
                                    <String>[UserController.currentUser.uid, user.uid]
                                );
                                Navigator.of(context).maybePop(channelId);
                            }
                        )
                    )
                ],
            ),
        );
    }
}