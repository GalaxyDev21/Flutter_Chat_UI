import 'package:flutter/material.dart';
import 'package:organizer/models/chat/message_model.dart';
import 'package:organizer/views/chat/chat_components/system_message/member_changed_builder.dart';

abstract class SystemMessageType {
    String get type;
}

abstract class SystemMessageBuilder implements SystemMessageType {
    Map<String, dynamic> attributes;
    String body;
    DateTime dateCreated;

    SystemMessageBuilder({
        @required this.attributes,
        @required this.body,
        @required this.dateCreated
    }) {
        assert(type == body);
    }
    
    Widget builder(BuildContext context);
    
    factory SystemMessageBuilder.fromAttributes({@required String body, @required Map<String, dynamic> attributes, @required DateTime dateCreated}) {
        switch (body) {
            case SystemMessageTypes.member:
                return MemberChangedBuilder(body: body, attributes: attributes, dateCreated: dateCreated);
                break;
            default:
                return null;
        }
    }
}

