import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:organizer/icons_icons.dart';
import 'package:organizer/controllers/library/child_library_controller.dart';
import 'package:organizer/controllers/user_controller.dart';
import 'package:organizer/models/chat/channel_model.dart';
import 'package:organizer/models/chat/member_model.dart';
import 'package:organizer/services/notification_service.dart';
import 'package:organizer/services/router_service.dart';
import 'package:organizer/views/chat/chat_group/prayer_points.dart';
import 'package:organizer/views/components/dialogs.dart';
import 'package:organizer/views/library/resource_library.dart';
import 'package:organizer/views/profile/channel_profile/channel_profile_route.dart';
import 'package:provider/provider.dart';
import 'package:organizer/globals.dart' as globals;
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/controllers/tab_controller.dart';
import 'package:organizer/views/chat/chat_components/chat_screen/chat_screen.dart';
import 'package:organizer/controllers/option.dart';
import 'package:organizer/views/chat/chat_group/group_event_preview.dart';
import 'package:organizer/views/chat/chat_group/group_create_event.dart';
import 'package:organizer/views/components/shadow_view.dart';

class ChatGroup extends ChatScreen {
    const ChatGroup({
        Key key,
        String channelSid
    }) : super(
        key: key,
        channelSid: channelSid
    );
    
    @override
    State createState() => ChatGroupState();
}

class ChatGroupState extends ChatScreenState<ChatGroup> {
    
    TaskTabController _taskTabController;
    
    @override
    List<Option> get floatingActions => <Option>[
        EventOptions.newEvent
    ];

    @override
    Future<void> onActionListItemPressed(Option option) async {
        if (option == EventOptions.newEvent) {
            await showMyModalBottomSheet<void>(
                context: context,
                child: GroupCreateEvent(),
                fullScreen: true
            );
        }
    }
    
    @override
    void initState() {
        NotificationService.instance.configure(
            onResume: (Map<String, dynamic> message) async {
                print('on resume: $message');
                final String channelType = message['channelType'] ?? message['data']['channelType'];
                final String channelSid = message['channelSid'] ?? message['data']['channelSid'];
                if (!ModalRoute.of(context).settings.name.contains(channelSid)) {
                    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
                    handleNotification(channelType, channelSid);
                } else {
                    Navigator.of(context).popUntil((Route<dynamic> route) => route.settings.name.contains(channelSid));
                }
            }
        );
        super.initState();
        _taskTabController = Provider.of<TaskTabController>(context, listen: false);
    }
    
    @override
    void dispose() {
        NotificationService.instance.configure();
        super.dispose();
    }

