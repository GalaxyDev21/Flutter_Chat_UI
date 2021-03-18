import 'package:flutter/material.dart';
import 'package:organizer/icons_icons.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/member_model.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/views/chat/chat_components/chat_screen/scheduled_unsent_message.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:provider/provider.dart';

class UnsentScheduledMessageButton extends StatelessWidget {
    
    final Channel channel;

    const UnsentScheduledMessageButton({Key key, this.channel}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Selector<List<Member>, Member>(
            selector: (BuildContext context, List<Member> members) => members.firstWhere(
                (Member member) => member.uid == UserController.currentUser.uid),
            builder: (BuildContext context, Member member, Widget child) {
                final int running = member.attributes['currentSMCount'] ?? 0;
                return running == 0
                    ? Container(height: 0)
                    : Stack(children: <Widget>[
                        Positioned(
                            child: Padding(
                                padding: const EdgeInsets.all(0),
                                child : IconButton(
                                    key: const Key('unsent-scheduled-messages'),
                                    padding: const EdgeInsets.all(0),
                                    icon: Icon(MyIcons.timer, color: globals.Colors.gray),
                                    onPressed: () {
                                        showMyModalBottomSheet<String>(
                                            context: context,
                                            child: ScheduledUnsentMessages(
                                                channel: channel,
                                            ),
                                            fullScreen: true
                                        );
                                    },
                                )
                            )
                        ),
                        Positioned(
                            left: 27,
                            bottom: 27,
                            child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                    color: globals.Colors.lightRed,
                                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                                    border: Border.all(color:Colors.white),
                                    boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: globals.Colors.black.withOpacity(0.16),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2)
                                        )
                                    ]
                                ),
                                child: Center(
                                    child: Text(
                                        running.toString(),
                                        style: const TextStyle(color: Colors.white, fontSize: 10),
                                    )
                                ),
                            )
                        )
                    ]
                );
            },
        );
    }
}