import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:organizer/icons_icons.dart';
import 'package:organizer/common/common_controller.dart';
import 'package:organizer/controllers/chat/channel_controller.dart';
import 'package:organizer/controllers/chat/polling_message_controller.dart';
import 'package:organizer/controllers/chat/prayer_reminder_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/library/bible_controller.dart';
import 'package:organizer/controllers/library/child_library_controller.dart';
import 'package:organizer/controllers/tab_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/models/bible/book_model.dart';
import 'package:organizer/models/bible/verse_verse_model.dart';
import 'package:organizer/models/chat/channel_info_model.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/models/chat/prayer_reminder_model.dart';
import 'package:organizer/models/library/file_model.dart';
import 'package:organizer/pojo/document.dart';
import 'package:organizer/pojo/file.dart';
import 'package:organizer/pojo/media_file.dart';
import 'package:organizer/views/chat/chat_components/polling_message/bubble/bubble_multiple_choice_builder.dart';
import 'package:organizer/views/chat/chat_components/polling_message/bubble/bubble_open_ended_builder.dart';
import 'package:organizer/views/chat/chat_components/custom_linkifier.dart';
import 'package:organizer/controllers/chat/audio_controller.dart';
import 'package:organizer/views/chat/chat_components/prayer_reminder_message/prayer_reminder_submitted.dart';
import 'package:organizer/views/chat/custom_video_player.dart';
import 'package:organizer/views/chat/custom_webview.dart';
import 'package:organizer/views/chat/show_location.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/views/components/cached_image.dart';
import 'package:organizer/views/components/future_builder.dart';
import 'package:organizer/views/components/modal_bottom_sheet_header.dart';
import 'package:organizer/views/components/option_list.dart';
import 'package:organizer/views/components/oval_avatar.dart';
import 'package:organizer/views/components/progress_indicator.dart';
import 'package:organizer/views/components/buttons.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/controllers/option.dart';
import 'package:organizer/views/components/user_name_view.dart';
import 'package:organizer/views/constants/style_constants.dart';
import 'package:organizer/views/library/edit_note.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

abstract class BubbleBuilderHandler {
    void onLink(String url);
    void onBibleLink(Book book);
    void onReply();
    void onTapReply();
    Future<void> onJoin(String channelSid);
    void onGroupProfile(String channelSid);
}

abstract class BubbleType {
    String get type;
}

abstract class BubbleBuilder implements BubbleType {
    Map<String, dynamic> attributes;
    String body;
    BubbleBuilderHandler messageHandler;
    bool isOwner;
    String outChannelSid;
    BubbleBuilder({
        @required this.attributes,
        @required this.body,
        @required this.messageHandler,
        @required this.isOwner,
        this.outChannelSid
    });
    
    Widget builder(BuildContext context);
    Widget replyToBuilder(BuildContext context, Widget header);
    Widget replyBuilder(BuildContext context, Widget header);
    Future<Option> showBottomSheet(BuildContext context);
    
    factory BubbleBuilder.fromAttributes(bool isOwner, String body, Map<String, dynamic> attributes, BubbleBuilderHandler messageHandler, {String outChannelSid, String channelSid}) {
        switch (attributes['type']) {
            case MessageTypes.bot:
                return BubbleBotBuilder(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler);
                break;
            case MessageTypes.text:
                return BubbleTextBuilder(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler, channelSid: channelSid);
                break;
            case MessageTypes.image:
                return BubbleImageBuilder(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler, outChannelSid: outChannelSid);
                break;
            case MessageTypes.video:
                return BubbleVideoBuilder(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler, outChannelSid: outChannelSid);
                break;
            case MessageTypes.onboardingVideo:
                return BubbleOnboardingVideoBuilder(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler);
                break;
            case MessageTypes.audio:
                return BubbleAudioBuilder(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler, outChannelSid: outChannelSid);
                break;
            case MessageTypes.location:
                return BubbleLocationBuilder(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler);
                break;
            case MessageTypes.bible:
                return BubbleBibleBuilder(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler);
                break;
            case MessageTypes.invite:
                return BubbleInviteBuilder(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler);
                break;
            case MessageTypes.hyperlink:
                return BubbleHyperlinkBuilder(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler);
                break;
            case MessageTypes.document:
                return BubbleDocumentBuilder(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler, outChannelSid: outChannelSid);
                break;
            case MessageTypes.application:
                return BubbleApplicationBuilder(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler, outChannelSid: outChannelSid);
                break;
            case MessageTypes.polling:
                return BubblePollingBuilder(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler, outChannelSid: outChannelSid);
                break;
            default:
                return null;
        }
    }
    
    Widget _abnormalWidget(IconData iconData, String text) {
        return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    Icon(iconData, color: globals.Colors.brownGray, size: 24),
                    Container(width: 6),
                    Text(
                        text,
                        style: TextStyle(
                            color: globals.Colors.brownGray,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            fontStyle: FontStyle.italic
                        ),
                    )
                ],
            ),
        );
    }
    
    Widget realBuilder(BuildContext context) {
        if (ChatListController.isDeleted(attributes))
            return _abnormalWidget(BlockedOptions.deleted.icon, BlockedOptions.deleted.title);
        if (ChatListController.isDocumentDeleted(attributes))
            return _abnormalWidget(BlockedOptions.documentDeleted.icon, BlockedOptions.documentDeleted.title);
        if (ChatListController.isBlocked(attributes))
            return _abnormalWidget(BlockedOptions.blocked.icon, BlockedOptions.blocked.title);
        if (ChatListController.isHidden(attributes))
            return _abnormalWidget(BlockedOptions.hidden.icon, BlockedOptions.hidden.title);
        return builder(context);
    }
}

class BubbleBotBuilder extends BubbleBuilder {
    @override
    String get type => MessageTypes.bot;
    
    Map<String, dynamic> get replyTo => attributes['replyTo'] != null ? Map<String, dynamic>.from(attributes['replyTo']) : null;
    
    String replyToHeaderText;
    BubbleBotBuilder({
        bool isOwner,
        String body,
        Map<String, dynamic> attributes,
        BubbleBuilderHandler messageHandler
    }) : super(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler){
        switch (attributes['botMessageType']) {
            case MybotMessageTypes.prayerReminderCollect:
                replyToHeaderText = 'chat_prayer_points_title';
                break;
            case MybotMessageTypes.prayerReminderRecall:
                replyToHeaderText = 'chat_prayer_points_title';
                break;
            case MybotMessageTypes.prayerReminderPray:
                replyToHeaderText = 'chat_prayer_points_title';
                break;
            case MybotMessageTypes.collectionComplete:
                replyToHeaderText = 'chat_prayer_points_title';
                break;
        }
    }

