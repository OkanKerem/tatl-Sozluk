import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({super.key});

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String _result = 'Test sonuçları burada görünecek';
  bool _isLoading = false;
  
  // Koleksiyonları test et
  Future<void> _testCollections() async {
    setState(() {
      _isLoading = true;
      _result = 'Koleksiyonlar test ediliyor...';
    });
    
    try {
      // Mevcut koleksiyonların listesini al
      final collections = await _listAllCollections();
      String collectionList = "Mevcut koleksiyonlar:\n";
      
      if (collections.isEmpty) {
        collectionList += "Hiç koleksiyon bulunamadı!";
      } else {
        for (var collection in collections) {
          collectionList += "- $collection\n";
          
          // Her koleksiyondaki doküman sayısını göster
          try {
            final snapshot = await _firestore.collection(collection).get();
            collectionList += "  (${snapshot.docs.length} döküman)\n";
          } catch (e) {
            collectionList += "  (Dokümanlar okunamadı: $e)\n";
          }
        }
      }
      
      setState(() {
        _result = collectionList;
      });
    } catch (e) {
      setState(() {
        _result = 'Koleksiyonları test ederken hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Manuel bir mesaj koleksiyonu oluştur
  Future<void> _createMessagesCollection() async {
    setState(() {
      _isLoading = true;
      _result = 'Messages koleksiyonu oluşturuluyor...';
    });
    
    try {
      // Test mesajı oluştur
      final testMessage = {
        'senderId': _auth.currentUser?.uid ?? 'test_sender',
        'receiverId': 'test_receiver',
        'content': 'Bu bir test mesajıdır',
        'timestamp': Timestamp.now(),
        'isRead': false,
      };
      
      // Mesajlar koleksiyonuna ekle
      final docRef = await _firestore.collection('messages').add(testMessage);
      
      setState(() {
        _result = 'Messages koleksiyonu oluşturuldu!\nTest mesajı eklendi: ${docRef.id}';
      });
    } catch (e) {
      setState(() {
        _result = 'Messages koleksiyonu oluşturulurken hata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Oturum açma durumunu kontrol et
  Future<void> _checkAuthStatus() async {
    setState(() {
      _isLoading = true;
      _result = 'Oturum açma durumu kontrol ediliyor...';
    });
    
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        setState(() {
          _result = 'Kullanıcı oturum açmış!\n'
              'UID: ${currentUser.uid}\n'
              'Email: ${currentUser.email}\n'
              'İsim: ${currentUser.displayName}';
        });
      } else {
        setState(() {
          _result = 'Kullanıcı oturum açmamış!';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Oturum durumu kontrol edilirken hata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Tüm koleksiyonları listele
  Future<List<String>> _listAllCollections() async {
    List<String> collections = [];
    
    try {
      // Firestore'dan koleksiyonları almanın doğrudan bir yolu yok
      // Bu nedenle bir root koleksiyona erişip sonra metaveriyi kontrol ediyoruz
      // Bu test amaçlı bir yaklaşımdır
      
      // Kontrol edilecek bilinen koleksiyonlar
      final knownCollections = [
        'messages', 'users', 'posts', 'comments'
      ];
      
      for (var collection in knownCollections) {
        try {
          // Koleksiyonu kontrol et
          await _firestore.collection(collection).limit(1).get();
          collections.add(collection);
        } catch (e) {
          // Bu koleksiyon mevcut değil veya erişilemiyor
          print('Koleksiyon kontrol edilemiyor: $collection, $e');
        }
      }
    } catch (e) {
      print('Koleksiyonları listelerken hata: $e');
    }
    
    return collections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testCollections,
              child: const Text('Koleksiyonları Test Et'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _createMessagesCollection,
              child: const Text('Messages Koleksiyonu Oluştur'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkAuthStatus,
              child: const Text('Oturum Durumunu Kontrol Et'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sonuç:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Text(_result),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 