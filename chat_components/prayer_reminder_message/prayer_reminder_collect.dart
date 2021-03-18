import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/controllers/chat/prayer_reminder_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/handlers/chat_message_builder_handler.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/models/chat/prayer_reminder_model.dart';
import 'package:organizer/services/analytics_service.dart';
import 'package:organizer/views/chat/chat_components/mybot_message/mybot_header.dart';
import 'package:organizer/views/chat/chat_components/bubble.dart';
import 'package:organizer/views/chat/chat_components/prayer_reminder_message/well_done_dialog.dart';
import 'package:organizer/views/components/bot_avatar.dart';
import 'package:organizer/views/components/chat_button.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet_wrapper.dart';
import 'package:organizer/views/components/modal_bottom_sheet_navbar.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/views/constants/style_constants.dart';
import 'package:provider/provider.dart';
import 'package:organizer/globals.dart' as globals;

class PrayerReminderCollect extends StatelessWidget {
    final DateTime dateCreated;
    final Message message;
    final String channelSid;
    final bool collectionComplete;
    final int index;
    final ChatMessageBuilderHandler builderHandler;
    final bool isHighlight;
    final bool isRecall;
    
    const PrayerReminderCollect({
        Key key, 
        this.dateCreated, 
        this.message, 
        this.channelSid,
        this.collectionComplete = false,
        this.index,
        this.builderHandler,
        this.isHighlight = false,
        this.isRecall = false
    }) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
        
        
        return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                MyBotAvatar(),
                Container(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                            MybotHeader(dateCreated, visibleToAll: !isRecall),
                            Column(
                                children: <Widget>[
                                    Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: ClipRect(
                                            child: Padding(
                                                padding: const EdgeInsets.fromLTRB(2, 2, 4, 4),
                                                child: Bubble(
                                                    message: message,
                                                    index: index,
                                                    builderHandler: builderHandler,
                                                    isHighlight: isHighlight,
                                                ),
                                            ),
                                        )
                                    ),
                                    

                                    Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: collectionComplete 
                                            ? MyChatButton(
                                                color: collectionComplete?
                                                globals.Colors.lightGray:
                                                globals.Colors.orange,
                                                text: allTranslations.text('chat_prayer_points_expired'),
                                                
                                                onPressed: () => null
                                            ) 
                                            : Consumer<CollectorAnswers>(builder: (BuildContext context, CollectorAnswers answers, Widget child) => 
                                                MyChatButton(
                                                        color: collectionComplete?
                                                        globals.Colors.lightGray:
                                                        globals.Colors.orange,
                                                        text:
                                                        collectionComplete
                                                        ? allTranslations.text('chat_prayer_points_expired')
                                                        : answers.answers.isEmpty 
                                                            ? (isRecall
                                                                ? allTranslations.text('prayer_reminder_provide')
                                                                : allTranslations.text('chat_prayer_points_start_collection'))
                                                            : allTranslations.text('chat_prayer_points_edit_answers'),
                                                        onPressed: () async {
                                                            showMyModalBottomSheet<String>(
                                                                context: context,
                                                                child: PrayerReminderCollectorSubmission(
                                                                    prayTime:DateTime.parse(message.attributes['prayTime']),
                                                                    answers: answers,
                                                                    channelSid: channelSid,
                                                                    questions: List<Map<String,dynamic>>.from(message.attributes['questions']).map((map)=>Question.fromMap(map)).toList()
                                                                ),
                                                                fullScreen: true
                                                            );
                                                        },
                                                    ),
                                                )
                                    ),
                                ],
                            )
                        ],
                    ),
                )
            ]
        );
    }
}

class PrayerReminderCollectorSubmission extends MyFullscreenBottomSheet {
    final CollectorAnswers answers;
    final String channelSid;
    final DateTime prayTime;
    final List<Question> questions;
    PrayerReminderCollectorSubmission({this.answers,this.channelSid, this.prayTime,this.questions});
    @override
    State<PrayerReminderCollectorSubmission> createState() => PrayerReminderCollectorSubmissionState();
}

class PrayerReminderCollectorSubmissionState extends MyFullscreenBottomSheetState<PrayerReminderCollectorSubmission> {
    
    List<TextEditingController> editingController =[];
    List<String> answers;
    List<Question> questions;
    @override
    void initState() {
        super.initState();
        current = 0;
        answers = widget.answers.answers;
        questions = widget.questions;
        if (answers.isEmpty){
            answers = List<String>.generate(questions.length, (index)=>'');
        }
        for (int i = 0; i < questions.length; i++) {
            TextEditingController textEditingController = TextEditingController();
            editingController.add(textEditingController);
            textEditingController.text = answers?.elementAt(i)??'';
        }
        
    }

