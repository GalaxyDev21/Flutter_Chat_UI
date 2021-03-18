import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/services/router_service.dart';
import 'package:organizer/views/chat/chat_components/system_message/system_message_builder.dart';
import 'package:organizer/views/profile/user_profile/user_profile_route.dart';

class MemberChangedBuilder extends SystemMessageBuilder {
    @override
    String get type => SystemMessageTypes.member;

    MemberChangedBuilder({
        String body,
        Map<String, dynamic> attributes,
        DateTime dateCreated
    }) : super(body: body, attributes: attributes, dateCreated: dateCreated);
    
    // before schdeuled message update, 'uid' is not included in system message attributes
    String get uid => attributes.containsKey('uid') ? attributes['uid'] : null;
    String get name => attributes['name'];
    bool get joined => attributes['joined'];
    
    @override
    Widget builder(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    GestureDetector(
                        onTap: () {
                            RouterService.instance.navigateTo(UserProfileRoute.buildPath(uid), context: context);
                        },
                        child: Text(
                            uid == UserController.currentUser.uid ? allTranslations.text('chat_you') : name,
                            style: TextStyle(
                                color: globals.Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                            ),
                        ),
                    ),
                    RichText(
                        text: TextSpan(
                            children: <TextSpan>[
                                TextSpan(
                                    text: allTranslations.text(joined ? 'chat_system_joined' : 'chat_system_left'),
                                    style: TextStyle(
                                        color: globals.Colors.brownGray,
                                        fontSize: 12
                                    ),
                                ),
                                TextSpan(
                                    text: DateFormat('hh:mm a').format(dateCreated.toLocal()),
                                    style: TextStyle(
                                        color: globals.Colors.lightGray,
                                        fontSize: 12
                                    ),
                                )
                            ]
                        ),
                    )
                ],
            ),
        );
    }
}