import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';

class OrderPlaced extends StatefulWidget {
  const OrderPlaced({super.key});

  @override
  State<OrderPlaced> createState() => _OrderPlacedState();
}

class _OrderPlacedState extends State<OrderPlaced> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadedSlideAnimation(
        beginOffset: const Offset(0, 0.3),
        endOffset: const Offset(0, 0),
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'wemustsay',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'locale.youveGreatChoiceOfTaste!.toUpperCase()',
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          fontSize: 20,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Spacer(
                  flex: 2,
                ),
                FadedScaleAnimation(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.height * 0.42,
                    child: const Image(
                      image: AssetImage("assets/order confirmed.png"),
                    ),
                  ),
                  // durationInMilliseconds: 400,
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      'locale.orderConfirmedWith!.toUpperCase()',
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          fontSize: 13,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    RichText(
                        text: TextSpan(
                            style:
                                Theme.of(context).textTheme.subtitle1!.copyWith(
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.bold,
                                    ),
                            children: <TextSpan>[
                          const TextSpan(
                            text: 'HUNGERZ',
                          ),
                          TextSpan(
                              text: 'RESTRO',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                        ])),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      'locale.yourOrderWillBeAtYourTable!.toUpperCase()',
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          fontSize: 13,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800),
                    ),
                    Text(
                      'locale.anytimeSoon!.toUpperCase()',
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          fontSize: 13,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        // curve: Curves.linearToEaseOut,
      ),
    );
  }
}
