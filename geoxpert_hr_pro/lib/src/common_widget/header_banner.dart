import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/colors.dart';

class HeaderBanner extends StatefulWidget {
  const HeaderBanner({super.key});

  @override
  State<HeaderBanner> createState() => _HeaderBannerState();
}

class _HeaderBannerState extends State<HeaderBanner> {

  bool first = true;

  @override
  void initState() {
    super.initState();
    // Start a timer to toggle the 'first' variable every 5 seconds
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      setState(() {
        first = !first;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Positioned(
            top: 10,
            width: screenWidth-10,
            height: 170,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: GREY.withOpacity(0.2),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(duration: const Duration(milliseconds: 1000),
                            switchInCurve: Curves.easeInOut,
                            switchOutCurve: Curves.easeInOut,
                            transitionBuilder: (child, animation) {
                              var beginOffset = const Offset(0.0, -1.0); // Start from top
                              var endOffset = const Offset(0.0, 0.0);

                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: beginOffset,
                                  end: endOffset,
                                ).animate(animation),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: first? const Column(
                              key: ValueKey('true'),
                              children: [
                                Text(
                                  "TAKE A PART IN OUR DRAWING",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "And Get A Chance To Win Up To \$100,000",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: GREY2,
                                      fontWeight: FontWeight.w700
                                  ),
                                ),
                              ],
                            ):
                            const Column(
                              key: ValueKey('false'),
                              children: [
                                Text(
                                  "CURRENT GAMES IN ACTION",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Stay updated with all the thrilling action by checking out the ongoing games below!",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: GREY2,
                                      fontWeight: FontWeight.w700
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          AnimatedSwitcher(duration: const Duration(milliseconds: 1000),
                            switchInCurve: Curves.easeInOut,
                            switchOutCurve: Curves.easeInOut,
                            transitionBuilder: (child, animation) {
                              var beginOffset = const Offset(0.0, -1.0); // Start from top
                              var endOffset = const Offset(0.0, 0.0);

                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: beginOffset,
                                  end: endOffset,
                                ).animate(animation),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: first ? Container(
                              key: const ValueKey('true'),
                              width: 140,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: DARK,
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 75,
                                    child: TextButton(
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all<Color>(PRIMARY),
                                      ),
                                      onPressed: null,
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'PLAY',
                                            style: TextStyle(
                                              color: WHITE,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Icon(
                                            Icons.arrow_circle_right_outlined,
                                            color: WHITE,
                                            size: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,),
                                  const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "10 : 55 : 15",
                                        style: TextStyle(
                                          color: GREY1,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        "Don't Miss",
                                        style: TextStyle(
                                          color: GREY1,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ):
                            Container(
                              key: const ValueKey('true'),
                              width: 140,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: DARK,
                                borderRadius: BorderRadius.all(Radius.circular(25)),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 75,
                                    child: TextButton(
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all<Color>(PRIMARY),
                                      ),
                                      onPressed: null,
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'WATCH',
                                            style: TextStyle(
                                              color: WHITE,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Icon(
                                            Icons.arrow_circle_right_outlined,
                                            color: WHITE,
                                            size: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,),
                                  const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "10 : 55 : 15",
                                        style: TextStyle(
                                          color: GREY1,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        "Don't Miss",
                                        style: TextStyle(
                                          color: GREY1,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            height: 190,
            width: 280,
            //right: -55,
            left: 180,
            bottom: 20,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                var beginOffset = const Offset(0.0, -1.0); // Start from top
                var endOffset = const Offset(0.0, 0.0);

                return SlideTransition(
                  position: Tween<Offset>(
                    begin: beginOffset,
                    end: endOffset,
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: first? Image.asset(
                key: const ValueKey('true'),
                "assets/img/home/Group 696.png",
              ):
              Image.asset(
                key: const ValueKey('false'),
                "assets/img/home/Group 697.png",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
