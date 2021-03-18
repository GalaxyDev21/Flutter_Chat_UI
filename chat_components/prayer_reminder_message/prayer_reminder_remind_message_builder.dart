import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:organizer/controllers/chat/prayer_reminder_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/models/chat/handlers/chat_message_builder_handler.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/models/chat/prayer_reminder_model.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/mybot_message_builder.dart';
import 'package:organizer/views/chat/chat_components/chat_message/chat_message_header.dart';
import 'package:organizer/views/chat/chat_components/prayer_reminder_message/prayer_reminder_slider.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet.dart';
import 'package:organizer/views/components/oval_avatar.dart';
import 'package:organizer/views/constants/style_constants.dart';
import 'package:provider/provider.dart';

class PrayerReminderPrayMessageBuilder extends MybotMessageBuilder {
    @override
    String get type => MybotMessageTypes.prayerReminderPray;
    String channelSid;
    String messageSid;
    final bool prayComplete;
    final Map<String,dynamic> attributes;

    PrayerReminderPrayMessageBuilder({
        this.channelSid,
        String body,
        this.attributes,
        this.messageSid,
        DateTime dateCreated,
        final int index,
        final ChatMessageBuilderHandler builderHandler,
        final bool isHighlight,
        this.prayComplete = false
    }) : super(
            body: body, 
            attributes: attributes, 
            dateCreated: dateCreated, 
            index:index, 
            builderHandler: builderHandler,
            isHighlight: isHighlight
        ) { 
                message = Message(
                    from: 'system',
                    body: body,
                    attributes: attributes,
                    sid: messageSid,
                    channelSid: channelSid
                );
            }
    
    Message message;
    String get visibleTo => attributes['visibleTo'][0];
    
    @override
    Widget builder(BuildContext context, {int totalMessageCount,dynamic listScrollController}) {
        SubmittedQuestionsAnswers answers;
        if (attributes['prId'] == null) 
            answers = SubmittedQuestionsAnswers.fromV1MessageAttributes(attributes);
        else
            answers = SubmittedQuestionsAnswers.fromMessageAttributes(attributes);
        final Widget child = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                Center(
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
                        decoration: BoxDecoration(
                            color: globals.Colors.veryLightGray,
                            borderRadius: BorderRadius.circular(22)
                        ),
                        child: Column(
                            children: <Widget>[
                                Text(
                                    allTranslations.text('prayer_reminder_title'),
                                    style: TextStyle(
                                        color: globals.Colors.brownGray,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500
                                    ),
                                ),
                                Text(
                                    DateFormat('h:mm a').format(dateCreated.toLocal()),
                                    style: TextStyle(
                                        color: globals.Colors.lightGray,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w400
                                    ),
                                )
                            ],
                        ),
                    ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: PrayerReminderSlider(
                        channelSid:channelSid,
                        answers: answers,
                        message: message,
                        showFirstLast: !(attributes['prId'] == null),
                        timePassed: prayComplete
                    ),
                )
            ],
        );
        if (prayComplete)
            return child;
        return StreamProvider<bool>(
            initialData: false,
            create: (BuildContext context) =>
                PrayerReminderController.hasPrayed(channelSid, attributes['prId'], UserController.currentUser.uid),
            child: child
        );
    }
}

class PrayerReminderAnswers extends MyFullscreenBottomSheet {
    final SubmittedQuestionsAnswers quesAnswers;
    final String channelSid;
  PrayerReminderAnswers(this.quesAnswers,this.channelSid);
    @override
    State<PrayerReminderAnswers> createState() => PrayerReminderAnswersState();
}

class PrayerReminderAnswersState extends MyFullscreenBottomSheetState<PrayerReminderAnswers> {

    @override
    void initState() {
        super.initState();
        quesAnswers = widget.quesAnswers;
        ansLength = quesAnswers.userAnswers.length;
        mainTitle = allTranslations.text('prayer_reminder_title');
    }

    @override
    void dispose() {
        super.dispose();
    }

    SubmittedQuestionsAnswers quesAnswers;
    int ansLength;

    @override
    Widget mainWidget() {
        return ListView.builder(
            itemCount: quesAnswers.questions.length,
            itemBuilder: (BuildContext context, int index) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                        Container(
                            decoration: kBottomBorderDecoration,
                            padding: const EdgeInsets.all(12),
                            child: Text(
                                quesAnswers.questions[index].question,
                                style: kBoldTextStyle.copyWith(
                                    height: 24 / 16
                                )
                            ),
                        ),
                        Container(
                            decoration: kBottomBorderDecoration,
                            padding: const EdgeInsets.only(left: 12,right: 12,top: 12),
                            child:  Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:
                                quesAnswers.userAnswers.map((SubmittedAnswers answer) =>
                                    Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: UserAnswerTile(
                                            timestamp: answer.timestamp,
                                            uid: answer.uid,
                                            answer: answer.answers[index],
                                        )
                                    )
                                ).toList()
                            ),
                        )
                    ],
                );
            }
        );
    }
}

class UserAnswerTile extends StatelessWidget {
    final String uid;
    final String answer;
    final String timestamp;

    const UserAnswerTile({
        Key key,
        @required this.uid,
        @required this.answer,
        @required this.timestamp
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        final Message message = Message(
            from: uid,
            body: answer,
            dateCreated: DateTime.parse(timestamp),
            attributes: {}
        );
        return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                MyOvalAvatar.ofUser(uid, iconRadius: 20,),
                Container(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                            ChatMessageHeader(message),
                            ClipRect(
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(2, 2, 4, 4),
                                    child: bubbleItem()
                                ),
                                )
                            ]
                    ),
                ),
            ],
        );
    }

    Widget bubbleItem(){
        BoxDecoration boxDecoration = BoxDecoration(
            boxShadow: <BoxShadow>[
                BoxShadow(
                    color: globals.Colors.shadow,
                    blurRadius: 3,
                    offset: const Offset(1, 1)
                )
            ],
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16)
            )
        );
        return Row(
            children: <Widget>[
                Flexible(
                    child: Stack(
                        children: <Widget>[
                            Container(
                                margin: EdgeInsets.zero,
                                decoration: boxDecoration,
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(0),
                                        topRight: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16)
                                    ),
                                    child: Container(
                                        color: Colors.white,
                                        child: Padding(
                                            child: Text(answer,style: k14TextStyle,),
                                            padding: const EdgeInsets.all(12)
                                        )
                                    ),
                                ),
                            ),
                        ],
                    ),
                )
            ],
        );
    }
}