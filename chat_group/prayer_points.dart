import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:organizer/icons_icons.dart';
import 'package:organizer/common/date_utils.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/controllers/chat/prayer_reminder_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/models/chat/channel_info_model.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/models/chat/prayer_reminder_model.dart';
import 'package:organizer/views/chat/chat_components/prayer_reminder_message/prayer_reminder_collect.dart';
import 'package:organizer/views/chat/chat_components/prayer_reminder_message/prayer_reminder_slider.dart';
import 'package:organizer/views/chat/chat_components/prayer_reminder_message/prayer_reminder_submitted.dart';
import 'package:organizer/views/chat/chat_group/prayer_points_day.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet.dart';
import 'package:organizer/views/components/progress_indicator.dart';
import 'package:organizer/views/components/thumbnail.dart';
import 'package:organizer/views/components/buttons.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/views/constants/style_constants.dart';
import 'package:provider/provider.dart';

class PrayerPoints extends MyFullscreenBottomSheet {
    final Channel channel;
    PrayerPoints({this.channel});
    @override
    State<PrayerPoints> createState() => PrayerPointsState();
}

class PrayerPointsState extends MyFullscreenBottomSheetState<PrayerPoints> {
    
    @override
    void initState() {
        super.initState();
        _future = PrayerReminderController.getHistory(widget.channel.info.sid, null, limit);
        mainTitle = allTranslations.text('prayer_reminder_title');
    }
    bool resultsEnd = false;
    bool incomingData= false;

