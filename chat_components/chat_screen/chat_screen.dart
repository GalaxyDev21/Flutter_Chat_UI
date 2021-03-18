import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:organizer/controllers/tab_controller.dart';
import 'package:organizer/models/bible/book_model.dart';
import 'package:organizer/services/router_service.dart';
import 'package:organizer/views/chat/chat_components/bible_tab_preview.dart';
import 'package:organizer/views/chat/chat_components/chat_screen/chat_screen_input_field.dart';
import 'package:organizer/views/chat/chat_components/chat_screen/date_splitter_chat_screen.dart';
import 'package:organizer/views/chat/chat_group/chat_group_route.dart';
import 'package:organizer/views/chat/chat_private/chat_private_route.dart';
import 'package:organizer/views/chat/chat_self/chat_self_route.dart';
import 'package:organizer/views/chat/insert/set_message_reminder.dart';
import 'package:organizer/views/profile/channel_profile/channel_profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:organizer/controllers/chat/polling_message_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/chat/handlers/chat_insert_handler.dart';
import 'package:organizer/models/chat/handlers/chat_message_builder_handler.dart';
import 'package:organizer/views/chat/block_report_file.dart';
import 'package:organizer/views/chat/chat_components/bottom_list_count.dart';
import 'package:organizer/views/chat/chat_components/chat_indexed_list_view.dart';
import 'package:organizer/views/chat/chat_components/chat_message_builder.dart';
import 'package:organizer/views/chat/chat_components/chat_screen/welcome_message.dart';
import 'package:organizer/views/chat/chat_components/chat_screen/chat_read_by.dart';
import 'package:organizer/views/components/flush_bar.dart';
import 'package:organizer/views/components/user_name_view.dart';
import 'package:organizer/views/profile/user_profile/user_profile.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/views/library/library.dart';
import 'package:organizer/controllers/option.dart';
import 'package:organizer/controllers/library/report_controller.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/common/common_controller.dart';
import 'package:organizer/models/bible/verse_verse_model.dart';
import 'package:organizer/views/chat/chat_components/bubble_builder.dart';
import 'package:organizer/views/chat/insert/insert_to.dart';
import 'package:provider/provider.dart';

abstract class ChatScreen extends Library {
    const ChatScreen({
        Key key,
        this.channelSid
    }) : super(key: key);
    
    final String channelSid;
}

abstract class ChatScreenState<T extends ChatScreen> extends LibraryState<T> implements ChatMessageBuilderHandler, ChatInsertHandler {

    Map<String, dynamic> replyTo;
    
    File imageFile;
    TextEditingController textEditingController;
    ChatListController chatListController;
    UserController userController;
    TabController tabController;
    final ChatIndexedScrollController chatIndexedScrollController = ChatIndexedScrollController(0, 0);
    final ScrollController scrollController = ScrollController();
    
    FocusNode _focusNode;
    
    Channel channel;
    List<Message> messages = <Message>[];
    List<int> readCount;
    final Map<String, DocumentSnapshot> _fileCache = <String, DocumentSnapshot>{};
    final Map<String, String> _urlCache = <String, String>{};
    
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    
    bool isOutsidePublisher = false;
    
    @override
    void initState() {
        super.initState();
        chatListController = ChatListController();
        textEditingController = TextEditingController();
        userController = UserController();
        _focusNode = FocusNode();
        channel = chatListController.channels.firstWhere((Channel c) {
            return c.info.sid == widget.channelSid;
        }, orElse: () => null);
        /// make false to [isOutsidePublisher] to handle notifications coming from newly created channel
        isOutsidePublisher = channel.isOutsidePublisher ?? false;
        tabController = Provider.of<TabController>(context, listen: false);
    }
    
    @override
    void dispose() {
        super.dispose();
    }