    Widget _buildReply(BuildContext context) {
        final Map<String, dynamic> attributes = Map<String, dynamic>.from(replyTo['attributes']) ?? <String, dynamic>{};
        // print('*********${replyTo['from']== null}');
        return InkWell(
            child: Container(
                margin: const EdgeInsets.only(top: 6),
                child: IntrinsicWidth(
                    child: Stack(
                        children: <Widget>[
                            Positioned(
                                left: 0, top: 0, bottom: 0,
                                child: Container(
                                    width: 4, height: 50,
                                    color: globals.Colors.veryLightGray,
                                ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: BubbleBuilder.fromAttributes(isOwner, replyTo['body'], attributes, null)
                                    .replyBuilder(
                                    context,
                                    UserNameView(
                                        replyTo['from'] ?? '',
                                        textStyle: TextStyle(
                                            color: globals.Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12
                                        )
                                    )
                                ),
                            )
                        ],
                    ),
                ),
            ),
            onTap: () {
                if (messageHandler != null) {
                    messageHandler.onTapReply();
                }
            },
        );
    }
    
    Widget scheduledMessageNotice() {
        final List<String> messagePart = body.split('**');
        final String scheduledDate = DateFormat('MMM d yyyy').format(DateTime.parse(messagePart[1]).toLocal());
        final String scheduledTime = DateFormat('h:mm a').format(DateTime.parse(messagePart[1]).toLocal());
        final String total = messagePart[0] + '**' + scheduledDate + ' at ' + scheduledTime + '**.';
        return Container(
            color: globals.Colors.multiTab,
            padding: const EdgeInsets.all(12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    MarkdownBody(data: total)
                ],
            ),
        );
    }
    
    Widget prayerReminderNotice() {
        final List<String> messagePart = body.split('**');
        final String collectionTime = DateFormat('h:mm a').format(DateTime.parse(messagePart[1]).toLocal());
        final String prayTime = DateFormat('h:mm a').format(DateTime.parse(messagePart[5]).toLocal());
        return GestureDetector(
            onLongPress:(){} ,
            child: Container(
                decoration: BoxDecoration(color: globals.Colors.multiTab),
                padding: const EdgeInsets.all(12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        RichText(text: TextSpan(
                            style:k14TextStyle,
                            children:<TextSpan>[
                                TextSpan(text:messagePart[0]),
                                TextSpan(text:collectionTime, style:k14BoldTextStyle),
                                TextSpan(text:messagePart[2]+messagePart[3], style:k14BoldTextStyle),
                                TextSpan(text:messagePart[4], ),
                                TextSpan(text: prayTime+'.', style: k14BoldTextStyle ),
                                
                        ]))
                    ],
                ),
            ),
        );
        
    }
    Widget collectBuilder(String messageBody) {
        return Container(
            decoration: BoxDecoration(color: globals.Colors.white),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Container(
                        padding: const EdgeInsets.only(left:16.0, bottom:12, top:13),
                        decoration: const BoxDecoration(
                            border:  Border(bottom: BorderSide(color:globals.Colors.veryLightGray))
                        ),
                        child: Row(
                            children: <Widget>[
                                Icon(
                                    MyIcons.prayer,
                                    color: globals.Colors.gray
                                ),
                                const SizedBox(width: 10),
                                Text(
                                    allTranslations.text('chat_prayer_points_title'),
                                    style: k16BoldTextStyle
                                ),
                            ],
                        ),
                    ),
                    Container(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                MarkdownBody(data: messageBody)
                            ],
                        ),
                    ),
                ],
            ),
        );
    }
    Widget prayerReminderCollectNotice() { 
        
        final String messageBody = attributes['v2MessageBody'];
        if (messageBody == null)
            return collectBuilder(body);
        final String collectionFrequency = attributes['collectionFrequency'];
        final String prayDay = attributes['prayDay'];
        final String prayTime = attributes['prayTime'];
        
        final List<String> splits = messageBody.split( RegExp('((?<={.*?})|(?={.*?}))',caseSensitive: false));
        
        for(int i = 0; i < splits.length; i++) {
            if (splits[i] == '{frequency}'){
                splits[i] = collectionFrequency;
            }
            else if (splits[i] == '{prayDay}'){
                splits[i] = prayDay;
            }
            else if (splits[i] == '{prayTime}'){
                splits[i] = DateFormat('h:mm a').format(DateTime.parse(prayTime).toLocal());
            }
        }
        final String evaluatedString = splits.join();
        
        return collectBuilder(evaluatedString);
    }
    Widget submittedBuilder(MembersAnswered membersAnswered) {
        return membersAnswered.membersAnswered.isNotEmpty ?
            Row(
                children: <Widget>[
                    PrayerReminderSubmitted(
                        uids: membersAnswered.membersAnswered,
                    ),
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.only(left: membersAnswered.membersAnswered.isNotEmpty ? 6 : 0),
                            child: Text(
                                '${membersAnswered.membersAnswered.length} ${allTranslations.text('prayer_reminder_submitted')}',
                                style: k12MediumTextStyle.copyWith(color: globals.Colors.brownGray),
                            ),
                        ),
                    )
                ],
            ):
            Container();
    }
    Widget prayerReminderRecallNotice({bool recallComplete = false}) {
        return Container(
            decoration: BoxDecoration(color: globals.Colors.multiTab),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Container(
                        padding: const EdgeInsets.only(left:16.0, bottom:12, top:13),
                        decoration: const BoxDecoration(
                            border:  Border(bottom: BorderSide(color:globals.Colors.veryLightGray))
                        ),
                        child: Row(
                            children: <Widget>[
                                Icon(
                                    MyIcons.prayer,
                                    color: globals.Colors.gray
                                ),
                                const SizedBox(width: 10),
                                Text(
                                    allTranslations.text('chat_prayer_points_title'),
                                    style: k16BoldTextStyle
                                ),
                            ],
                        ),
                    ),
                    Container(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                Text(body, style: k14TextStyle,),
                                Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: !recallComplete ?
                                        Consumer<MembersAnswered>(
                                            builder: (BuildContext context, MembersAnswered membersAnswered, Widget child) {
                                                return submittedBuilder(membersAnswered);
                                            },
                                        )
                                        :FutureBuilder<MembersAnswered>(
                                            future: PrayerReminderController.membersAnsweredCall(super.attributes['channelSid'], super.attributes['prId']),
                                            initialData: MembersAnswered([]),
                                            builder: (BuildContext context, AsyncSnapshot<MembersAnswered> snapshot) {
                                                if (snapshot.hasData)
                                                    return submittedBuilder(snapshot.data);
                                                return Container();
                                            },
                                        ),
                                )
                            ],
                        ),
                    ),
                ],
            ),
        );
    }
    
    Widget prayerReminderPrayNotice() {
        return Container(
            decoration: BoxDecoration(color: globals.Colors.white),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Container(
                        padding: const EdgeInsets.only(left:16.0, bottom:12, top:13),
                        decoration: const BoxDecoration(
                            border:  Border(bottom: BorderSide(color:globals.Colors.veryLightGray))
                        ),
                        child: Row(
                            children: <Widget>[
                                Icon(
                                    MyIcons.prayer,
                                    color: globals.Colors.gray
                                ),
                                const SizedBox(width: 10),
                                Text(
                                    allTranslations.text('chat_prayer_points_title'),
                                    style: k16BoldTextStyle
                                ),
                            ],
                        ),
                    ),
                    Container(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                            body,
                            style: k14TextStyle,
                        ),
                    ),
                ],
            ),
        );
    }

    Widget messageReminder(BuildContext context) {
        final List<String> messagePart = body.split('**');
        final String scheduledDate = DateFormat('MMM d').format(DateTime.parse(messagePart[1]).toLocal());
        final String scheduledTime = DateFormat('h:mm a').format(DateTime.parse(messagePart[1]).toLocal());
        final String total = messagePart[0] + '**' + scheduledDate + ' at ' + scheduledTime + '**';
        return Container(
            padding: const EdgeInsets.all(12),
            color: globals.Colors.multiTab,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    MarkdownBody(data: total),
                    if (attributes['replyTo'] != null)
                        _buildReply(context)
                ],
            ),
        );
    }

    Widget deletedNotice() {
        return Container(
            color: globals.Colors.multiTab,
            padding: const EdgeInsets.all(12),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    Icon(
                        Icons.delete,
                        color: globals.Colors.brownGray
                    ),
                    Text(
                        body,
                        style: const TextStyle(
                            color: globals.Colors.brownGray,
                            fontStyle: FontStyle.italic
                        )
                    )
                ],
            )
        );
    }

    @override
    Widget builder(BuildContext context) {
        switch (attributes['botMessageType']) {
            case MybotMessageTypes.text:
                return BubbleTextBuilder(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler).realBuilder(context);
            case MybotMessageTypes.scheduled:
                return scheduledMessageNotice();
            case MybotMessageTypes.deleted:
                return deletedNotice();
            case MybotMessageTypes.prayerReminderSet:
                return prayerReminderNotice();
            case MybotMessageTypes.prayerReminderCollect:
                return prayerReminderCollectNotice();
            case MybotMessageTypes.prayerReminderRecall:
                return prayerReminderRecallNotice();
            case MybotMessageTypes.recallComplete:
                return prayerReminderRecallNotice(recallComplete:true);
            case MybotMessageTypes.prayerReminderPray:
                return prayerReminderPrayNotice();
            case MybotMessageTypes.reminderStopped:
                return prayerReminderNotice();
            case MybotMessageTypes.collectionComplete:
                return prayerReminderCollectNotice();
            case MybotMessageTypes.messageReminderReady:
                return messageReminder(context);
            case MybotMessageTypes.messageReminderSent:
                return messageReminder(context);
            case MybotMessageTypes.messageReminderPr:
                return BubbleTextBuilder(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler).realBuilder(context);
            case MybotMessageTypes.messageReminderDeleted:
                return messageReminder(context);
            default:
                return null;
        }
    }

    @override
    Widget replyBuilder(BuildContext context, Widget header) {
        if (attributes['botMessageType'] == MybotMessageTypes.messageReminderReady ||
            attributes['botMessageType'] == MybotMessageTypes.messageReminderSent ||
            attributes['botMessageType'] == MybotMessageTypes.messageReminderDeleted
        ) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    header,
                    Container(height: 3),
                    Text(
                        body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: globals.Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 12
                        ),
                    )
                ],
            );
        }
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                header,
                Container(height: 3),
                Row(
                    children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                                MyIcons.prayer,
                                size: 14,
                                color: globals.Colors.gray
                            ),
                        ),
                        Text(
                            allTranslations.text(replyToHeaderText),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: globals.Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 12
                            ),
                        )
                    ]
                ),
            ],
        );
    }
    
    @override
    Widget replyToBuilder(BuildContext context, Widget header) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                header,
                Container(height: 3),
                Row(
                    children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                                MyIcons.prayer,
                                size: 14,
                                color: globals.Colors.gray
                            ),
                        ),
                        Text(
                            allTranslations.text(replyToHeaderText),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 12
                            ),
                        )
                    ]
                ),
            ],
        );
    }

    @override
    Future<Option> showBottomSheet(BuildContext context) {
        return null;
    }
}

