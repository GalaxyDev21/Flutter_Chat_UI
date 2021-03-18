
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:organizer/icons_icons.dart';
import 'package:organizer/controllers/chat/handlers/insert_to_scheduled_message_handler.dart';
import 'package:organizer/controllers/chat/scheduled_message_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/library/child_library_controller.dart';
import 'package:organizer/controllers/library/file_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/models/bible/verse_verse_model.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/pojo/file.dart';
import 'package:organizer/pojo/folder.dart';
import 'package:organizer/pojo/media_file.dart';
import 'package:organizer/views/calendar/views_components/calendar_globals.dart';
import 'package:organizer/views/chat/insert/insert_item.dart';
import 'package:organizer/views/chat/insert/polling_message/polling_message.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet_wrapper.dart';
import 'package:organizer/views/components/modal_bottom_sheet_navbar.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/views/components/progress_indicator.dart';
import 'package:organizer/views/library/add_bible.dart';
import 'package:organizer/views/library/file_selector/file_selector.dart';
import 'package:organizer/common/common_controller.dart';
import 'package:provider/provider.dart';
class ScheduleMessage extends StatefulWidget {

    ScheduleMessage({
        @required this.channel,
    });

    Channel channel;
    
    @override
    _ScheduleMessageState createState() => _ScheduleMessageState();
}

class _ScheduleMessageState extends State<ScheduleMessage> {

    DateTime _startTime;
    bool _isValidDateRange = true;
    bool hasClickedAnyElement = false;
    bool textIsEmpty = true;

    // attachments
    // file messages (images, videos)
    // document messages
    // bible messages

    InsertToScheduledMessageHandler _insertToScheduledMessageHandler;
    final ScheduledMessageController _scheduledMsgController = ScheduledMessageController();
    final TextEditingController _textController = TextEditingController();
    final ScrollController _scrollController = ScrollController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    @override
    void initState() {
        super.initState();
        _insertToScheduledMessageHandler = InsertToScheduledMessageHandler(_scheduledMsgController);
        _startTime = DateTime.now().add(const Duration(minutes: 5));
    }
    
    @override
    void dispose() {
        _textController.dispose();
        _scrollController.dispose();
        super.dispose();
    }
    
    bool allowConfirm(){
        return !textIsEmpty || _scheduledMsgController.attachments.isNotEmpty;
    }

