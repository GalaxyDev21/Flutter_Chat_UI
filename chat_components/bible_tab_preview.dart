import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:organizer/globals.dart' as globals;
import 'package:organizer/icons_icons.dart';
import 'package:organizer/models/bible/book_model.dart';
import 'package:organizer/views/components/bible_content.dart';
import 'package:organizer/views/components/bible_header.dart';
import 'package:organizer/views/tab_component.dart';


/// A multi-task tab that represent the content of a media file.
class BibleTabPreview extends TabComponent {
    
    BibleTabPreview({
        @required this.book
    }) {
        iconData = MyIcons.bible;
        keyIndex = '${book.name}${book.number}${book.from}${book.to}';
    }
    
    final Book book;
    
    BibleTabPreviewState _state;
    
    @override
    State<StatefulWidget> createState() {
        _state = BibleTabPreviewState();
        return _state;
    }
    
    @override
    void setState() {
        _state._setState();
    }
}

class BibleTabPreviewState extends State<BibleTabPreview> {
    
    void _setState() {
        setState(() {
        
        });
    }
    
    @override
    void initState() {
        super.initState();
    }
    
    @override
    Widget build(BuildContext context) {
        return Container(
            color: Colors.white,
            child: Column(
                children: <Widget>[
                    Row(
                        children: <Widget>[
                            IconButton(
                                iconSize: 20,
                                icon: const Icon(MdiIcons.arrowCollapse, color: globals.Colors.brownGray),
                                onPressed: () {
                                    widget.onCollapse();
                                },
                            ),
                        ],
                    ),
                    const Divider(height: 1, color: globals.Colors.lightGray),
                    Expanded(
                        child: ListView(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            children: <Widget>[
                                MyBibleHeader(book: widget.book),
                                Container(height: 12),
                                MyBibleContent(book: widget.book),
                            ]
                        ),
                    )
                ],
            )
        );
    }
}