    void handleNotification(String channelType, String channelSid) {
        Provider.of<TabController>(context, listen: false).animateTo(0);
        switch (channelType) {
            case 'private': {
                RouterService.instance.navigateTo(
                    ChatPrivateRoute.buildPath(channelSid),
                    context: context
                );
            }
            break;
            case 'organization': {
                RouterService.instance.navigateTo(
                    ChatGroupRoute.buildPath(channelSid),
                    context: context
                );
            }
            break;
            case 'self': {
                RouterService.instance.navigateTo(
                    ChatSelfRoute.buildPath(channelSid),
                    context: context
                );
            }
            break;
        }
    }
    
    Future<void> onSendMessage(String body, {Map<String, dynamic> attributes, String channelSid, bool isOutsidePublisher}) async {
        attributes = ChatListController.setReplyToAttributes(attributes, replyTo);
        if (body != null && body.trim() != '') {
            textEditingController.clear();
            channel.typingMessage = '';
            setState(() {
                replyTo = null;
            });
            await chatListController.sendMessage(channelSid ?? channel.info.sid, body, 'text', attributes, isOutsidePublisher);
        }
    }
    
    Future<Option> _getBottomSheet(int index) {
        if (ChatListController.isDeleted(messages[index].attributes))
            return null;
        if (ChatListController.isBlocked(messages[index].attributes)) {
            if (channel.isAdmin()) {
                return showMyModalBottomSheetWithOptions(
                    context: context,
                    header: Option(title: BlockedOptions.blocked.title, icon: BlockedOptions.blocked.icon, multiLocale: false),
                    options: <Option>[ChatActions.unblock]
                );
            }
            if (messages[index].from == UserController.currentUser.uid) {
                return showMyModalBottomSheetWithOptions(
                    context: context, 
                    header: Option(title: BlockedOptions.blocked.title, icon: BlockedOptions.blocked.icon, multiLocale: false),
                    options: <Option>[ChatActions.delete]
                );
            }
            return null;
        }
        if (ChatListController.isHidden(messages[index].attributes)) {
            return showMyModalBottomSheetWithOptions(
                context: context,
                header: Option(title: BlockedOptions.hidden.title, icon: BlockedOptions.hidden.icon, multiLocale: false),
                options: <Option>[ChatActions.show]
            );
        }
        final BubbleBuilder bubbleBuilder = BubbleBuilder.fromAttributes(
            messages[index].from == UserController.currentUser.uid,
            messages[index].body,
            messages[index].attributes,
            null,
            outChannelSid: channel.info.sid,
            channelSid: channel.info.sid,
        );
        return bubbleBuilder.showBottomSheet(context);
    }