class BubbleTextBuilder extends BubbleBuilder {
    @override
    String get type => MessageTypes.text;
    
    String channelSid;
    
    BubbleTextBuilder({
        bool isOwner,
        String body,
        Map<String, dynamic> attributes,
        BubbleBuilderHandler messageHandler,
        this.channelSid
    }) : super(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler);

    Map<String, dynamic> get replyTo => attributes['replyTo'] != null ? Map<String, dynamic>.from(attributes['replyTo']) : null;
    
    Widget _buildReply(BuildContext context) {
        final Map<String, dynamic> attributes = Map<String, dynamic>.from(replyTo['attributes']) ?? <String, dynamic>{};
        return InkWell(
            child: Container(
                margin: const EdgeInsets.only(top: 6),
                child: IntrinsicWidth(
                    child: Stack(
                        children: <Widget>[
                            Positioned(
                                left: 0, top: 0, bottom: 0,
                                child: Container(
                                    width: 4, height: 50,
                                    color: globals.Colors.veryLightGray,
                                ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: BubbleBuilder.fromAttributes(isOwner, replyTo['body'], attributes, null, outChannelSid: replyTo['from'] == 'outsidePublisher' ? channelSid : null)
                                    .replyBuilder(
                                    context,
                                    UserNameView(
                                        replyTo['from'] ?? '',
                                        textStyle: TextStyle(
                                            color: globals.Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12
                                        )
                                    ),
                                ),
                            )
                        ],
                    ),
                ),
            ),
            onTap: () {
                if (messageHandler != null) {
                    messageHandler.onTapReply();
                }
            },
        );
    }
    
    @override
    Widget builder(BuildContext context) {
        return Container(
            padding: const EdgeInsets.all(12),
            color: attributes['visibleTo'] == null ? globals.Colors.white : globals.Colors.multiTab,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Linkify(
                        text: body,
                        style: TextStyle(color: globals.Colors.black),
                        options: LinkifyOptions(humanize: false),
                        linkifiers: const <Linkifier>[
//                            UrlLinkifier(),
                            EmailLinkifier(),
                            CustomLinkifier()
                        ],
                        onOpen: (LinkableElement link) async {
                            if (link.url.contains('mailto')) {
                        
                            } else {
                                if (messageHandler != null) {
                                    if (link.url.toLowerCase().startsWith('http'))
                                        messageHandler.onLink('http' + link.url.substring(4));
                                    else {
                                        final Book book = BibleController().checkValidBible(link.url);
                                        if (book == null)
                                            messageHandler.onLink('https://' + link.url);
                                        else
                                            messageHandler.onBibleLink(book);
                                    }
                                }
                            }
                        },
                    ),
                    if (attributes['replyTo'] != null)
                        _buildReply(context)
                ],
            ),
        );
    }

    @override
    Widget replyToBuilder(BuildContext context, Widget header) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                header,
                Container(height: 3),
                Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: globals.Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 12
                    ),
                )
            ],
        );
    }
    
    @override
    Widget replyBuilder(BuildContext context, Widget header) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                header,
                Container(height: 3),
                Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: globals.Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 12
                    ),
                )
            ],
        );
    }
    
    @override
    Future<Option> showBottomSheet(BuildContext context) {
        return showMyModalBottomSheetWithOptions(
            context: context,
            header: Option(title: body, icon: Icons.chat, multiLocale: false),
            options: ChatListController.getTextMenu(isOwner)
        );
    }
}