    Widget _highlightItem(int index) {
        return ShadowView(
            width: 250, height: 262,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    Image.asset(
                        'assets/images/sample_image.png',
                        width: 250, height: 150, fit: BoxFit.cover,
                    ),
                    Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                            'How To Boost Your Traffic Of Your Blog And Destroy The Competition',
                            style: TextStyle(
                                color: globals.Colors.black,
                                fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                        ),
                    ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                        child: Row(
                            children: <Widget>[
                                Icon(
                                    Icons.access_time, color: globals.Colors.black, size: 12,
                                ),
                                Container(width: 6),
                                Text(
                                    'Dec 22, 4:15pm',
                                    style: TextStyle(
                                        color: globals.Colors.black,
                                        fontSize: 12,
                                    ),
                                )
                            ],
                        ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                            children: <Widget>[
                                Icon(
                                    Icons.location_on, color: globals.Colors.black, size: 12,
                                ),
                                Container(width: 6),
                                Expanded(
                                    child: Text(
                                        'The Coffee House Cafe',
                                        style: TextStyle(
                                            color: globals.Colors.black,
                                            fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                    ),
                                )
                            ],
                        ),
                    )
                ],
            )
        );
    }

    Widget _highlightWidget() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                        allTranslations.text('library_highlight'),
                        style: TextStyle(
                            color: globals.Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700
                        ),
                    ),
                ),
                Container(
                    height: 268,
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListView.builder(
                        itemCount: 4,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                            return Padding(
                                padding: const EdgeInsets.only(left: 12, bottom: 6),
                                child: _highlightItem(index),
                            );
                        }
                    ),
                )
            ],
        );
    }

    Widget _eventItem(int index) {
        return InkWell(
            child: SizedBox(
                height: 62,
                child: Stack(
                    children: <Widget>[
                        Positioned(
                            left: 28, top: 0, right: 0, bottom: 0,
                            child: Container(
                                padding: const EdgeInsets.fromLTRB(30, 12, 12, 12),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(3)
                                ),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                        Text(
                                            'How To Boost Your Traffic ',
                                            style: TextStyle(
                                                color: globals.Colors.black,
                                                fontSize: 14
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                        Container(height: 6,),
                                        Row(
                                            children: <Widget>[
                                                Icon(
                                                    Icons.access_time, color: globals.Colors.brownGray, size: 12,
                                                ),
                                                Container(width: 6),
                                                Text(
                                                    'Dec 22, 4:15pm',
                                                    style: TextStyle(
                                                        color: globals.Colors.brownGray,
                                                        fontSize: 12,
                                                    ),
                                                ),
                                                Container(width: 16),
                                                Icon(
                                                    Icons.location_on, color: globals.Colors.brownGray, size: 12,
                                                ),
                                                Container(width: 6),
                                                Expanded(
                                                    child: Text(
                                                        'The Coffee House Cafe',
                                                        style: TextStyle(
                                                            color: globals.Colors.brownGray,
                                                            fontSize: 12,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                    ),
                                                )
                                            ],
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        Positioned(
                            left: 0, top: 6, bottom: 6,
                            child: ShadowView(
                                width: 45, height: 50,
                                offset: const Offset(0, 2),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                        Text(
                                            '02',
                                            style: TextStyle(
                                                color: globals.Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500
                                            ),
                                        ),
                                        Text(
                                            'Mon',
                                            style: TextStyle(
                                                color: globals.Colors.black,
                                                fontSize: 12,
                                            ),
                                        )
                                    ],
                                )
                            ),
                        )
                    ],
                ),
            ),
            onTap: () {
                _taskTabController.addWidget(GroupEventPreview());
                _taskTabController.showDialog(context);
            },
        );
    }

    Widget _eventList() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                        'December 2019',
                        style: TextStyle(
                            color: globals.Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700
                        ),
                    ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ListView.builder(
                        itemCount: 4,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                            return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _eventItem(index),
                            );
                        }
                    ),
                )
            ],
        );
    }

    Widget _eventWidget() {
        return ListView(
            children: <Widget>[
                _highlightWidget(),
                _eventList()
            ],
        );
    }
    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: globals.Colors.multiTab,
            appBar: AppBar(
                elevation: 0,
                leading: IconButton(
                    icon: Icon(
                        Icons.arrow_back,
                        color: globals.Colors.brownGray
                    ),
                    onPressed: () {
                        Navigator.of(context).maybePop();
                    },
                ),
                centerTitle: false,
                titleSpacing: 0,
                title: InkWell(
                    child: Row(
                        children: <Widget>[
                            Expanded(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                        Text(
                                            channel != null ? channel.name : '',
                                            style: TextStyle(
                                                color: globals.Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800
                                            )
                                        ),
                                        if (!isOutsidePublisher)
                                            Padding(
                                                padding: const EdgeInsets.only(top: 3),
                                                child: Text(
                                                    channel != null ? '${channel.memberUids.length} ' + allTranslations.text('chat_members') : '',
                                                    style: TextStyle(
                                                        color: globals.Colors.brownGray,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w400
                                                    )
                                                )
                                            )
                                    ],
                                ),
                            )
                        ],
                    ),
                    onTap: isOutsidePublisher ? null : () async {
                        await RouterService.instance.navigateTo(ChannelProfileRoute.buildPath(channel.info.sid), context: context);
                        if (!chatListController.channels.contains(channel))
                            Navigator.of(context).maybePop();
                    }
                ),
                actions: <Widget>[
                    if (!isOutsidePublisher)
                        PrayerButton(channel: channel),
                    IconButton(
                        icon: Icon(Icons.folder, color: globals.Colors.brownGray),
                        onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute<bool>(
                                    builder: (BuildContext context) => ResourceLibraryLoader(channel: channel),
                                ),
                            );
                        }
                    ),
                    if (!isOutsidePublisher)
                        IconButton(
                            icon: Icon(Icons.info_outline, color: globals.Colors.brownGray),
                            onPressed: () async {
                                await RouterService.instance.navigateTo(ChannelProfileRoute.buildPath(channel.info.sid), context: context);
                                if (!chatListController.channels.contains(channel))
                                    Navigator.of(context).maybePop();
                            }
                        )
                ],
            ),
        body: chatWidget()
        );
    }
}

