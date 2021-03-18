import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:organizer/icons_icons.dart';
import 'package:organizer/common/date_utils.dart';
import 'package:organizer/common/firebase_helper.dart';
import 'package:organizer/controllers/chat/channel_controller.dart';
import 'package:organizer/controllers/deeplink_controller.dart';
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/controllers/chat/chat_list_controller.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/member_model.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/models/deeplink/deeplink_model.dart';
import 'package:organizer/models/user/user_model.dart';
import 'package:organizer/services/analytics_service.dart';
import 'package:organizer/services/notification_service.dart';
import 'package:organizer/services/router_service.dart';
import 'package:organizer/views/calendar/views_components/calendar_globals.dart';
import 'package:organizer/views/chat/chat_list/add_contact.dart';
import 'package:organizer/views/chat/chat_group/chat_group_route.dart';
import 'package:organizer/views/chat/chat_private/chat_private_route.dart';
import 'package:organizer/views/chat/chat_self/chat_self_route.dart';
import 'package:organizer/views/components/floating_action_button.dart';
import 'package:organizer/views/components/nested_scroll_view.dart';
import 'package:organizer/views/components/oval_avatar.dart';
import 'package:organizer/views/components/quick_note_avatar.dart';
import 'package:organizer/views/components/progress_indicator.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/views/components/shadow_view.dart';
import 'package:organizer/views/components/user_name_view.dart';
import 'package:organizer/views/profile/channel_profile/channel_profile.dart';
import 'package:organizer/views/profile/user_profile/user_profile.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
    
    final String identity;
    
    ChatList({
        Key key,
        this.identity
    }): super(key: key);
    
    @override
    ChatListState createState() => ChatListState();
}

class ChatListState extends State<ChatList> with TickerProviderStateMixin, WidgetsBindingObserver {
    
    final ChatListController _chatListController = ChatListController();
    TabController _tabController;
    bool foundNotificationChannel = false;
    
    @override
    void initState() {
        _tabController = TabController(length: 1, initialIndex: 0, vsync: this);
        _chatListController.chatNotifier.navigate = _navigateToChannel;
        NotificationService.instance.configure(
            onMessage: (Map<String, dynamic> notificationMessage) async {
                print('on message: $notificationMessage');
                
                final String channelSid = notificationMessage['data']['channelSid'];
                final String uid = notificationMessage['data']['uid'];
                final String messageSid = notificationMessage['data']['messageSid'];
                Message message;
                try {
                    message = await Message.messageFromSid(channelSid, messageSid);
                } catch(err) {
                    message = null;
                    print(err);

                }
                final String channelType = notificationMessage['channelType'] ??
                    notificationMessage['data']['channelType'];

                AnalyticsService().sendAmplitudeAnalyticsEvent(
                    UserController.currentUser.uid ?? 'Unknown',
                    AmplitudeEvents.receiveMessage,
                    properties: <String,dynamic> {
                        'senderUid': uid,
                        'messageLength': message != null ? message.body.length : '',
                        'messageType': message != null ? message.attributes['type'] == 'bot' ? 
                            message.attributes['botMessageType'] : message.attributes['type'] : '',
                        'senderType': channelType
                    }
                );
            },
            onResume: (Map<String, dynamic> message) async {
                print('on resume: $message');
                final String channelType = message['channelType'] ?? message['data']['channelType'];
                final String channelSid = message['channelSid'] ?? message['data']['channelSid'];
                Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
                Navigator.of(globals.mainScaffold.currentContext).popUntil((Route<dynamic> route) => route.isFirst);
                _handleNotification(channelType, channelSid);
            },
            onLaunch: (Map<String, dynamic> message) async {
                print('on launch: $message');
                final String channelType = message['channelType'] ?? message['data']['channelType'];
                final String channelSid = message['channelSid'] ?? message['data']['channelSid'];
                _chatListController.setNotificationChannelDetails(channelType, channelSid);
            },
        );
        WidgetsBinding.instance.addObserver(this);
        super.initState();
    }
    
