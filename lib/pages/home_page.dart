import 'dart:async';
import 'dart:convert';

import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_amazink/models/category.dart';
import 'package:pos_amazink/models/deposit.dart';
import 'package:pos_amazink/models/order_item.dart';
import 'package:pos_amazink/models/product.dart';
import 'package:pos_amazink/pages/cashout_page.dart';
import 'package:pos_amazink/pages/login_page.dart';
import 'package:pos_amazink/pages/print_page.dart';
import 'package:pos_amazink/pages/report_page.dart';
import 'package:pos_amazink/utils/amazink_database.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:pos_amazink/utils/date_ext.dart';
import 'package:pos_amazink/utils/setting_shared_preferences.dart';

import '../component/custom_circular_button.dart';
import '../theme/colors.dart';
import '../utils/text_utils.dart';
import 'info_item.dart';
// import '../models/cart_item.dart';
// import '../models/food_item.dart';
// import '../models/item_category.dart';
// import 'order_placed.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController bayarController = TextEditingController();
  List<Product> listProduct = [];
  List<Category> listCategory = [];
  DateTime? lastSent;
  bool isPressOrder = false;
  @override
  void initState() {
    super.initState();
    // getProduct().then((value) => setState(
    //       () => isLoading = false,
    //     ));
    // getCategory().then((value) => setState(
    //       () => isLoading = false,
    //     ));
    refreshData();
    periodicSentToServer();
  }

  void periodicSentToServer() async {
    await sentToServer();
    lastSent = DateTime.now();
  }

  final urlController = TextEditingController();
  final namaWarungController = TextEditingController();
  final alamatWarungController = TextEditingController();

  BlueThermalPrinter printer = BlueThermalPrinter.instance;

  Future refreshData() async {
    setState(() {
      isLoading = true;
    });
    listProduct = await AmazinkDatabase.instance.readAllProduct();
    listCategory = await AmazinkDatabase.instance.readAllCategory();
    setState(() {
      isLoading = false;
    });
  }

  bool isLoading = false;
  int totalPrice = 0;
  double totalPajak = 0;

  Future<void> getCategory() async {
    setState(() {
      isLoading = true;
    });
    String urlServer = SettingSharedPreferences.getUrlServer() ?? '';
    Response response;
    var dio = Dio();

    response = await dio.get('$urlServer/publish/getCategory');

    listCategory = categoryFromMap(response.data.toString());
    await AmazinkDatabase.instance.deleteAllCategory();
    for (final item in listCategory) {
      await AmazinkDatabase.instance.createCategory(item);
    }
  }

  Future<void> saveOrder(List<OrderItem> orders, pay) async {
    int id = await AmazinkDatabase.instance
        .createOrder(pay: pay, total: totalPrice.toString());
    for (final item in orders) {
      await AmazinkDatabase.instance.createOrderDetail(orderId: id, item: item);
    }
  }

  Future<void> getProduct() async {
    setState(() {
      isLoading = true;
    });
    String urlServer = SettingSharedPreferences.getUrlServer() ?? '';
    Response response;
    var dio = Dio();

    response = await dio.get('$urlServer/publish/getData');

    listProduct = productFromMap(response.data.toString());
    await AmazinkDatabase.instance.deleteAllProduct();
    for (final item in listProduct) {
      await AmazinkDatabase.instance.createProduct(item);
    }
  }

  Future<Deposit> getDeposit() async {
    var dio = Dio();
    String urlServer = SettingSharedPreferences.getUrlServer() ?? '';
    final response = await dio.get('$urlServer/publish/getDeposit');
    return Deposit.fromJson(response.data.toString());
  }

  List<OrderItem> orders = [];

  void handleClickProduct(Product product) {
    if (orders.any((element) => element.product == product)) {
      var o = orders.where((element) => element.product == product);
      o.first.quantity++;
    } else {
      orders.add(OrderItem(product: product, quantity: 1));
    }
    totalPrice = 0;
    for (final item in orders) {
      totalPrice += int.parse(item.product.price) * item.quantity;
    }
    totalPajak = (totalPrice).toDouble() * 10 / 100;
    setState(() {});
  }

  void handleClickProductDecrease(Product product) {
    if (orders.any((element) => element.product == product)) {
      var o = orders.where((element) => element.product == product);
      o.first.quantity--;
    }
    totalPrice = 0;
    for (final item in orders) {
      totalPrice += int.parse(item.product.price) * item.quantity;
    }
    totalPajak = (totalPrice).toDouble() * 10 / 100;
    setState(() {});
  }

  void handleClickRemoveProduct(Product product) {
    if (orders.any((element) => element.product == product)) {
      var o = orders.where((element) => element.product == product);
      orders.remove(o.first);
    }
    totalPrice = 0;
    for (final item in orders) {
      totalPrice += int.parse(item.product.price) * item.quantity;
    }
    totalPajak = (totalPrice).toDouble() * 10 / 100;
    setState(() {});
  }

  void _onSendingData() async {
    setState(() {
      bool buttonEnabled = false;
    });
    await sentToServer();
    showSnack(context, 'Transaksi berhasil sinkron ke server');
    setState(() {
      bool buttonEnabled = true;
    });
  }

  bool buttonEnabled = true;
  bool itemSelected = false;
  String? img, name;
  int drawerCount = 0;
  int currentIndex = 0;
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        child: Drawer(
          child: drawerCount == 1
              ? ItemInfoPage(img, name)
              : SafeArea(
                  child: Stack(
                    children: [
                      ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              buildItemsInCartButton(context, totalPrice),
                              const SizedBox(
                                width: 16,
                              ),
                            ],
                          ),
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 150),
                              itemCount: orders.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 10),
                                      leading: GestureDetector(
                                        onTap: () {},
                                        child: FadedScaleAnimation(
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: FadedScaleAnimation(
                                                child: SizedBox(
                                                  height: 60,
                                                  width: 60,
                                                  child: CachedNetworkImage(
                                                    imageUrl: orders[index]
                                                        .product
                                                        .picture,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  // Image.network(
                                                  //   orders[index]
                                                  //       .product
                                                  //       .picture,
                                                  //   fit: BoxFit.cover,
                                                  // ),
                                                ),
                                              )),
                                        ),
                                      ),
                                      title: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                orders[index]
                                                    .product
                                                    .productName,
                                                maxLines: 2,
                                                overflow: TextOverflow.clip,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1!
                                                    .copyWith(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            FadedScaleAnimation(
                                                child: InkWell(
                                              onTap: () {
                                                handleClickRemoveProduct(
                                                    orders[index].product);
                                              },
                                              child: const Icon(
                                                Icons.delete_forever,
                                                color: Colors.red,
                                              ),
                                            )),
                                          ],
                                        ),
                                      ),
                                      subtitle: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: 30,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2,
                                                        horizontal: 4),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    border: Border.all(
                                                        color: newOrderColor,
                                                        width: 0.5)),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const SizedBox(
                                                      width: 4,
                                                    ),
                                                    GestureDetector(
                                                        onTap: () {
                                                          if (orders[index]
                                                                  .quantity >
                                                              0) {
                                                            handleClickProductDecrease(
                                                                orders[index]
                                                                    .product);
                                                          }
                                                        },
                                                        child: Icon(
                                                          Icons.remove,
                                                          color: newOrderColor,
                                                          size: 20,
                                                        )),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      orders[index]
                                                          .quantity
                                                          .toString(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle1!
                                                          .copyWith(
                                                              fontSize: 16),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        handleClickProduct(
                                                            orders[index]
                                                                .product);
                                                      },
                                                      child: Icon(
                                                        Icons.add,
                                                        color: newOrderColor,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 4,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                'Rp. ${getThousandSeparator(orders[index].product.price)}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              })
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                tileColor: Theme.of(context).backgroundColor,
                                title: Text('Total:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1!
                                        .copyWith(fontSize: 15)),
                                trailing: Text(
                                  'Rp ${getCurrencySeparator((totalPrice).toString())}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      ?.copyWith(
                                        fontSize: 15,
                                      ),
                                ),
                              ),
                              CustomButton(
                                onTap: () {
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             const OrderPlaced()));
                                  showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (context) {
                                        return SimpleDialog(
                                          title: const Center(
                                              child: Text('PEMBAYARAN')),
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                              ),
                                              child: TextField(
                                                controller: bayarController,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black),
                                                // controller: modelController,
                                                textInputAction:
                                                    TextInputAction.done,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  hoverColor:
                                                      Colors.red.shade100,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.red),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                      width: 2.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                InkWell(
                                                    onTap: () => bayarController
                                                        .text = '10000',
                                                    child: const Chip(
                                                      label: Text(
                                                        'Rp. 10.000',
                                                      ),
                                                    )),
                                                InkWell(
                                                    onTap: () => bayarController
                                                        .text = '20000',
                                                    child: const Chip(
                                                      label: Text(
                                                        'Rp. 20.000',
                                                      ),
                                                    )),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                InkWell(
                                                    onTap: () => bayarController
                                                        .text = '50000',
                                                    child: const Chip(
                                                      label: Text(
                                                        'Rp. 50.000',
                                                      ),
                                                    )),
                                                InkWell(
                                                    onTap: () => bayarController
                                                        .text = '100000',
                                                    child: const Chip(
                                                      label: Text(
                                                        'Rp. 100.000',
                                                      ),
                                                    )),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red),
                                                  onPressed: isPressOrder
                                                      ? null
                                                      : () async {
                                                          setState(() {
                                                            isPressOrder = true;
                                                          });
                                                          await saveOrder(
                                                              orders,
                                                              bayarController
                                                                  .text);
                                                          setState(() {
                                                            isPressOrder =
                                                                false;
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false,
                                                              builder:
                                                                  (context) {
                                                                return SimpleDialog(
                                                                  title:
                                                                      const Center(
                                                                    child: Text(
                                                                        'Summary'),
                                                                  ),
                                                                  children: [
                                                                    ...orders
                                                                        .map(
                                                                          (e) =>
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 8),
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        Text(e.product.productName),
                                                                                        const SizedBox(
                                                                                          width: 4,
                                                                                        ),
                                                                                        Text('x ${e.quantity.toString()}'),
                                                                                      ],
                                                                                    ),
                                                                                    Text(getCurrencySeparator((int.parse(e.product.price) * e.quantity).toString())),
                                                                                  ],
                                                                                ),
                                                                                const Divider(
                                                                                  thickness: 1,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        )
                                                                        .toList(),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          const Text(
                                                                              'Sub Total'),
                                                                          Text(getCurrencySeparator(
                                                                              totalPrice.toString())),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const Divider(
                                                                      thickness:
                                                                          1,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    const Divider(
                                                                      thickness:
                                                                          1,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          const Text(
                                                                              'Total'),
                                                                          Text(getCurrencySeparator(
                                                                              (totalPrice).toString())),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const Divider(
                                                                      thickness:
                                                                          1,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          const Text(
                                                                              'Bayar'),
                                                                          Text(getCurrencySeparator(bayarController
                                                                              .text
                                                                              .toString())),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const Divider(
                                                                      thickness:
                                                                          1,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              8),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          const Text(
                                                                              'Kembalian'),
                                                                          Text(getCurrencySeparator(
                                                                              (int.parse(bayarController.text) - (totalPrice)).toString())),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const Divider(
                                                                      thickness:
                                                                          1,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          CustomButton(
                                                                            onTap:
                                                                                () {
                                                                              totalPrice = 0;
                                                                              totalPajak = 0;
                                                                              _scaffoldKey.currentState!.closeEndDrawer();
                                                                              bayarController.clear();
                                                                              orders.clear();
                                                                              setState(() {});
                                                                              Navigator.pop(context);
                                                                            },
                                                                            title:
                                                                                const Text(
                                                                              ' Kembali ',
                                                                              style: TextStyle(
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                            bgColor:
                                                                                Colors.grey,
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          CustomButton(
                                                                            onTap:
                                                                                () {
                                                                              printer.printCustom(SettingSharedPreferences.getNamaWarung() ?? '', 2, 1);
                                                                              printer.printCustom(SettingSharedPreferences.getAlamatWarung() ?? '', 0, 1);
                                                                              printer.printCustom('Date : ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}', 0, 1);
                                                                              printer.printCustom('==============================', 0, 1);
                                                                              for (var order in orders) {
                                                                                printer.printCustom(order.product.productName, 0, 0);
                                                                                printer.printLeftRight('${order.quantity} x ${getThousandSeparator(order.product.price.toString())}', getThousandSeparator((int.parse(order.product.price) * order.quantity).toString()), 0);
                                                                              }
                                                                              printer.printNewLine();
                                                                              printer.printCustom('................................', 0, 1);
                                                                              printer.printLeftRight('Sub Total', 'Rp ${getCurrencySeparator(totalPrice.toString())}', 0);
                                                                              printer.printLeftRight('Total', 'Rp ${getCurrencySeparator((totalPrice).toString())}', 0);
                                                                              printer.printLeftRight('Bayar', 'Rp ${getCurrencySeparator(bayarController.text.toString())}', 0);
                                                                              printer.printLeftRight('Kembalian', 'Rp ${getCurrencySeparator((int.parse(bayarController.text) - (totalPrice)).toString())}', 0);
                                                                              printer.printNewLine();
                                                                              printer.printCustom('Terima Kasih', 1, 1);
                                                                              printer.paperCut();
                                                                              totalPrice = 0;
                                                                              totalPajak = 0;
                                                                              _scaffoldKey.currentState!.closeEndDrawer();
                                                                              bayarController.clear();
                                                                              orders.clear();
                                                                              setState(() {});
                                                                              Navigator.pop(context);
                                                                            },
                                                                            title:
                                                                                const Text(
                                                                              ' Print Nota ',
                                                                              style: TextStyle(
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                  child: isPressOrder
                                                      ? const CircularProgressIndicator()
                                                      : const Text(
                                                          'bayar',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 20),
                                bgColor: Colors.red,
                                title: Text(
                                  'Bayar',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .copyWith(
                                          fontSize: 24, color: Colors.white),
                                ),
                                borderRadius: 0,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: FadedScaleAnimation(
          child: Row(
            children: [
              InkWell(
                onDoubleTap: () {
                  showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        return SimpleDialog(
                          title: const Center(child: Text('SETORAN KASIR')),
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Center(
                                  child: Text(
                                'Rp. 1.000.000',
                                style: TextStyle(
                                  fontSize: 24,
                                ),
                              )),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () {},
                                  child: const Text(
                                    'SETOR',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black),
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(context,
                                        MaterialPageRoute(builder: (context) {
                                      return const LoginPage();
                                    }), (route) => false);
                                  },
                                  child: const Text(
                                    'LOGOUT',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                            ),
                          ],
                        );
                      });
                },
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        letterSpacing: 1, fontWeight: FontWeight.bold),
                    children: const <TextSpan>[
                      TextSpan(
                        text: 'AMAZINK',
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        letterSpacing: 1, fontWeight: FontWeight.bold),
                    children: const <TextSpan>[
                      TextSpan(
                          text: 'POS', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
              CustomButton(
                margin: const EdgeInsets.only(left: 10),
                onTap: () async {
                  if (SettingSharedPreferences.getUrlServer() != null) {
                    urlController.text =
                        SettingSharedPreferences.getUrlServer()!;
                  }
                  if (SettingSharedPreferences.getNamaWarung() != null) {
                    namaWarungController.text =
                        SettingSharedPreferences.getNamaWarung()!;
                  }
                  if (SettingSharedPreferences.getAlamatWarung() != null) {
                    alamatWarungController.text =
                        SettingSharedPreferences.getAlamatWarung()!;
                  }
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Setting'),
                        content: SingleChildScrollView(
                          child: SizedBox(
                            width: 400,
                            child: ListBody(
                              children: [
                                TextFormField(
                                  maxLength: 150,
                                  controller: urlController,
                                  decoration: const InputDecoration(
                                    labelText: 'Url Server',
                                    labelStyle: TextStyle(
                                      color: Colors.blueGrey,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    helperText: "Url Server?",
                                  ),
                                  onChanged: (value) {},
                                ),
                                TextFormField(
                                  maxLength: 50,
                                  controller: namaWarungController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama Warung',
                                    labelStyle: TextStyle(
                                      color: Colors.blueGrey,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    helperText: "Nama Warung?",
                                  ),
                                  onChanged: (value) {},
                                ),
                                TextFormField(
                                  maxLength: 200,
                                  maxLines: 4,
                                  controller: alamatWarungController,
                                  decoration: const InputDecoration(
                                    labelText: 'Alamat Warung',
                                    labelStyle: TextStyle(
                                      color: Colors.blueGrey,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    helperText: "Alamat Warung?",
                                  ),
                                  onChanged: (value) {},
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("No"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () async {
                              if (urlController.text.isNotEmpty ||
                                  namaWarungController.text.isNotEmpty ||
                                  alamatWarungController.text.isNotEmpty) {
                                SettingSharedPreferences.setSetting(
                                  urlStr: urlController.text,
                                  namaWarungStr: namaWarungController.text,
                                  alamatWarungStr: alamatWarungController.text,
                                );
                                showSnack(
                                  context,
                                  'Setting berhasil di update',
                                );
                                Navigator.pop(context);
                              } else {
                                await showDialog<void>(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Info'),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: const <Widget>[
                                            Text(
                                                'Url, nama, dan alamat warung wajib diisi.'),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueGrey,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Ok"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: const Text("Yes"),
                          ),
                        ],
                      );
                    },
                  );
                },
                title: const Icon(
                  Icons.settings,
                ),
                bgColor: Colors.red,
              ),
              CustomButton(
                margin: const EdgeInsets.only(left: 10),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return const ReportPage();
                  }));
                },
                title: const Icon(
                  Icons.note,
                ),
                bgColor: Colors.red,
              ),
              CustomButton(
                margin: const EdgeInsets.only(left: 10),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Center(
                          child: Column(
                            children: [
                              const Text('Kirim Ke Server'),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                  'Last sent: ${lastSent == null ? '-' : lastSent!.dateTimeFormat()}'),
                            ],
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 2),
                            child: FutureBuilder(
                              future: getDeposit(),
                              builder: (context, snapshot) {
                                return Text(
                                    'Pendapatan: ${(snapshot.data?.pendapatan)}');
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 2),
                            child: FutureBuilder(
                              future: getDeposit(),
                              builder: (context, snapshot) {
                                return Text(
                                    'Pengeluaran: ${(snapshot.data?.pengeluaran)}');
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: FutureBuilder(
                              future: getDeposit(),
                              builder: (context, snapshot) {
                                return Text(
                                    'Setoran: Rp ${(snapshot.data?.setoran)}');
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: CustomButton(
                              onTap: buttonEnabled
                                  ? () {
                                      Navigator.pop(context);
                                      _onSendingData();
                                    }
                                  : () {},
                              title: const Text(
                                'Upload',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                title: const Icon(Icons.upload_file),
                bgColor: Colors.red,
              ),
              CustomButton(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return const CashoutPage();
                  }));
                },
                margin: const EdgeInsets.only(left: 10),
                title: const Text('Kas Keluar'),
                bgColor: Colors.red,
              )
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: CustomButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrintPage()),
                );
              },
              title: Row(
                children: const [
                  SizedBox(
                    width: 8,
                  ),
                  Text('Set Printer'),
                  SizedBox(
                    width: 4,
                  ),
                  Icon(Icons.print),
                  SizedBox(
                    width: 8,
                  ),
                ],
              ),
              bgColor: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CustomButton(
              onTap: () async {
                await getCategory();
                await getProduct();
                refreshData();
                showSnack(context, 'Update Product Success');
              },
              title: Row(
                children: const [
                  SizedBox(
                    width: 8,
                  ),
                  Text('Update Produk'),
                  SizedBox(
                    width: 4,
                  ),
                  Icon(Icons.refresh),
                  SizedBox(
                    width: 8,
                  ),
                ],
              ),
              bgColor: Colors.black,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          buildItemsInCartButton(context, totalPrice),
          const SizedBox(
            width: 16,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : listProduct.isEmpty
              ? const Center(
                  child: Text(
                      'Tidak ada data product, please update data product!'),
                )
              : Container(
                  color: Theme.of(context).backgroundColor,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: listCategory.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    currentIndex = index;
                                    _pageController.jumpToPage(currentIndex);
                                  });
                                },
                                child: Container(
                                  height: 80,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: currentIndex == index
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                            .scaffoldBackgroundColor,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: CachedNetworkImage(
                                          imageUrl: listCategory[index].picture,
                                          fit: BoxFit.cover,
                                        ),
                                        // Image.network(
                                        //   listCategory[index].picture,
                                        //   fit: BoxFit.cover,
                                        // ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        listCategory[index]
                                            .categoryName
                                            .toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .copyWith(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                      Expanded(
                        child: PageView(
                          physics: const BouncingScrollPhysics(),
                          controller: _pageController,
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          children: listCategory
                              .map((e) =>
                                  buildPage(e, handleClickProduct, orders))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  CustomButton buildItemsInCartButton(BuildContext context, int totalPrice) {
    return CustomButton(
      onTap: () {
        setState(() {
          drawerCount = 0;
          _scaffoldKey.currentState!.openEndDrawer();
        });
        if (itemSelected) {}
      },
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      title: Text(
        'Rp. ${getThousandSeparator(totalPrice.toString())}',
        style: Theme.of(context)
            .textTheme
            .bodyText1
            ?.copyWith(color: Colors.white),
      ),
      bgColor: Colors.red,
    );
  }

  Widget buildPage(Category category, void Function(Product) onTapHandling,
      List<OrderItem> orders) {
    var newListProduct = listProduct
        .where((element) => element.categoryId == category.id)
        .toList();
    return GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsetsDirectional.only(
            top: 16, bottom: 16, start: 16, end: 32),
        itemCount: newListProduct.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).scaffoldBackgroundColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 22,
                  child: GestureDetector(
                    onTap: () {
                      onTapHandling(newListProduct[index]);
                    },
                    child: Stack(
                      children: [
                        FadedScaleAnimation(
                          child: CachedNetworkImage(
                            imageUrl: newListProduct[index].picture,
                            // fit: BoxFit.cover,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        orders.any((element) =>
                                element.product == newListProduct[index])
                            ? Opacity(
                                opacity: 0.4,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10),
                                    ),
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        orders.any((element) =>
                                element.product == newListProduct[index])
                            ? Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 6),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.white,
                                          child: Text(
                                            orders
                                                .firstWhere((element) =>
                                                    element.product ==
                                                    newListProduct[index])
                                                .quantity
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1!
                                                .copyWith(
                                                  fontSize: 24,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    newListProduct[index].productName,
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Text(
                          'Rp ${getThousandSeparator(newListProduct[index].price)}'),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          );
        });
  }

  Future<void> sentToServer() async {
    List<Order> orders = await AmazinkDatabase.instance.readAllOrder();

    var dio = Dio();
    String urlServer = SettingSharedPreferences.getUrlServer() ?? '';

    List<Map<String, dynamic>> dataToSend = [];

    for (final item in orders) {
      List<OrderDetail> details =
          await AmazinkDatabase.instance.readAllOrderDetail(item.id);
      List<Map<String, dynamic>> productData = [];

      for (final detail in details) {
        productData.add({
          'produk_id': detail.product_id,
          'qty': detail.qty,
          'price': detail.price,
        });
      }

      Map<String, dynamic> transactionData = {
        'id': item.id,
        'tanggal': item.transactionTime.toString(),
        'nilai': item.total,
        'bayar': item.pay,
        'produk': productData,
      };

      dataToSend.add(transactionData);
    }

    Response response;

    try {
      response = await dio.post(
        '$urlServer/publish/addTransaction',
        data: {'head': dataToSend},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.data);
        var code = responseData['code'];
        var updateData = responseData['update'];
        if (code == 201) {
          for (var updateItem in updateData) {
            var posId = updateItem['pos_id'];
            AmazinkDatabase.instance.updateOrder(posId);
          }
        }
      }
    } catch (error) {
      showSnack(context, 'Error sending data to server: $error');
    }
  }
}
