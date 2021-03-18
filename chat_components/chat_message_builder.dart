import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/handlers/chat_message_builder_handler.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/mybot_message_builder.dart';
import 'package:organizer/views/chat/chat_components/bubble.dart';
import 'package:organizer/views/chat/chat_components/chat_indexed_list_view.dart';
import 'package:organizer/views/chat/chat_components/chat_message_avatar.dart';
import 'package:organizer/views/chat/chat_components/date_splitter_chat_message.dart';
import 'package:organizer/views/chat/chat_components/system_message/system_message_builder.dart';
import 'package:organizer/views/chat/chat_components/chat_message/chat_message_header.dart';
import 'package:organizer/views/chat/chat_components/polling_message/polling_message_builder.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:provider/provider.dart';

class BubbleItem extends StatefulWidget {
    final int index;
    final Channel channel;
    final List<Message> messages;
    final int readCount;
    final ChatMessageBuilderHandler builderHandler;
    final TabController tabController;
    const BubbleItem({this.index, this.channel, this.messages, this.readCount, this.builderHandler, this.tabController});

  @override
  _BubbleItemState createState() => _BubbleItemState();
}

class _BubbleItemState extends State<BubbleItem> with AutomaticKeepAliveClientMixin {
    TabController tabController;
    @override
    void initState() {
        tabController = widget.tabController;
        super.initState();
    }
    @override
    bool get wantKeepAlive { 
        return tabController.index == 0;
    }
    @override
    Widget build(BuildContext context) {
        super.build(context);
        if (!wantKeepAlive)
            super.updateKeepAlive();
        final bool isFirst = ChatListController.isFirstMessage(widget.messages, widget.index);
        final bool isScheduledMessage = ChatListController.isScheduledMessage(widget.messages[widget.index]);
        final bool isPreviousMessageScheduled = !(widget.index+1 == widget.messages.length) &&
            ChatListController.isPreviousMessageScheduled(widget.messages[widget.index], widget.messages[widget.index + 1]);
        final bool isBotMessage = ChatListController.isBotMessage(widget.messages[widget.index]);
        final bool hasChatMessageAvatar = (isFirst || (isScheduledMessage && !isPreviousMessageScheduled) || isBotMessage || (!isScheduledMessage && isPreviousMessageScheduled))
            && !ChatListController.isHiddenForMeMessage(widget.messages[widget.index]);
        final bool isLast = ChatListController.isLastMessage(widget.messages, widget.index);
        
        final DateTime currentMessageDate = widget.messages[widget.index].dateCreated.toLocal();
        int validNextIndex = widget.index + 1;
        while (validNextIndex < widget.messages.length && ChatListController.isHiddenForMeMessage(widget.messages[validNextIndex]))
            validNextIndex++;
        final DateTime nextMessageDate = validNextIndex < widget.messages.length
            ? widget.messages[validNextIndex].dateCreated.toLocal()
            : DateTime.fromMillisecondsSinceEpoch(0);
        final String currentDate = ChatListController.generateDate(currentMessageDate);
        final String nextDate = ChatListController.generateDate(nextMessageDate);
        
        return Selector<ChatIndexedScrollController,int> (
            selector:  (BuildContext context, ChatIndexedScrollController indexedScrollController) => indexedScrollController.jumpedIndex,
            builder: (BuildContext context, int jumpedIndex, Widget child) {
                bool isHighlight = false;
                // BoxDecoration cardDecoration ;
                if (jumpedIndex != widget.index) {
                    isHighlight = false;
                }
                else if (jumpedIndex != 0) {
                    isHighlight = true;
                }
                final Widget child = Container(
                    key: Key(widget.messages[widget.index].body),
                    margin: EdgeInsets.only(top: hasChatMessageAvatar ? 12 : 0),
                    child: ChatMessageBuilder(
                        channel: widget.channel,
                        message: widget.messages[widget.index],
                        totalMessageCount: widget.messages.length,
                        hasChatMessageAvatar: hasChatMessageAvatar,
                        isLast: isLast,
                        readCount: widget.readCount,
                        index: widget.index,
                        builderHandler: widget.builderHandler,
                        isHighlight: isHighlight,
                    ),
                );
                if (currentDate != nextDate && !ChatListController.isHiddenForMeMessage(widget.messages[widget.index])) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: DateSplitterOnChatMessage(dateTime: widget.messages[widget.index].dateCreated.toLocal()),
                            ),
                            child
                        ],
                    );
                }
                return child;
            },
        );
    }
}