class BubbleImageBuilder extends BubbleBuilder {
    @override
    String get type => MessageTypes.image;
    
    BubbleImageBuilder({
        bool isOwner,
        String body,
        Map<String, dynamic> attributes,
        BubbleBuilderHandler messageHandler,
        String outChannelSid
    }) : super(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler, outChannelSid: outChannelSid);
    
    Widget _imageBuilder({@required BuildContext context, double width}) {
        Map<String, DocumentSnapshot> fileCache;
        try {
            fileCache = Provider.of<Map<String, DocumentSnapshot>>(context);
        }
        catch (err) {
            fileCache = <String, DocumentSnapshot>{};
            print('No cache found');
        }
        
        return StreamBuilder<DocumentSnapshot>(
            key: const Key('image-bubble'),
            stream: FileModel(outChannelSid: outChannelSid).watchFile(body),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (fileCache[body] == null && !snapshot.hasData) {
                    return SizedBox(
                        width: width ?? MediaQuery.of(context).size.width - 12 - 40 - 12 - 12,
                        child: MyProgressIndicator()
                    );
                }
                fileCache[body] = snapshot.data ?? fileCache[body];
                if ((snapshot.hasData && !snapshot.data.exists) || !fileCache[body].exists)
                    return SizedBox(
                        width: width ?? MediaQuery.of(context).size.width - 12 - 40 - 12 - 12,
                        child: MyProgressIndicator()
                    );
                final MediaFile mediaFile = MediaFile.fromSnapshot(fileCache[body]);
                return SizedBox(
                    width: width ?? MediaQuery.of(context).size.width - 12 - 40 - 12 - 12,
                    child: MyCachedImage.loader(
                        path: mediaFile.path,
                        imageBuilder: (BuildContext context, ImageProvider imageProvider) {
                            return Image(image: imageProvider, width: width, fit: BoxFit.contain);
                        }
                    ),
                );
            },
        );
    }
    
    @override
    Widget builder(BuildContext context) {
        return _imageBuilder(context: context);
    }

    @override
    Widget replyToBuilder(BuildContext context, Widget header) {
        return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                _imageBuilder(width: 50, context: context),
                Container(width: 12),
                Expanded(
                    child: header,
                ),
            ],
        );
    }
    
    @override
    Widget replyBuilder(BuildContext context, Widget header) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                header,
                Container(height: 3),
                _imageBuilder(width: 100, context: context)
            ],
        );
    }

    @override
    Future<Option> showBottomSheet(BuildContext context) async {
        final File file = await FileModel(outChannelSid: outChannelSid).getFile(body);
        return showMyModalBottomSheetWithOptions(
            context: context,
            header: Option(title: file?.name ?? '', icon: Icons.image, multiLocale: false),
            options: ChatListController.getFileMenu(isOwner)
        );
    }
}

class BubbleVideoBuilder extends BubbleBuilder {
    @override
    String get type => MessageTypes.video;
    
    BubbleVideoBuilder({
        bool isOwner,
        String body,
        Map<String, dynamic> attributes,
        BubbleBuilderHandler messageHandler,
        String outChannelSid
    }) : super(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler, outChannelSid: outChannelSid);

    String get thumb => attributes['thumb'];

    final ChildLibraryController _childLibraryController = ChildLibraryController();
    
    Future<String> _getVideoInfo(String path) async {
        final String urlPath = await _childLibraryController.getVideoUrl(Uri.https(globals.apiUrl, '/api/uploaded', <String, String>{ 'path': path }).toString());
        if (urlPath.isEmpty)
            return '';
        final VideoPlayerController _videoPlayerController = VideoPlayerController.network(urlPath);
        await _videoPlayerController.initialize();
        if (_videoPlayerController.value == null)
            return '';
        _videoPlayerController.dispose();
        return '${_videoPlayerController.value.duration.inMinutes}:${(_videoPlayerController.value.duration.inSeconds - _videoPlayerController.value.duration.inMinutes * 60).toString().padLeft(2, '0')}';
    }
    
    Widget _thumbnailBuilder({MediaFile mediaFile, double iconWidth}) {
        return MyCachedImage.loader(
            path: mediaFile.thumbnail,
            imageBuilder: (BuildContext context, ImageProvider imageProvider) {
                return ClipRRect(
                    borderRadius: BorderRadius.circular(2.5),
                    child: Image(image: imageProvider, width: iconWidth, height: iconWidth, fit: BoxFit.fitWidth)
                );
            }
        );
    }

    Widget _videoBuilder({
        double textSize = 14,
        double iconWidth = 40,
        bool replyBuilder = false,
        bool replyToBuilder = false,
    }) {
        return StreamBuilder<DocumentSnapshot>(
            stream: FileModel(outChannelSid: outChannelSid).watchFile(body),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                Map<String, DocumentSnapshot> fileCache;
                Map<String, String> urlCache;
                try {
                    fileCache = Provider.of<Map<String, DocumentSnapshot>>(context);
                    urlCache = Provider.of<Map<String, String>>(context);
                }
                catch (err) {
                    fileCache = <String, DocumentSnapshot>{};
                    urlCache = <String, String>{};
                    print('No cache found');
                }
                if (fileCache[body] == null && !snapshot.hasData) {
                    return MyProgressIndicator();
                }
                fileCache[body] = snapshot.data ?? fileCache[body];
                if ((snapshot.hasData && !snapshot.data.exists) || !fileCache[body].exists)
                    return MyProgressIndicator();
                final MediaFile mediaFile = MediaFile.fromSnapshot(fileCache[body]);
                if (replyToBuilder)
                    return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            _thumbnailBuilder(mediaFile: mediaFile, iconWidth: iconWidth),
                            Container(width: 12),
                            Expanded(
                                child: Text(
                                    mediaFile.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                ),
                            ),
                        ],
                    );
                return MyFutureBuilder<String>.bounce(
                    future: _getVideoInfo(mediaFile.path),
                    initialData: urlCache[mediaFile.path],
                    builder: (BuildContext context, String videoInfo) {
                        urlCache[mediaFile.path] = videoInfo;
                        if (videoInfo.isEmpty)
                            return Text(
                                allTranslations.text('chat_file_deleted'),
                                style: TextStyle(
                                    color: globals.Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700
                                ),
                            );
                        if (replyBuilder) {
                            return _videoRow(mediaFile: mediaFile, videoInfo: videoInfo);
                        }
                        return InkWell(
                            onTap: () {
                                Navigator.push(
                                    globals.mainScaffold.currentContext,
                                    MaterialPageRoute<void>(
                                        builder: (BuildContext context) => CustomVideoPlayer(path: mediaFile.path),
                                    ),
                                );
                            },
                            child: _videoRow(mediaFile: mediaFile, videoInfo: videoInfo)
                        );
                    }
                );
            },
        );
    }

    Widget _videoRow({
        @required MediaFile mediaFile,
        @required String videoInfo,
        double textSize = 14,
        double iconWidth = 40,
        bool replyBuilder = false,
        bool replyToBuilder = false
    }) {
        return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                if (mediaFile.thumbnail == null)
                    Icon(Icons.videocam, size: 40, color: globals.Colors.gray)
                else
                    MyCachedImage.loader(
                        path: mediaFile.thumbnail,
                        imageBuilder: (BuildContext context, ImageProvider imageProvider) {
                            return ClipRRect(
                                borderRadius: BorderRadius.circular(2.5),
                                child: Image(image: imageProvider, width: iconWidth, height: iconWidth, fit: BoxFit.fitWidth)
                            );
                        }
                    ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            Text(
                                mediaFile.name ?? 'Loading...',
                                maxLines: null,
                                style: TextStyle(
                                    fontSize: textSize,
                                    fontWeight: FontWeight.w700
                                ),
                            ),
                            const Padding(padding: EdgeInsets.only(top: 5)),
                            Text(
                                /// padLeft is used to add leading 0 in front of single digit seconds
                                videoInfo,
                                style: TextStyle(
                                    fontSize: textSize,
                                    fontWeight: FontWeight.w400,
                                    color: globals.Colors.brownGray
                                )
                            )
                        ],
                    )
                )
            ],
        );
    }

    @override
    Widget builder(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(12),
            child: _videoBuilder()
        );
    }

    @override
    Widget replyToBuilder(BuildContext context, Widget header) {
        return _videoBuilder(textSize: 12, replyToBuilder: true);
    }
    
    @override
    Widget replyBuilder(BuildContext context, Widget header) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                header,
                Container(height: 3),
                _videoBuilder(textSize: 12, replyBuilder: true)
            ],
        );
    }

    @override
    Future<Option> showBottomSheet(BuildContext context) async {
        final File file = await FileModel(outChannelSid: outChannelSid).getFile(body);
        return showMyModalBottomSheetWithOptions(
            context: context,
            header: Option(title: file?.name ?? '', icon: Icons.videocam, multiLocale: false),
            options: ChatListController.getFileMenu(isOwner)
        );
    }
}

