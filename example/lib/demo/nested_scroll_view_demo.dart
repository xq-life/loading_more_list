import 'package:flutter/material.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:flutter_candies_demo_library/flutter_candies_demo_library.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
    name: "fluttercandies://NestedScrollViewDemo",
    routeName: "NestedScrollView",
    description:
        "Show how to build loading more list in NestedScrollView quickly")
class NestedScrollViewDemo extends StatefulWidget {
  @override
  _NestedScrollViewDemoState createState() => _NestedScrollViewDemoState();
}

class _NestedScrollViewDemoState extends State<NestedScrollViewDemo>
    with TickerProviderStateMixin {
  TuChongRepository listSourceRepository;
  TuChongRepository listSourceRepository1;
  TuChongRepository listSourceRepository2;
  TuChongRepository listSourceRepository3;
  TabController primaryTC;
  @override
  void initState() {
    listSourceRepository = new TuChongRepository();
    listSourceRepository1 = new TuChongRepository();
    listSourceRepository2 = new TuChongRepository();
    listSourceRepository3 = new TuChongRepository();
    primaryTC = new TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    listSourceRepository.dispose();
    listSourceRepository1.dispose();
    listSourceRepository2.dispose();
    listSourceRepository3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    var primaryTabBar = new TabBar(
      controller: primaryTC,
      labelColor: Colors.blue,
      indicatorColor: Colors.blue,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 2.0,
      isScrollable: false,
      unselectedLabelColor: Colors.grey,
      tabs: [
        Tab(text: "Tab0"),
        Tab(text: "Tab1"),
        Tab(text: "Tab2"),
      ],
    );
    var tabBarHeight = primaryTabBar.preferredSize.height;
    var pinnedHeaderHeight =
        //statusBar height
        statusBarHeight +
            //pinned SliverAppBar height in header
            kToolbarHeight +
            //pinned tabbar height in header
            tabBarHeight;

    return Scaffold(
      body: PullToRefreshNotification(
        color: Colors.blue,
        pullBackOnRefresh: true,
        onRefresh: onRefresh,
        maxDragOffset: 100.0,
        child: extended.NestedScrollView(
          physics: ClampingScrollPhysics(),
          pinnedHeaderSliverHeightBuilder: () {
            return pinnedHeaderHeight;
          },
          innerScrollPositionKeyBuilder: () {
            var index = "Tab";
            return Key(index + primaryTC.index.toString());
          },
          headerSliverBuilder: (c, f) {
            var widgets = <Widget>[];
            widgets.add(PullToRefreshContainer(builderAppbar));
            widgets.add(SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: CommonSliverPersistentHeaderDelegate(
                    Container(
                      child: primaryTabBar,
                      //color: Colors.white,
                    ),
                    primaryTabBar.preferredSize.height)));

            return widgets;
          },
          body: TabBarView(controller: primaryTC, children: <Widget>[
            Tab0(listSourceRepository),
            Tab1(listSourceRepository1, listSourceRepository2),
            Tab2(listSourceRepository3),
          ]),
        ),
      ),
    );
  }

  Widget builderAppbar(PullToRefreshScrollNotificationInfo info) {
    Widget action = Padding(
      child: info?.refreshWiget ?? Icon(Icons.more_horiz),
      padding: EdgeInsets.all(15.0),
    );
    var offset = info?.dragOffset ?? 0.0;
    Widget child = Container();
    if (info != null) {
      if (info.mode == RefreshIndicatorMode.error) {
        child = GestureDetector(
          onTap: () {
            // refreshNotification;
            info?.pullToRefreshNotificationState?.show();
          },
          child: Text(
            (info.mode?.toString() ?? "") + "  click to retry" ?? "",
            style: TextStyle(fontSize: 10.0),
          ),
        );
        action = Container();
      } else {
        child = Text(
          info?.mode?.toString() ?? "",
          style: TextStyle(fontSize: 10.0),
        );
      }
    }

    return SliverAppBar(
        pinned: true,
        title: Text("NestedScrollViewDemo"),
        centerTitle: true,
        expandedHeight: 200.0 + offset,
        actions: <Widget>[action],
        flexibleSpace: FlexibleSpaceBar(
            //centerTitle: true,
            title: child,
            collapseMode: CollapseMode.pin,
            background: Image.asset(
              "assets/467141054.jpg",
              //fit: offset > 0.0 ? BoxFit.cover : BoxFit.fill,
              fit: BoxFit.cover,
            )));
  }

  Future<bool> onRefresh() async {
    print("onRefresh");
    if (primaryTC.index == 0) {
      return await listSourceRepository.refresh(false);
    } else if (primaryTC.index == 1) {
      listSourceRepository2.clear();
      return await listSourceRepository1.refresh(true);
    } else if (primaryTC.index == 2) {
      return await listSourceRepository3.refresh(true);
    }
    return true;
  }
}

class CommonSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  CommonSliverPersistentHeaderDelegate(this.child, this.height);

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(CommonSliverPersistentHeaderDelegate oldDelegate) {
    //print("shouldRebuild---------------");
    return oldDelegate != this;
  }
}

class Tab0 extends StatefulWidget {
  final TuChongRepository listSourceRepository;
  Tab0(this.listSourceRepository);
  @override
  _Tab0State createState() => _Tab0State();
}

class _Tab0State extends State<Tab0> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return extended.NestedScrollViewInnerScrollPositionKeyWidget(
        Key("Tab0"),
        LoadingMoreCustomScrollView(
          showGlowLeading: false,
          rebuildCustomScrollView: true,
          physics: ClampingScrollPhysics(),
          slivers: <Widget>[
            SliverPersistentHeader(
                pinned: false,
                floating: false,
                delegate: CommonSliverPersistentHeaderDelegate(
                    Container(
                      alignment: Alignment.center,
                      height: 50.0,
                      color: Colors.red,
                      child: Text(
                          "This is a single sliver List with no pinned header"),
                      //color: Colors.white,
                    ),
                    50.0)),
            LoadingMoreSliverList(SliverListConfig<TuChongItem>(
              itemBuilder: itemBuilder,
              sourceList: widget.listSourceRepository,
              //isLastOne: false
            ))
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class Tab1 extends StatefulWidget {
  final TuChongRepository listSourceRepository1;
  final TuChongRepository listSourceRepository2;
  Tab1(this.listSourceRepository1, this.listSourceRepository2);
  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return extended.NestedScrollViewInnerScrollPositionKeyWidget(
        Key("Tab1"),
        LoadingMoreCustomScrollView(
          rebuildCustomScrollView: true,
          showGlowLeading: false,
          physics: ClampingScrollPhysics(),
          slivers: <Widget>[
            SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: CommonSliverPersistentHeaderDelegate(
                    Container(
                      alignment: Alignment.center,
                      height: 50.0,
                      color: Colors.red,
                      child: Text(
                          "This is a multiple loading sliver List with pinned header"),
                      //color: Colors.white,
                    ),
                    50.0)),
            LoadingMoreSliverList(SliverListConfig<TuChongItem>(
              itemBuilder: itemBuilder,
              sourceList: widget.listSourceRepository1,
              //isLastOne: false
            )),
            SliverToBoxAdapter(
              child: Container(
                alignment: Alignment.center,
                child: Text("Next list"),
                color: Colors.blue,
                height: 100.0,
              ),
            ),
            LoadingMoreSliverList(SliverListConfig<TuChongItem>(
              itemBuilder: itemBuilder,
              sourceList: widget.listSourceRepository2,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 3.0,
                mainAxisSpacing: 3.0,
//                    childAspectRatio: 0.5
              ),
            ))
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class Tab2 extends StatefulWidget {
  final TuChongRepository listSourceRepository3;
  Tab2(this.listSourceRepository3);

  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return extended.NestedScrollViewInnerScrollPositionKeyWidget(
        Key("Tab2"),
        Column(
          children: <Widget>[
            Container(
              height: 50.0,
              child: Text("This is a single ListView with pinned header"),
              color: Colors.red,
              alignment: Alignment.center,
            ),
            Expanded(
              child: LoadingMoreList(
                ListConfig<TuChongItem>(
                    itemBuilder: itemBuilder,
                    sourceList: widget.listSourceRepository3,
                    showGlowLeading: false,
                    physics: ClampingScrollPhysics(),
//                    showGlowTrailing: false,
                    padding: EdgeInsets.all(0.0)),
              ),
            )
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
