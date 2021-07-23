import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:reddigram/screens/screens.dart';
import 'package:reddigram/store/store.dart';
import 'package:reddigram/widgets/reddigram_logo.dart';
import 'package:reddigram/widgets/widgets.dart';

class MainScreen extends StatefulWidget {
  static final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const _TAB_POPULAR = 0;
  static const _TAB_BEST = 1; // ignore: unused_field
  static const _TAB_SUBSCRIPTIONS = 2;
  static const _TAB_NEWEST = 3; // ignore: unused_field

  final feedKeys = List.generate(3, (i) => GlobalKey<InfiniteListState>());

  final _pageController = PageController();
  int _currentTab = _TAB_POPULAR;

  @override
  Widget build(BuildContext context) {
    final subheadTheme = Theme.of(context).textTheme.subhead;

    final subscribeCTA = GestureDetector(
      onTap: () => _changeTab(_TAB_SUBSCRIPTIONS),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No', style: subheadTheme),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.short_text,
                  size: 28.0,
                ),
              ),
              Text('yet.', style: subheadTheme)
            ],
          ),
          const SizedBox(height: 12.0),
          const Text('Subscribe to something!'),
        ],
      ),
    );

    final itemsPlaceholder = ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) => PhotoListItem.placeholder(),
    );

    return Scaffold(
      key: MainScreen.scaffoldKey,
      appBar: _buildAppBar(context),
      body: StoreConnector<ReddigramState, bool>(
        onInit: (store) => store.dispatch(fetchFreshFeed(POPULAR)),
        converter: (store) => store.state.subscriptions.isNotEmpty,
        builder: (context, anySubs) => PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            FeedTab(
              feedName: POPULAR,
              infiniteListKey: feedKeys[0],
              placeholder: itemsPlaceholder,
            ),
            const SubscriptionsTab(),
            FeedTab(
              feedName: BEST_SUBSCRIBED,
              infiniteListKey: feedKeys[1],
              placeholder: anySubs ? itemsPlaceholder : subscribeCTA,
            ),
            FeedTab(
              feedName: NEW_SUBSCRIBED,
              infiniteListKey: feedKeys[2],
              placeholder: anySubs ? itemsPlaceholder : subscribeCTA,
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          /*FancyBottomNavigation(
          initialSelection: _currentTab,
          tabs: [
            TabData(iconData: Icons.show_chart, title: "Popular"),
            TabData(iconData: Icons.whatshot, title: "Search"),
            TabData(iconData: Icons.star, title: "Newest"),
            TabData(iconData: Icons.short_text, title: "Subs")
          ],
          onTabChangedListener: (index) {
            setState(() {
              if (_currentTab != index) {
                // Change the current tab
                _changeTab(index);
              } else {
                // Scroll to the top
                setState(() => feedKeys[index].currentState.scrollToOffset(0));
              }
            });
          },
        ),*/

          IconNavigationBar(
        currentIndex: _currentTab,
        icons: [
          const IconNavigationBarItem(
            icon: ImageIcon(
              AssetImage(
                "assets/images/trend.png",
              ),
              size: 800,
              color: Colors.red,
            ),
            tooltip: 'Popular',
          ),
          const IconNavigationBarItem(
            icon: Icon(Icons.search),
            tooltip: 'Your best',
          ),
          const IconNavigationBarItem(
            icon: ImageIcon(
              AssetImage(
                "assets/images/new.png",
              ),
              size: 800,
            ),
            tooltip: 'Your newest',
          ),
          const IconNavigationBarItem(
            icon: ImageIcon(
              AssetImage(
                "assets/images/sub.png",
              ),
              size: 800,
            ),
            tooltip: 'Subscriptions',
          ),
        ],
        onTap: (index) {
          if (_currentTab != index) {
            // Change the current tab
            _changeTab(index);
          } else {
            // Scroll to the top
            setState(() => feedKeys[index].currentState.scrollToOffset(0));
          }
        },
      ),
    );
  }

  void _changeTab(int tab) {
    setState(() {
      _currentTab = tab;
      _pageController.animateToPage(
        tab,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const ReddigramLogo(),
      centerTitle: true,
      leading: _buildAccountLeadingIcon(context),
    );
  }

  Widget _buildAccountLeadingIcon(BuildContext context) {
    return IconButton(
      icon: StoreConnector<ReddigramState, bool>(
        converter: (store) =>
            store.state.authState.status == AuthStatus.authenticated,
        builder: (context, signedIn) => AnimatedContainer(
          curve: Curves.ease,
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: signedIn
                  ? Theme.of(context).buttonTheme.colorScheme.primary
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: ImageIcon(
            AssetImage(
              "assets/images/2spree.png",
            ),
            size: 800,
            color: Colors.red,
          ),
        ),
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => PreferencesSheet(),
        );
      },
    );
  }
}
