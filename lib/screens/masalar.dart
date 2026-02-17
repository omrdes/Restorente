import 'dart:async';
import 'package:flutter/material.dart';
import 'package:restorente/screens/masa.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
const String baseUrl = "http://192.168.1.10:5000/api";
class Masalar extends StatefulWidget {
  const Masalar({super.key, required this.kisim, required this.kid});

  final String kisim;
  final String kid;

  @override
  State<Masalar> createState() => _MasalarState();
}

class _MasalarState extends State<Masalar> {
  bool isLoading = false;

  List<KatModel> kategoriler = [];
  List<MasaModel> masalar = [];

  String seciliUid = "1"; // ilk açılış uid

  @override
  void initState() {
    super.initState();
    fetchKategoriler();
    fetchMasalar();
    Timer.periodic(const Duration(seconds: 10), (_) => fetchMasalar());
  }

  /* ---------------- KATEGORİLER ---------------- */


Future<void> fetchKategoriler() async {
  try {
    var res = await http.get(Uri.parse("$baseUrl/kat"));
    if (res.statusCode == 200) {
      List data = json.decode(res.body);

      setState(() {
        kategoriler = data
            .map((e) => KatModel(
                  id: e['id'].toString(),
                  isim: e['isim'].toString(),
                ))
            .toList();
      });
      // ignore: avoid_print
      print(kategoriler.toString());
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}


  /* ---------------- MASALAR ---------------- */

  Future<void> fetchMasalar() async {
    setState(() => isLoading = true);
    try {
      var res = await http.get(
        Uri.parse("$baseUrl/masa/$seciliUid"),
      );

      if (res.statusCode == 200) {
        List data = json.decode(res.body);
        masalar = data
            .map((e) => MasaModel(
                  isim: e['isim'].toString().trim(),
                  durum: e['durum'].toString(),
                  sure: e['asure'] != null
                      ? e['asure'].toString().substring(11, 16)
                      : "",
                ))
            .toList();
      }
    } catch (_) {}
    setState(() => isLoading = false);
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 213, 129),
        appBar: AppBar(
          title: const Text('MASALAR', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
        ),
        body: Column(
          children: [

            /* ====== ÜST KATEGORİ BUTONLARI ====== */
SizedBox(
  height: 45,
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(), // iOS / POS hissi
    child: Row(
      children: kategoriler.map((k) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: 
        SizedBox(
  height:70,
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
    child: Row(
      children: kategoriler.map((k) {
        return SizedBox(
          width: 137, // Expanded yerine sabit genişlik (yatay scroll için şart)
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    seciliUid == k.id ? const Color.fromARGB(226, 128, 14, 1) : const Color.fromARGB(160, 13, 13, 13), 
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              onPressed: () {
                setState(() {
                  seciliUid = k.id;
                });
                fetchMasalar();
              },
              child: Text(
                k.isim,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    ),
  ),
),

        );
      }).toList(),
    ),
  ),
),


            /* ====== MASALAR ====== */
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 8,
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(3),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                        childAspectRatio: 2.2 / 1,
                      ),
                      itemCount: masalar.length,
                      itemBuilder: (context, index) {
                        final m = masalar[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => masa(
                                  ms: m.isim,
                                  kisi: widget.kisim,
                                  kid: widget.kid,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            color: m.durum == "0"
                                ? Colors.black
                                : Colors.white,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    m.isim,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: m.durum == "0"
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                m.durum == "1"
                                    ? Text(
                                        m.sure,
                                        style: TextStyle(
                                            color: Colors.grey[850]),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= MODELLER ================= */

class KatModel {
  final String id;
  final String isim;
  KatModel({required this.id, required this.isim});
}

class MasaModel {
  final String isim;
  final String durum;
  final String sure;
  MasaModel(
      {required this.isim, required this.durum, required this.sure});
}