class ChatMessageBuilder extends StatelessWidget {
    const ChatMessageBuilder({
        @required this.channel,
        @required this.message,
        this.totalMessageCount,
        this.hasChatMessageAvatar = true,
        this.isLast = true,
        this.readCount = 0,
        @required this.index,
        @required this.builderHandler,
        this.listScrollController,
        this.isHighlight = false
    });
    
    final Channel channel;
    final Message message;
    final int totalMessageCount;
    final bool hasChatMessageAvatar;
    final bool isLast;
    final int index;
    final int readCount;
    final ChatMessageBuilderHandler builderHandler;
    final ChatIndexedScrollController listScrollController;
    final bool isHighlight;
    
    Widget _systemMessage(BuildContext context) {
        final SystemMessageBuilder _systemBuilder = SystemMessageBuilder.fromAttributes(
            body: message.body,
            attributes: message.attributes,
            dateCreated: message.dateCreated
        );
        return _systemBuilder != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _systemBuilder.builder(context),
            )
            : Container();
    }

    Widget _myBotMessage(BuildContext context) {
        final MybotMessageBuilder _mybotBuilder = MybotMessageBuilder.fromAttributes(
            attributes: message.attributes,
            body: message.body,
            channel: channel,
            messageSid: message.sid,
            dateCreated: message.dateCreated,
            index: index,
            builderHandler: builderHandler,
            isHighlight: isHighlight
        );
        return _mybotBuilder != null
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: message.attributes['botMessageType'] == MybotMessageTypes.prayerReminderPray ||
                    message.attributes['botMessageType'] == MybotMessageTypes.prayComplete ? 0 : 12),
                child: _mybotBuilder.builder(context),
            )
            : Container();
    }

    Widget _pollingMessage(BuildContext context) {
        final PollingMessageBuilder _pollingMessageBuilder = PollingMessageBuilder.fromMessage(
            channel: channel,
            message: message,
            totalMessageCount: totalMessageCount,
            hasChatMessageAvatar: hasChatMessageAvatar,
            isLast: isLast,
            readCount: readCount,
            index: index,
            builderHandler: builderHandler,
            isHighlight: isHighlight,
        );
        return _pollingMessageBuilder != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _pollingMessageBuilder.builder(context),
            )
            : Container();
    }
    
    @override
    Widget build(BuildContext context) {
        if (message.type == MessageTypes.system)
            return _systemMessage(context);
        if (message.type == MessageTypes.bot)
            return _myBotMessage(context);
        if (message.type == MessageTypes.polling)
            return _pollingMessage(context);
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    ChatMessageAvatar(
                        channel: channel,
                        message: message,
                        hasChatMessageAvatar: hasChatMessageAvatar,
                        index: index,
                        builderHandler: builderHandler
                    ),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                if (hasChatMessageAvatar)
                                    ChatMessageHeader(message, channel: channel),
                                ClipRect(
                                    child: Slidable(
                                        actionPane: const SlidableDrawerActionPane(),
                                        child: Padding(
                                            padding: const EdgeInsets.fromLTRB(2, 2, 4, 4),
                                            child: Bubble(
                                                message: message,
                                                isLast: isLast,
                                                readCount: readCount,
                                                outChannelSid: (channel.isOutsidePublisher || message.from == 'outsidePublisher') ? channel.info.sid : null,
                                                channelSid: channel.info.sid,
                                                index: index,
                                                builderHandler: builderHandler,
                                                isHighlight: isHighlight
                                            ),
                                        ),
                                        actions: <Widget>[
                                            if (!ChatListController.isDeleted(message.attributes)
                                                && !ChatListController.isHidden(message.attributes)
                                                && !ChatListController.isBlocked(message.attributes)
                                                && message.type != MessageTypes.invite)
                                                IconSlideAction(
                                                    caption: allTranslations.text('chat_reply'),
                                                    color: Colors.transparent,
                                                    icon: Icons.reply,
                                                    foregroundColor: globals.Colors.brownGray,
                                                    onTap: () => builderHandler.onReply(index),
                                                ),
                                        ]
                                    ),
                                )
                            ],
                        ),
                    ),
                ],
            ),
        );
    }
}