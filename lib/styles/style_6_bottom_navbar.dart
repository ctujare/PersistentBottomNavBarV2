part of persistent_bottom_nav_bar_v2;

class Style6BottomNavBar extends StatefulWidget {
  const Style6BottomNavBar({
    required this.navBarConfig,
    this.navBarDecoration = const NavBarDecoration(),
    this.itemAnimationProperties = const ItemAnimation(),
    Key? key,
  }) : super(key: key);

  final NavBarConfig navBarConfig;
  final NavBarDecoration navBarDecoration;

  /// This controls the animation properties of the items of the NavBar.
  final ItemAnimation itemAnimationProperties;

  @override
  State<Style6BottomNavBar> createState() => _Style6BottomNavBarState();
}

class _Style6BottomNavBarState extends State<Style6BottomNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllerList;
  late List<Animation<double>> _animationList;

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.navBarConfig.selectedIndex;
    _animationControllerList = List<AnimationController>.empty(growable: true);
    _animationList = List<Animation<double>>.empty(growable: true);

    for (int i = 0; i < widget.navBarConfig.items.length; ++i) {
      _animationControllerList.add(
        AnimationController(
          duration: widget.itemAnimationProperties.duration,
          vsync: this,
        ),
      );
      _animationList.add(
        Tween(begin: 0.95, end: 1.18)
            .chain(CurveTween(curve: widget.itemAnimationProperties.curve))
            .animate(_animationControllerList[i]),
      );
    }

    _ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((_) {
      _animationControllerList[_selectedIndex].forward();
    });
  }

  Widget _buildItem(ItemConfig item, bool isSelected, int itemIndex) =>
      AnimatedBuilder(
        animation: _animationList[itemIndex],
        builder: (context, child) => Transform.scale(
          scale: _animationList[itemIndex].value,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconTheme(
                data: IconThemeData(
                  size: item.iconSize,
                  color: isSelected
                      ? item.activeColorPrimary
                      : item.inactiveColorPrimary,
                ),
                child: isSelected ? item.icon : item.inactiveIcon,
              ),
              if (item.title != null)
                FittedBox(
                  child: Text(
                    item.title!,
                    style: item.textStyle.apply(
                      color: isSelected
                          ? item.activeColorPrimary
                          : item.inactiveColorPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

  @override
  void dispose() {
    for (int i = 0; i < widget.navBarConfig.items.length; ++i) {
      _animationControllerList[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.navBarConfig.selectedIndex != _selectedIndex) {
      _animationControllerList[_selectedIndex].reverse();
      _selectedIndex = widget.navBarConfig.selectedIndex;
      _animationControllerList[_selectedIndex].forward();
    }
    return DecoratedNavBar(
      decoration: widget.navBarDecoration,
      filter:
          widget.navBarConfig.items[widget.navBarConfig.selectedIndex].filter,
      opacity:
          widget.navBarConfig.items[widget.navBarConfig.selectedIndex].opacity,
      height: widget.navBarConfig.navBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.navBarConfig.items.map((item) {
          final int index = widget.navBarConfig.items.indexOf(item);
          return Expanded(
            child: InkWell(
              onTap: () {
                widget.navBarConfig.onItemSelected(index);
              },
              child: _buildItem(
                item,
                widget.navBarConfig.selectedIndex == index,
                index,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