class BubbleOnboardingVideoBuilder extends BubbleBuilder {
    @override
    String get type => MessageTypes.onboardingVideo;
    
    BubbleOnboardingVideoBuilder({
        bool isOwner,
        String body,
        Map<String, dynamic> attributes,
        BubbleBuilderHandler messageHandler,
    }) : super(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler);

    String get url => body;

    @override
    Widget builder(BuildContext context) {
        return InkWell(
            onTap: () {
                Navigator.push(
                    globals.mainScaffold.currentContext,
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) => CustomVideoPlayer(url: url),
                    ),
                );
            },
            child: Stack(
                children: <Widget>[
                    Image.asset('assets/images/onboarding_video_thumbnail.png'),
                    Positioned.fill(
                        child: Center(
                            child: Icon(
                                MdiIcons.playCircle,
                                size: 48,
                                color: globals.Colors.white
                            )
                        )
                    )
                ],
            ),
        );
    }

    @override
    Widget replyToBuilder(BuildContext context, Widget header) {
        return const Text('This is onboarding video');
    }
    
    @override
    Widget replyBuilder(BuildContext context, Widget header) {
        return const Text('This is onboarding video');
    }

    @override
    Future<Option> showBottomSheet(BuildContext context) async {
        throw 'This is onboarding video';
    }
}

class BubbleHyperlinkBuilder extends BubbleBuilder {
    @override
    String get type => MessageTypes.hyperlink;

    BubbleHyperlinkBuilder({
        bool isOwner,
        String body,
        Map<String, dynamic> attributes,
        BubbleBuilderHandler messageHandler
    }) : super(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler);
    
    Map<String, dynamic> get contents => attributes['contents'] != null ? Map<String, dynamic>.from(attributes['contents']) : null;
    
    @override
    Widget builder(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    RichText(
                        text: TextSpan(
                            children: contents.keys.map((String key) {
                                return TextSpan(
                                    text: key,
                                    style: TextStyle(
                                        color: contents[key] != '' ? globals.Colors.lightBlue : globals.Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14
                                    ),
                                    recognizer: TapGestureRecognizer()..onTap = () {
                                        if (contents[key] != '') {
                                            showMyModalBottomSheet(
                                                context: globals.mainScaffold.currentContext,
                                                fullScreen: true,
                                                child: MyModalBottomSheetHeader(
                                                    child: CustomWebView2(
                                                        initialUrl: contents[key]
                                                    )
                                                )
                                            );
                                        }
                                    }
                                );
                            }).toList(),
                        ),
                    ),
                ],
            ),
        );
    }
    
    @override
    Widget replyToBuilder(BuildContext context, Widget header) {
        return header;
    }
    
    @override
    Widget replyBuilder(BuildContext context, Widget header) {
        return header;
    }
    
    @override
    Future<Option> showBottomSheet(BuildContext context) {
        return null;
    }
}

class BubbleDocumentBuilder extends BubbleBuilder {
    @override
    String get type => MessageTypes.document;

    BubbleDocumentBuilder({
        bool isOwner,
        String body,
        Map<String, dynamic> attributes,
        BubbleBuilderHandler messageHandler,
        String outChannelSid
    }) : super(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler, outChannelSid: outChannelSid);
    
    Widget _documentBuilder({bool isReply = false}) {
        return StreamBuilder<DocumentSnapshot>(
            stream: FileModel(outChannelSid: outChannelSid).watchFile(body),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                Map<String, DocumentSnapshot> fileCache;
                try {
                    fileCache = Provider.of<Map<String, DocumentSnapshot>>(context);
                }
                catch (err) {
                    fileCache = <String, DocumentSnapshot>{};
                    print('No cache found');
                }
                if (fileCache[body] == null && !snapshot.hasData) {
                    return MyProgressIndicator();
                }
                fileCache[body] = snapshot.data ?? fileCache[body];
                if (fileCache[body].data == null)
                    return Text(
                        allTranslations.text('chat_file_deleted'),
                        style: TextStyle(
                            color: globals.Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700
                        ),
                    );
                final Document document = Document.fromSnapshot(fileCache[body]);
                return GestureDetector(
                    child: IntrinsicWidth(
                        child: Row(
                            children: <Widget>[
                                SvgPicture.asset(
                                    'assets/images/document.svg',
                                    width: isReply ? 14 : 20,
                                    height: isReply ? 14 : 20,
                                ),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: isReply ? 6 : 12),
                                        child: Text(
                                            document.name,
                                            style: TextStyle(
                                                color: globals.Colors.black,
                                                fontSize: isReply ? 14 : 16,
                                                fontWeight: isReply? FontWeight.w600 : FontWeight.w500
                                            ),
                                        ),
                                    ),
                                )
                            ],
                        ),
                    ),
                    onTap: isReply ? null : () {
                        Provider.of<TaskTabController>(context, listen: false).addWidget(EditNote(note: document));
                        Provider.of<TaskTabController>(context, listen: false).showDialog(context);
                    },
                );
            },
        );
    }
    
    @override
    Widget builder(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: _documentBuilder(isReply: false),
        );
    }
    
    @override
    Widget replyToBuilder(BuildContext context, Widget header) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                header,
                Container(height: 6),
                _documentBuilder(isReply: true)
            ],
        );
    }
    
    @override
    Widget replyBuilder(BuildContext context, Widget header) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                header,
                Container(height: 6),
                _documentBuilder(isReply: true)
            ],
        );
    }
    
    @override
    Future<Option> showBottomSheet(BuildContext context) async {
        final File file = await FileModel(outChannelSid: outChannelSid).getFile(body);
        return showMyModalBottomSheetWithOptions(
            context: context,
            header: Option(title: file?.name ?? '', svgIcon: SvgPicture.asset('assets/images/document.svg', width: 24, height: 24), multiLocale: false),
            options: ChatListController.getFileMenu(isOwner)
        );
    }
}