    @override
    void dispose() {
        WidgetsBinding.instance.removeObserver(this);
        super.dispose();
    }
    
    @override
    void didChangeAppLifecycleState(AppLifecycleState state) {
        if (state == AppLifecycleState.resumed) {
            FirebaseHelper.getFirebaseToken();
        }
    }
    
    Widget _chatList(List<Channel> channels, List<String> outsidePublisherOf) {
        final DeeplinkController deepLinkController = Provider.of<DeeplinkController>(context);
        print(channels[3].name);
        return Container(
            color: globals.Colors.multiTab,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(
                padding: const EdgeInsets.only(top: 12, bottom: 75),
                children: <Widget>[
                    ShadowView(
                        shadowColor: globals.Colors.shadow,
                        offset: const Offset(1, 1),
                        height: 73.0 * channels.length,
                        child: ListView.builder(
                            itemCount: channels.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (BuildContext context, int index) {
                                // this section is to handle clicking notification after app is killed
                                if (channels[index].info.sid == _chatListController.notificationChannelSid
                                    && !foundNotificationChannel) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _handleNotification(_chatListController.notificationChannelType, _chatListController.notificationChannelSid);
                                    });
                                }
                                // this section is to handle user coming from deeplinks
                                if (_chatListController.pinnedChannels != null && deepLinkController.startOrgId == null && deepLinkController.fromDeeplink) {
                                    final Deeplink deeplink = deepLinkController.deeplink;
                                    deepLinkController.fromDeeplink = false;
                                    
                                    if (deeplink.path == DeeplinkPath.userInvite ||
                                        deeplink.path == DeeplinkPath.groupInvite
                                    ) {
                                        WidgetsBinding.instance.addPostFrameCallback(
                                                (_) => Navigator.push(
                                                context,
                                                MaterialPageRoute<Widget>(
                                                    builder: (BuildContext context) => (deeplink.path == DeeplinkPath.userInvite)
                                                        ? UserProfile(uid: deepLinkController.deeplink.linkProperties['uid'])
                                                        : ChannelProfile(sid: deepLinkController.deeplink.linkProperties['channel_sid'])
                                                )
                                            )
                                        );
                                    }
                                }
                                // the reason why there is no checking of [hasData] is that we wanted to show
                                // the chat list before all the messages are fetched, to minimize the loading time
                                return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                        ChatListItem(
                                            key: Key(channels[index].info.sid),
                                            channel: channels[index],
                                            isOutsidePublisher: outsidePublisherOf.contains(channels[index].info.sid)
                                        ),
                                        if (index < channels.length - 1)
                                            const Divider(height: 1, color: globals.Colors.veryLightGray),
                                    ],
                                );
                            }
                        )
                    )
                ],
            )
        );
    }
    
    @override
    Widget build(BuildContext context) {
        return ValueListenableBuilder<FirebaseUser>(
            valueListenable: ValueNotifier<FirebaseUser>(UserController.currentUser),
            builder: (BuildContext context, FirebaseUser user, Widget child) {
                return ChangeNotifierProvider<ChatNotifier>.value(
                    value: _chatListController.chatNotifier,
                    child: Consumer2<ChatNotifier, CurrentUserController>(
                        builder: (BuildContext context, ChatNotifier chatNotifier, CurrentUserController currentUserController, Widget child) {
                            return MultiProvider(
                                providers: [
                                    StreamProvider<User>(
                                        create: (_) => UserController().watchUser,
                                        catchError: (BuildContext context, err){
                                            print(err);
                                            return null;
                                        },
                                    ),
                                    StreamProvider<List<Channel>>(
                                        create: (_) => UserController().watchChannels,
                                        catchError: (BuildContext context, err){
                                            print(err);
                                            return null;
                                        },
                                    )
                                ],
                                child: Consumer2<User, List<Channel>>(
                                    builder: (BuildContext context, User loggedUser, List<Channel> channels, Widget child) {
                                        if (loggedUser == null || channels == null ||
                                            channels.isEmpty || loggedUser.pinnedChannels == null)
                                            return MyProgressIndicator();
                                        if (loggedUser.pinnedChannels != null) {
                                            _chatListController.pinnedChannels = loggedUser.pinnedChannels;
                                            _chatListController.blockedUids = loggedUser.blocked;
                                            final List<String> pinnedChannels = loggedUser.pinnedChannels;
                                            final List<Channel> sortedChannels = channels;
                                            final List<String> outChannels = loggedUser.outsidePublisherOf ?? <String>[];
                                            sortedChannels.sort((Channel a, Channel b) {
                                                if (pinnedChannels.contains(a.info.sid) && pinnedChannels.contains(b.info.sid))
                                                    return a.name.compareTo(b.name);
                                                if (pinnedChannels.contains(a.info.sid))
                                                    return -1;
                                                if (pinnedChannels.contains(b.info.sid))
                                                    return 1;
                                                if (outChannels.contains(a.info.sid) && outChannels.contains(b.info.sid))
                                                    return a.name.compareTo(b.name);
                                                if (outChannels.contains(a.info.sid))
                                                    return 1;
                                                if (outChannels.contains(b.info.sid))
                                                    return -1;
                                                return b.lastDate.compareTo(a.lastDate);
                                            });
                                            _chatListController.channels = sortedChannels;
                                        }
                                        return Provider<List<String>>(
                                            create: (_) => loggedUser.outsidePublisherOf ?? <String>[],
                                            child: Scaffold(
                                                floatingActionButton: MyFloatingActionButton(
                                                    onPressed: () async {
                                                        final String channelSid = await showMyModalBottomSheet<String>(
                                                            context: context,
                                                            child: AddContact(),
                                                            fullScreen: true,
                                                        );
                                                        if (channelSid != null) {
                                                            final int index = _chatListController.channels.indexWhere(
                                                                (Channel c) => c.info.sid == channelSid
                                                            );
                                                            if (index >= 0) {
                                                                _navigateToChannel(_chatListController.channels[index]);
                                                            }
                                                        }
                                                    }
                                                ),
                                                body: Consumer<List<String>>(
                                                    builder: (BuildContext context, List<String> outsidePublisherOf, Widget child) {
                                                        return MyNestedScrollView(
                                                            bottom: PreferredSize(child: Container(), preferredSize: const Size.fromHeight(0)),
                                                            body: _chatListController.channels == null
                                                                ? MyProgressIndicator()
                                                                : _chatList(_chatListController.channels, outsidePublisherOf)
                                                        );
                                                    }
                                                )
                                            )
                                        );
                                    }
                                )
                            );
                        }
                    )
                );
            },
        );
    }
    
    /// Since Dashboard is a [IndexedStack] to enable effects like switching tab with different [Navigator] with perserving routes,
    /// We will only have to do the notification handling in [ChatList] once,
    /// instead of doing the configurations in [MainLibrary] / [CalendarOnboarding] / [MainCalendar] / [MyProfile]
    void _handleNotification(String channelType, String channelSid) {
        Provider.of<TabController>(context, listen: false).animateTo(0);
        setState(() {
            foundNotificationChannel = true;
        });
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
        }
    }
    
    void _navigateToChannel(Channel channel) {
        switch (channel.type) {
            case ChannelType.PRIVATE: {
                RouterService.instance.navigateTo(
                    ChatPrivateRoute.buildPath(channel.info.sid),
                    context: context
                );
            }
            break;
            case ChannelType.ORGANIZATION: {
                RouterService.instance.navigateTo(
                    ChatGroupRoute.buildPath(channel.info.sid),
                    context: context,
                );
            }
            break;
            case ChannelType.SELF: {
                RouterService.instance.navigateTo(
                    ChatSelfRoute.buildPath(channel.info.sid),
                    context: context
                );
            }
            break;
            case ChannelType.TOPIC:
                print('no TOPIC');
                break;
        }
    }
}

