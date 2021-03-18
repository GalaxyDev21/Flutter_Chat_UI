import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/rectgetter.dart';
class ChatIndexedScrollController extends ChangeNotifier{
    int startIndex;
    int endIndex;
    int jumpedIndex = -1;
    bool isJump = false;
    
    void updateIndex(int start, int end) {
        startIndex = start;
        endIndex = end;
        notifyListeners();
    }
    
    void jumpComplete() {
        jumpedIndex = -1;
        isJump = false;
        notifyListeners(); //tbd: can be removed?
    }
    
    void jumpToIndex(int index){
        jumpedIndex = index;
        isJump = true;
        notifyListeners();
    }
    
    ChatIndexedScrollController(this.startIndex, this.endIndex);
}

class ChatIndexedListView extends StatefulWidget {

    const ChatIndexedListView.builder({
        Key key,
        this.itemBuilder,
        this.scrollController,
        this.reverse,
        this.itemCount,
        this.padding,
    }) : super(key: key);
    
    final ScrollController scrollController;
    final IndexedWidgetBuilder itemBuilder;
    final bool reverse;
    final int itemCount;
    final EdgeInsets padding;
    
    @override
    _ChatIndexedListViewState createState() => _ChatIndexedListViewState();
}


class _ChatIndexedListViewState extends State<ChatIndexedListView> {
    ChatIndexedScrollController _indexedScrollController;
    final GlobalKey _listViewKey = RectGetter.createGlobalKey();
    final Map<int, GlobalKey> _keys = {};
    bool _reverse = false;
    ScrollController _scrollController;
    bool jumping = false;
    int target;
    
    @override
    void initState() {
        super.initState();
        
        _reverse = widget.reverse ?? false;
        _scrollController = widget.scrollController?? ScrollController();
        _scrollController.addListener(_onScroll);
        
        for (int i = 0 ; i < widget.itemCount ; i++) {
            _keys[i] = RectGetter.createGlobalKey();
        }
    }
    
    @override
    void dispose() {
        _scrollController.removeListener(_onScroll);
        super.dispose();
    }
    
    void _onScroll() {
        final List<int> items = getVisibleIndices()['visible'];
        if (items.isNotEmpty) {
            _indexedScrollController.updateIndex(items.first, items.last);
        }
    }
    
    Map<String, List<int>> getVisibleIndices() {
        final Rect rect = RectGetter.getRectFromKey(_listViewKey);
        // skipping the rest of out-framed rects to boost performance
        bool isVisible(int index, GlobalKey key) {
            final Rect itemRect = RectGetter.getRectFromKey(key);
            return itemRect != null && rect.overlaps(itemRect);
        }
        bool isTopVisible(int index, GlobalKey key) {
            final Rect itemRect = RectGetter.getRectFromKey(key);
            return itemRect != null && itemRect.top >= rect.top && itemRect.top <= (rect.top + rect.bottom) / 2;
        }
        bool isBottomVisible(int index, GlobalKey key) {
            final Rect itemRect = RectGetter.getRectFromKey(key);
            return itemRect != null && itemRect.bottom <= rect.bottom && itemRect.bottom >= (rect.top + rect.bottom) / 2;
        }
        
        final List<int> visibleItems = <int>[];
        final List<int> topVisibleItems = <int>[];
        final List<int> bottomVisibleItems = <int>[];
        _keys.entries
            .skipWhile((MapEntry<int, GlobalKey> entry) => !isVisible(entry.key, entry.value))
            .takeWhile((MapEntry<int, GlobalKey> entry) => isVisible(entry.key, entry.value))
            .forEach((MapEntry<int, GlobalKey> entry) {
                if (isTopVisible(entry.key, entry.value))
                    topVisibleItems.add(entry.key);
                if (isBottomVisible(entry.key, entry.value))
                    bottomVisibleItems.add(entry.key);
                visibleItems.add(entry.key);
            });
        return {
            'top': topVisibleItems,
            'bottom': bottomVisibleItems,
            'visible': visibleItems
        };
    }
    
    void scrollLoop(Rect listRect, {bool showTop}) {
        final Map<String, List<int>> result = getVisibleIndices();
        final List<int> visible = result['visible'];
        showTop ??= (visible.last - target).abs() <= (visible.first - target).abs();
        int direction;
        if (visible.first > target || (visible.last - target).abs() > (target - visible.first).abs())
            direction = -1;
        else if (visible.last < target || (visible.last - target).abs() < (target - visible.first).abs())
            direction = 1;
        else
            direction = showTop ? 1 : -1;
        final List<int> finalVisible = showTop ? result['top'] : result['bottom'];
        if (!finalVisible.contains(target)) {
            final int first = direction == 1 ? visible.last : visible.first;
            double offset;
            if ((target - first).abs() > 2) {
                offset = _scrollController.offset + direction * listRect.height / 8 * (target - first).abs() / 2;
            } else {
                offset = _scrollController.offset + direction * listRect.height / 8;
            }
            _scrollController.animateTo(offset, duration: const Duration(microseconds: 10), curve: Curves.linear)
                .then((_) {
                scrollLoop(listRect, showTop: showTop);
            });
        } else {
            target = null;
            final List<int> items = getVisibleIndices()['visible'];
            if (items.isNotEmpty) {
                _indexedScrollController.updateIndex(items.first, items.last);
            }
            _indexedScrollController.jumpComplete();
        }
    }
    
    void jumpTo(int target) {
        final Rect listRect = RectGetter.getRectFromKey(_listViewKey);
        final bool isScrollingToTarget = this.target != null;
        this.target = target;
        if (!isScrollingToTarget) {
            scrollLoop(listRect);
        }
    }

    @override
    Widget build(BuildContext context) {
        _indexedScrollController = Provider.of<ChatIndexedScrollController>(context,listen: false);
        return Selector<ChatIndexedScrollController, bool>(
            selector: (BuildContext context, ChatIndexedScrollController indexedScrollController) => indexedScrollController.isJump,
            builder:(BuildContext context, bool isJump, Widget child) {
                if (isJump) {
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) {
                            jumpTo(_indexedScrollController.jumpedIndex);
                        }
                    );
                }
                return ListView.builder(
                    key: _listViewKey,
                    controller: _scrollController,
                    reverse: _reverse,
                    itemCount: widget.itemCount ?? 0,
                    padding: widget.padding ?? const EdgeInsets.all(0),
                    itemBuilder: (BuildContext context, int index) {
                        if (_keys[index] == null) {
                            _keys[index] = RectGetter.createGlobalKey();
                        }
                        return RectGetter(
                            key: _keys[index],
                            child: widget.itemBuilder(context, index),
                        );
                    }
                );
            }, 
        );
    }
}
