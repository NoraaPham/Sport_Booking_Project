// lib/modules/admin/manage_venues_view.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_booking_project/theme.dart';
import 'package:sport_booking_project/modules/admin/add_edit_venue_view.dart';

class ManageVenuesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Quản lý Sân", style: titleTextStyle),
        backgroundColor: colorWhite,
        centerTitle: true,
        elevation: 0, // Bỏ bóng
        automaticallyImplyLeading: false, // QUAN TRỌNG: Bỏ nút Back
        iconTheme: IconThemeData(color: darkBlue500),
      ),
      // Nút thêm sân mới
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor500,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditVenueView()),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('sport_fields').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("Chưa có sân nào. Hãy bấm + để thêm.", style: descTextStyle),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

              String name = data['name'] ?? 'Chưa đặt tên';
              String address = data['address'] ?? 'Chưa có địa chỉ';
              int price = data['price'] ?? 0;
              String imageAsset = data['imageAsset'] ?? 'assets/images/vio_basketball.jpg';

              return Card(
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Bo tròn hơn cho đẹp
                elevation: 2,
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imageAsset,
                      width: 70, height: 70, fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(width: 70, height: 70, color: Colors.grey),
                    ),
                  ),
                  title: Text(name, style: subTitleTextStyle.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(address, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text("$price VND/h", style: priceTextStyle.copyWith(fontSize: 14, color: primaryColor500)),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditVenueView(document: document)));
                      } else if (value == 'delete') {
                        // Xác nhận xóa
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text("Xóa sân này?"),
                            content: Text("Hành động này không thể hoàn tác."),
                            actions: [
                              TextButton(child: Text("Hủy"), onPressed: () => Navigator.pop(ctx)),
                              TextButton(
                                child: Text("Xóa", style: TextStyle(color: Colors.red)),
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  await FirebaseFirestore.instance.collection('sport_fields').doc(document.id).delete();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã xóa sân!")));
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text('Sửa')]),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Xóa')]),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}