class ChatListTileIconBuilder extends StatelessWidget {
    
    const ChatListTileIconBuilder({
        this.channel,
        this.iconRadius = 21.0,
    });
    
    final Channel channel;
    final double iconRadius;
    
    @override
    Widget build(BuildContext context) {
        if (channel.type == ChannelType.SELF)
            return MyQuickNoteAvatar(
                chatListVersion: true,
                radius: iconRadius,
                backgroundColor: globals.Colors.veryLightGray,
                imagePadding: iconRadius / 10
            );
        return MyOvalAvatar.fromChannel(channel, iconRadius: iconRadius);
    }
}

class ChatListItem extends StatelessWidget {
    final Channel channel;
    final bool isOutsidePublisher;
    
    const ChatListItem({
        Key key,
        this.channel,
        this.isOutsidePublisher
    }) : super(key: key);
    
    @override
    Widget build(BuildContext context) {
        if (isOutsidePublisher)
            return MultiProvider(
                providers: [
                    StreamProvider<List<Message>>(
                        create: (_) => Message.watchOutsidePublisherMessages(channel.info.sid),
                        initialData: const <Message>[],
                    ),
                    Provider<List<Member>>(
                        create: (_) => const <Member>[],
                    ),
                    Provider<bool>(
                        create: (_) => isOutsidePublisher
                    )
                ],
                child: Consumer3<List<Message>, List<Member>, bool>(
                    builder: (BuildContext context, List<Message> messages, List<Member> members, bool isOutsidePublisher, Widget child) {
                        return ChatListItemDetails(channel);
                    },
                )
            );
        return MultiProvider(
            providers: [
                StreamProvider<List<Message>>.value(
                    value: Message.watchMessages(channel.info.sid),
                    initialData: const <Message>[],
                ),
                StreamProvider<List<Member>>(
                    create: (_) => Member.watchMembers(channel.info.sid),
                    initialData: const <Member>[],
                ),
                Provider<bool>(
                    create: (_) => isOutsidePublisher
                )
            ],
            child: Consumer3<List<Message>, List<Member>,  bool>(
                builder: (BuildContext context, List<Message> messages, List<Member> members, bool isOutsidePublisher, Widget child) {
                    return ChatListItemDetails(channel);
                },
            )
        );
    }
}