    Widget chatWidget() {
        messages = Provider.of<List<Message>>(context);
        if (messages == null)
            return Container();
        if (isOutsidePublisher)
            messages = messages.where((Message msg) => msg.from == 'outsidePublisher' || msg.type == 'bot').toList();
        else
            messages = messages;
        final Map<String, dynamic> attributes = replyTo != null ? replyTo['attributes'] : null;
        return MultiProvider(
            providers: [
                Provider<Map<String, DocumentSnapshot>>.value(value: _fileCache),
                Provider<Map<String, String>>.value(value: _urlCache),
                ChangeNotifierProvider<ChatIndexedScrollController>.value(value: chatIndexedScrollController)
            ],
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    if (isOutsidePublisher)
                        Container(
                            height: 40,
                            color: globals.Colors.lightYellow,
                            alignment: Alignment.center,
                            child: Text(
                                allTranslations.text('chat_as_outside'),
                                style: const TextStyle(
                                    color: globals.Colors.black,
                                    fontSize: 14,
                                ),
                            ),
                        ),
                    DateSplitterOnChatScreen(messages: messages),
                    Expanded(
                        child: Stack(
                            children: <Widget>[
                                GestureDetector(
                                    child: ChatIndexedListView.builder(
                                        itemBuilder: (BuildContext context, int index) {
                                            return (index == messages.length)
                                                ? WelcomeMessage(channel)
                                                : Column(
                                                    children: <Widget>[
                                                        BubbleItem(
                                                            index: index,
                                                            channel: channel,
                                                            messages: messages,
                                                            readCount: messages[index].from == UserController.currentUser.uid && !isOutsidePublisher
                                                                ? messages[index].readBy.length
                                                                : 0,
                                                            builderHandler: this,
                                                            tabController: tabController,
                                                        ),
                                                    ],
                                                );
                                        },
                                        itemCount: messages != null ? messages.length + 1 : 0,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        reverse: true,
                                        scrollController: scrollController,
                                    ),
                                    onTap: () {
                                        setState((){
                                            _focusNode.unfocus();
                                        });
                                    },
                                ),
                                BottomListCount(
                                    channel: channel,
                                    isOutsidePublisher: isOutsidePublisher,
                                    chatListController: chatListController,
                                ),
                            ],
                        ),
                    ),
                    if (replyTo != null)
                        Container(
                            color: globals.Colors.veryLightPink,
                            padding: const EdgeInsets.fromLTRB(12, 6, 0, 6),
                            child: IntrinsicHeight(
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                        Container(width: 4, color: globals.Colors.lightGray),
                                        Container(width: 6),
                                        Expanded(
                                            child: BubbleBuilder.fromAttributes(
                                                replyTo['from'] == UserController.currentUser.uid,
                                                replyTo['body'],
                                                attributes,
                                                null,
                                                channelSid: channel.info.sid
                                            ).replyToBuilder(
                                                context,
                                                UserNameView(
                                                    replyTo['from'],
                                                    textStyle: TextStyle(
                                                        color: globals.Colors.black,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 12
                                                    )
                                                )
                                            ),
                                        ),
                                        IconButton(
                                            icon: Icon(
                                                Icons.cancel,
                                                color: globals.Colors.brownGray,
                                                size: 20,
                                            ),
                                            onPressed: () {
                                                setState(() {
                                                    replyTo = null;
                                                });
                                            },
                                        )
                                    ],
                                ),
                            ),
                        ),
                    ChatScreenInputField(
                        replyTo: replyTo,
                        focusNode: _focusNode,
                        textEditingController: textEditingController,
                        channel: channel,
                        chatInsertHandler: this,
                        onPressed: () {
                            onSendMessage(
                                textEditingController.text,
                                attributes: <String, dynamic> {
                                    'type': MessageTypes.text,
                                },
                                isOutsidePublisher: isOutsidePublisher
                            );
                            scrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
                        },
                    )
                ],
            )
        );
    }

    /// Bubble Message Handling
    
    @override
    void onReply(int index) {
        setState(() {
            replyTo = ChatListController.createReplyToFromMessage(messages[index]);
        });
        WidgetsBinding.instance.addPostFrameCallback((_){
            _focusNode.unfocus();
            FocusScope.of(context).requestFocus(_focusNode);
        });
    }

    @override
    void onTapReply(int index, {String messageSid}) {
        if (messageSid !=null) {
            final int mIndex =messages.indexWhere((Message message) => message.sid == messageSid);
            chatIndexedScrollController.jumpToIndex(mIndex);
        }
        final int mIndex = ChatListController.getJumpToIndex(messages, index);
        if (mIndex != -1)
            chatIndexedScrollController.jumpToIndex(mIndex);
    }

    @override
    Future<void> onUser(int index) async {
        final String uid = messages[index].from;
        if (uid != UserController.currentUser.uid) {
            await Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (BuildContext context) => UserProfile(
                        uid: uid,
                    ),
                ),
            );
        }
    }

    @override
    Future<void> onJoin(String channelSid) async {
        await chatListController.joinChannel(channelSid);
        setState(() {});
    }

    @override
    void onReadCount(int index) {
        final List<String> uids = messages[index].readBy;
        if (uids.isNotEmpty)
            showMyModalBottomSheet<void>(
                context: context,
                child: ChatReadBy(
                    uids: uids
                ),
                fullScreen: true,
                useRootNavigator: false
            );
    }

    @override
    Future<void> onLink(String url) async {
        if (await canLaunch(url)) {
            launch(url);
        }
    }

    @override
    Future<void> onBibleLink(Book book) async {
        Provider.of<TaskTabController>(context, listen: false).addWidget(BibleTabPreview(book: book));
        Provider.of<TaskTabController>(context, listen: false).showDialog(context);
    }

    @override
    Future<void> onLongPress(int index) async {
        final int messageIndex = index;
        final Option selectedOption = await _getBottomSheet(index);
        switch (selectedOption) {
            case ChatActions.block: {
                final List<Option> result = await showMyModalBottomSheet<List<Option>>(
                    context: context,
                    child: BlockReportFile(
                        isAdmin: channel.isAdmin(),
                    ),
                    fullScreen: true
                ) ?? <Option>[];
                if (result.contains(BlockOptions.hide)) {
                    chatListController.hideMessage(channel.info.sid, messageIndex, true);
                }
                if (result.contains(BlockOptions.blockFile)) {
                    chatListController.blockMessage(channel.info.sid, messageIndex, true);
                }
                break;
            }
            case ChatActions.delete: {
                chatListController.deleteMessage(channel.info.sid, messageIndex);
                break;
            }
            case ChatActions.unblock: {
                chatListController.blockMessage(channel.info.sid, messageIndex, false);
                break;
            }
            case ChatActions.show: {
                chatListController.hideMessage(channel.info.sid, messageIndex, false);
                break;
            }
            case ChatActions.copyText: {
                if (messages[index].type == MessageTypes.bible) {
                    Clipboard.setData(ClipboardData(text: CommonController.getBibleText(
                        messages[index].body,
                        messages[index].attributes['chapter'].toInt(),
                        (messages[index].attributes['verses'] as List<dynamic>).map((dynamic e) => Map<String, dynamic>.from(e)).toList()
                    )));
                } else {
                    Clipboard.setData(ClipboardData(text: messages[index].body));
                }
                final Flushbar<void> flushBar = MyFlushbar<void>.info(
                    key: _formKey,
                    title: allTranslations.text('library_copy_successful')
                );
                flushBar.show(globals.mainScaffold.currentContext);
                break;
            }
            case ChatActions.insert: {
                showMyModalBottomSheet<String>(
                    context: context,
                    child: InsertTo(
                        onSend: (String channelSid) {
                            final Map<String, dynamic> attributes = Map<String, dynamic>.from(messages[index].attributes);
                            attributes.remove('replyTo');
                            onSendMessage(
                                messages[index].body,
                                attributes: attributes,
                                channelSid: channelSid,
                                isOutsidePublisher: isOutsidePublisher
                            );
                        },
                    ),
                    fullScreen: true
                );
                break;
            }
            case ChatActions.reply: {
                onReply(index);
                break;
            }
            case ChatActions.remind: {
                showMyModalBottomSheet<String>(
                    context: context,
                    child: SetMessageReminder(
                        message: messages[index],
                    ),
                    fullScreen: true
                );
                break;
            }
            case PollingActions.stop: {
                final bool isStop = await showCancelAndOkDialog(
                    context,
                    title: 'chat_polling_message_stop_poll_title',
                    content: 'chat_polling_message_stop_poll_content',
                    okText: 'chat_polling_message_stop_poll_big'
                );
                if (isStop)
                    await PollingMessageController(channelSid: channel.info.sid).stopPoll(messages[index].attributes['pollingId']);
                break;
            }
        }
    }

    @override
    Future<void> onGroupProfile(String channelSid) async {
        Navigator.push(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => ChannelProfile(
                    sid: channelSid
                ),
            ),
        );
    }

    // Chat Message Handle
    
    @override
    Future<void> onSendFile(String id, String type, String filename) async {
        onSendMessage(
            id,
            attributes: <String, dynamic>{
                'type': type,
                'filename': filename,
            },
            isOutsidePublisher: isOutsidePublisher
        );
    }

    @override
    void onSendBible(String book, int chapter, List<VerseVerseModel> chosenVerse) {
        onSendMessage(
            book,
            attributes: <String, dynamic>{
                'type': MessageTypes.bible,
                'chapter': chapter,
                'verses': chosenVerse.map((VerseVerseModel verse) => verse.toJson()).toList(),
            },
            isOutsidePublisher: isOutsidePublisher
        );
    }
}