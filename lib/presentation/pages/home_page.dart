import 'package:collapsible_sidebar/collapsible_sidebar.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'balance_page.dart';
import 'coin_list_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  final List<Widget> _pages = [const BalancePage(), const CoinListPage()];

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _pos = 0;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var deviceType = getDeviceType(size);
    final isDesktop = (deviceType == DeviceScreenType.desktop) && ScreenUtil().orientation == Orientation.landscape;
    return Scaffold(
      bottomNavigationBar: isDesktop
          ? null
          : _BottomNavigationBar(
              onTap: (pos) {
                setState(() {
                  _pos = pos;
                });
              },
            ),
      backgroundColor: const Color(0XFFF3A00FF),
      body: isDesktop
          ? CollapsibleSidebar(
              items: [
                CollapsibleItem(
                  text: 'Balance',
                  icon: Icons.home_filled,
                  onPressed: () {
                    setState(() {
                      _pos = 0;
                    });
                  },
                  isSelected: _pos == 0,
                ),
                CollapsibleItem(
                    text: 'Market',
                    icon: Icons.equalizer,
                    onPressed: () {
                      setState(() {
                        _pos = 1;
                      });
                    },
                    isSelected: _pos == 1),
              ],
              body: Padding(
                padding: EdgeInsets.only(left: 2.w),
                child: widget._pages[_pos],
              ),
              avatarImg: const AssetImage('assets/profile.jpeg'),
              backgroundColor: Colors.white,
              title: 'Phong Nguyen',
              selectedIconColor: const Color(0xFFF55050),
              selectedTextColor: const Color(0xFFF55050),
              unselectedTextColor: Colors.black87,
              textStyle: TextStyle(fontSize: 10.sp),
              titleStyle: TextStyle(fontSize: 10.sp, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
              toggleTitleStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
            )
          : widget._pages[_pos],
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({required this.onTap});

  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
        color: Colors.white,
        backgroundColor: Colors.white,
        initialActiveIndex: 0,
        items: const [
          TabItem(icon: Icon(Icons.home_filled)),
          TabItem(
            icon: Icon(Icons.equalizer),
          )
        ],
        onTap: onTap);
  }
}
