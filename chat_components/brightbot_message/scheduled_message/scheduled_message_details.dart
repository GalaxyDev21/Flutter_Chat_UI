import 'package:flutter/material.dart';
import 'package:organizer/common/date_utils.dart';
import 'package:organizer/controllers/chat/scheduled_message_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/scheduled_message/scheduled_message_details_chat_header.dart';
import 'package:organizer/views/chat/chat_components/bubble.dart';
import 'package:organizer/views/components/oval_avatar.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/views/components/indexedlistview.dart';
import 'package:organizer/views/components/progress_indicator.dart';

class ScheduledMessageDetails extends StatelessWidget {

    ScheduledMessageDetails({
        @required this.channel,
        @required this.scheduledMessages
    });

    final Channel channel;
    final ScheduledMessageController _scheduledMsgController = ScheduledMessageController();
    final List<ScheduledMessage> scheduledMessages;

    String get scheduledTime => Utils.formatScheduledMessageTime(DateTime.parse(scheduledMessages[0].scheduledTime).toLocal());
    String get scheduledTaskId => scheduledMessages[0].scheduledTaskId;

    Widget _buildItem(int index) {
        final ScheduledMessage message = scheduledMessages[index];
        return Container(
            margin: EdgeInsets.only(left: 12, top: index == 0 ? 12 : 0, right: 12, bottom: 0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    if (index == 0 && channel.isOutsidePublisher)
                        MyOvalAvatar.fromChannel(channel, iconRadius: 20)
                    else if (index == 0)
                        MyOvalAvatar.ofUser(message.from, iconRadius: 20)
                    else
                        Container(width: 40),
                    Container(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                if (index == 0)
                                    ScheduledMessageDetailsChatHeader(channel, message),
                                ClipRect(
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(2, 2, 4, 4),
                                        child: Bubble(
                                            message: message,
                                            index: null,
                                            builderHandler: null,
                                        ),
                                    ),
                                )
                            ],
                        )
                    )
                ],
            )
        );
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
                title: Text(
                    scheduledTime,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700
                    )
                ),
                actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.delete, color: globals.Colors.brownGray),
                        onPressed: () async {
                            final bool isDelete = await showCancelAndOkDialog(
                                context,
                                title: 'chat_schedule_message_delete_title',
                                content: 'chat_schedule_message_delete_content',
                                okText: 'chat_schedule_message_delete'
                            );
                            if (isDelete) {
                                showActivityIndicator();
                                final bool isDeleted = await _scheduledMsgController.deleteScheduledMsg(scheduledTaskId);
                                if (isDeleted) {
                                    hideActivityIndicator();
                                    Navigator.of(context).maybePop(isDeleted);
                                }
                                else {
                                    hideActivityIndicator();
                                    showOkDialog(
                                        context,
                                        title: 'error',
                                        content: 'error'
                                    );
                                }
                            }
                        }
                    ),
                ]
            ),
            body: Stack(
                children: <Widget>[
                    GestureDetector(
                        child: IndexedListView.builder(
                            itemBuilder: (BuildContext context, int index) {
                                return _buildItem(index);
                            },
                            itemCount: scheduledMessages.length,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                        )
                    ),
                ],
            )
        );
    }
}