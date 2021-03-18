
import 'package:flutter/material.dart';
import 'package:organizer/views/components/block_report.dart';

class BlockReportFile extends BlockReport {
    
    BlockReportFile({bool isAdmin, String name}) : super(isAdmin: isAdmin, name: name);
    
    @override
    State<StatefulWidget> createState() {
        return BlockReportFileState();
    }
}

class BlockReportFileState extends BlockReportState<BlockReportFile> {
    @override
    Widget mainWidget() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
                reportWidget(),
                hideWidget(),
                if (widget.isAdmin)
                    fileBlockWidget()
            ],
        );
    }
}