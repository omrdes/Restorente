import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:http/http.dart' as http;
import 'package:restorente/screens/hesap.dart';
import 'package:restorente/screens/masalar.dart';
const String baseUrl = "http://192.168.1.10:5000/api";

// ignore: camel_case_types
class masa extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const masa({
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
  State<masa> createState() => _masaState();
}

// ignore: camel_case_types
class _masaState extends State<masa> {
  bool isLoading = false;

  List<TestModel> ilkliste = [];
  List<SptModel> ikiliste = [];
  List<SptModel> sptliste = [];

  // ignore: non_constant_identifier_names
  List<TestModel> Ktg = [];
  List<SptModel> urunler = [];
  List<SptModel> sepetler = [];

  String ssil = "";
  String dsi = "1";
  String urunadi = "";
  String barkod = "";
  String alis = "";
  String satis = "";
  String adet = "";
  String yi = "";
  String sid = "";
  String fis = "";
  double thsp = 0;
  int sptbs = 0;
  double _n = 1.0;

  final _notyaz = TextEditingController();
  final _adet = TextEditingController();
  @override
  void initState() {
    kategori();
    urun();
    sepet();
    _adet.text = "1.0";
    super.initState();
  }

Future<void> kategori() async {
   
  ilkliste.clear();
  Ktg.clear();

  setState(() {
    isLoading = true;
  });

  final res = await http.get(
    Uri.parse("$baseUrl/kategori"),
  );

  if (res.statusCode == 200) {
    final List data = jsonDecode(res.body);

    for (var element in data) {
      ilkliste.add(
        TestModel(
          isim: element['isim'].toString(),
          durum: element['id'].toString(),
        ),
      );
    }

    Ktg.addAll(ilkliste);

    setState(() {
      isLoading = false;
    });
  }
}

Future<void> urun() async {
 
  ikiliste.clear();
  urunler.clear();

  final res = await http.get(
    Uri.parse("$baseUrl/stok/$dsi"),
  );

  if (res.statusCode == 200) {
    final List data = jsonDecode(res.body);

    for (var element in data) {
      ikiliste.add(
        SptModel(
          id: element['id'].toString(),
          urunadi: element['urunadi'] ?? "",
          barkod: element['barkod'] ?? "",
          alis: element['alis'].toString(),
          satis: element['satis'].toString(),
          adet: element['adet']?.toString() ?? "1",
          notlar: element['notlar'] ?? "",
          yi: element['yi'].toString(),
        ),
      );
    }

    urunler.addAll(ikiliste);

    if (urunler.isEmpty) {
      urunler.add(
        SptModel(
          id: "0",
          urunadi: "Boş",
          barkod: "0",
          alis: "0",
          satis: "0",
          adet: "0",
          notlar: "0",
          yi: "0",
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }
}

Future<void> sepet() async {

  sepetler.clear();

  try {
    final url = Uri.parse(
        "$baseUrl/hesap/${widget.ms}/0");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json =
          jsonDecode(response.body);

      final List detay = json['detay'];
      // ignore: unused_local_variable
      final toplam = json['toplam'];

      for (var j in detay) {
        sepetler.add(
          SptModel(
            urunadi: j['urunadi']?.toString().trim() ?? "",
            satis: j['satis'].toString(),
            adet: j['adet'].toString(),
            notlar: j['notlar']?.toString().trim() ?? "", id: j['id'].toString(), barkod: j['barkod'].toString(), alis: j['alis'].toString(), yi: j['yi'].toString(),
          ),
        );
      }


    }
  } catch (e) {
    // sessiz geç
  }

  setState(() {});
}

Future<void> sepetSil() async {
  try {
    final url =
        Uri.parse('$baseUrl/sepet/sil/$ssil');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // başarıyla silindi
      sepet();
      setState(() {});
    } else {
      // hata durumu
      // print('Silme başarısız: ${response.body}');
    }
  } catch (e) {
    // print(e.toString());
  }
}

Future<void> sptgnc() async {
  await http.put(
    Uri.parse("$baseUrl/sepet/suncelle/$sid"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "adet": adet,
    }),
  );

  sepet();
}

Future<void> sepetOnayla() async {
  final masa = widget.ms; // widget'tan alıyoruz

  // ignore: unnecessary_null_comparison
  if (masa == null || masa.isEmpty) {
    throw Exception("Masa bilgisi boş");
  }

  final uri = Uri.parse('$baseUrl/sepet/ony/$masa');


  final response = await http.get(uri);


  if (response.statusCode != 200) {
    throw Exception("Sepet onaylanamadı");
  }
}

Future<bool> masaAc() async {
  final String url = "$baseUrl/Masa/ac/${widget.ms}";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Masa başarıyla açıldı
      return true;
    
    } else {
      // API hata döndü
      print("Masa açılamadı: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("Hata oluştu: $e");
    return false;
  }
}

Future<void> sptekle() async {
final url = Uri.parse("$baseUrl/sepet/sekle");
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "uid": widget.kid,
      "urunadi": urunadi,
      "barkod": barkod,
      "alis": double.tryParse(alis) ?? 0,
      "satis": double.tryParse(satis) ?? 0,
      "adet": double.tryParse(_adet.text) ?? 1,
      "notlar": _notyaz.text,
      "masa": widget.ms,
      "atan": widget.kisi,
      "yi": yi
    }),
  );

  if (response.statusCode == 200) {
        _adet.text = "1.0";
        _notyaz.text = "";
       sepet();
      setState(() {});

  } else {
    print("Hata: ${response.statusCode}");
  }

}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.ms.toUpperCase(),
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
                Column(children: [
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
                                    Text(' MASALAR',
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
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => hesap(
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
                                ),
                              ),
                              child: const Text(
                                "MASA HESABI",
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
                  Container(
                    
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      color: const Color.fromARGB(255, 255, 213, 129),
                    ),
                    height: MediaQuery.of(context).size.height / 5.5,
                    margin: const EdgeInsets.only(top: 1),
                    child: GridView.builder(
                      //shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3 / 1,
                      ),
                      itemCount: Ktg.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            //  //print(Ktg[index].isim.toString());
                            dsi = Ktg[index].durum.toString();
                            ////print("eeeeeeeeeeeeeeeee" + dsi);
                            urun();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              color: const Color.fromARGB(255, 255, 213, 129),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        Ktg[index].isim.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            // fontSize: 18,
                                            color: Colors.black),
                                      )),
                                ]),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    color: Colors.black,
                    height: MediaQuery.of(context).size.height / 5.5,
                    child: GridView.builder(
                      //shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3 / 1,
                      ),
                      itemCount: urunler.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            urunadi = urunler[index].urunadi.toString().trim();
                            barkod = urunler[index].barkod.toString().trim();
                            alis = urunler[index].alis.toString().trim();
                            satis = urunler[index].satis.toString().trim();
                            yi = urunler[index].yi.toString().trim();

                            sptekle();
                     
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: const Color.fromARGB(255, 56, 56, 56),
                              ),
                              color: Colors.black,
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      urunler[index].urunadi.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          // fontSize: 18,
                                          color: Color.fromARGB(
                                              255, 255, 213, 129)),
                                    ),
                                  ),
                                ]),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    color: Colors.grey[400],
                    height: MediaQuery.of(context).size.height /9.6,
                    // color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: 
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    height: 55,
                                    child:
                                     TextField(
                                      controller: _adet,
                                      onChanged: (value) {
                                        _n = double.parse(_adet.text.trim());
                                      },
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        labelText: 'Sayı Gir',
                                        prefix: SizedBox(
                                          width: 45,
                                          height: 45,
                                          child: TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  if (_n > 0.5) _n = _n - 0.5;
                                                  _adet.text = _n.toString();
                                                });
                                              },
                                              child: const Text(
                                                "-",
                                                style: TextStyle(fontSize: 25),
                                              )),
                                        ),
                                        suffixIcon: SizedBox(
                                          width: 45,
                                          height: 45,
                                          child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _n++;
                                                _adet.text = _n.toString();
                                              });
                                            },
                                            child: const Text(
                                              "+",
                                              style: TextStyle(fontSize: 25),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width /1.8,
                                    child: TextField(
                                      controller: _notyaz,
                                      decoration: const InputDecoration(
                                        hintText: 'Not Yaz',
                                        border: OutlineInputBorder(),
                                        labelText: 'Not Yaz',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    height: MediaQuery.of(context).size.height / 3.4,
                    child: ListView.builder(
                      //shrinkWrap: true,
                      itemCount: sepetler.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (context) => masa(
                            //           ms: Ktg[index].isim.toString(),
                            //         )));
                          },
                          child: Container(
                            height: 70,
                            color: Colors.white,
                            child: sepetler[index].id.trim() == "0"
                                ? const Text(
                                    "Sepet Boş",
                                    textAlign: TextAlign.center,
                                  )
                                : SizedBox(
                                    height: 40,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.3,
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: sepetler[index]
                                                        .notlar
                                                        .trim()
                                                        .isEmpty
                                                    ? Text(
                                                        sepetler[index].urunadi,
                                                        textAlign:
                                                            TextAlign.center,
                                                      )
                                                    : Text(
                                                        "${sepetler[index].urunadi} (${sepetler[index].notlar.trim()})",
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.6,
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: SpinBox(
                                                        min: 0.5,
                                                        max: 999,
                                                        decimals: 1,
                                                        step: 0.5,
                                                        value: double.parse(sepetler[index].adet),

                                                        onChanged: (value) {
                                                          double yeniDeger = value;

                                                          // + basıldıysa (artan yönde)
                                                          if (value > double.parse(sepetler[index].adet)) {
                                                            yeniDeger = (value * 2).round() / 2;

                                                            // + her zaman 1 artsın
                                                            yeniDeger = double.parse(sepetler[index].adet) + 1;
                                                          }

                                                          // min koruması
                                                          if (yeniDeger < 0.5) yeniDeger = 0.5;

                                                          adet = yeniDeger.toString();
                                                          sid = sepetler[index].id.toString().trim();

                                                          sptgnc();
                                                        },

                                                        decoration: const InputDecoration(
                                                          labelText: 'Sayı Gir',
                                                        ),
                                                      ),

                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    7,
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: IconButton(
                                                  icon:
                                                      const Icon(Icons.delete),
                                         onPressed: () {
                                                    ssil = sepetler[index]
                                                        .id
                                                        .trim();
                                                    sepetSil();
                                     
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ]),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (sptbs == 0)
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      child:
                     ElevatedButton(
  onPressed: () async {
    try {
      await sepetOnayla();
      await masaAc();
      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Masalar(
            kisim: widget.kisi,
            kid: widget.kid,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  },
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.all(2),
    backgroundColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
  ),
  child: const Text("SİPARİŞİ TAMAMLA", style: TextStyle(color: Colors.white)),
)


                           ),
                ]),
            ],
          ),
        ),
      ),
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

class SptModel {
  final String id;

  final String urunadi;
  final String barkod;
  final String alis;
  final String satis;
  final String adet;
  final String notlar;

  final String yi;

  SptModel({
    required this.id,
    required this.urunadi,
    required this.barkod,
    required this.alis,
    required this.satis,
    required this.adet,
    required this.notlar,
    required this.yi,
  });
}
