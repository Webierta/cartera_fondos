import 'package:flutter/material.dart';

class FABBottomAppBarItem {
  IconData iconData;
  String text;
  FABBottomAppBarItem({required this.iconData, required this.text});
}

class FABBottomAppBar extends StatefulWidget {
  final List<FABBottomAppBarItem> items;
  final ValueChanged<int> onTabSelected;

  const FABBottomAppBar({Key? key, required this.items, required this.onTabSelected})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => FABBottomAppBarState();
}

class FABBottomAppBarState extends State<FABBottomAppBar> {
  int _selectedIndex = 0;

  _updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: items,
      ),
    );
  }

  Widget _buildTabItem({
    required FABBottomAppBarItem item,
    required int index,
    required ValueChanged<int> onPressed,
  }) {
    Color color = _selectedIndex == index ? Colors.blue : Colors.grey;
    /*IconButton(
      icon: const Icon(Icons.assessment, color: Colors.white),
      padding: const EdgeInsets.only(left: 28.0),
      onPressed: () {
        setState(() => _selectedIndex = 0);
      },
    ),*/
    return IconButton(
      icon: Icon(item.iconData, color: color, size: 32),
      padding: const EdgeInsets.only(left: 32.0),
      onPressed: () => onPressed(index),
    );

    /*return Padding(
      padding: const EdgeInsets.only(left: 28),
      child: SizedBox(
        height: 50,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(item.iconData, color: color),
                Text(item.text, style: TextStyle(color: color)),
                //padding: const EdgeInsets.only(left: 28.0),
              ],
            ),
          ),
        ),
      ),
    );*/
  }
}
