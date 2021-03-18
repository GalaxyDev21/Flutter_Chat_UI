import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';

class RichTextView extends StatefulWidget {
  @override
  RichTextViewState createState() => RichTextViewState();
}

class RichTextViewState extends State<RichTextView> {
  ZefyrController _controller;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // Create an empty document or load existing if you have one.
    // Here we create an empty document:
    final NotusDocument document = NotusDocument();
    _controller = ZefyrController(document);
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: ZefyrScaffold(
            child: ZefyrEditor(
              controller: _controller,
              focusNode: _focusNode,
            ),
          )
      ),
    );
  }
}