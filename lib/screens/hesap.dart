import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:restorente/screens/masa.dart';
import 'package:flutter/material.dart';
import 'package:restorente/screens/masalar.dart';
const String baseUrl = "http://192.168.1.10:5000/api";

// ignore: camel_case_types
class hesap extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const hesap({
    Key? key,
    required this.ms,
    Key? key2,
    required this.kisi,
    Key? key3,
    required this.kid,
  });
  final String kisi;
  final String kid;
  final String ms;

  @override
  State<hesap> createState() => _hesapState();
}

// ignore: camel_case_types
class _hesapState extends State<hesap> {
  bool isLoading = false;

  List<SptMhsp> hspliste = [];
  double hsp = 0;
  // ignore: non_constant_identifier_names

  List<SptMhsp> sepethsp = [];

  @override
  void initState() {
 
     sepet();
    super.initState();
  }

 Future<void> sepet() async {
  hspliste.clear();
  sepethsp.clear();
  setState(() => isLoading = true);

  try {
    final response = await http.get(
      Uri.parse("$baseUrl/hesap/${widget.ms}/1"), // ony=1
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
    jsonDecode(utf8.decode(response.bodyBytes));

      hspliste.clear();
      sepethsp.clear();
      double toplamHsp = 0;

      for (var element in data["detay"]) {
        final spt = SptMhsp.fromJson(element);
        hspliste.add(spt);
        toplamHsp += spt.tpl;
        sepethsp.add(spt);
      }

      // Eğer sepet boşsa
      if (sepethsp.isEmpty) {
        sepethsp.add(
          SptMhsp(
            urunadi: "",
            satis: 0,
            adet: 0,
            notlar: "0",
            tpl: 0,
          ),
        );
      }

      hsp = toplamHsp;
    } else {
      // Hata varsa konsola bas
      print("Sepet çekme hatası: ${response.statusCode}");
    }
  } catch (e) {
    print("Sepet çekme hatası: $e");
  }

  setState(() {
    isLoading = false;
  });
}
 
 Future<void> tamamla() async {
  await http.put(
    Uri.parse(
      "$baseUrl/Hesap/fguncelle/${widget.ms}",
    ),
  );
}
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "${widget.ms.toUpperCase()} HESAP",
            style: const TextStyle(color: Color.fromARGB(255, 255, 213, 129)),
          ),
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (isLoading)
                Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 1.2,
                      alignment: Alignment.center,
                      child: const SizedBox(
                        height: 80.0,
                        width: 80.0,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 8,
                        ),
                      ),
                    ),
                    const Text("YÜKLENİYOR....")
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              height: 40,
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => masa(
                                                  ms: widget.ms,
                                                  kisi: widget.kisi,
                                                  kid: widget.kid,
                                                )));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(2),
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      // side: BorderSide(
                                      //   width: 1,
                                      //   color: Color.fromARGB(255, 255, 213, 129),
                                      // )
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.white,
                                      ),
                                      Text(' MASAYA DÖN',
                                          style: TextStyle(
                                            color: Colors.white,
                                          )),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2.01,
                              height: 40,
                              child: ElevatedButton(
                                
                                onPressed: () async {
                                  try {
                                  await tamamla();
                                   } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Masalar(
                                                kisim: widget.kisi,
                                                kid: widget.kid,
                                              )));
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(2),
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                ),
                                child: const Text(
                                  "YAZDIR",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.25,
                      width: MediaQuery.of(context).size.width / 1.1,
                      child: ListView.builder(
                        //shrinkWrap: true,
                        itemCount: sepethsp.length,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 40,
                            color: Colors.white,
                            child: sepethsp[index].urunadi.trim().isEmpty
                                ? const Text(
                                    "Sepet Boş",
                                    textAlign: TextAlign.center,
                                  )
                                : sepethsp[index].notlar.trim().isEmpty
                                    ? Text(
                                        "${sepethsp[index].urunadi} \n ${sepethsp[index].adet} x ${sepethsp[index].satis} = ${sepethsp[index].tpl}",
                                      )
                                    : Text(
                                        "${sepethsp[index].urunadi} (${sepethsp[index].notlar.trim()}) \n ${sepethsp[index].adet} x ${sepethsp[index].satis} = ${sepethsp[index].tpl}",
                                      ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      width: MediaQuery.of(context).size.width / 1.2,
                      child: Text(
                        " Toplam Hesap $hsp TL",
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 18),
                      ),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SptMhsp {
  final String urunadi;
  final double satis;
  final double adet;
  final String notlar;
  final double tpl; // biz içeride tpl diyoruz ama API'de tutar

  SptMhsp({
    required this.urunadi,
    required this.satis,
    required this.adet,
    required this.notlar,
    required this.tpl,
  });
  factory SptMhsp.fromJson(Map<String, dynamic> json) {
    return SptMhsp(
      urunadi: json['urunadi'].toString().trim(),
      satis: double.parse(json['satis'].toString()),
      adet: double.parse(json['adet'].toString()),
      notlar: json['notlar']?.toString().trim() ?? "",
      tpl: double.parse(json['tutar'].toString()), //
    );
  }
}

class TestModel {
  final String isim;
  final String durum;

  TestModel({
    required this.isim,
    required this.durum,
  });
}


  

