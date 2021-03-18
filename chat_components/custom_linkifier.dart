import 'package:linkify/linkify.dart';
import 'package:organizer/controllers/library/bible_controller.dart';
import 'package:organizer/models/bible/book_model.dart';

class CustomLinkifier extends Linkifier {
    const CustomLinkifier();

    RegExpMatch checkValidBible(String text, bool multiple) {
        final RegExpMatch bibleMatch = RegExp(
            multiple
                ? r'^((?:.|\n)*?)(([1-3]{1}[ ]{1})?[a-z]+[ ]{1}[0-9]{1,2}[:]{1}[0-9]{1,2}([-]{1}[0-9]{1,2})?)'
                : r'^((?:.|\n)*?)(([a-z]+|Song of Solomon)[ ]{1}[0-9]{1,2}[:]{1}[0-9]{1,2}([-]{1}[0-9]{1,2})?)',
            caseSensitive: false,
        ).firstMatch(text);
        
        if (bibleMatch == null)
            return null;
        final Book book = BibleController().checkValidBible(bibleMatch.group(2));
        if (book == null) {
            if (multiple)
                return checkValidBible(text, false);
            return null;
        }
        return bibleMatch;
    }
    
    @override
    List<LinkifyElement> parse(List<LinkifyElement> elements, LinkifyOptions options) {
        final List<LinkifyElement> list = <LinkifyElement>[];
        
        elements.forEach((LinkifyElement element) {
            if (element is TextElement) {
                final RegExpMatch match = RegExp(
                    r'^((?:.|\n)*?)((http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\.]{1}[a-z0-9]+)([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?)',
                    caseSensitive: false,
                ).firstMatch(element.text);
                
                if (match == null) {
                    final RegExpMatch bibleMatch = checkValidBible(element.text, true);
                    if (bibleMatch == null) {
                        list.add(element);
                    } else {
                        final String text = element.text.replaceFirst(bibleMatch.group(0), '');
    
                        if (bibleMatch.group(1).isNotEmpty) {
                            list.add(TextElement(bibleMatch.group(1)));
                        }
    
                        if (bibleMatch.group(2).isNotEmpty) {
                            list.add(UrlElement(bibleMatch.group(2)));
                        }
    
                        if (text.isNotEmpty) {
                            list.addAll(parse([TextElement(text)], options));
                        }
                    }
                } else {
                    final String text = element.text.replaceFirst(match.group(0), '');

                    if (match.group(1).isNotEmpty) {
                        list.add(TextElement(match.group(1)));
                    }

                    if (match.group(2).isNotEmpty) {
                        if (options.humanize ?? false) {
                            list.add(UrlElement(
                                match.group(2),
                                match.group(2).replaceFirst(RegExp(r'https?://'), ''),
                            ));
                        } else {
                            list.add(UrlElement(match.group(2)));
                        }
                    }

                    if (text.isNotEmpty) {
                        list.addAll(parse([TextElement(text)], options));
                    }
                }
            } else {
                list.add(element);
            }
        });
        
        return list;
    }
}