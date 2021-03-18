import 'package:flutter/material.dart';
import 'package:organizer/common/date_utils.dart';
import 'package:organizer/controllers/chat/prayer_reminder_controller.dart';
import 'package:organizer/views/chat/chat_components/prayer_reminder_message/prayer_reminder_slider.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet_wrapper.dart';
import 'package:organizer/views/components/modal_bottom_sheet_navbar.dart';
import 'package:organizer/views/components/progress_indicator.dart';

import 'package:organizer/models/chat/prayer_reminder_model.dart';
class PrayerPointsDay extends StatelessWidget {
    final String prId;
    final String channelSid;
    final DateTime dateCreated;
    PrayerPointsDay({this.prId, this.channelSid, this.dateCreated});
    
    @override
    Widget build(BuildContext context) {
        return MyFullscreenBottomSheetWrapper(
            child: FutureBuilder<SubmittedQuestionsAnswers>(
                future: PrayerReminderController.getAnswers(channelSid, prId) ,
                builder: (BuildContext context, AsyncSnapshot<SubmittedQuestionsAnswers> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                        return MyProgressIndicator();
                    }
                    SubmittedQuestionsAnswers answers = snapshot.data;
                    return Column(
                        children: <Widget>[
                            MyModalSheetNavBar(
                                mainTitle: Utils.formatMonthDateYear(dateCreated),
                            ),
                            PrayerReminderSlider(showFirstLast: false, channelSid: channelSid,answers:answers)
                        ],
                    );
                }
            )
        );
    }
}