    List<PrHistoryPiece> prHistory;
    PrHistoryPiece firstPrayer;
    Future _future;
    final int limit = 10;
    void fetchMore() async{
        Timestamp lastCreateTime = Timestamp.fromDate(prHistory.last.createTime); 
        setState(() {
            _future = PrayerReminderController.getHistory(widget.channel.info.sid, prHistory.last.prId, limit);
            incomingData = true;
        });
    }
    Widget _prayerRunning() {

        final Message message = widget.channel.messages.firstWhere((Message msg) {                            
            return msg.attributes['prId'] == firstPrayer.prId;
        });
        SubmittedQuestionsAnswers quesAnswers = SubmittedQuestionsAnswers.fromMessageAttributes(message.attributes);
        return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(top: 48, bottom: 3),
                    child: Text(
                        Utils.formatMonDateYear(message.dateCreated.toLocal()),
                        style: k16SemiBoldTextStyle,
                    ),
                ),
                StreamProvider<bool>(
                    create: (BuildContext context) => PrayerReminderController.hasPrayed(
                        widget.channel.info.sid, 
                        firstPrayer.prId,
                        UserController.currentUser.uid
                    ),
                    initialData: false,
                    child: 
                        PrayerReminderSlider(channelSid: widget.channel.info.sid, answers: quesAnswers, message: message,)
                )
                
            ],
        );
    }
    
    Widget _bottomWidget(List<PrHistoryPiece> bottomList) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                ListView.builder(
                    padding: EdgeInsets.fromLTRB(12, firstPrayer.isStopped ? 12 : 60, 12, 0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bottomList.length,
                    itemBuilder: (BuildContext context, int index) {
                        return bottomList[index].stage != 4 
                            && bottomList[index].isStopped 
                            && bottomList[index].membersAnswered.isEmpty ?
                            Container()
                        : AbsorbPointer(
                            absorbing: bottomList[index].membersAnswered.isEmpty,
                            child: 
                                Opacity(
                                    opacity: bottomList[index].membersAnswered.isEmpty ? 0.3 :1 ,
                                    child: InkWell(
                                        child: Container(
                                            padding: const EdgeInsets.all(12),
                                            margin: const EdgeInsets.only(bottom: 6),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(3),
                                                border: Border.all(color: globals.Colors.veryLightGray)
                                            ),
                                            child: Row(
                                                children: <Widget>[
                                                    Text(
                                                        Utils.formatMonDateYear(bottomList[index].createTime.toLocal()),
                                                        style: k14TextStyle,
                                                    ),
                                                    const Spacer(),
                                                    Icon(
                                                        MdiIcons.accountGroup,
                                                        size: 15,
                                                        color: globals.Colors.brownGray,
                                                    ),
                                                    Padding(
                                                        padding: const EdgeInsets.only(left: 3),
                                                        child: Text(
                                                            bottomList[index].membersAnswered.length.toString(),
                                                            style: k14TextStyle,
                                                        ),
                                                    )
                                                ],
                                            ),
                                        ),
                                        onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute<bool>(
                                                    builder: (BuildContext context) {
                                                        return PrayerPointsDay(
                                                            prId:bottomList[index].prId, 
                                                            channelSid:widget.channel.info.sid, 
                                                            dateCreated: bottomList[index].createTime.toLocal()
                                                        );
                                                    }
                                                )
                                            );
                                        },
                                    )      
                                    )
                                );
                    },
                ),
                if (!resultsEnd)
                InkWell(
                    child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 30),
                        alignment: Alignment.center,
                        child: Text(
                            allTranslations.text('prayer_reminder_show'),
                            style: k14BoldTextStyle.copyWith(color: globals.Colors.brownGray),
                        ),
                    ),
                    onTap: () {
                        fetchMore();
                    },
                )
            ],
        );
    }
    
    @override
    Widget mainWidget() {
        return FutureBuilder<PrayerReminderHistory>(
            future: _future,
            builder: (BuildContext context, AsyncSnapshot<PrayerReminderHistory> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                    return MyProgressIndicator();
                if (!snapshot.hasData)
                    return Container();
                if (snapshot.data.history.length < limit)
                        resultsEnd = true;
                if (incomingData) {
                    prHistory.addAll(snapshot.data.history);
                    incomingData = false;
                }
                else if (snapshot.data.history.isNotEmpty && prHistory == null){
                    prHistory = snapshot.data.history;
                }
                if (prHistory == null)
                    return Container();
                firstPrayer = prHistory.first;
                return ListView(children: <Widget>[
                    if (!firstPrayer.isStopped) 
                        if (firstPrayer.stage > 1 && firstPrayer.stage < 4)
                            MultiProvider(
                                providers: [
                                    StreamProvider<CollectorAnswers>(
                                        create: (BuildContext context ) => PrayerReminderController.answerSnapshot(widget.channel.info.sid, UserController.currentUser.uid, firstPrayer.prId),
                                        initialData: CollectorAnswers([]),
                                    ),
                                    StreamProvider<MembersAnswered>(
                                        create: (BuildContext context) => PrayerReminderController.membersAnsweredSnapshot(widget.channel.info.sid, firstPrayer.prId),
                                        initialData: MembersAnswered([]), 
                                    )
                                ],
                                child: CollectionRunning(channel: widget.channel,prId: firstPrayer.prId,),
                            )

                        else if (firstPrayer.stage == 4 && firstPrayer.membersAnswered.isNotEmpty)
                            _prayerRunning(),

                    (!firstPrayer.isStopped && (firstPrayer.stage != 4 || firstPrayer.membersAnswered.isNotEmpty ))
                        ? _bottomWidget([...prHistory.getRange(1, prHistory.length)])
                        : _bottomWidget(prHistory)
                ]);
            }
        );
    }
    
}

class CollectionRunning extends StatelessWidget {
    final Channel channel;
    final String prId;
    const CollectionRunning({Key key, this.channel, this.prId}) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
        final Message message = channel.messages.firstWhere((Message msg) {                            
            return msg.attributes['prId'] == prId;
        });

