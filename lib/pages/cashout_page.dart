import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pos_amazink/models/rekening.dart';
import 'package:pos_amazink/utils/amazink_database.dart';
import 'dart:math' as math;

import 'package:expansion_widget/expansion_widget.dart';
import 'package:pos_amazink/utils/date_ext.dart';

import '../utils/setting_shared_preferences.dart';
import '../utils/text_utils.dart';

class CashoutPage extends StatefulWidget {
  const CashoutPage({super.key});

  @override
  State<CashoutPage> createState() => _CashoutPageState();
}

class _CashoutPageState extends State<CashoutPage> {
  List<Cashout> cashouts = [];
  final keperluanController = TextEditingController();
  final nominalController = TextEditingController();
  int total = 0;
  DateTime? selectedDate;
  Rekening selected = Rekening(
      rekening_code: '410100061', rekening_name: 'Belanja bahan baku makanan');
  List<Rekening> rekeningList = [
    Rekening(
        rekening_code: '410100061',
        rekening_name: 'Belanja bahan baku makanan'),
    Rekening(
        rekening_code: '410100062',
        rekening_name: 'Belanja bahan baku minuman'),
    Rekening(
        rekening_code: '410100063', rekening_name: 'Belanja bahan baku snack'),
    Rekening(rekening_code: '110510001', rekening_name: 'Kas bon'),
  ];

  @override
  void initState() {
    super.initState();
    AmazinkDatabase.instance
        .getCashoutByDate(DateTime.now().dateFormat())
        .then((value) {
      setState(() {
        cashouts = value;
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
                        text: 'KAS KELUAR - AMAZINK',
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
              ElevatedButton(
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Kas Keluar'),
                        content: SingleChildScrollView(
                          child: SizedBox(
                            width: 400,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Rekening',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                DropdownButton<Rekening>(
                                  value: selected,
                                  items: rekeningList
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e.rekening_name),
                                          ))
                                      .toList(),
                                  onChanged: (Rekening? val) {
                                    setState(() {
                                      if (val != null) selected = val;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                const Text(
                                  'Keperluan',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                TextFormField(
                                  controller: keperluanController,
                                  maxLines: 2,
                                  maxLength: 200,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                const Text(
                                  'Nominal',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                TextFormField(
                                  controller: nominalController,
                                  maxLines: 1,
                                  maxLength: 10,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
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
                              if (keperluanController.text.isNotEmpty &&
                                  nominalController.text.isNotEmpty) {
                                int id = await AmazinkDatabase.instance
                                    .createCashout(
                                  rekening: selected.rekening_code,
                                  rekening_name: selected.rekening_name,
                                  tanggal: DateTime.now().dateFormat(),
                                  keperluan: keperluanController.text,
                                  nominal: nominalController.text,
                                );

                                final dataRequest = Cashout(
                                  id: id,
                                  rekening: selected.rekening_code,
                                  rekening_name: selected.rekening_name,
                                  tanggal: DateTime.now().dateFormat(),
                                  keperluan: keperluanController.text,
                                  nominal: nominalController.text,
                                );

                                var dio = Dio();
                                String urlServer =
                                    SettingSharedPreferences.getUrlServer() ??
                                        '';
                                final response = await dio.post(
                                  '$urlServer/publish/addCashOut',
                                  data: dataRequest.toMap(),
                                );
                                nominalController.text = '';
                                keperluanController.text = '';
                                if (response.statusCode == 200) {
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  await showDialog<void>(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Info'),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: const <Widget>[
                                              Text('Kirim data Kas Berhasil.'),
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
                                  AmazinkDatabase.instance
                                      .getCashoutByDate(
                                          DateTime.now().dateFormat())
                                      .then((value) {
                                    setState(() {
                                      cashouts = value;
                                    });
                                  });
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
                                              Text('Kirim data Kas Gagal.'),
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
                                            Text('Semua wajib diisi.'),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('TAMBAH KAS KELUAR'),
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Text('ID.'),
                    SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                      width: 150,
                      child: Text('REKENING'),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                      width: 100,
                      child: Text('TANGGAL'),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                      width: 300,
                      child: Text('KEPERLUAN'),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text('NOMINAL'),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (_, index) {
                    return Card(
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('${cashouts[index].id}.'),
                          const SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                            width: 150,
                            child: Text(cashouts[index].rekening_name),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(cashouts[index].tanggal),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                            width: 300,
                            child: Text(
                              cashouts[index].keperluan.substring(
                                  0,
                                  cashouts[index].keperluan.length > 60
                                      ? 60
                                      : cashouts[index].keperluan.length),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(cashouts[index].nominal),
                        ],
                      ),
                    );
                  },
                  itemCount: cashouts.length,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
