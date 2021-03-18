import 'dart:math';

import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/member_model.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/chat/chat_components/chat_indexed_list_view.dart';
import 'package:organizer/views/components/shadow_view.dart';
import 'package:provider/provider.dart';
import 'package:organizer/globals.dart' as globals;

class BottomListCount extends StatelessWidget {
    final Channel channel;
    final bool isOutsidePublisher;
    final ChatListController chatListController;
    
    BottomListCount({
        @required this.channel,
        @required this.isOutsidePublisher,
        @required this.chatListController
    });

    int setMessageAndMembers(BuildContext context) {
        final ChatIndexedScrollController chatIndexedScrollController = Provider.of<ChatIndexedScrollController>(context);
        List<Message> messages = Provider.of<List<Message>>(context);
        if (isOutsidePublisher)
            messages = messages.where((Message msg) => msg.from == 'outsidePublisher' || msg.type == 'bot').toList();
        else
            messages = messages;
        channel.messages = messages;
        List<Member> members = Provider.of<List<Member>>(context);
        Member myMember;
        if (members != null) {
            channel.members = members;
            myMember = channel.members.firstWhere ((Member m) {
                return m.uid == UserController.currentUser.uid;
            }, orElse: () => null);
        }
        if (myMember == null)
            return 0;
        int unreadCount = 0;
        final int channelLastConsumedMessageIndex = channel.lastConsumedMessageIndex ?? 0;
        final int memberLastConsumedMemberIndex = myMember.lastConsumedMessageIndex ?? 0;
        if (messages != null && myMember != null && channelLastConsumedMessageIndex > memberLastConsumedMemberIndex){
            final List<String> readMessageSid = <String>[];
            for (int i = 0 ; i < min(chatIndexedScrollController.startIndex, channelLastConsumedMessageIndex - memberLastConsumedMemberIndex) ; i++) {
                if (channel.messages[i].from != UserController.currentUser.uid) {
                    unreadCount ++;
                }
            }
            for (int i = chatIndexedScrollController.startIndex; i < channelLastConsumedMessageIndex - memberLastConsumedMemberIndex; i++){
                if (channel.messages[i].from != UserController.currentUser.uid) {
                    readMessageSid.add(channel.messages[i].sid);
                }
            }
            chatListController.setReadBy(channel.info.sid, readMessageSid);
            Member.setLastConsumedMessageIndex(channel.info.sid, max(memberLastConsumedMemberIndex, channelLastConsumedMessageIndex - chatIndexedScrollController.startIndex));
        }
        return unreadCount;
    }
    
    @override 
    Widget build(BuildContext context) {
        final ChatIndexedScrollController params = Provider.of<ChatIndexedScrollController>(context);
        final int unreadCount = setMessageAndMembers(context);
        return Stack(
            children: <Widget>[
                if (params.startIndex > 0)
                    Positioned(
                        right: 16, bottom: 16,
                        child: ShadowView(
                            width: 36, height: 36, borderRadius: 18, blurRadius: 10,
                            offset: const Offset(0, 5),
                            child: InkWell(
                                child: Icon(Icons.keyboard_arrow_down, color: globals.Colors.brownGray, size: 24),
                                onTap: () {
                                    params.jumpToIndex(0);
                                },
                            )
                        ),
                    ),
                if (unreadCount > 0)
                    Positioned(
                        right: 40, bottom: 36,
                        child: CircleAvatar(
                            radius: 8.5 + (unreadCount >= 100 ? (unreadCount.toString().length - 2).toDouble() * 3.5 : 0),
                            backgroundColor: globals.Colors.black,
                            child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white
                                ),
                            ),
                        ),
                    ),
            ],
        );
    }
}