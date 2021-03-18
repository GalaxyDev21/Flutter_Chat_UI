
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:organizer/controllers/library/report_controller.dart';
import 'package:organizer/controllers/user_controller.dart';

import 'package:organizer/globals.dart' as globals;
import 'package:organizer/controllers/language_controller.dart';
import 'package:organizer/models/bible/book_model.dart';
import 'package:organizer/models/chat/handlers/chat_message_builder_handler.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/chat/chat_components/bubble_builder.dart';

class Bubble extends StatefulWidget {
    Bubble({
        @required this.message,
        this.isLast = true,
        this.readCount = 0,
        this.outChannelSid,
        this.channelSid,
        this.index,
        this.builderHandler,
        this.isHighlight = false
    });
    
    final Message message;
    final bool isLast;
    final int readCount;
    final String outChannelSid;
    final String channelSid;
    final int index;
    final ChatMessageBuilderHandler builderHandler;
    final bool isHighlight;

    @override
    State<StatefulWidget> createState() => BubbleState();
}

class BubbleState extends State<Bubble> with BubbleBuilderHandler {
    @override
    void initState() {
        super.initState();
        
    }

    Widget _bubbleItem(BuildContext context) {
        final BubbleBuilder _bubbleBuilder = BubbleBuilder.fromAttributes(
            widget.message.from == UserController.currentUser?.uid,
            widget.message.body,
            widget.message.attributes,
            this,
            outChannelSid: widget.outChannelSid,
            channelSid: widget.channelSid
        );
        return _bubbleBuilder != null
            ? _bubbleBuilder.realBuilder(context)
            : Container(width: 200, height: 40, color: Colors.white);
    }
    BoxDecoration highlightedDecoration = BoxDecoration(
        // boxShadow: [BoxShadow(
        //     color: const Color(0x24000000),
        //     // offset: Offset(0,6),
        //     blurRadius: 6,
        //     spreadRadius: 5
        // )]
        boxShadow: kElevationToShadow[6]
    );
    
    @override
    Widget build(BuildContext context) {
        
        BoxDecoration boxDecoration = BoxDecoration(
            boxShadow: <BoxShadow>[
                BoxShadow(
                    color: globals.Colors.shadow,
                    blurRadius: 3,
                    offset: const Offset(1, 1)
                )
            ],
            borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(0),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(widget.isLast ? 16 : 0),
                bottomRight: const Radius.circular(16)
            )
        );
        if (widget.isHighlight)
            boxDecoration = boxDecoration.copyWith(boxShadow: highlightedDecoration.boxShadow); 
        return Row(
            children: <Widget>[
                Flexible(
                    child: Stack(
                        children: <Widget>[
                            AnimatedContainer(
                                curve: Curves.easeInOut,
                                duration: const Duration(milliseconds: 800),
                                margin: 
                                    widget.isHighlight && widget.readCount > 0 ?
                                        const EdgeInsets.fromLTRB (2,0,2,8) 
                                    : widget.isHighlight ?
                                        const EdgeInsets.fromLTRB(2,0,0,0)
                                    : widget.readCount > 0 ?
                                        const EdgeInsets.only(bottom:8)
                                    : EdgeInsets.zero,
                                
                                decoration: boxDecoration,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(0),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(widget.isLast ? 16 : 0),
                                        bottomRight: const Radius.circular(16)
                                    ),
                                    child: 
                                    Container(
                                        color: Colors.white,
                                        constraints: widget.readCount > 0 ? BoxConstraints(
                                            minWidth: widget.readCount == 1 ? 40.0 : (12 + 8 + 9 + 2 + 12 + widget.readCount.toString().length.toDouble() * 8)
                                        ) : null,
                                        child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            child: _bubbleItem(context),
                                            onLongPress: () => widget.builderHandler.onLongPress(widget.index),
                                        ),
                                        // child:Container()
                                    ),
                                ),
                            ),
                            if (widget.readCount > 0)
                                Positioned(
                                    right: 12, bottom: 0,
                                    child: InkWell(
                                        child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(horizontal: widget.readCount > 1 ? 4 : 0),
                                            constraints: const BoxConstraints(
                                                minWidth: 16, minHeight: 16
                                            ),
                                            decoration: BoxDecoration(
                                                color: globals.Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: globals.Colors.lightWhite)
                                            ),
                                            child: Row(
                                                children: <Widget>[
                                                    Icon(
                                                        Icons.check,
                                                        size: 9,
                                                        color: globals.Colors.brownGray,
                                                    ),
                                                    if (widget.readCount > 1)
                                                        Padding(
                                                            padding: const EdgeInsets.only(left: 2),
                                                            child: Text(
                                                                '${widget.readCount}',
                                                                style: TextStyle(
                                                                    fontSize: 11,
                                                                    color: globals.Colors.brownGray
                                                                )
                                                            ),
                                                        ),
                                                ],
                                            ),
                                        ),
                                        onTap: () => widget.builderHandler.onReadCount(widget.index),
                                    ),
                                )
                        ],
                    ),
                )
            ],
        );
    }
    
    @override
    void onLink(String url) => widget.builderHandler.onLink(url);

    @override
    void onBibleLink(Book book) => widget.builderHandler.onBibleLink(book);

    @override
    void onReply() => widget.builderHandler.onReply(widget.index);

    @override
    void onTapReply() => widget.builderHandler.onTapReply(widget.index);

    @override
    Future<void> onJoin(String channelSid) => widget.builderHandler.onJoin(channelSid);
    
    @override
    void onGroupProfile(String channelSid) => widget.builderHandler.onGroupProfile(channelSid);
}

