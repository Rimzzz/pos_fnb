import 'dart:convert';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pos_amazink/utils/amazink_database.dart';
import 'dart:math' as math;

import 'package:expansion_widget/expansion_widget.dart';

import '../utils/setting_shared_preferences.dart';
import '../utils/text_utils.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<Order> orders = [];
  int total = 0;
  DateTime? selectedDate;

  BlueThermalPrinter printer = BlueThermalPrinter.instance;

  @override
  void initState() {
    super.initState();
    AmazinkDatabase.instance.readAllOrder().then((value) {
      setState(() {
        orders = value;
        for (final o in orders) {
          total += int.parse(o.total);
        }
      });
    });
  }

  Future<void> reloadData() async {
    List<Order> updatedOrders = await AmazinkDatabase.instance.readAllOrder();
    setState(() {
      orders = updatedOrders;
      total = 0;
      for (final o in orders) {
        total += int.parse(o.total);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: true,

          backgroundColor: Colors.white,
          title: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              InkWell(
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        letterSpacing: 1, fontWeight: FontWeight.bold),
                    children: const <TextSpan>[
                      TextSpan(
                        text: 'REPORT - AMAZINK',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              RichText(
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(letterSpacing: 1, fontWeight: FontWeight.bold),
                  children: const <TextSpan>[
                    TextSpan(text: 'POS', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 16,
              ),
              Text(selectedDate != null
                  ? 'Saldo ${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year} : $total'
                  : 'Saldo Saat Ini : ${getThousandSeparator(total.toString())}'),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate:
                        selectedDate != null ? selectedDate! : DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                    AmazinkDatabase.instance
                        .getOrdersByDate(
                            DateFormat('yyyy-MM-dd').format(selectedDate!))
                        .then((value) {
                      setState(() {
                        orders = value;
                        for (final o in orders) {
                          total += int.parse(o.total);
                        }
                      });
                    });
                    // setState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(selectedDate == null
                    ? 'Pilih Tanggal'
                    : '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}'),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('No.'),
                    Text('Waktu Order'),
                    Text('Bayar'),
                    Row(
                      children: [
                        Text('Total'),
                        SizedBox(
                          width: 16,
                        ),
                      ],
                    ),
                    Text('Status'),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (_, index) {
                    return Card(
                      color: Colors.white,
                      child: ExpansionWidget(
                        initiallyExpanded: false,
                        titleBuilder: (double animationValue, _, bool isExpaned,
                            toogleFunction) {
                          return InkWell(
                              onTap: () => toogleFunction(animated: true),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${index + 1}.'),
                                          Text(orders[index].transactionTime),
                                          Text(getThousandSeparator(
                                              orders[index].pay)),
                                          Text(getThousandSeparator(
                                              orders[index].total)),
                                          Text(orders[index]
                                                      .isUpdated
                                                      .toString() ==
                                                  '1'
                                              ? 'Terupload'
                                              : 'Belum Diupload'),
                                        ],
                                      ),
                                    ),
                                    Transform.rotate(
                                      angle: math.pi * animationValue / 2,
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.arrow_right,
                                          size: 40),
                                    )
                                  ],
                                ),
                              ));
                        },
                        content: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          child: FutureBuilder(
                            future: AmazinkDatabase.instance
                                .readAllOrderDetail(orders[index].id),
                            builder: (context, snapshot) {
                              return snapshot.hasData
                                  ? Column(
                                      children: [
                                        ...snapshot.data!
                                            .map(
                                              (e) => Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    width: 16,
                                                  ),
                                                  SizedBox(
                                                      width: 200,
                                                      child:
                                                          Text(e.product_name)),
                                                  const SizedBox(
                                                    width: 16,
                                                  ),
                                                  SizedBox(
                                                      width: 40,
                                                      child: Text(e.qty)),
                                                  const SizedBox(
                                                    width: 16,
                                                  ),
                                                  SizedBox(
                                                      width: 60,
                                                      child: Text(e.price)),
                                                  const SizedBox(
                                                    width: 16,
                                                  ),
                                                  SizedBox(
                                                    width: 100,
                                                    child: Text((int.parse(
                                                                e.qty) *
                                                            int.parse(e.price))
                                                        .toString()),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                int totalPrice = int.parse(
                                                    orders[index].total);
                                                double totalPajak =
                                                    ((totalPrice).toDouble() *
                                                            10) /
                                                        100;
                                                String bayar =
                                                    orders[index].pay;

                                                printer.printCustom(
                                                    SettingSharedPreferences
                                                            .getNamaWarung() ??
                                                        '',
                                                    2,
                                                    1);
                                                printer.printCustom(
                                                    SettingSharedPreferences
                                                            .getAlamatWarung() ??
                                                        '',
                                                    0,
                                                    1);
                                                printer.printCustom(
                                                    'Date : ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
                                                    0,
                                                    1);
                                                printer.printCustom(
                                                    '==============================',
                                                    0,
                                                    1);
                                                for (var order
                                                    in snapshot.data!) {
                                                  printer.printCustom(
                                                      order.product_name, 0, 0);
                                                  printer.printLeftRight(
                                                      '${order.qty} x ${getThousandSeparator(order.price.toString())}',
                                                      getThousandSeparator((int
                                                                  .parse(order
                                                                      .price) *
                                                              int.parse(
                                                                  order.qty))
                                                          .toString()),
                                                      0);
                                                }
                                                printer.printNewLine();
                                                printer.printCustom(
                                                    '................................',
                                                    0,
                                                    1);
                                                printer.printLeftRight(
                                                    'Sub Total',
                                                    'Rp ${getCurrencySeparator(totalPrice.toString())}',
                                                    0);
                                                printer.printLeftRight(
                                                    'Pajak',
                                                    'Rp ${getCurrencySeparator(totalPajak.toString())}',
                                                    0);
                                                printer.printLeftRight(
                                                    'Total',
                                                    'Rp ${getCurrencySeparator((totalPrice + totalPajak).toString())}',
                                                    0);
                                                printer.printLeftRight(
                                                    'Bayar',
                                                    'Rp ${getCurrencySeparator(bayar.toString())}',
                                                    0);
                                                printer.printLeftRight(
                                                    'Kembalian',
                                                    'Rp ${getCurrencySeparator((int.parse(bayar) - (totalPrice + totalPajak)).toString())}',
                                                    0);
                                                printer.printNewLine();
                                                printer.printCustom(
                                                    'Terima Kasih', 1, 1);
                                                printer.paperCut();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: const Text('Print Note'),
                                            ),
                                            const SizedBox(width: 16),
                                            ElevatedButton(
                                              onPressed: () async {
                                                var dio = Dio();
                                                String urlServer =
                                                    SettingSharedPreferences
                                                            .getUrlServer() ??
                                                        '';
                                                List<Map<String, dynamic>>
                                                    dataToSend = [];
                                                List<Map<String, dynamic>>
                                                    productData = [];

                                                for (var order
                                                    in snapshot.data!) {
                                                  productData.add({
                                                    'produk_id':
                                                        order.product_id,
                                                    'qty': order.qty,
                                                    'price': order.price,
                                                  });
                                                }

                                                Map<String, dynamic>
                                                    transactionData = {
                                                  'id': orders[index].id,
                                                  'tanggal': orders[index]
                                                      .transactionTime
                                                      .toString(),
                                                  'nilai': orders[index].total,
                                                  'bayar': orders[index].pay,
                                                  'produk': productData,
                                                };
                                                dataToSend.add(transactionData);
                                                try {
                                                  Response response =
                                                      await dio.post(
                                                    '$urlServer/publish/addTransaction',
                                                    data: {'head': dataToSend},
                                                  );
                                                  if (response.statusCode ==
                                                      200) {
                                                    var responseData = json
                                                        .decode(response.data);
                                                    var code =
                                                        responseData['code'];
                                                    var updateData =
                                                        responseData['update'];
                                                    if (code == 201) {
                                                      for (var updateItem
                                                          in updateData) {
                                                        var posId = updateItem[
                                                            'pos_id'];
                                                        AmazinkDatabase.instance
                                                            .updateOrder(posId);
                                                      }
                                                      showSnack(context,
                                                          'Transaksi berhasil kirim ke server');
                                                      await reloadData();
                                                    }
                                                  }
                                                } catch (error) {
                                                  showSnack(context,
                                                      'Error sending data to server: $error');
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                              ),
                                              child: const Text('Kirim Server'),
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: orders.length,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
