
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/prayer_reminder_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/models/chat/prayer_reminder_model.dart';
import 'package:organizer/views/chat/insert/set_message_reminder.dart';
import 'package:organizer/views/components/bot_avatar.dart';
import 'package:organizer/views/components/oval_avatar.dart';
import 'package:organizer/views/components/thumbnail.dart';
import 'package:organizer/views/components/buttons.dart';
import 'package:organizer/views/components/shadow_view.dart';
import 'package:organizer/views/components/user_name_view.dart';
import 'package:organizer/views/constants/style_constants.dart';
import 'package:provider/provider.dart';

class PrayerReminderPrayCard extends StatelessWidget {
    final String headerTitle;
    final Widget header;
    final Widget child;
    final Widget bottom;
    final Widget topIcon;
    
    PrayerReminderPrayCard({this.headerTitle, this.header, this.child, this.bottom, this.topIcon});
    
    @override
    Widget build(BuildContext context) {
        return Stack(
            children: <Widget>[
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: ShadowView(
                        width: (MediaQuery.of(context).size.width - 24) * 0.7,
                        borderRadius: 16,
                        shadowColor: globals.Colors.shadow,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                                    child: header ?? Text(
                                        headerTitle ?? '',
                                        style: kBoldTextStyle,
                                    ),
                                ),
                                Expanded(
                                    child: child ?? Container(),
                                ),
                                if (bottom != null)
                                    bottom
                            ],
                        ),
                    ),
                ),
                if (topIcon != null)
                    Positioned(
                        top: 0, right: 12,
                        child: topIcon,
                    )
            ],
        );
    }
}

class PrayerReminderSlider extends StatefulWidget {
    
    final SubmittedQuestionsAnswers answers;
    final Message message;
    final bool showFirstLast;
    final String channelSid;
    final bool timePassed;
    const PrayerReminderSlider({@required this.channelSid, @required this.answers, this.message, this.showFirstLast = true, this.timePassed = false});

    @override
    _PrayerReminderSliderState createState() => _PrayerReminderSliderState();
}

