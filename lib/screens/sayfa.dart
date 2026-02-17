import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Sayfa extends StatefulWidget {
  const Sayfa({super.key, required this.masa});

  final String masa;

  @override
  State<Sayfa> createState() => _SayfaState();
}

class _SayfaState extends State<Sayfa> {
  bool isLoading = true;
  double toplam = 0;

  final String baseUrl = "http://192.168.1.10:5000/api";

  @override
  void initState() {
    super.initState();
    toplamGetir();
  }

  Future<void> toplamGetir() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/sepet/toplam/${widget.masa}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        toplam = double.parse(data["toplam"].toString());
      }
    } catch (_) {}

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 171, 4),
      appBar: AppBar(
        title: const Text(
          'HESAP',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 6,
                  ),
                  SizedBox(height: 10),
                  Text("YÜKLENİYOR...")
                ],
              )
            : Text(
                "$toplam TL",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