        final CollectorAnswers answers = Provider.of<CollectorAnswers>(context);
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Image.asset('assets/images/artwork_praying.png', width: 166, height: 147),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            children: <TextSpan>[
                                TextSpan(
                                    text: 'Provide your prayer points before ',
                                    style: k14TextStyle
                                ),
                                TextSpan(
                                    text: DateFormat('h:mm a').format(DateTime.parse(message.attributes['prayTime']).toLocal()),
                                    style: k14BoldTextStyle
                                ),
                                TextSpan(
                                    text: " ${message.attributes['prayDay']?? 'today' }.",
                                    style: k14TextStyle
                                )
                            ]
                        ),
                    ),
                ),
                // Center(
                //     child: Container(
                //         width: 4 * 24.0 + 36,
                //         height: 36,
                //         child: Stack(
                //             children: List<Widget>.generate(5, (int index) {
                //                 return Positioned(
                //                     left: index * 24.0, top: 0,
                //                     child: Container(
                //                         decoration: BoxDecoration(
                //                             borderRadius: BorderRadius.circular(16),
                //                             border: Border.all(color: globals.Colors.white, width: 2),
                //                             color: globals.Colors.white
                //                         ),
                //                         child: Stack(
                //                             children: <Widget>[
                //                                 MyThumbnail.ovalAvatar(
                //                                     icon: Icons.person,
                //                                     radius: 16,
                //                                     path: 'user/${'IfIsvBU5Ggav5xElI4S3thQ01eY2'}/avatar/${'IfIsvBU5Ggav5xElI4S3thQ01eY2'}.jpg',
                //                                 ),
                //                                 if (index == 4)
                //                                     Positioned(
                //                                         left: 0, top: 0, right: 0, bottom: 0,
                //                                         child: Container(
                //                                             alignment: Alignment.center,
                //                                             decoration: BoxDecoration(
                //                                                 color: globals.Colors.black.withOpacity(0.48),
                //                                                 borderRadius: BorderRadius.circular(16)
                //                                             ),
                //                                             child: Text(
                //                                                 '+8',
                //                                                 style: k14MediumTextStyle.copyWith(color: globals.Colors.white),
                //                                             ),
                //                                         ),
                //                                     )
                //                             ],
                //                         ),
                //                     ),
                //                 );
                //             }),
                //         ),
                //     ),
                // ),
                // Padding(
                //     padding: const EdgeInsets.only(top: 3, bottom: 12),
                //     child: Text(
                //         '12 ${allTranslations.text('prayer_reminder_submitted')}',
                //         textAlign: TextAlign.center,
                //         style: k12MediumTextStyle.copyWith(color: globals.Colors.brownGray),
                //     ),
                // ),
                Consumer<MembersAnswered>(
                    builder: (BuildContext context, MembersAnswered membersAnswered, Widget child) {
                        return membersAnswered.membersAnswered.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                    PrayerReminderSubmitted(
                                        uids: membersAnswered.membersAnswered,
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 3, bottom: 12),
                                        child: Text(
                                            '${membersAnswered.membersAnswered.length} ${allTranslations.text('prayer_reminder_submitted')}',
                                            textAlign: TextAlign.center,
                                            style: k12MediumTextStyle.copyWith(color: globals.Colors.brownGray),
                                        ),
                                    )
                                ]
                            )
                            : Container();
                    },
                ),


                Container(
                    alignment: Alignment.center,
                    child: shadowGradientButton(
                        width: 256, height: 54,
                        child: Center(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                    Icon(
                                        MyIcons.prayer,
                                        color: globals.Colors.white,
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Text(
                                            answers.answers.isEmpty
                                                ? allTranslations.text('prayer_reminder_provide').toUpperCase()
                                                : allTranslations.text('chat_prayer_points_edit_answers').toUpperCase(),
                                            style: k14SemiBoldTextStyle.copyWith(color: globals.Colors.white),
                                        ),
                                    )
                                ],
                            ),
                        ),
                        onPressed: (){
                            showMyModalBottomSheet<String>(
                                context: context,
                                child: PrayerReminderCollectorSubmission(
                                    prayTime: DateTime.parse(message.attributes['prayTime']),
                                    answers: answers,
                                    channelSid: channel.info.sid,
                                    questions: List<Map<String,dynamic>>.from(message.attributes['questions']).map((map)=>Question.fromMap(map)).toList()
                                ),
                                fullScreen: true
                            );
                        }
                    ),
                )
            ],
        );
    }
}