class BubbleApplicationBuilder extends BubbleBuilder {
    @override
    String get type => MessageTypes.application;

    BubbleApplicationBuilder({
        bool isOwner,
        String body,
        Map<String, dynamic> attributes,
        BubbleBuilderHandler messageHandler,
        String outChannelSid
    }) : super(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler, outChannelSid: outChannelSid);
    
    Widget _applicationBuilder({bool isReply = false}) {
        return StreamBuilder<DocumentSnapshot>(
            stream: FileModel(outChannelSid: outChannelSid).watchFile(body),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                Map<String, DocumentSnapshot> fileCache;
                try {
                    fileCache = Provider.of<Map<String, DocumentSnapshot>>(context);
                }
                catch (err) {
                    fileCache = <String, DocumentSnapshot>{};
                    print('No cache found');
                }
                if (fileCache[body] == null && !snapshot.hasData) {
                    return MyProgressIndicator();
                }
                fileCache[body] = snapshot.data ?? fileCache[body];
                if (fileCache[body].data == null)
                    return Text(
                        allTranslations.text('chat_file_deleted'),
                        style: TextStyle(
                            color: globals.Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700
                        ),
                    );
                final Document application = Document.fromSnapshot(fileCache[body]);
                return GestureDetector(
                    child: IntrinsicWidth(
                        child: Row(
                            children: <Widget>[
                                SvgPicture.asset(
                                    'assets/images/file.svg',
                                    width: isReply ? 14 : 20,
                                    height: isReply ? 14 : 20,
                                ),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: isReply ? 6 : 12),
                                        child: Text(
                                            application.name,
                                            style: TextStyle(
                                                color: globals.Colors.black,
                                                fontSize: isReply ? 14 : 16,
                                                fontWeight: isReply? FontWeight.w600 : FontWeight.w500
                                            ),
                                        ),
                                    ),
                                )
                            ],
                        ),
                    ),
                    onTap: isReply ? null : () async {
                        await showBottomSheet(context);
                    },
                );
            },
        );
    }

    @override
    Widget builder(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: _applicationBuilder(isReply: false),
        );
    }

    @override
    Widget replyBuilder(BuildContext context, Widget header) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                header,
                Container(height: 6),
                _applicationBuilder(isReply: true)
            ],
        );
    }

    @override
    Widget replyToBuilder(BuildContext context, Widget header) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                header,
                Container(height: 6),
                _applicationBuilder(isReply: true)
            ],
        );
    }

    @override
    Future<Option> showBottomSheet(BuildContext context) async {
        final File file = await FileModel(outChannelSid: outChannelSid).getFile(body);
        return showMyModalBottomSheetWithOptions(
            context: context,
            header: Option(title: file?.name ?? '', svgIcon: SvgPicture.asset('assets/images/file.svg', width: 24, height: 24), multiLocale: false),
            options: ChatListController.getFileMenu(isOwner)
        );
    }
}

class BubbleLocationBuilder extends BubbleBuilder {
    @override
    String get type => MessageTypes.location;

    BubbleLocationBuilder({
        bool isOwner,
        String body,
        Map<String, dynamic> attributes,
        BubbleBuilderHandler messageHandler
    }) : super(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler);
    
    double get latitude => attributes['latitude'] ?? 0;
    double get longitude => attributes['longitude'] ?? 0;
    
    @override
    Widget builder(BuildContext context) {
        final LatLng location = LatLng(latitude, longitude);
        return Container(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(5),
            child: GoogleMap(
                compassEnabled: false,
                rotateGesturesEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                tiltGesturesEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                    target: location,
                    zoom: 12,
                ),
                markers: Set<Marker>.of([Marker(
                    markerId: MarkerId(body),
                    position: location
                )]),
                onTap: (_) {
                    Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) => ShowLocation(
                                location: location,
                            ),
                        ),
                    );
                },
            ),
        );
    }

    @override
    Widget replyToBuilder(BuildContext context, Widget header) {
        return header;
    }
    
    @override
    Widget replyBuilder(BuildContext context, Widget header) {
        return Container();
    }

    @override
    Future<Option> showBottomSheet(BuildContext context) {
        return null;
//        return showBottomSheetWithOptions(
//            context, body, Icons.chat, chatListController.getTextMenu(isOwner)
//        );
    }
}

class BubbleBibleBuilder extends BubbleBuilder {
    @override
    String get type => MessageTypes.bible;
    
    BubbleBibleBuilder({
        bool isOwner,
        String body,
        Map<String, dynamic> attributes,
        BubbleBuilderHandler messageHandler
    }) : super(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler);
    
    String get book => body;
    int get chapter => attributes['chapter'].toInt();
    List<VerseVerseModel> get verses => (attributes['verses'] as List<dynamic>).map((dynamic e) => VerseVerseModel.fromJson(Map<String, dynamic>.from(e))).toList();
    
    @override
    Widget builder(BuildContext context) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(MyIcons.bible, color: globals.Colors.gray)
                            ),
                            Flexible(
                                child: Text(
                                    '$book $chapter:${verses.first.number}${verses.length > 1 ? '-${verses.last.number}' : ''}',
                                    style: TextStyle(
                                        color: globals.Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500
                                    ),
                                ),
                            )
                        ],
                    ),
                ),
                const Divider(height: 1, color: globals.Colors.veryLightGray,),
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: verses.length < 2
                        ? Text(
                            verses.first.text,
                            style: TextStyle(
                                color: globals.Colors.black,
                                fontSize: 14
                            ),
                        )
                        : Column(
                            children: List<Widget>.generate(
                                verses.length,
                                    (int index) => Container(
                                    margin: EdgeInsets.only(bottom: index < verses.length - 1 ? 12 : 0),
                                    child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                            Text(
                                                '${verses[index].number}',
                                                style: TextStyle(
                                                    color: globals.Colors.black,
                                                    fontSize: 14,
                                                ),
                                            ),
                                            Container(width: 6),
                                            Flexible(
                                                child: Text(
                                                    verses[index].text,
                                                    style: TextStyle(
                                                        color: globals.Colors.black,
                                                        fontSize: 14
                                                    ),
                                                ),
                                            )
                                        ],
                                    ),
                                )
                            ),
                        ),
                ),
                const Divider(height: 1, color: globals.Colors.veryLightGray,),
                orangeButton(
                    text: allTranslations.text('library_read_full'),
                    onPressed: () {
                        messageHandler.onLink('https://netbible.org/bible/$book+$chapter');
                    },
                ),
            ],
        );
    }

    @override
    Widget replyToBuilder(BuildContext context, Widget header) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                header,
                Container(height: 6),
                Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        const Icon(MyIcons.bible, size: 20),
                        Container(width: 6),
                        Flexible(
                            child: Text(
                                '$book $chapter:${verses.first.number}${verses.length > 1 ? '-${verses.last.number}' : ''}',
                                style: TextStyle(
                                    color: globals.Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400
                                ),
                            ),
                        )
                    ],
                )
            ],
        );
    }

    @override
    Widget replyBuilder(BuildContext context, Widget header) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                header,
                Container(height: 6),
                Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        const Icon(MyIcons.bible, size: 16),
                        Container(width: 6),
                        Flexible(
                            child: Text(
                                CommonController.getBibleTitle(
                                    book,
                                    chapter,
                                    (attributes['verses'] as List<dynamic>).map((dynamic e) => Map<String, dynamic>.from(e)).toList()
                                ),
                                style: TextStyle(
                                    color: globals.Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600
                                ),
                            ),
                        )
                    ],
                )
            ],
        );
    }

    @override
    Future<Option> showBottomSheet(BuildContext context) {
        return showMyModalBottomSheetWithOptions(
            context: context,
            header: Option(title: CommonController.getBibleTitle(
                book,
                chapter,
                (attributes['verses'] as List<dynamic>).map((dynamic e) => Map<String, dynamic>.from(e)).toList()
            ), icon: MyIcons.bible, multiLocale: false),
            options: ChatListController.getBibleMenu(isOwner)
        );
    }
}

