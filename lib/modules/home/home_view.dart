import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_booking_project/theme.dart';
import 'package:sport_booking_project/modules/detail/detail_venue_view.dart';
import 'package:sport_booking_project/model/sport_field.dart';
import 'package:sport_booking_project/model/sport_category.dart';
import 'package:sport_booking_project/model/field_facility.dart';
import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _searchQuery = "";
  String _selectedCategory = "Tất cả";
  final user = FirebaseAuth.instance.currentUser;
  final currencyFormat = NumberFormat("#,##0", "vi_VN");

  // Bảng màu hệ thống
  final Color bgMint = const Color(0xFFF1F6F2);
  final Color primaryEmerald = const Color(0xFF4A9B7B);
  final Color darkForest = const Color(0xFF1B4332);
  final Color customBrown = const Color(0xFF8D6E63);

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Bóng đá', 'image': 'assets/icons/soccer.png'},
    {'name': 'Cầu lông', 'image': 'assets/icons/tennis.png'},
    {'name': 'Bóng rổ', 'image': 'assets/icons/basketball.png'},
    {'name': 'Tennis', 'image': 'assets/icons/tennis.png'},
    {'name': 'Bóng chuyền', 'image': 'assets/icons/volley.png'},
  ];

  @override
  Widget build(BuildContext context) {
    String userName = user?.displayName ?? user?.email?.split('@')[0] ?? "Người chơi";
    if (userName.isNotEmpty) {
      userName = userName[0].toUpperCase() + userName.substring(1);
    }

    return Scaffold(
      backgroundColor: bgMint,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HEADER GRADIENT ---
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 35),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryEmerald, darkForest],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Chào mừng bạn trở lại,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(userName, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            "https://api.dicebear.com/7.x/adventurer/png?seed=${user?.uid ?? 'Kitty'}&backgroundColor=f1f6f2",
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm sân bóng, cầu lông...",
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: primaryEmerald),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- 2. MÔN THỂ THAO CÓ HIỆN SỐ LƯỢNG ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text("Môn thể thao", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 115,
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('sport_fields').snapshots(),
                  builder: (context, snapshot) {
                    return ListView.builder(
                      padding: const EdgeInsets.only(left: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final bool isSelected = _selectedCategory == cat['name'];

                        // Tính toán số lượng sân cho môn này
                        int count = 0;
                        if (snapshot.hasData) {
                          count = snapshot.data!.docs.where((doc) {
                            var data = doc.data() as Map<String, dynamic>;
                            String dbCat = (data['category'] is Map) ? (data['category']['name'] ?? "") : (data['type'] ?? "");
                            return dbCat == cat['name'] || dbCat == _mapVietnameseToEnglish(cat['name']);
                          }).length;
                        }

                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = isSelected ? "Tất cả" : cat['name']),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 95,
                                margin: const EdgeInsets.only(right: 20, top: 5),
                                decoration: BoxDecoration(
                                  color: isSelected ? darkForest : Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white24 : bgMint,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                          cat['image'],
                                          width: 28, height: 28,
                                          color: isSelected ? Colors.white : primaryEmerald
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(cat['name'], style: TextStyle(color: isSelected ? Colors.white : darkForest, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                              ),
                              // BADGE HIỆN SỐ LƯỢNG SÂN
                              if (count > 0)
                                Positioned(
                                  top: 0,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: customBrown, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                    child: Text("$count", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  }
              ),
            ),

            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                  _selectedCategory == "Tất cả" ? "Sân gần bạn" : "Sân $_selectedCategory",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))
              ),
            ),
            const SizedBox(height: 16),

            // --- 3. STREAM DANH SÁCH SÂN (VND) ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sport_fields').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryEmerald));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Chưa có sân nào."));

                var docs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['name'] ?? "").toLowerCase();
                  bool matchSearch = name.contains(_searchQuery);
                  bool matchCategory = true;
                  if (_selectedCategory != "Tất cả") {
                    String dbCat = (data['category'] is Map) ? (data['category']['name'] ?? "") : (data['type'] ?? "");
                    matchCategory = (dbCat == _selectedCategory || dbCat == _mapVietnameseToEnglish(_selectedCategory));
                  }
                  return matchSearch && matchCategory;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    int price = data['price'] ?? 0;

                    return GestureDetector(
                      onTap: () {
                        SportField field = SportField(
                          id: docs[index].id, name: data['name'] ?? 'Sân bóng',
                          address: data['address'] ?? 'Địa chỉ', price: price,
                          imageAsset: data['imageAsset'] ?? 'assets/images/vio_basketball.jpg',
                          imageUrl: '', category: SportCategory(name: 'Sport', image: ''),
                          facilities: [], author: 'Admin', authorUrl: '',
                          openDay: 'Mỗi ngày', openTime: '06:00', closeTime: '22:00',
                          phoneNumber: data['phoneNumber'] ?? '0909 123 456',
                        );
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailView(field: field)));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: darkForest.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                  child: Image.asset(data['imageAsset'] ?? 'assets/images/vio_basketball.jpg', height: 180, width: double.infinity, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 15, right: 15,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(color: customBrown, borderRadius: BorderRadius.circular(15)),
                                    child: Text("${currencyFormat.format(price)}đ/giờ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(data['name'] ?? 'Sân bóng', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)))),
                                      const Row(children: [Icon(Icons.star_rounded, color: Colors.orange, size: 20), Text(" 4.8", style: TextStyle(fontWeight: FontWeight.bold))]),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_rounded, size: 16, color: primaryEmerald),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(data['address'] ?? 'Địa chỉ', style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  String _mapVietnameseToEnglish(String vnName) {
    switch (vnName) {
      case 'Bóng đá': return 'Futsal';
      case 'Cầu lông': return 'Badminton';
      case 'Bóng rổ': return 'Basketball';
      case 'Tennis': return 'Tennis';
      case 'Bóng chuyền': return 'Volley';
      default: return vnName;
    }
  }
}