import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pos_amazink/utils/amazink_database.dart';
import 'dart:math' as math;

import 'package:expansion_widget/expansion_widget.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<Order> orders = [];
  int total = 0;
  DateTime? selectedDate;
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
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
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
                      .subtitle1!
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
                  : 'Saldo Saat Ini : $total'),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('No.'),
                    const Text('Waktu Order'),
                    const Text('Bayar'),
                    Row(
                      children: const [
                        Text('Total'),
                        SizedBox(
                          width: 16,
                        ),
                      ],
                    ),
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
                                          Text(orders[index].pay),
                                          Text(orders[index].total),
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
                                      children: snapshot.data!
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