class BubbleInviteBuilder extends BubbleBuilder {
    @override
    String get type => MessageTypes.invite;
    
    BubbleInviteBuilder({
        bool isOwner,
        String body,
        Map<String, dynamic> attributes,
        BubbleBuilderHandler messageHandler
    }) : super(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler);
    
    String get channelSid => body;
    
    @override
    Widget builder(BuildContext context) {
        return _BubbleInviteWidget(
            isOwner: isOwner,
            channelSid: channelSid,
            messageHandler: messageHandler
        );
    }
    
    @override
    Widget replyToBuilder(BuildContext context, Widget header) {
        return header;
    }
    
    @override
    Widget replyBuilder(BuildContext context, Widget header) {
        return header;
    }
    
    @override
    Future<Option> showBottomSheet(BuildContext context) {
        if (!isOwner)
            return null;
        return showMyModalBottomSheet<Option>(
            context: context,
            child: Column(
                children: <Widget>[
                    ChannelInfoView(channelSid),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: MyOptionList(
                            options: ChatListController.getInviteMenu(isOwner)
                        )
                    )
                ]
            )
        );
    }
}

class _BubbleInviteWidget extends StatefulWidget {
    final bool isOwner;
    final String channelSid;
    final BubbleBuilderHandler messageHandler;
    
    _BubbleInviteWidget({this.isOwner, this.channelSid, this.messageHandler});
    
    @override
    State<StatefulWidget> createState() => _BubbleInviteWidgetState();
}

class _BubbleInviteWidgetState extends State<_BubbleInviteWidget> {
    Future<ChannelInfo> _getChannel;
    bool _isPressed = false;
    
    @override
    void initState() {
        super.initState();
        _getChannel = ChannelController().getChannelFromSid(widget.channelSid);
    }
    
    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    Text(
                        allTranslations.text('chat_invite_you'),
                        style: TextStyle(
                            color: globals.Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400
                        ),
                        textAlign: TextAlign.start,
                    ),
                    Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(top: 6, bottom: 12),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: globals.Colors.lightGray)
                        ),
                        child: MyFutureBuilder<ChannelInfo>.spin(
                            future: _getChannel,
                            initialData: ChannelController.channelCache[widget.channelSid],
                            builder: (BuildContext context, ChannelInfo channelInfo) {
                                if (channelInfo == null)
                                    return MyCircularIndicator();
                                if (channelInfo.sid == null) {
                                    return Text(
                                        allTranslations.text('chat_group_deleted'),
                                        style: TextStyle(
                                            color: globals.Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700
                                        ),
                                    );
                                }
                                final Channel channel = Channel(info: channelInfo);
                                return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                        InkWell(
                                            child: Row(
                                                children: <Widget>[
                                                    MyOvalAvatar.ofChannel(channel.avatar, iconRadius: 12),
                                                    Container(width: 6),
                                                    Text(
                                                        channel.name,
                                                        style: TextStyle(
                                                            color: globals.Colors.black,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w700
                                                        ),
                                                    )
                                                ],
                                            ),
                                            onTap: () {
                                                widget.messageHandler.onGroupProfile(widget.channelSid);
                                            },
                                        ),
                                        if (channel.description.isNotEmpty)
                                            Padding(
                                                padding: const EdgeInsets.only(top: 12),
                                                child: Text(
                                                    channel.description,
                                                    style: TextStyle(
                                                        color: globals.Colors.black,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w400
                                                    ),
                                                    textAlign: TextAlign.start,
                                                ),
                                            )
                                    ],
                                );
                            }
                        )
                    ),
                    if (!widget.isOwner && !ChatListController.isJoined(channelSid: widget.channelSid))
                        SizedBox(
                            height: 36,
                            child: OutlineButton(
                                borderSide: BorderSide(color: globals.Colors.orange, width: 1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                                child: Text(
                                    allTranslations.text('chat_join'),
                                    style: TextStyle(
                                        color: globals.Colors.orange,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600
                                    ),
                                ),
                                onPressed: !_isPressed ? () async {
                                    setState(() {
                                        _isPressed = true;
                                    });
                                    await widget.messageHandler.onJoin(widget.channelSid);
                                    Future<void>.delayed(const Duration(milliseconds: 100), () {
                                        setState(() {
                                            _isPressed = false;
                                        });
                                    });
                                } : null,
                            ),
                        )
                    else if (!widget.isOwner)
                        Container(
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: globals.Colors.veryLightGray
                            ),
                            child: Text(
                                allTranslations.text('chat_joined'),
                                style: TextStyle(
                                    color: globals.Colors.lightGray,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600
                                ),
                            ),
                        )
                ],
            ),
        );
    }
}

class BubblePollingBuilder extends BubbleBuilder {
    @override
    String get type => MessageTypes.polling;
    
    BubblePollingBuilder({
        bool isOwner,
        String body,
        Map<String, dynamic> attributes,
        BubbleBuilderHandler messageHandler,
        String outChannelSid
    }) : super(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler, outChannelSid: outChannelSid);
    
    String get question => body;
    String get pollingType => attributes['pollingType'];
    String get channelSid => attributes['channelSid'];
    String get pollingId => attributes['pollingId'];
    bool get viewOnly => attributes['viewOnly'] ?? false;
    String get viewOnlyQuestion => attributes['question'];
    List<String> get viewOnlyChoices => attributes['choices'] != null ?
        List<String>.from(attributes['choices']) : null;
    
