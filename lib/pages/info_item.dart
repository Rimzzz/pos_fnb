import 'package:animation_wrappers/animation_wrappers.dart';

import 'package:flutter/material.dart';

import '../component/custom_circular_button.dart';
import '../models/food_item.dart';
import '../theme/colors.dart';

class ItemInfoPage extends StatefulWidget {
  final String? img;
  final String? name;
  ItemInfoPage(this.img, this.name);
  @override
  _ItemInfoPageState createState() => _ItemInfoPageState();
}

// class FoodItem {
//   String image;
//   String name;
//   bool isVeg;
//   String price;

//   FoodItem(this.image, this.name, this.isVeg, this.price);
// }

class _ItemInfoPageState extends State<ItemInfoPage> {
  List<FoodItem> foodItems = [
    FoodItem('assets/food items/food1.jpg', 'Veg Sandwich', true, '5.00', false, 0),
    FoodItem('assets/food items/food2.jpg', 'Shrips Rice', true, '3.00', false, 0),
    FoodItem('assets/food items/food3.jpg', 'Cheese Bread', true, '4.00', false, 0),
    FoodItem('assets/food items/food4.jpg', 'Veg Cheeswich', true, '3.50', false, 0),
    FoodItem('assets/food items/food5.jpg', 'Margherita Pizza', true, '4.50', false, 0),
    FoodItem('assets/food items/food6.jpg', 'Veg Manchau', true, '2.50', false, 0),
    FoodItem('assets/food items/food7.jpg', 'Spring Noodle', true, '3.00', false, 0),
    FoodItem('assets/food items/food8.jpg', 'Veg Mix Pizza', true, '5.00', false, 0),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: FadedSlideAnimation(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).backgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 150,
                            child: buildItemsInCartButton(context),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Stack(
                        children: [
                          FadedScaleAnimation(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(8)),
                                  image: DecorationImage(
                                      image: AssetImage(widget.img!),
                                      fit: BoxFit.cover)),
                            ),
                            // durationInMilliseconds: 400,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Theme.of(context).scaffoldBackgroundColor,
                                    transparentColor
                                  ],
                                  stops: [
                                    0.0,
                                    0.5
                                  ]),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(left: 15, right: 15, top: 8),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(bottom: Radius.circular(8)),
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name!,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Row(
                              children: [
                                Text(
                                  'fastFood',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption!
                                      .copyWith(height: 1.8),
                                ),
                                Spacer(),
                                Text(
                                  '\$12.00',
                                  style: Theme.of(context).textTheme.bodyText2,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('PILIHAN Masukkan',
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.5)),
                            buildAddOption(context, 'Extra Cheese', '\$5.00'),
                            buildAddOption(context, 'Extra Honey', '\$3.00'),
                            buildAddOption(
                                context, 'Extra Mayonnaise', '\$4.00'),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                      Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(8)),
                              color: Theme.of(context).primaryColor),
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: Text(
                            'Masukkan ke keranjang',
                            style: Theme.of(context).textTheme.bodyText1,
                          )))
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                          TextSpan(
                              text: 'DESKRIPSI' + '\n\n',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.5)),
                          TextSpan(
                              text:
                                  'Lorem ipsum dolor sit amet, consecutar adi piscing elit, sed do eiusmod incidudant ut djd labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(height: 1.3)),
                        ])),
                      ),
                      FadedScaleAnimation(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.4,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                  image: AssetImage(widget.img!),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.4),
                                      BlendMode.darken))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Spacer(),
                              Center(
                                child: Image.asset(
                                  'assets/yt.png',
                                  scale: 4,
                                ),
                              ),
                              Spacer(),
                              RichText(
                                  text: TextSpan(children: <TextSpan>[
                                TextSpan(
                                    text:
                                        'Tahu Bagaimana Kami memasaknya' + '\n',
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                                TextSpan(
                                    text: '3 ' + 'min video',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(color: strikeThroughColor)),
                              ]))
                            ],
                          ),
                        ),
                        // durationInMilliseconds: 400,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                        child: Row(
                          // mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildCustomContainer(
                                context,
                                'assets/ItemCategory/cat_fastfood.png',
                                'porsi',
                                '2 ' + 'orang'),
                            Spacer(),
                            buildCustomContainer(
                                context,
                                'assets/icon_cooktime.png',
                                'waktu',
                                '12 ' + 'menit'),
                            Spacer(),
                            buildCustomContainer(
                                context,
                                'assets/icon_orders.png',
                                'energi',
                                '227 ' + 'kalori'),
                          ],
                        ),
                      ),
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                          TextSpan(
                              text: 'resep' + '\n\n',
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.5)),
                          TextSpan(
                              text: 'item',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                      letterSpacing: 0.4,
                                      height: 1.6,
                                      wordSpacing: 15,
                                      fontWeight: FontWeight.w500)),
                        ])),
                      ),
                      SizedBox(
                        height: 18,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 18),
                        child: Text(
                          'like',
                          style: Theme.of(context).textTheme.caption!.copyWith(
                              fontWeight: FontWeight.w500, letterSpacing: 1.5),
                        ),
                      ),
                      SizedBox(
                        height: 230,
                        child: ListView.builder(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, bottom: 20),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(right: 10),
                                width: 170,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // Navigator.push(context, MaterialPageRoute(builder: (context)=>ItemInfoPage(foodItems[index].image, foodItems[index].name)));
                                      },
                                      child: Container(
                                        height: 150,
                                        width: 170,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(10)),
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    foodItems[index].image),
                                                fit: BoxFit.fill)),
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        foodItems[index].name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .copyWith(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            foodItems[index].isVeg
                                                ? 'assets/ic_veg.png'
                                                : 'assets/ic_nonveg.png',
                                            scale: 2.5,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text('\$ ' + foodItems[index].price),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          beginOffset: Offset(0, 0.3),
          endOffset: Offset(0, 0),
          // curve: Curves.linearToEaseOut,
        ),
      ),
    );
  }

  Container buildAddOption(
    BuildContext context,
    String title,
    String price,
  ) {
    bool? val = title == 'Extra Cheese' ? true : false;
    return Container(
      height: 30,
      child: Row(
        children: [
          Transform.scale(
              scale: 0.7,
              child: Checkbox(
                activeColor: Theme.of(context).primaryColor,
                checkColor: Theme.of(context).scaffoldBackgroundColor,
                value: val,
                onChanged: (bool? value) {
                  setState(() {
                    val = value;
                  });
                },
              )),
          Text(
            title,
            style:
                Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 14),
          ),
          Spacer(),
          Text(price)
        ],
      ),
    );
  }

  Widget buildCustomContainer(
      BuildContext context, String icon, String title, String subtitle) {
    return Expanded(
      flex: 7,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        height: MediaQuery.of(context).size.height * 0.25,
        // width: MediaQuery.of(context).size.width * 0.13,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Spacer(
              flex: 2,
            ),
            Expanded(
              flex: 5,
              child: Image.asset(
                icon,
                // scale: 3,
              ),
            ),
            Spacer(),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(fontWeight: FontWeight.w500, letterSpacing: 1.5)),
            Spacer(),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }

  CustomButton buildItemsInCartButton(BuildContext context) {
    return CustomButton(
      onTap: () {
        // _scaffoldKey.currentState.openEndDrawer();
      },
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      title: Text(
        ' item (3)',
        style: Theme.of(context).textTheme.bodyText1,
      ),
      bgColor: buttonColor,
    );
  }
}
