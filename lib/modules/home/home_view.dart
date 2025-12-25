import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_booking_project/theme.dart';
import 'package:sport_booking_project/modules/detail/detail_venue_view.dart';
import 'package:sport_booking_project/model/sport_field.dart';
import 'package:sport_booking_project/model/sport_category.dart';
import 'package:sport_booking_project/model/field_facility.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _searchQuery = "";
  String _selectedCategory = "All";
  final user = FirebaseAuth.instance.currentUser;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Futsal', 'image': 'assets/icons/soccer.png', 'color': Color(0xFF4AC1BC)},
    {'name': 'Badminton', 'image': 'assets/icons/tennis.png', 'color': Color(0xFFAB47BC)},
    {'name': 'Basketball', 'image': 'assets/icons/basketball.png', 'color': Color(0xFF7CB342)},
    {'name': 'Tennis', 'image': 'assets/icons/tennis.png', 'color': Color(0xFFE57373)},
    {'name': 'Volley', 'image': 'assets/icons/volley.png', 'color': Color(0xFFFFB74D)},
  ];

  @override
  Widget build(BuildContext context) {
    // Lấy tên người dùng (nếu có) hoặc dùng Email
    String userName = user?.displayName ?? user?.email?.split('@')[0] ?? "Player";
    // Viết hoa chữ cái đầu
    if (userName.isNotEmpty) {
      userName = userName[0].toUpperCase() + userName.substring(1);
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(24, 60, 24, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0061FF), Color(0xFF60EFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Xin chào,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                          SizedBox(height: 4),
                          Text(userName, style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.blue[100],
                          backgroundImage: AssetImage("assets/images/user_profile_example.png"),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: "Tìm sân bóng, cầu lông...",
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: primaryColor500),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Môn thể thao", style: titleTextStyle.copyWith(fontSize: 18)),
                  if (_selectedCategory != "All")
                    GestureDetector(
                      onTap: () => setState(() => _selectedCategory = "All"),
                      child: Text("Xóa lọc", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                ],
              ),
            ),
            SizedBox(height: 16),

            SizedBox(
              height: 140,
              child: ListView.builder(
                padding: EdgeInsets.only(left: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final bool isSelected = _selectedCategory == cat['name'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedCategory == cat['name']) {
                          _selectedCategory = "All";
                        } else {
                          _selectedCategory = cat['name'];
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: 110,
                      margin: EdgeInsets.only(right: 16, bottom: 10),
                      decoration: BoxDecoration(
                          color: cat['color'],
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                          boxShadow: [
                            BoxShadow(
                              color: (cat['color'] as Color).withOpacity(0.4),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            )
                          ]
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 16, left: 12,
                            child: Text(
                              cat['name'],
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Positioned(
                            bottom: -10, right: -10,
                            child: Opacity(
                              opacity: 0.8,
                              child: Image.asset(cat['image'], width: 70, height: 70, color: Colors.white),
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 8, right: 8,
                              child: Icon(Icons.check_circle, color: Colors.white, size: 20),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                  _selectedCategory == "All" ? "Sân gần bạn" : "Sân $_selectedCategory",
                  style: titleTextStyle.copyWith(fontSize: 18)
              ),
            ),
            SizedBox(height: 16),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sport_fields').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Column(
                    children: [
                      SizedBox(height: 40),
                      Icon(Icons.sports_soccer, size: 60, color: Colors.grey[300]),
                      Text("Chưa có sân nào.", style: descTextStyle),
                    ],
                  ));
                }

                // LOGIC LỌC
                var docs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['name'] ?? "").toLowerCase();
                  bool matchSearch = name.contains(_searchQuery);

                  bool matchCategory = true;
                  if (_selectedCategory != "All") {
                    String catName = "";
                    if (data['category'] is Map) {
                      catName = data['category']['name'] ?? "";
                    }
                    matchCategory = (catName == _selectedCategory);
                  }
                  return matchSearch && matchCategory;
                }).toList();

                if (docs.isEmpty) {
                  return Center(child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Text("Không tìm thấy sân phù hợp!", style: descTextStyle),
                  ));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  shrinkWrap: true, // Quan trọng khi nằm trong SingleChildScrollView
                  physics: NeverScrollableScrollPhysics(), // Để scroll theo trang chính
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;

                    String imageAsset = data['imageAsset'] ?? 'assets/images/vio_basketball.jpg';
                    String name = data['name'] ?? 'Sân bóng';
                    String address = data['address'] ?? 'Địa chỉ';
                    String phone = data['phoneNumber'] ?? '0909 123 456';
                    int price = data['price'] ?? 0;

                    // Tạo đối tượng Field để truyền sang trang chi tiết
                    SportField field = SportField(
                      id: docs[index].id,
                      name: name, address: address, price: price,
                      imageAsset: imageAsset, imageUrl: '',
                      category: SportCategory(name: 'Sport', image: 'assets/icons/soccer.png'),
                      facilities: <FieldFacility>[],
                      author: 'Admin', authorUrl: '',
                      openDay: 'All Day', openTime: '06:00', closeTime: '22:00',
                      phoneNumber: phone,
                    );

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailView(field: field)));
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ẢNH SÂN TRÀN VIỀN
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  child: Image.asset(
                                    imageAsset,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Tag giá tiền nổi bật
                                Positioned(
                                  top: 16, right: 16,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.confirmation_number, size: 16, color: primaryColor500),
                                        SizedBox(width: 4),
                                        Text(
                                            "\$${price/1000}k/h",
                                            style: TextStyle(color: primaryColor500, fontWeight: FontWeight.bold, fontSize: 14)
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),

                            // THÔNG TIN
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                            name,
                                            style: titleTextStyle.copyWith(fontSize: 18),
                                            maxLines: 1, overflow: TextOverflow.ellipsis
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.orange, size: 18),
                                          Text(" 4.8", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(address, style: descTextStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ),
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
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}