    @override
    Widget builder(BuildContext context) {
        if (pollingType == PollingMessageTypes.openEnded)
            return BubbleOpenEndedBuilder(
                isOutsidePublisher: outChannelSid != null,
                viewOnly: viewOnly,
                viewOnlyQuestion: viewOnlyQuestion,
            ); 
        return BubbleMultipleChoiceBuilder(
            channelSid: channelSid,
            pollingId: pollingId,
            isOutsidePublisher: outChannelSid != null,
            viewOnly: viewOnly,
            viewOnlyChoices: viewOnlyChoices,
            viewOnlyQuestion: viewOnlyQuestion,
        );
    }
    
    @override
    Widget replyBuilder(BuildContext context, Widget header) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                header,
                Container(height: 3),
                Row(
                    children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                                MyIcons.poll,
                                size: 14,
                                color: globals.Colors.gray
                            ),
                        ),
                        Text(
                            body,
                            style: TextStyle(
                                color: globals.Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 12
                            ),
                        )
                    ]
                ),
            ],
        );
    }
    
    @override
    Widget replyToBuilder(BuildContext context, Widget header) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                header,
                Container(height: 3),
                Row(
                    children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                                MyIcons.poll,
                                size: 14,
                                color: globals.Colors.gray
                            ),
                        ),
                        Text(
                            body,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 12
                            ),
                        )
                    ]
                ),
            ],
        );
    }
    
    @override
    Future<Option> showBottomSheet(BuildContext context) {
        return showMyModalBottomSheetWithOptions(
            context: context,
            header: Option(title: body, icon: MyIcons.poll, multiLocale: false),
            options: PollingMessageController.getPollingMenu(isOwner)
        );
    }
}

class BubbleAudioBuilder extends BubbleBuilder {
    @override
    String get type => MessageTypes.audio;
    
    BubbleAudioBuilder({
        bool isOwner,
        String body,
        Map<String, dynamic> attributes,
        BubbleBuilderHandler messageHandler,
        String outChannelSid
    }) : super(isOwner: isOwner, body: body, attributes: attributes, messageHandler: messageHandler, outChannelSid: outChannelSid);
    
    Widget _audioBuilder({bool isReply = false}) {
        return StreamBuilder<DocumentSnapshot>(
            stream: FileModel().watchFile(body),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                Map<String, DocumentSnapshot> fileCache;
                try {
                    fileCache = Provider.of<Map<String, DocumentSnapshot>>(context);
                }
                catch (err) {
                    fileCache = <String, DocumentSnapshot>{};
                    print('No cache found');
                }
                if (fileCache[body] == null && !snapshot.hasData) {
                    return MyProgressIndicator();
                }
                fileCache[body] = snapshot.data ?? fileCache[body];
                
                if (fileCache[body].data == null)
                    return Text(
                        allTranslations.text('chat_file_deleted'),
                        style: TextStyle(
                            color: globals.Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700
                        ),
                    );
                final Document application = Document.fromSnapshot(fileCache[body]);
                return GestureDetector(
                    child: IntrinsicWidth(
                        child: Row(
                            children: <Widget>[
                                SvgPicture.asset(
                                    'assets/images/file.svg',
                                    width: isReply ? 14 : 20,
                                    height: isReply ? 14 : 20,
                                ),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: isReply ? 6 : 12),
                                        child: Text(
                                            application.name,
                                            style: TextStyle(
                                                color: globals.Colors.black,
                                                fontSize: isReply ? 14 : 16,
                                                fontWeight: isReply? FontWeight.w600 : FontWeight.w500
                                            ),
                                        ),
                                    ),
                                )
                            ],
                        ),
                    ),
                    onTap: isReply ? null : () async {
                        await showBottomSheet(context);
                    },
                );
            },
        );
    }

    @override
    Widget builder(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: _audioBuilder(isReply: false),
        );
    }

    @override
    Widget replyBuilder(BuildContext context, Widget header) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                header,
                Container(height: 6),
                _audioBuilder(isReply: true)
            ],
        );
    }

    @override
    Widget replyToBuilder(BuildContext context, Widget header) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                header,
                Container(height: 6),
                _audioBuilder(isReply: true)
            ],
        );
    }

    @override
    Future<Option> showBottomSheet(BuildContext context) async {
        final File file = await FileModel().getFile(body);
        return showMyModalBottomSheetWithOptions(
            context: context,
            header: Option(title: file?.name ?? '', svgIcon: SvgPicture.asset('assets/images/file.svg', width: 24, height: 24), multiLocale: false),
            options: ChatListController.getFileMenu(isOwner)
        );
    }
}

class AudioPlayer extends StatefulWidget {
    Map<String, dynamic> attributes;
    String body;
    
    AudioPlayer({this.body, this.attributes});
    
    @override
    State createState() => AudioPlayerState();
}

class AudioPlayerState extends State<AudioPlayer> {
    double _value = 0;
    bool _isLoading = false;
    AudioController _audioController;
    
    @override
    void initState() {
        super.initState();
    
        _audioController = AudioController();
    }

    @override
    void dispose() {
        _audioController.dispose();
    
        super.dispose();
    }
    
    @override
    Widget build(BuildContext context) {
        final int period = widget.attributes['period'].toInt();
        final int position = _value == 0 ? period : (period * _value).toInt();
        final NumberFormat format = NumberFormat('##');
        format.minimumIntegerDigits = 2;
        return Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
                children: <Widget>[
                    SizedBox(
                        width: 30,
                        height: 30,
                        child: _isLoading
                            ? Container(
                                child: Center(
                                    child: CircularIndicator(size: 20),
                                ),
                            )
                            : FlatButton(
                                padding: const EdgeInsets.all(0),
                                child: Icon(
                                    _audioController.isPlaying(widget.body)
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.black,
                                ),
                                onPressed: () async {
                                    if (!_audioController.isPlaying(widget.body)) {
                                        setState(() {
                                            _isLoading = true;
                                        });
                                    }
                                    await _audioController.seek(Duration(milliseconds: (_value * period * 1000).toInt()));
                                    _audioController.play(widget.body);
                                    _audioController.listen((Duration d) {
                                        final double percent = d.inSeconds / max(d.inSeconds, period);
                                        setState(() {
                                            _value = percent;
                                        });
                                        if (_audioController.isPlaying(widget.body) && percent > 0) {
                                            setState(() {
                                                _isLoading = false;
                                            });
                                        }
                                    });
                                    setState(() {
                                    
                                    });
                                },
                            ),
                    ),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                Container(height: 10),
                                SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: Colors.blue,
                                        inactiveTrackColor: Colors.grey[600],
                                        trackHeight: 1.0,
                                        thumbColor: Colors.blue,
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                                        overlayColor: Colors.blue.withAlpha(60),
                                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
                                    ),
                                    child: Slider(
                                        value: _value,
                                        onChanged: (double value) {
                                            setState(() {
                                                _value = value;
                                            });
                                            if (_audioController.isPlaying(widget.body)) {
                                                _audioController.seek(Duration(milliseconds: (_value * period * 1000).toInt()));
                                            }
                                        }
                                    ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Text('${Duration(seconds: position).inMinutes.remainder(60)}:${format.format(Duration(seconds: position).inSeconds.remainder(60))}',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10.0,
                                            fontStyle: FontStyle.normal
                                        ),
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