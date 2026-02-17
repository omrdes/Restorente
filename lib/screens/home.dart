import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restorente/screens/masalar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _sifreController = TextEditingController();
  bool isLoading = false;
  bool hidePassword = true;

  void onError(String message) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 6),
        padding: const EdgeInsets.all(8.0),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login(String sifre) async {
    setState(() {
      isLoading = true;
    });

    try {
      // LAN üzerinden API URL
      var url = Uri.parse('http://192.168.1.10:5000/api/login');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sifre': sifre}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data != null && data['isim'] != null && data['id'] != null) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Masalar(
              kisim: data['isim'],
              kid: data['id'].toString(),
            ),
          ));
        } else {
          onError("Şifre Yanlış");
        }
      } else if (response.statusCode == 401) {
        // Yanlış şifre
        onError("Şifre Yanlış");
      } else {
        onError("Sunucu hatası: ${response.statusCode}");
      }
    } catch (e) {
      onError("Hata: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 220),
            child: Column(
              children: [
                const Image(image: AssetImage("lib/assets/image/logo.png")),
                const SizedBox(height: 20),
                TextField(
                  controller: _sifreController,
                  keyboardType: TextInputType.number,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 213, 129),
                    hintText: 'Şifreyi Gir',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: hidePassword
                          ? const Icon(Icons.visibility_off)
                          : const Icon(Icons.visibility),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10, width: 400),
                SizedBox(
                  height: 60,
                  width: 400,
                  child: ElevatedButton(
                    onPressed: () {
                      login(_sifreController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Giriş Yap',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
