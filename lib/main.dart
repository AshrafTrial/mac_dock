import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[icon.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(icon, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T extends IconData> extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T extends IconData> extends State<Dock<T>> {
  late List<T> _items = widget.items.toList();
  int? _draggingIndex;
  int? _targetIndex;

  bool isMovingRight = false;


  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          final item = _items[index];

          return DragTarget<T>(
            onWillAcceptWithDetails: (details) {
              return details.data != item;
            },
            onAcceptWithDetails: (details) {
              setState(() {
                if (_draggingIndex != null) {
                  _items.removeAt(_draggingIndex!);
                  _items.insert(index, details.data);
                }
                _draggingIndex = null;
                _targetIndex = null;
              });
            },
            onLeave: (data) {
              setState(() {
                if (_draggingIndex == index) {
                  _targetIndex = null;
                }
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Draggable<T>(
                data: item,
                feedback: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.primaries[item.hashCode % Colors.primaries.length],
                    ),
                    child: Center(child: Icon(item, color: Colors.white)),
                  ),
                ),
                childWhenDragging: Container(
                  width: 0,
                  height: 0,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.transparent,
                  ),
                ),
                onDragStarted: () {
                  setState(() {
                    _draggingIndex = index;
                  });
                },
                onDraggableCanceled: (velocity, offset) {
                  setState(() {
                    _draggingIndex = null;
                  });
                },
                onDragEnd: (_) {
                  setState(() {
                    _draggingIndex = null;
                  });
                },
                onDragUpdate: (details) {
                  setState(() {
                    _targetIndex = _getTargetIndex(details.localPosition);
                    print(_targetIndex);
                    if(_targetIndex! <=_draggingIndex!){
                      isMovingRight = true;
                    }
                  });

                },
                child: _targetIndex != index ?AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.all(4),
                  child: widget.builder(item),
                ):Row(
                  children: [
                    isMovingRight ? Container(width: 60,
                      height: 60,):SizedBox(),
                    widget.builder(item),
                    !isMovingRight?Container(width: 60,
                      height: 60,):SizedBox()
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  int? _getTargetIndex(Offset position) {
    for (int i = 0; i < _items.length; i++) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final offset = renderBox.localToGlobal(Offset.zero);
      final itemPosition = offset.translate(i * 56, 0);
      final itemRect = Rect.fromLTWH(itemPosition.dx, itemPosition.dy, 56, 56);

      if (itemRect.contains(position)) {
        return i;
      }
    }
    return null;
  }
}