class AcceptBubble extends StatelessWidget {
    AcceptBubble({
        this.sender,
        this.onAccept,
        this.onRemove,
        this.onBlock
    });
    
    final String sender;
    final Function() onAccept;
    final Function() onRemove;
    final Function() onBlock;

    @override
    Widget build(BuildContext context) {
        final Widget child = Row(
            children: <Widget>[
                Flexible(
                    child: Container(
                        decoration: BoxDecoration(
                            boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: globals.Colors.shadow,
                                    blurRadius: 3,
                                    offset: const Offset(1, 1)
                                )
                            ],
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16)
                            )
                        ),
                        child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16)
                            ),
                            child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.only(top: 12),
                                child: Column(
                                    children: <Widget>[
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                            child: RichText(
                                                text: TextSpan(
                                                    children: <TextSpan>[
                                                        TextSpan(
                                                            text: sender,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w700,
                                                                color: globals.Colors.black
                                                            )
                                                        ),
                                                        TextSpan(
                                                            text: allTranslations.text('chat_has_sent'),
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w400,
                                                                color: globals.Colors.black
                                                            )
                                                        )
                                                    ]
                                                ),
                                            ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                            child: GestureDetector(
                                                child: Row(
                                                    children: <Widget>[
                                                        Icon(
                                                            Icons.delete,
                                                            color: globals.Colors.black,
                                                        ),
                                                        Container(width: 6),
                                                        Text(
                                                            allTranslations.text('chat_remove_from'),
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w400,
                                                                color: globals.Colors.black
                                                            )
                                                        )
                                                    ],
                                                ),
                                                onTap: onRemove
                                            ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                            child: GestureDetector(
                                                child: Row(
                                                    children: <Widget>[
                                                        Icon(
                                                            BlockOptions.report.icon,
                                                            color: globals.Colors.danger,
                                                        ),
                                                        Container(width: 6),
                                                        Text(
                                                            BlockOptions.report.title,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w400,
                                                                color: globals.Colors.danger
                                                            )
                                                        )
                                                    ],
                                                ),
                                                onTap: onBlock
                                            ),
                                        ),
                                        const Divider(height: 1, color: globals.Colors.veryLightPink,),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            child: Center(
                                                child: GestureDetector(
                                                    child: Text(
                                                        allTranslations.text('chat_this_good'),
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w600,
                                                            color: globals.Colors.green
                                                        )
                                                    ),
                                                    onTap: onAccept,
                                                ),
                                            ),
                                        )
                                    ],
                                ),
                            ),
                        ),
                    ),
                )
            ],
        );
        return ClipRect(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 4, 4),
                child: child,
            ),
        );
    }
}