class PrayerButton extends StatefulWidget {
    final Channel channel;

    const PrayerButton({Key key, this.channel}) : super(key: key);
    @override
    _PrayerButtonState createState() => _PrayerButtonState();
}

class _PrayerButtonState extends State<PrayerButton> {
    @override
    void initState() {    
        super.initState();
    }
    bool isRed = false;
    bool validPrExists = false;
    Widget prIconBuilder () => validPrExists ? Stack(
        alignment: Alignment.center,
        children: <Widget>[
            IconButton(
                icon: Icon(MyIcons.prayer, color: globals.Colors.brownGray),
                onPressed: () async {
                    showMyModalBottomSheet<String>(
                        context: context,
                        child: PrayerPoints(channel: widget.channel,),
                        fullScreen: true
                    );
                }
            ),
            if(isRed)
                Positioned(
                    top: 10, right: 5,
                    child: CircleAvatar(
                        radius: 5,
                        backgroundColor: globals.Colors.orange,
                        child: Container(),
                    ),
                )
        ],
    ) : Container();

    @override
    Widget build(BuildContext context) {
        return Consumer2<Channel, List<Member>>(
            builder:(BuildContext context, Channel channel, List<Member> members, Widget child) {
                if (members == null)
                    return prIconBuilder();
                final Member thisMember = members.firstWhere(
                    (Member member) => member.uid == UserController.currentUser.uid);
                
                final PrayerReminderAttributes prAttr = PrayerReminderAttributes.fromChannel(channel, thisMember);
                validPrExists = prAttr.validPrExists;
                final bool currentExist = prAttr.currentPrExist;
                final bool hasPrayedCurrentPr = prAttr.hasPrayedCurrentPr;
                final bool hasCurrentPrAns = prAttr.hasCurrentPrAns;
                final int stage = prAttr.prStage;
                isRed =  ((stage >= 2 && stage < 4 && !hasCurrentPrAns) 
                    || (stage == 4 && !hasPrayedCurrentPr)) && currentExist;
                return prIconBuilder();
            }
        );
    }
}

class PrayerReminderAttributes with ChangeNotifier{
    ///channel property
    final int prStage;
    /// channel property
    final bool currentPrExist;
    /// channel property
    final bool validPrExists;
    /// channel property
    final String currentPrId;
    /// member property
    final bool hasCurrentPrAns;
    /// member property
    final bool hasPrayedCurrentPr;

    PrayerReminderAttributes({
        this.prStage,
        this.currentPrExist, 
        this.validPrExists,
        this.currentPrId,
        this.hasCurrentPrAns,
        this.hasPrayedCurrentPr, 
    });
    factory PrayerReminderAttributes.fromChannel(Channel channel, Member thisMember) {
        final Map<String, dynamic> attr =  channel.info.attributes;
        final Map<String,dynamic> memberAttr = thisMember.attributes;
        return PrayerReminderAttributes(
            prStage: attr['prStage'] ?? 1,
            currentPrExist: channel.info.currentPrId!=null,
            validPrExists: attr['validPrExists'] ?? false,
            currentPrId: channel.info.currentPrId,
            hasCurrentPrAns: memberAttr['hasCurrentPrAns'] ?? false,
            hasPrayedCurrentPr: memberAttr['hasPrayedCurrentPr'] ?? false,
            
        );
    }
}