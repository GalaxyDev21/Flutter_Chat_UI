import 'package:flutter/material.dart';
import 'package:organizer/common/date_utils.dart';
import 'package:organizer/controllers/chat/scheduled_message_controller.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/models/chat/scheduled_message_model.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/scheduled_message/scheduled_message_view.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/views/components/progress_indicator.dart';
import 'package:organizer/views/constants/style_constants.dart';

class ScheduledUnsentMessages extends MyFullscreenBottomSheet {

    final Channel channel;

    ScheduledUnsentMessages({
        @required this.channel
    });

    @override
    _ScheduledUnsentMessagesState createState() => _ScheduledUnsentMessagesState();
}

class _ScheduledUnsentMessagesState extends MyFullscreenBottomSheetState<ScheduledUnsentMessages> {

    // Future<List<ScheduledMessagePreview>> unsentScheduledMessagesFuture;
    List<ScheduledMessagePreview> unsentMessages;

    @override
    void initState() {
        super.initState();
        // unsentScheduledMessagesFuture = ScheduledMessageController().getUnsentScheduledMessages(widget.channel.info.sid);
    }

    Widget unsentMessageTile(ScheduledMessagePreview msg){
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                        child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: kFullBorderDecoration,
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                        Text(
                                            msg.body ?? '(No text)',
                                            style: k14TextStyle,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(top:6.0),
                                            child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                    Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                            Text(
                                                                scheduledTime(msg.scheduledTime),
                                                                style: k12SubtitleTextStyle ,
                                                            ),
                                                        ],
                                                    ),
                                        
                                                    Container(
                                                        child: Row(
                                                            children: <Widget>[
                                                                ...List<Widget>.generate(
                                                                    msgIcons(msg).length, (int index) => 
                                                                        Padding(padding: const EdgeInsets.only(right:6),
                                                                            child: Icon(
                                                                                msgIcons(msg)[index],
                                                                                size: 14,
                                                                                color: globals.Colors.gray
                                                                            )
                                                                        ),
                                                                ),   
                                                            ],
                                                        ),
                                                    )
                                                ],
                                            ),
                                        )
                                    ],
                                )
                            ),
                        ),
                    ],
                );

    }

    @override
    Widget mainWidget() {
        return FutureBuilder<List<ScheduledMessagePreview>>(
            future: ScheduledMessageController().getUnsentScheduledMessages(widget.channel.info.sid),
            builder: (BuildContext context, AsyncSnapshot<List<ScheduledMessagePreview>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                    return MyProgressIndicator();
                if (!snapshot.hasData)
                    return Container();
                if (snapshot.data.isEmpty){
                    WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pop(context));
                }
                unsentMessages = snapshot.data;
                return ListView.builder(
                    itemCount: unsentMessages.length,
                    itemBuilder: (BuildContext context, int index){
                        return InkWell(
                            child: unsentMessageTile(unsentMessages[index]),
                            onTap:() async {
                                bool maybeDeleted = await Navigator.push(
                                    context,
                                    MaterialPageRoute<bool>(builder: (BuildContext context) =>
                                        ScheduledMessageView(
                                            channel: widget.channel,
                                            documentId: unsentMessages[index].documentId
                                        )
                                    )
                                );
                                // if (maybeDeleted)
                                //     setState(() {
                                //         future = ScheduledMessageController().getUnsentScheduledMessages(widget.channel.info.sid);
                                //     });
                            }
                        );
                    },
                );
            }
        );
    }

    List<IconData> msgIcons(ScheduledMessagePreview msgs){
        final List<IconData> icons = [];
        final List<String> types = msgs.messageTypes.keys.toList();
        for (String type in  types){
            if (type != 'text')
                icons.add(Message.iconFromType(type));
        }
        return icons;
    }

    String scheduledTime(DateTime scheduledTime) => Utils.formatScheduledMessageTime(scheduledTime.toLocal());
}