class ChatListItemDetails extends StatelessWidget {
    
    final Channel channel;
    final ChatListController _chatListController = ChatListController();
    
    ChatListItemDetails(this.channel);
    
    int myUnreadCount(BuildContext context) {
        if (channel.messages == null || channel.messages.isEmpty)
            return 0;
        final Member me = channel.members.firstWhere ((Member m) {
            return m.uid == UserController.currentUser.uid;
        }, orElse: () => null);
        
        int unreadCount = 0;
        /// In case of joinChannel,  me.lastConsumedMessageIndex is null (cloud function take some time to set it to channel's lastConsumedMessageIndex)
        /// During that time set it to channel's lastConsumedMessageIndex so that unreadCount is 0
        for(int i = 0; i< channel.lastConsumedMessageIndex - (me?.lastConsumedMessageIndex ?? channel.lastConsumedMessageIndex); i++){
            if (channel.messages[i].from!=UserController.currentUser.uid && ChatListController.validMessageCondition(channel.messages[i])){
                unreadCount++;
            }
        }
        if (channel.unreadCount != unreadCount) {
            channel.unreadCount = unreadCount;
            WidgetsBinding.instance.addPostFrameCallback((_) =>
                Provider.of<ChannelUnreadCount>(context,listen: false).updateChannelUnreadCount(channel.info.sid, unreadCount)
            );
        }
        return unreadCount;
    }
    
    String get time {
        if (channel.info.lastMessageDate != null) {
            if (Utils.isSameDay(channel.info.lastMessageDate, DateTime.now()))
                return CalendarGlobals.fullHourFormat.format(channel.info.lastMessageDate);
            if (Utils.isSameDay(channel.info.lastMessageDate, DateTime.now().subtract(const Duration(days: 1))))
                return allTranslations.text('chat_yesterday');
            if (channel.info.lastMessageDate.year == DateTime.now().year)
                return CalendarGlobals.abbrMonthDayFormat.format(channel.info.lastMessageDate);
            return CalendarGlobals.fullDateFormat.format(channel.info.lastMessageDate);
        }
        return '';
    }
    
