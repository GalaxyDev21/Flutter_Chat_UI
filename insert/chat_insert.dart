import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:organizer/icons_icons.dart';
import 'package:organizer/controllers/chat/prayer_reminder_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/library/child_library_controller.dart';
import 'package:organizer/controllers/library/file_controller.dart';
import 'package:organizer/controllers/option.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/bible/verse_verse_model.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/handlers/chat_insert_handler.dart';
import 'package:organizer/models/chat/member_model.dart';
import 'package:organizer/models/chat/prayer_reminder_model.dart';
import 'package:organizer/models/user/user_model.dart';
import 'package:organizer/pojo/file.dart';
import 'package:organizer/pojo/folder.dart';
import 'package:organizer/pojo/media_file.dart';
import 'package:organizer/views/chat/insert/insert_item.dart';
import 'package:organizer/views/chat/insert/prayer_reminder/prayer_reminder.dart';
import 'package:organizer/views/chat/insert/polling_message/polling_message.dart';
import 'package:organizer/views/chat/insert/schedule_message.dart';
import 'package:organizer/views/components/fullscreen_bottom_sheet.dart';
import 'package:organizer/views/components/option_tile.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/views/components/progress_indicator.dart';
import 'package:organizer/views/library/add_bible.dart';
import 'package:organizer/views/library/file_selector/file_selector.dart';
import 'package:provider/provider.dart';

class ChatInsert extends MyFullscreenBottomSheet {

    ChatInsert({
        @required this.channel,
        @required this.insertHandler,
        @required this.isAdmin,
    });

    Channel channel;
    ChatInsertHandler insertHandler;
    final bool isAdmin;
    @override
    State<ChatInsert> createState() => ChatInsertState();
}

class ChatInsertState extends MyFullscreenBottomSheetState<ChatInsert> {
    
    PrayerReminderController prayerReminderController;
    
    @override
    void initState() {
        super.initState();
        mainTitle = allTranslations.text('chat_insert_to_chat');
        prayerReminderController = PrayerReminderController(widget.channel.info.sid);
    }
    
    @override
    Widget mainWidget() {
        return ListView(
            children: <Widget>[
                const Padding(padding: EdgeInsets.symmetric(vertical: 6)),
                MyOptionTile(
                    option: Option(title: 'library_photo_video', icon: MdiIcons.image),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () async {
                        final bool isInserted = await Navigator.of(context).push(
                            MaterialPageRoute<bool>(
                                builder: (BuildContext context) {
                                    return InsertItem(
                                        channel: widget.channel,
                                        insertHandler: widget.insertHandler,
                                    );
                                }
                            )
                        );
                        if (isInserted == true)
                            Navigator.of(context).maybePop();
                    }
                ),
                MyOptionTile(
                    option: Option(title: 'library_bible_verse', icon: MyIcons.bible),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) {
                                    return AddBible(
                                        onComplete: (String book, int chapter, List<VerseVerseModel> verses) {
                                            if (widget.insertHandler != null) {
                                                widget.insertHandler.onSendBible(book, chapter, verses);
                                            }
                                            Navigator.maybePop(context);
                                        },
                                    );
                                }
                            )
                        );
                    }
                ),
                MyOptionTile(
                    option: Option(title: 'library_files_from', icon: Icons.insert_drive_file),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () async {
                        final File file = await Navigator.of(context).push(
                            MaterialPageRoute<File>(
                                builder: (BuildContext context) {
                                    return Provider<String>(
                                        create: (_) => null,
                                        child: FileSelector(),
                                    );
                                }
                            )
                        );
                        if (file != null) {
                            // getting the channelTitle
                            String channelTitle;
                            if (widget.channel.type == ChannelType.PRIVATE) {
                                final Member member = widget.channel.members.firstWhere((Member member) => member.uid != UserController.currentUser.uid, orElse: () => null);
                                final String otherUseruid = member?.uid;

                                final User otherUser = Provider.of<UsersInfo>(context,listen: false).user(otherUseruid);
                                channelTitle = otherUser?.displayName;
                            }
                            else {
                                channelTitle = widget.channel.name;
                            }
                            // popping out a confirmation dialog showing the filename and the name of the channel to be inserted
                            final bool confirmed = await showDialog<bool>(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext dialogContext) {
                                    return InsertDocumentDialog(
                                        documentName: file.name,
                                        channelTitle: channelTitle
                                    );
                                }
                            );
                            if (confirmed) {
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
                                    if (widget.insertHandler != null)
                                        widget.insertHandler.onSendFile(
                                            existing.id,
                                            (file is MediaFile) ? (file as MediaFile).mainType : 'document',
                                            existing.name
                                        );
                                    hideActivityIndicator();
                                    Navigator.maybePop(context);
                                }
                                catch (e) {
                                    hideActivityIndicator();
                                    print(e);
                                }
                            }
                        }
                    }
                ),
                MyOptionTile(
                    option: Option(title: 'chat_schedule_message', icon: MyIcons.timer),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) {
                                    return ScheduleMessage(
                                        channel: widget.channel,
                                    );
                                }
                            )
                        );
                    }
                ),
                if (widget.channel.type == ChannelType.ORGANIZATION && (widget.isAdmin || widget.channel.isOutsidePublisher))
                    MyOptionTile(
                        option: Option(
                            title: 'chat_prayer_points_title',
                            icon: MyIcons.prayer
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        onPressed: () async {
                            final PrayerReminderProperties properties = await prayerReminderController.reminderExists();
                            if (properties == null) {
                                Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                        builder: (BuildContext context) {
                                            return PrayerReminder(widget.channel.info.sid);
                                        }
                                    )
                                );
                            } else {
                                final bool result = await showCancelAndOkDialog(
                                    context,
                                    title: 'prayer_reminder_active_title',
                                    content: 'prayer_reminder_active',
                                    okText: 'prayer_reminder_stop_button',
                                    cancelText: 'library_cancel'
                                );
                                if (result == true) {
                                    showActivityIndicator();
                                    try{
                                        await prayerReminderController.stopPrayerReminder();
                                        hideActivityIndicator();
                                    }
                                    catch(e) {
                                        print(e);
                                        hideActivityIndicator();
                                    }
                                }
                            }
                        }
                    ),
                if (widget.channel.type == ChannelType.ORGANIZATION)
                    MyOptionTile(
                        option: Option(title: 'chat_polling_message', icon: MyIcons.poll),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        onPressed: () {
                            Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                    builder: (BuildContext context) {
                                        return PollingMessage(
                                            channel: widget.channel,
                                        );
                                    }
                                )
                            );
                        }
                    ),
            ],
        );
    }

}