import 'package:flutter/material.dart';
import 'package:organizer/controllers/chat/message_reminder_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/option.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/calendar/views_components/calendar_globals.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet.dart';
import 'package:organizer/views/components/option_tile.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/views/components/progress_indicator.dart';

class SetMessageReminder extends MyFullscreenBottomSheet {

    SetMessageReminder({
        this.message
    });

    Message message;

    @override
    _SetMessageReminderState createState() => _SetMessageReminderState();
}

class _SetMessageReminderState extends MyFullscreenBottomSheetState<SetMessageReminder> {

    DateTime _startTime;
    MessageReminderController _messageReminderController;

    
    @override
    void initState() {
        super.initState();
        mainTitle = allTranslations.text('chat_set_reminder');
        _messageReminderController = MessageReminderController();
        _startTime = null;
    }

    Future<void> _createMsgReminder(DateTime scheduledTime, String channelSid, String messageSid) async {
        showActivityIndicator();
        try {
            final bool isCreated = await _messageReminderController.createMsgReminder(scheduledTime, channelSid, messageSid);
            hideActivityIndicator();
            if (isCreated) {
                Navigator.of(context).pop();
            }
            else
                throw 'fail to create message reminder';
        }
        catch (err) {
            print('createMsgReminder error: ' + err);
            hideActivityIndicator();
            showOkDialog(
                context,
                title: 'error',
                content: 'error'
            );
        }
    }

    @override
    Widget mainWidget() {
        return Column(
            children: <Widget>[
                const Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Text(
                        allTranslations.text('chat_set_reminder_title'),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                        ),
                    )
                ),
                MyOptionTile(
                    option: const Option(title: 'chat_set_reminder_15_minutes'),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () async {
                        final DateTime now = DateTime.now();
                        _startTime = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second).add(const Duration(minutes: 15));
                        await _createMsgReminder(_startTime, widget.message.channelSid, widget.message.sid);
                    },
                ),
                MyOptionTile(
                    option: const Option(title: 'chat_set_reminder_1_hour'),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () async {
                        final DateTime now = DateTime.now();
                        _startTime = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second).add(const Duration(hours: 1));
                        await _createMsgReminder(_startTime, widget.message.channelSid, widget.message.sid);
                    },
                ),
                MyOptionTile(
                    option: const Option(title: 'chat_set_reminder_3_hour'),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () async {
                        final DateTime now = DateTime.now();
                        _startTime = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second).add(const Duration(hours: 3));
                        await _createMsgReminder(_startTime, widget.message.channelSid, widget.message.sid);
                    },
                ),
                MyOptionTile(
                    option: const Option(title: 'chat_set_reminder_tomorrow_at_9'),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () async {
                        final DateTime now = DateTime.now();
                        _startTime = DateTime(now.year, now.month, now.day).add(const Duration(days: 1)).add(const Duration(hours: 9));
                        await _createMsgReminder(_startTime, widget.message.channelSid, widget.message.sid);
                    },
                ),
                MyOptionTile(
                    option: const Option(title: 'chat_set_reminder_pick_a_date_and_time'),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () async {
                        final bool isValidDateRange = await selectDate(context);
                        if (isValidDateRange) {
                            final bool isValidDateTime = await selectTime(context);
                            if (isValidDateTime)
                                await _createMsgReminder(_startTime, widget.message.channelSid, widget.message.sid);
                        }
                    }
                )
            ],
        );
    }

    Future<bool> selectDate(BuildContext context) async {
        final DateTime picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1997),
            lastDate: DateTime(2047),
        );
        if (picked != null) {
            setState(() {
                final DateTime now = DateTime.now();
                _startTime = DateTime(picked.year, picked.month, picked.day, now.hour, now.minute).add(const Duration(minutes: 5));
            });
            if (CalendarGlobals.isValidDate(_startTime))
                return true;
            else {
                /// if date is invalid, reset time and pop this message
                setState(() {
                    _startTime = null;
                });
                showOkDialog(
                    context,
                    title: 'chat_set_reminder_unable_to_schedule',
                    content: 'chat_set_reminder_unable_details_date'
                );
                return false;
            }
        }
        return false;
    }

    Future<bool> selectTime(BuildContext context) async {
        final TimeOfDay picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: _startTime.hour, minute: _startTime.minute),
        );
        if (picked != null) {
            setState(() {
                _startTime = DateTime(_startTime.year, _startTime.month, _startTime.day, picked.hour, picked.minute);
            });
            if (_startTime.isAfter(DateTime.now().add(const Duration(minutes: 2)))) {
                return true;
            }
            else {
                /// if date is invalid, reset time and pop this message
                setState(() {
                    _startTime = null;
                });
                showOkDialog(
                    context,
                    title: 'chat_set_reminder_unable_to_schedule',
                    content: 'chat_set_reminder_unable_details_time'
                );
                return false;
            }
        }
        return false;
    }
}