    @override
    Widget build(BuildContext context) {
        final List<Message> messages = Provider.of<List<Message>>(context);
        final List<Member> members = Provider.of<List<Member>>(context);
        final bool isOutsidePublisher = Provider.of<bool>(context);
        if (isOutsidePublisher)
            channel.messages = messages.where((Message msg) => msg.from == 'outsidePublisher' || msg.type == 'bot').toList();
        else
            channel.messages = messages;
        channel.members = members;
        channel.isOutsidePublisher = isOutsidePublisher;
        int unreadCount = myUnreadCount(context);
        return Container(
            height: 72,
            alignment: Alignment.center,
            color: isOutsidePublisher ? globals.Colors.lightYellow : Colors.transparent,
            child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: ChatListTileIconBuilder(channel: channel),
                title: Row(
                    children: <Widget>[
                        Expanded(
                            child: Row(
                                children: <Widget>[
                                    Flexible(
                                        child: channel.type == ChannelType.PRIVATE
                                            ? UserNameView(
                                            channel.name,
                                            noDataChild: SizedBox(
                                                width: 15, height: 15,
                                                child: CircularIndicator(size: 15),
                                            )
                                        )
                                            : Text(
                                            channel.name ?? '',
                                            style: TextStyle(
                                                color: globals.Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                    ),
                                    if (_chatListController.pinnedChannels.contains(channel.info.sid))
                                        Container(
                                            width: 16, height: 16,
                                            margin: const EdgeInsets.symmetric(horizontal: 3),
                                            child: Center(
                                                child: Icon(
                                                    MyIcons.pin,
                                                    size: 12,
                                                    color: globals.Colors.orange,
                                                )
                                            ),
                                        ),
                                ],
                            ),
                        ),
                        if (!isOutsidePublisher)
                            Text(
                                time ?? '',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    color: globals.Colors.brownGray,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400
                                ),
                            )
                    ]
                ),
                subtitle: isOutsidePublisher ? null : Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                        children: <Widget>[
                            Expanded(
                                child: Text(
                                    channel.subtitle(context) ?? '',
                                    style: TextStyle(
                                        color: globals.Colors.brownGray,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                ),
                            ),
                            if (unreadCount > 0 && !isOutsidePublisher)
                                Container(
                                    height: 20,
                                    constraints: const BoxConstraints(minWidth: 20),
                                    padding: const EdgeInsets.symmetric(horizontal: 3),
                                    decoration: BoxDecoration(
                                        color: globals.Colors.orange,
                                        borderRadius: BorderRadius.circular(3)
                                    ),
                                    child: Center(
                                        child: Text(
                                            '$unreadCount',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600
                                            ),
                                        ),
                                    ),
                                )
                            else
                                Container(width: 5, height: 20,)
                        ],
                    ),
                ),
                onTap: () {
                    if (channel.info.friendlyName != null)
                        _navigateToChannel(channel, context, isOutsidePublisher);
                },
            ),
        );
    }
}

void _navigateToChannel(Channel channel, BuildContext context, bool isOutsidePublisher) {
    switch (channel.type) {
        case ChannelType.PRIVATE: {
            RouterService.instance.navigateTo(
                ChatPrivateRoute.buildPath(channel.info.sid),
                context: context
            );
        }
        break;
        case ChannelType.ORGANIZATION: {
            RouterService.instance.navigateTo(
                ChatGroupRoute.buildPath(channel.info.sid),
                context: context,
            );
        }
        break;
        case ChannelType.SELF: {
            RouterService.instance.navigateTo(
                ChatSelfRoute.buildPath(channel.info.sid),
                context: context
            );
        }
        break;
        case ChannelType.TOPIC:
            print('no TOPIC');
            break;
    }
}