    Widget navBar() {
        return MyModalSheetNavBar(
            rightButton: <Widget>[
                FlatButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                        allTranslations.text('library_confirm'),
                        style: TextStyle(
                            color: !allowConfirm() ? globals.Colors.veryLightGray : globals.Colors.orange,
                            fontWeight: FontWeight.w600
                        )
                    ),
                    onPressed: () async {
                        if (!allowConfirm())
                            return false;
                        if (_formKey.currentState.validate()) {
                            if (isScheduledAfter2Minutes(_startTime)) {
                                showActivityIndicator();
                                if (!textIsEmpty)
                                    _scheduledMsgController.onText(_textController.text);
                                _startTime = DateTime(_startTime.year, _startTime.month, _startTime.day, _startTime.hour, _startTime.minute);
                                final bool isScheduledMsg = await _scheduledMsgController.createScheduledMsg(_startTime, widget.channel.info.sid);
                                if (isScheduledMsg) {
                                    hideActivityIndicator();
                                    /// first pop out this [WillPopScope], then maybePop out of the bottom sheet (chat_insert)
                                    Navigator.of(context)..pop()..maybePop();
                                }
                            }
                            else {
                                hideActivityIndicator();
                                showOkDialog(
                                    context,
                                    title: 'chat_schedule_message_unable',
                                    content: 'chat_schedule_message_unable_description'
                                );
                            }
                        }
                        return true;
                    },
                )
            ]
        );
    }

    Widget textArea() {
        return Form(
            key: _formKey,
            child: Column(
                children: <Widget>[
                    Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        child: Row(
                            children: <Widget>[
                                FlatButton.icon(
                                    padding: const EdgeInsets.only(right: 24),
                                    icon: Icon(
                                        MdiIcons.calendarToday,
                                        color: globals.Colors.gray,
                                    ),
                                    label: Text(
                                        (CalendarGlobals.isToday(_startTime))
                                            ? allTranslations.text('calendar_today')
                                            : CalendarGlobals.fullDateWeekdayFormat.format(_startTime),
                                        style: TextStyle(
                                            color: _isValidDateRange ? globals.Colors.black : globals.Colors.red
                                        )
                                    ),
                                    onPressed: () => selectDate(context)
                                ),
                                const Spacer(),
                                FlatButton.icon(
                                    padding: const EdgeInsets.only(right: 24),
                                    icon: Icon(
                                        Icons.access_time,
                                        color: globals.Colors.gray
                                    ),
                                    label: Text(
                                        CalendarGlobals.fullHourFormat.format(_startTime),
                                        style: TextStyle(
                                            color: _isValidDateRange ? globals.Colors.black : globals.Colors.red
                                        )
                                    ),
                                    onPressed: () => selectTime(context),
                                ),
                            ],
                        ),
                    ),
                    const Divider(height: 1, color: globals.Colors.veryLightGray),
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: TextFormField(
                                controller: _textController,
                                autocorrect: true,
                                enableSuggestions: true,
                                decoration: InputDecoration(
                                    hintText: allTranslations.text('chat_schedule_message_text_hint'),
                                    hintStyle: const TextStyle(
                                        color: globals.Colors.lightGray
                                    ),
                                    border: InputBorder.none
                                ),
                                onChanged: (String value) {
                                    if (value.isNotEmpty)
                                        setState(() {textIsEmpty = false;});
                                    else
                                        setState(() {textIsEmpty = true;});
                                },
                                validator: (String value) {
                                    if (!allowConfirm())
                                        return 'Message should not be empty';
                                    return null;
                                },
                                maxLines: null,
                                cursorColor: Colors.black,
                            )
                        )
                    ),
                ],
            ),
        );
    }

    Widget addAttachmentBar() {
        // so that this bottom bar can display on top of keyboard
        return Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            decoration: const BoxDecoration(
                color: globals.Colors.multiTab,
                border: Border(
                    top: BorderSide(color: globals.Colors.veryLightGray)
                )
            ),
            child: Row(
                children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.image, color: globals.Colors.black),
                        onPressed: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                    builder: (BuildContext context) => InsertItem(
                                        channel: widget.channel,
                                        insertHandler: _insertToScheduledMessageHandler
                                    ),
                                ),
                            );
                            setState(() {});
                        },
                    ),
                    IconButton(
                        icon: Icon(Icons.insert_drive_file, color: globals.Colors.black),
                        onPressed: () async {
                            final File file = await showMyModalBottomSheet<File>(
                                context: context,
                                child: Provider<String>(
                                    create: (_) => null,
                                    child: FileSelector(),
                                ),
                                fullScreen: true
                            );
                            showActivityIndicator();
                            try {
                                final FileController fileController = FileController.of(file, outChannelSid: widget.channel.isOutsidePublisher ? widget.channel.info.sid : null);
                                File existing = await fileController.getChannelMirror(widget.channel.info.sid);
                                if (existing == null) {
                                    final ChildLibraryController libraryController = ChildLibraryController(outChannelSid: widget.channel.isOutsidePublisher ? widget.channel.info.sid : null);
                                    final Folder destinationFolder = await libraryController.getDefaultUploadFolder(widget.channel.info.sid);
                                    if (destinationFolder == null) {
                                        hideActivityIndicator();
                                        return null;
                                    }
                                    existing = await fileController.publish(widget.channel.info.sid, destinationFolder.id);
                                }
                                _scheduledMsgController.onFile(
                                    existing.id,
                                    (file is MediaFile) ? (file as MediaFile).mainType : 'document',
                                    existing.name
                                );
                                hideActivityIndicator();
                            }
                            catch (e) {
                                print(e);
                                hideActivityIndicator();
                            }
                            setState(() {});
                        },
                    ),
                    IconButton(
                        icon: Icon(MyIcons.bible, color: globals.Colors.black, size: 22,),
                        onPressed: () async {
                            await showMyModalBottomSheet<void>(
                                context: context,
                                child: AddBible(
                                    onComplete: (String book, int chapter, List<VerseVerseModel> chosenVerse) {
                                        if (_scheduledMsgController.onBible != null) {
                                            _scheduledMsgController.onBible(book, chapter, chosenVerse);
                                        }
                                    },
                                ),
                                fullScreen: true
                            );
                            setState(() {});
                        },
                    ),
                    IconButton(
                        icon: Icon(MyIcons.poll, color: globals.Colors.black, size: 22,),
                        onPressed: () async{
                            final Map<String, dynamic> pollingParams = await Navigator.push(
                                context,
                                MaterialPageRoute<Map<String, dynamic>>(
                                    builder: (BuildContext context) => PollingMessage(
                                        channel: widget.channel,
                                        isScheduledMsg: true,
                                    )
                                ),
                            );
                            _scheduledMsgController.onPoll(
                                pollingParams
                            );
                        }
                    ),
                    const Spacer(),
                    if (_scheduledMsgController.attachments.isNotEmpty)
                        InkWell(
                            child: Container(
                                padding: const EdgeInsets.fromLTRB(12, 3, 6, 3),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(color: globals.Colors.lightOrange, width: 2),
                                    color: globals.Colors.lightOrange.withOpacity(0.12)
                                ),
                                child: Row(
                                    children: <Widget>[
                                        Text(
                                            '${_scheduledMsgController.attachments.length}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: globals.Colors.orange
                                            ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(left: 3),
                                            child: Icon(Icons.attach_file, color: globals.Colors.orange, size: 22),
                                        )
                                    ],
                                ),
                            ),
                            onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                        builder: (BuildContext context) => ScheduleMessageAttachments(scheduledMsgController: _scheduledMsgController),
                                    ),
                                );
                                setState(() {});
                            },
                        )
                ],
            )
        );
    }

    Widget mainWidget() {
        return MyFullscreenBottomSheetWrapper(
            child: Column(
                children: <Widget>[
                    navBar(),
                    Expanded(
                        child: textArea(),
                    ),
                    addAttachmentBar()
                ],
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return WillPopScope(
            onWillPop: () async {
                bool isPop = true;
                if (_textController.text != ''
                || hasClickedAnyElement
                || _scheduledMsgController.attachments.isNotEmpty) {
                    isPop = await showCancelAndOkDialog(
                        context,
                        title: 'chat_schedule_message_discard_title',
                        content: 'chat_schedule_message_discard_content',
                        okText: 'general_discard'
                    );
                }
                return isPop == true;
            },
            child: mainWidget()
        );
    }

    bool isScheduledAfter2Minutes(DateTime _startTime) {
        final int difference = _startTime.difference(DateTime.now()).inMinutes;
        return difference > 1;
    }

    Future<void> selectDate(BuildContext context) async {
        hasClickedAnyElement = true;
        final DateTime picked = await showDatePicker(
            context: context,
            initialDate: _startTime,
            firstDate: DateTime(1997),
            lastDate: DateTime(2047),
        );
        if (picked != null) {
            setState(() {
                _startTime = picked;
                if (!CalendarGlobals.isValidDate(_startTime)) {
                    _isValidDateRange = false;
                }
                else
                    _isValidDateRange = true;
                return _startTime;
            });
        }
    }

    Future<void> selectTime(BuildContext context) async {
        hasClickedAnyElement = true;
        final TimeOfDay picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: _startTime.hour, minute: _startTime.minute),
        );
        if (picked != null) {
            setState(() {
                _startTime = DateTime(_startTime.year, _startTime.month, _startTime.day, picked.hour, picked.minute);
                if (!CalendarGlobals.isValidDate(_startTime)) {
                    _isValidDateRange = false;
                }
                else
                    _isValidDateRange = true;
            });
        }
    }
}

