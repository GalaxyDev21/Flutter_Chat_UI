import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:organizer/controllers/chat/prayer_reminder_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/models/chat/prayer_reminder_model.dart';
import 'package:organizer/views/calendar/views_components/calendar_globals.dart';
import 'package:organizer/views/chat/insert/prayer_reminder/frequency_controller.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet_wrapper.dart';
import 'package:organizer/views/components/modal_bottom_sheet_navbar.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/views/components/progress_indicator.dart';
import 'package:organizer/views/constants/style_constants.dart';

class PrayerReminder extends MyFullscreenBottomSheet {
    final String channelSid;
    
    PrayerReminder(this.channelSid); 

  @override
  _PrayerReminderState createState() => _PrayerReminderState();
}

class _PrayerReminderState extends MyFullscreenBottomSheetState<PrayerReminder> {
    
    PrayerReminderController prayerReminderController;
    DateTime collectionTime;
    DateTime prayTime;
    bool nextDay = false;
    bool bothSameTime = false;
    FrequencyController frequencyController;
    @override
    void initState(){
        super.initState();
        prayerReminderController = PrayerReminderController(widget.channelSid);
        collectionTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 0);
        prayTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 18, 0);
        frequencyController = FrequencyController();
    }
    
    @override
    Widget build(BuildContext context) {
        frequencyController.giveWarning = false;
        if (prayTime.compareTo(collectionTime) < 0)
            nextDay = true;
        else
            nextDay = false;
        if (prayTime.compareTo(collectionTime) == 0)
            bothSameTime = true;
        else
            bothSameTime = false;
        
        return MyFullscreenBottomSheetWrapper(
            child: Column(
                children: <Widget>[
                    navBar(),
                    prayTimeSetter()
                ], 
            ),
        );
    }

    Widget navBar() {
        return MyModalSheetNavBar(
            rightButton: [
                AbsorbPointer(
                    absorbing: bothSameTime,
                    child: FlatButton(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                            allTranslations.text('library_confirm'),
                            style: !bothSameTime
                                ? TextStyle(
                                    color: globals.Colors.orange,
                                    fontWeight: FontWeight.w600
                                )
                                : TextStyle(
                                    color: globals.Colors.lightGray,
                                    fontWeight: FontWeight.w600
                                )
                        ),
                        onPressed: () async {
                            showActivityIndicator();
                            try {
                                await prayerReminderController.createPrayerReminder(PrayerReminderProperties(
                                    isDaily: frequencyController.frequency == ReminderFrequency.daily,
                                    collectionFrequency: frequencyController.collectionFrequency,
                                    collectionTime: collectionTime,
                                    prayTime: prayTime)
                                );
                                hideActivityIndicator();
                                Navigator.of(context)..pop()..maybePop();
                            }
                            catch(e) {
                                print(e);
                                hideActivityIndicator();
                            }
                        }
                    ),
                )
            ]
        );
    }

    Widget prayTimeSetter() {
        final DateTime now = DateTime.now();
        return Expanded(
            child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 12, right: 12, top: 23),
                child: Column(
                    mainAxisAlignment:MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: <Widget>[
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                const CircleAvatar(
                                    radius:18,
                                    backgroundColor: Color.fromRGBO(228, 228, 228, 1),
                                    child: Text('1', style: k16TextStyle),
                                ),
                                const SizedBox(width: 6,),
                                Flexible(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                            Text (
                                                allTranslations.text('chat_prayer_point_collection_time_set_message'), 
                                                style: k16TextStyle
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 6,
                                                    top: 8,
                                                    bottom: 16 
                                                ),
                                                child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                        onTap: () async{
                                                            // selectFrequency(context);
                                                            await frequencyController.selectFrequency(context);
                                                            setState(() {
                                                              
                                                            });
                                                        },
                                                        child: Row(
                                                            children: <Widget>[
                                                                Icon(
                                                                    MdiIcons.calendarToday,
                                                                    color: globals.Colors.gray,
                                                                ),
                                                                const SizedBox(width: 8),
                                                                Flexible(
                                                                    child: Text(
                                                                        frequencyController.frequency == ReminderFrequency.weekly
                                                                            ? getFrequencyLabel()
                                                                            : 'Daily',
                                                                        style: k14TextStyle,
                                                                    ),
                                                                )
                                                            ],
                                                        )
                                                    ),
                                                ),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(left: 6),
                                                child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                        onTap: () {
                                                            selectTime(collectionTime, 'collection');
                                                        },
                                                        child: Row(
                                                            children: <Widget>[
                                                                Icon(
                                                                    Icons.access_time,
                                                                    color: globals.Colors.gray,
                                                                ),
                                                                const SizedBox(width: 8),
                                                                Text(
                                                                    CalendarGlobals.fullHourFormat.format(
                                                                        DateTime(
                                                                            now.year, now.month, now.day, 
                                                                            collectionTime.hour, collectionTime.minute
                                                                        )
                                                                    ),
                                                                    style: k14TextStyle
                                                                )
                                                            ],
                                                        )
                                                    ),
                                                ),
                                            )
                                        ],
                                    ),
                                )        
                            ], 
                        ),
                        const SizedBox(height: 26),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                const CircleAvatar(
                                    radius:18,
                                    backgroundColor: Color.fromRGBO(228, 228, 228, 1),
                                    child: Text('2', style: k16TextStyle),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                            Text(
                                                allTranslations.text('chat_prayer_point_reminder_time_set_message'), 
                                                style:k16TextStyle
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 6,
                                                    top: 8,
                                                ),
                                                child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                        onTap: () {
                                                            selectTime(prayTime,'reminder');
                                                        },
                                                        child: Row(
                                                            children: <Widget>[
                                                                Icon(
                                                                    Icons.access_time,
                                                                    color: globals.Colors.gray
                                                                ),
                                                                const SizedBox(width: 8),
                                                                Flexible(
                                                                    child: Text(
                                                                        CalendarGlobals.fullHourFormat.format(
                                                                            DateTime(
                                                                                now.year, now.month, now.day, 
                                                                                prayTime.hour, prayTime.minute
                                                                            )
                                                                        ),
                                                                        style: k14TextStyle
                                                                    ),
                                                                ),
                                                            ],
                                                        )
                                                    ),
                                                ),
                                            ),
                                            if (nextDay || bothSameTime)
                                                Padding(
                                                    padding: const EdgeInsets.only(
                                                        top: 0,
                                                        left: 6,
                                                    ),
                                                    child: Row(
                                                        children: <Widget>[
                                                            Icon(
                                                                null,
                                                                color: Colors.transparent
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                                bothSameTime
                                                                    ? allTranslations.text('chat_prayer_reminder_same_time')
                                                                    : allTranslations.text('chat_prayer_reminder_next_day'),
                                                                style: !bothSameTime
                                                                    ? k14TextStyle.copyWith(
                                                                        fontSize: 12,
                                                                        color: globals.Colors.lightGray
                                                                    )
                                                                    : k14TextStyle.copyWith(
                                                                        fontSize: 12,
                                                                        color: globals.Colors.red
                                                                    )
                                                            ),
                                                        ],
                                                    )
                                                ),
                                        ],
                                    ),
                                )         
                            ], 
                        )
                    ],
                ),
            )
        );
    }

    String getFrequencyLabel() {
        String label='Weekly: ';
        if (frequencyController.collectionFrequency.contains(true)) {
            const List<String> days = <String>['Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat', 'Sun'];
            for (int i = 0; i < 7 ; i++) {
                if (frequencyController.collectionFrequency[i]) {
                    label += '${days[i]} / ';
                }
            }
            label = label.substring(0, label.length - 2);
        }
        return label;
    }
    
    Future<void> selectTime(DateTime time, String type) async {
        final DateTime now = DateTime.now();
        final TimeOfDay picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: time.hour, minute: time.minute),
        );
        final DateTime pickedDateTime = DateTime(now.year,now.month, now.day, picked.hour, picked.minute);
        if (picked != null) {
            setState(() {
                type == 'reminder'
                ? prayTime = pickedDateTime
                : collectionTime = pickedDateTime;
            });
        }
    }

}
