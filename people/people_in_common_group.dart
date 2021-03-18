
import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/user/user_model.dart';
import 'package:organizer/views/components/thumbnail.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/views/components/progress_indicator.dart';

class PeopleInCommonGroup extends StatefulWidget {
    
    final User user;
    final Key buttonKey;

    const PeopleInCommonGroup({
        @required this.user,
        this.buttonKey
    });
    
    @override
    _PeopleInCommonGroupState createState() => _PeopleInCommonGroupState();
}

    
class _PeopleInCommonGroupState extends State<PeopleInCommonGroup>  {

    bool isAdded = false;
    final ChatListController _chatListController = ChatListController();

    @override
    void initState() {
        super.initState();
    }
    
    @override
    void dispose() {
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
                children: <Widget>[
                    MyThumbnail.ovalAvatar(
                        path: widget.user.avatar,
                        radius: 21.5,
                        icon: Icons.person,
                    ),
                    Container(width: 12),
                    Expanded(
                        child: Text(
                            widget.user.displayName ?? 'Loading...',
                            style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                color: globals.Colors.black,
                            )
                        ),
                    ),
                    SizedBox(
                        width: 75, height: 36,
                        child: OutlineButton(
                            key: widget.buttonKey,
                            borderSide: isAdded ? BorderSide(color: globals.Colors.gray, width: 1) : BorderSide(color: globals.Colors.red, width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                            child: Text(
                                isAdded ? allTranslations.text('chat_done') : allTranslations.text('chat_add'),
                                style: TextStyle(
                                    color: isAdded ? globals.Colors.gray : globals.Colors.orange,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600
                                ),
                            ),
                            onPressed: () {
                                if (isAdded)
                                    return null;
                                _chatListController.createPrivateChannelWith(widget.user.uid);
                                setState(() {
                                    isAdded = true;
                                });
                            },
                        ),
                    )
                ],
            ),
        );
    }
}