class ScheduleMessageAttachments extends StatefulWidget {
    final ScheduledMessageController scheduledMsgController;
    ScheduleMessageAttachments({this.scheduledMsgController});
    
    @override
    State<StatefulWidget> createState() {
        return _ScheduleMessageAttachmentsState();
    }
}

class _ScheduleMessageAttachmentsState extends State<ScheduleMessageAttachments> {
    @override
    Widget build(BuildContext context) {
        return MyFullscreenBottomSheetWrapper(
            child: Column(
                children: <Widget>[
                    const MyModalSheetNavBar(
                        mainTitle: '',
                    ),
                    Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.only(top: 12),
                            itemCount: widget.scheduledMsgController.attachments.length,
                            itemBuilder: (BuildContext context, int index) {
                                final String title =  widget.scheduledMsgController.attachments[index].attachmentName ??
                                    widget.scheduledMsgController.attachmentName(widget.scheduledMsgController.attachments[index]);
                                final IconData iconData = widget.scheduledMsgController.attachments[index].icon ?? widget.scheduledMsgController.icon(widget.scheduledMsgController.attachments[index]);
                                return Container(
                                    padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                                    decoration: const BoxDecoration(
                                        border: Border(bottom: BorderSide(color: globals.Colors.veryLightGray))
                                    ),
                                    child: Row(
                                        children: <Widget>[
                                            Padding(
                                                padding: const EdgeInsets.only(right: 12),
                                                child: Icon(
                                                    iconData,
                                                    color: iconData == null ? Colors.transparent : globals.Colors.gray,
                                                    size: 24
                                                )
                                            ),
                                            Expanded(
                                                child: Text(
                                                    CommonController.truncateWithEllipsis(30, title),
                                                    style: Theme.of(context).textTheme.body1,
                                                ),
                                            ),
                                            IconButton(
                                                icon: Icon(Icons.delete, color: globals.Colors.gray, size: 20),
                                                onPressed: () {
                                                    widget.scheduledMsgController.removeAttachment(widget.scheduledMsgController.attachments[index]);
                                                    setState(() {});
                                                    if (widget.scheduledMsgController.attachments.isEmpty)
                                                        Navigator.of(context).maybePop();
                                                },
                                            )
                                        ],
                                    ),
                                );
                            }
                        ),
                    )
                ],
            )
        );
    }
}