class _PrayerReminderSliderState extends State<PrayerReminderSlider> {
    Future<bool> _future;
    bool hasPrayed = true;
    @override
    void initState() { 
        super.initState();
        widget.showFirstLast
            ? _future =  PrayerReminderController.hasPrayedCall(
                widget.channelSid, 
                widget.message.attributes['prId'], 
                UserController.currentUser.uid
            )
            : _future = null;
    }
    Widget _firstPage(bool hasPrayed, BuildContext context) {
        return PrayerReminderPrayCard(
            headerTitle: allTranslations.text('onboarding_mybot'),
            topIcon: MyBotAvatar(size: 48),
            bottom: !hasPrayed
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                        const Divider(height: 1, color: globals.Colors.veryLightGray,),
                        orangeButton(
                            text: allTranslations.text('prayer_reminder_remind_later'),
                            onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                        builder: (BuildContext context) => SetMessageReminder(message:widget.message)
                                
                                    )
                                );
                            },
                        )
                    ],
                ): Container(),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                        child: RichText(
                            text: TextSpan(
                                children: <TextSpan>[
                                    TextSpan(
                                        text: allTranslations.text('prayer_reminder_finish'),
                                        style: k14TextStyle
                                    ),
                                    TextSpan(
                                        text: allTranslations.text('prayer_reminder_swipe_left'),
                                        style: k14BoldTextStyle.copyWith(color: globals.Colors.orange)
                                    ),
                                    TextSpan(
                                        text: allTranslations.text('prayer_reminder_when'),
                                        style: k14TextStyle
                                    )
                                ]
                            ),
                        ),
                    ),
                    const Spacer(),
                    Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                                Image.asset('assets/images/prayer_woman.png', width: 78, height: 115)
                            ],
                        ),
                    )
                ],
            ),
        );
    }

    Widget _questionsPage(List<Question> questions, int count) {
        return PrayerReminderPrayCard(
            headerTitle: allTranslations.text('prayer_reminder_questions'),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                            count > 1 
                                ? '$count ${allTranslations.text('prayer_reminder_members_responded')}'
                                : '$count ${allTranslations.text('prayer_reminder_member_responded')}',
                            style: k12TextStyle.copyWith(color: globals.Colors.lightGray),
                        ),
                    ),
                    Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.only(top: 14, right: 12),
                            itemCount: questions.length,
                            itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                            Container(
                                                width: 24,
                                                height: 24,
                                                margin: const EdgeInsets.only(right: 12),
                                                decoration: const BoxDecoration(
                                                    color: globals.Colors.veryLightGray,
                                                    borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4))
                                                ),
                                                child: Center(
                                                    child: Text(
                                                        '${index + 1}',
                                                        textAlign: TextAlign.center,
                                                        style: k14TextStyle
                                                    )
                                                )
                                            ),
                                            Expanded(
                                                child: Text(
                                                    questions[index].question,
                                                    style: k14TextStyle
                                                ),
                                            )
                                        ],
                                    ),
                                );
                            }
                        ),
                    )
                ],
            ),
        );
    }

    Widget _answerPage(List<SubmittedAnswers> userAnswers, int uIndex) {
        return PrayerReminderPrayCard(
            header:  UserNameView(
                userAnswers[uIndex].uid,
                textStyle: kBoldTextStyle
            ),
            topIcon: MyOvalAvatar.ofUser(userAnswers[uIndex].uid,iconRadius: 24, 
                iconPlaceholder:IconPlaceholder(
                    icon: Icons.person,
                    iconColor: globals.Colors.lightGray,
                    backgroundColor: globals.Colors.veryLightGray,
                    size: 24 * 1.1
                )
            ),

            bottom: Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.bottomRight,
                child: Text(
                    '${uIndex + 1}/${userAnswers.length}',
                    style: k12TextStyle.copyWith(color: globals.Colors.brownGray),
                ),
            ),
            child: ListView.builder(
                padding: const EdgeInsets.only(top: 12, right: 12),
                itemCount: userAnswers[uIndex].answers.length,
                itemBuilder: (BuildContext context, int aIndex) {
                    return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: const BoxDecoration(
                                        color: globals.Colors.veryLightGray,
                                        borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4))
                                    ),
                                    child: Center(
                                        child: Text(
                                            '${aIndex + 1}',
                                            textAlign: TextAlign.center,
                                            style: k14TextStyle
                                        )
                                    )
                                ),
                                Expanded(
                                    child: Text(
                                        userAnswers[uIndex].answers[aIndex],
                                        style: k14TextStyle
                                    ),
                                )
                            ],
                        ),
                    );
                }
            ),
        );
    }

    Widget _lastPageDone(BuildContext context) {
        assert(widget.showFirstLast);
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                Image.asset('assets/images/question@3x.png', width: 49, height: 80),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                        allTranslations.text('prayer_reminder_are_done'),
                        style: k14BoldTextStyle,
                    ),
                ),
                Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: shadowOrangeButton(
                        text: allTranslations.text('prayer_reminder_no_remind'),
                        width: 200, height: 36,
                        onPressed: () {
                            Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                        builder: (BuildContext context) => SetMessageReminder(message:widget.message)
                                
                                    )
                                );
                        }
                    ),
                ),
                shadowGradientButton(
                    width: 200, height: 36,
                    child: Center(
                        child: Text(
                            allTranslations.text('prayer_reminder_yes_done'),
                            style: k14SemiBoldTextStyle.copyWith(color: globals.Colors.white),
                        ),
                    ),
                    onPressed: () async{
                        try{
                            await PrayerReminderController.prayerComplete(widget.channelSid, widget.message.attributes['prId']);
                            
                            setState(() {
                                _future = Future<bool>.value(true);
                            });
                        }
                        catch(err) {
                            print(err);
                        }
                    }
                )
            ],
        );
    }

    Widget _lastPageNotDone() {
        assert(widget.showFirstLast);
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                Image.asset('assets/images/artwork_relaxing.png', width: 196, height: 120),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                        allTranslations.text('prayer_reminder_awesome'),
                        style: k14BoldTextStyle,
                        textAlign: TextAlign.center,
                    ),
                ),
                IntrinsicHeight(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                        Image.asset('assets/images/dot_start.png', width: 24, height: 16)
                                    ],
                                ),
                            ),
                            Expanded(
                                child: Text(
                                    widget.answers.quote.quote,
                                    
                                    style: k14TextStyle,
                                    textAlign: TextAlign.center,
                                ),
                            ),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                        Image.asset('assets/images/dot_end.png', width: 24, height: 16)
                                    ],
                                ),
                            )
                        ],
                    ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                        widget.answers.quote.author,
                        style: k14MediumTextStyle.copyWith(color: globals.Colors.brownGray),
                        textAlign: TextAlign.center,
                    ),
                )
            ],
        );
    }
    Widget prayChild(){
        return CarouselSlider(
            enableInfiniteScroll: false,
            aspectRatio: (MediaQuery.of(context).size.width - 24) / 292,
            viewportFraction: 0.7,
            items: <Widget>[
                if (widget.showFirstLast)
                    _firstPage(hasPrayed,context),
                _questionsPage(widget.answers.questions, widget.answers.userAnswers.length),
                ...List<Widget>.generate(widget.answers.userAnswers.length, (int index) => _answerPage(widget.answers.userAnswers, index)),
                if(widget.showFirstLast)
                    if (!hasPrayed)
                        _lastPageDone(context)
                    else
                        _lastPageNotDone()
                // if (showFirstLast)
            ],
        );
    }
    @override
    Widget build(BuildContext context) {
        if(widget.showFirstLast) 
            assert(widget.message != null);
        if (!widget.showFirstLast)
            return prayChild();
        if (!widget.timePassed)
        return Consumer<bool>(builder: (BuildContext context, bool hasPrayed, Widget child) {
            this.hasPrayed = hasPrayed;
            return prayChild();
        });
        return FutureBuilder<bool>(
            future: _future,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.data != null && snapshot.hasData )
                    hasPrayed = snapshot.data;
                return prayChild();
            }
        );
        
    }
}