import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_crypto_wallet/application/coin_list/coin_list_notifier.dart';
import 'package:flutter_crypto_wallet/application/coin_list/coin_list_provider.dart';
import 'package:flutter_crypto_wallet/domain/coin.dart';
import 'package:flutter_crypto_wallet/presentation/core/widgets/coin_item.dart';
import 'package:flutter_crypto_wallet/presentation/core/widgets/critical_failure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../core/utils.dart';

class BalancePage extends ConsumerWidget {
  const BalancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(coinNotifierProvider);
    return state.map(
        initial: (_) {
          return Container();
        },
        loading: (_) => const Center(child: CircularProgressIndicator()),
        loaded: (e) => _SuccessContent(loaded: e),
        failure: (e) => CriticalFailure(
            color: Colors.white,
            onRetry: () {
              ref.read(coinNotifierProvider.notifier).getCoins();
            }));
  }
}

class _SuccessContent extends StatefulWidget {
  const _SuccessContent({Key? key, required Loaded loaded})
      : _loaded = loaded,
        super(key: key);

  final Loaded _loaded;
  @override
  __SuccessContentState createState() => __SuccessContentState();
}

class __SuccessContentState extends State<_SuccessContent> {
  final _color = const Color.fromARGB(255, 28, 8, 8);
  bool visibility = true;

  @override
  Widget build(BuildContext context) {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    final isDesktop = deviceType == DeviceScreenType.desktop;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: _color,
          // elevation: 1.0,
          centerTitle: true,
          title: AnimatedCrossFade(
            crossFadeState: visibility ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.centerLeft,
            firstCurve: Curves.easeInCirc,
            secondChild: Text(Utils.getPrice(widget._loaded.totalDollars),
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
            firstChild: Text('My crypto wallet',
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light),
      backgroundColor: _color,
      body: isDesktop && ScreenUtil().orientation == Orientation.landscape
          ? Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Row(
                children: [
                  _HeaderSection(
                    isDesktop: true,
                    total: Utils.getPrice(widget._loaded.totalDollars),
                  ),
                  Expanded(child: _BalanceSection(coins: widget._loaded.coins))
                ],
              ),
            )
          : Stack(
              children: [
                _HeaderSection(
                  total: Utils.getPrice(widget._loaded.totalDollars),
                ),
                NotificationListener<DraggableScrollableNotification>(
                    onNotification: (DraggableScrollableNotification dsNotification) {
                      if (visibility && dsNotification.extent >= 0.75) {
                        setState(() {
                          visibility = false;
                        });
                      } else if (!visibility && dsNotification.extent <= 0.75) {
                        setState(() {
                          visibility = true;
                        });
                      }
                      return true;
                    },
                    child: DraggableScrollableSheet(
                        minChildSize: 0.45,
                        maxChildSize: 1,
                        initialChildSize: 0.45,
                        builder: (context, scrollController) {
                          return _BalanceSection(scrollController: scrollController, coins: widget._loaded.coins);
                        }))
              ],
            ),
    );
  }
}

class _BalanceSection extends StatelessWidget {
  const _BalanceSection({Key? key, ScrollController? scrollController, required List<Coin> coins})
      : _scrollController = scrollController,
        _coins = coins,
        super(key: key);

  final ScrollController? _scrollController;
  final List<Coin> _coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30, top: 10, right: 30, bottom: 50),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListView.separated(
        separatorBuilder: (context, index) {
          return const Divider(
            indent: 30,
            endIndent: 30,
          );
        },
        padding: EdgeInsets.only(top: 20.h),
        controller: _scrollController,
        itemBuilder: (context, index) {
          return CoinItem(
            coin: _coins[index],
            isPortafolio: true,
          );
        },
        itemCount: _coins.length,
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({Key? key, required this.total, this.isDesktop = false}) : super(key: key);
  final String total;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ElasticIn(
          child: SizedBox(
            height: isDesktop ? 1000.h : 500.h,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Lottie.asset(
                  'assets/animation.json',
                ),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Balance',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 15.sp, letterSpacing: 1.5, fontWeight: FontWeight.w500)),
                      SizedBox(
                        height: 10.h,
                      ),
                      SizedBox(
                        width: 300.w,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(total,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 25.sp, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            // context.router.push(const ConvertRoute());
          },
          child: PhysicalModel(
            shadowColor: Colors.white,
            elevation: 4,
            color: const Color(0XFFF01FFB2),
            borderRadius: BorderRadius.circular(25),
            child: Container(
              alignment: Alignment.center,
              height: 100.h,
              width: 600.w,
              constraints: const BoxConstraints(maxWidth: 400),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sync_alt,
                    color: const Color(0XFFF3A00FF),
                    size: 35.h,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Text('Something',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: const Color(0XFFF3A00FF), fontSize: 20.sp, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