    @override
    void dispose() {
        editingController.forEach((controller) => controller.dispose());
        super.dispose();
    }

    int current;
    TextEditingController currentTextEditingController;
    // String currentMainTitle;
    Text currentRightButtonText;
    Function rightButtonOnPressed;
    Function leftButtonOnPressed;
    Question currentQuestion;
    bool submitButtonDisabled =false;
    String currentText;
    @override
    Widget build(BuildContext context) {
        // print(currentText);
        currentQuestion = questions[current];
        currentTextEditingController = editingController[current];
        currentText = currentTextEditingController.text;
        currentRightButtonText = Text(
            current == questions.length-1 ?
            allTranslations.text('prayer_reminder_ques_confirm'):
            allTranslations.text('prayer_reminder_ques_next'),
            style:
             TextStyle(
                color: (current == questions.length-1  && submitButtonDisabled) || 
                    currentText.trim() == ''
                 ?
                    globals.Colors.lightGray : globals.Colors.orange,
                fontWeight: FontWeight.w600
            )
        );
        leftButtonOnPressed = () {
            if (current == 0)
                Navigator.of(context).maybePop();
            else 
                setState(() {
                    current--;
                });
            
        };
        rightButtonOnPressed = () async{
            if(current != questions.length - 1)
                setState(() {
                    current++;
                });
            else {
                PrayerReminderController.setAnswer(
                    DateTime.now().toUtc().toIso8601String(),
                    widget.channelSid, 
                    UserController.currentUser.uid, 
                    answers
                );
                final Channel channel = ChatListController().channels.firstWhere(
                    (Channel channel) => channel.info.sid == widget.channelSid, orElse: () => null);
                await AnalyticsService().sendAmplitudeAnalyticsEvent(
                    UserController.currentUser.uid,
                    AmplitudeEvents.sendMessage,
                    properties: <String, dynamic> {
                        'recipientChannelSid': widget.channelSid,
                        'messageType': 'Prayer Reminder Answer',
                        'receiverType': channel.info.attributes['type'],
                        'isScheduledMsg': false,
                        'groupAdminStatus': channel.isAdmin()
                    }
                );
                Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
                    builder: (BuildContext context) => WellDoneDialog(
                        prayTime: widget.prayTime,
                    ),
                ));
            }       
        };
        return MyFullscreenBottomSheetWrapper(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    
                    MyModalSheetNavBar(
                        mainTitle: 'Question ${current+1} of ${questions.length}',
                        rightButton: [
                            AbsorbPointer(
                                absorbing: currentText.trim()=='',
                                child: FlatButton(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: currentRightButtonText,
                                    onPressed: rightButtonOnPressed
                                )
                            )
                        
                        ],
                        leftButton: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                            onPressed: leftButtonOnPressed
                        ),
                    ),
                    
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: kBottomBorderDecoration,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                Text(
                                    currentQuestion.question,
                                    style: kBoldTextStyle,
                                ),
                                
                                if (currentQuestion.supportingText != null && currentQuestion.supportingText.isNotEmpty) 
                                    ... List<Widget>.generate(currentQuestion.supportingText.length, (int index)=>
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(4, index == 0 ? 3 : 0, 4, 0),
                                            child: Text(
                                                '- ' + currentQuestion.supportingText[index],
                                                style: k14BrownTextStyle,
                                            ),
                                        )
                                    )  
                            ],
                        ),
                    ),
                    
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.5),
                        child: 
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            // mainAxisAlignment:AxisAlignment.start,
                            children: <Widget>[
                                Expanded(
                                    child: TextField(
                                        autofocus: true,
                                        controller: currentTextEditingController,
                                        autocorrect: true,
                                        enableSuggestions: true,
                                        textCapitalization: TextCapitalization.sentences,
                                        decoration: InputDecoration(
                                            hintText: allTranslations.text('chat_prayer_points_answer_placeholder'),
                                            hintStyle: k14TextStyle.copyWith(color: globals.Colors.lightGray),
                                            border: InputBorder.none,
                                        ),
                                        style: k14TextStyle,
                                        cursorColor: Colors.black,
                                        maxLines: null,
                                        onChanged:((String text) {
                                            setState(() {
                                                currentText = text;
                                                answers[current] = currentText;
                                            });
                                        }),
                                    ),
                                )
                            ],
                        ),
                    )
                ],
            )
        );
    }
}