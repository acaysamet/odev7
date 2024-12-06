import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Öğrenci CRUD Uygulaması',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: OgrenciListesi(),
    );
  }
}

class OgrenciListesi extends StatefulWidget {
  @override
  _OgrenciListesiState createState() => _OgrenciListesiState();
}

class _OgrenciListesiState extends State<OgrenciListesi> {
  List ogrenciler = [];
  final String apiUrl =
      'http://localhost:3000/ogrenci'; // API URL'sini güncelleyin

  final TextEditingController adController = TextEditingController();
  final TextEditingController soyadController = TextEditingController();
  final TextEditingController bolumIdController = TextEditingController();
  int? selectedId;

  @override
  void initState() {
    super.initState();
    fetchOgrenciler();
  }

  // Öğrenci Listeleme
  Future<void> fetchOgrenciler() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        ogrenciler = json.decode(response.body);
      });
    } else {
      print('Öğrenciler alınamadı: ${response.statusCode}');
    }
  }

  // Öğrenci Ekleme
  Future<void> addOgrenci() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'ad': adController.text,
        'Soyad': soyadController.text,
        'BolumId': int.tryParse(bolumIdController.text) ?? 0,
      }),
    );
    if (response.statusCode == 200) {
      fetchOgrenciler();
      clearFields();
    } else {
      print('Öğrenci eklenemedi: ${response.statusCode}');
    }
  }

  // Öğrenci Güncelleme
  Future<void> updateOgrenci() async {
    if (selectedId != null) {
      final response = await http.put(
        Uri.parse('$apiUrl/$selectedId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ad': adController.text,
          'Soyad': soyadController.text,
          'BolumId': int.tryParse(bolumIdController.text) ?? 0,
        }),
      );
      if (response.statusCode == 200) {
        fetchOgrenciler();
        clearFields();
        setState(() {
          selectedId = null;
        });
      } else {
        print('Öğrenci güncellenemedi: ${response.statusCode}');
      }
    }
  }

  // Öğrenci Silme
  Future<void> deleteOgrenci(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));
    if (response.statusCode == 200) {
      fetchOgrenciler();
    } else {
      print('Öğrenci silinemedi: ${response.statusCode}');
    }
  }

  // Input alanlarını temizleme
  void clearFields() {
    adController.clear();
    soyadController.clear();
    bolumIdController.clear();
  }

  // Öğrenci Seçme (Güncelleme için)
  void selectOgrenci(int id, String ad, String soyad, int bolumId) {
    setState(() {
      selectedId = id;
      adController.text = ad;
      soyadController.text = soyad;
      bolumIdController.text = bolumId.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Öğrenci CRUD Uygulaması'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Öğrenci Ekleme / Güncelleme Formu
            TextField(
              controller: adController,
              decoration: InputDecoration(labelText: 'Ad'),
            ),
            TextField(
              controller: soyadController,
              decoration: InputDecoration(labelText: 'Soyad'),
            ),
            TextField(
              controller: bolumIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Bölüm ID'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: addOgrenci,
                  child: Text('Ekle'),
                ),
                ElevatedButton(
                  onPressed: updateOgrenci,
                  child: Text('Güncelle'),
                ),
              ],
            ),
            // Öğrenci Listeleme
            Expanded(
              child: ListView.builder(
                itemCount: ogrenciler.length,
                itemBuilder: (context, index) {
                  final ogrenci = ogrenciler[index];
                  return ListTile(
                    title: Text('${ogrenci['ad']} ${ogrenci['Soyad']}'),
                    subtitle: Text('Bölüm ID: ${ogrenci['BolumId']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => selectOgrenci(
                            ogrenci['ogrenciID'],
                            ogrenci['ad'],
                            ogrenci['Soyad'],
                            ogrenci['BolumId'],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteOgrenci(ogrenci['ogrenciID']),
                        ),
                      ],
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
