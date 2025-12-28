import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_booking_project/theme.dart';
import 'package:sport_booking_project/modules/admin/add_edit_venue_view.dart';
import 'package:intl/intl.dart';

class ManageVenuesView extends StatelessWidget {
  // Bảng màu đồng bộ
  final Color bgMint = const Color(0xFFF1F6F2);
  final Color primaryEmerald = const Color(0xFF4A9B7B);
  final Color darkForest = const Color(0xFF1B4332);

  // MÀU NÂU MỚI CHO NÚT CỘNG
  final Color customBrown = const Color(0xFF8D6E63);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,##0", "vi_VN");

    return Scaffold(
      backgroundColor: bgMint,
      appBar: AppBar(
        title: Text("Quản lý Sân bãi",
            style: TextStyle(color: darkForest, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),

      // CẬP NHẬT NÚT THÊM SÂN THÀNH MÀU NÂU
      floatingActionButton: FloatingActionButton(
        backgroundColor: customBrown, // Đã đổi từ darkForest sang customBrown
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
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
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stadium_outlined, size: 80, color: primaryEmerald.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text("Chưa có sân nào. Hãy thêm mới!", style: TextStyle(color: darkForest.withOpacity(0.5))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

              String name = data['name'] ?? 'Chưa đặt tên';
              String address = data['address'] ?? 'Chưa có địa chỉ';
              int price = data['price'] ?? 0;
              String imageAsset = data['imageAsset'] ?? 'assets/images/vio_basketball.jpg';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: darkForest.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: bgMint, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        imageAsset,
                        width: 70, height: 70, fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          width: 70, height: 70, color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  title: Text(name,
                      style: TextStyle(fontWeight: FontWeight.bold, color: darkForest, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(height: 6),
                      Text("${currencyFormat.format(price)} VND/h",
                          style: TextStyle(fontWeight: FontWeight.bold, color: primaryEmerald, fontSize: 14)),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    icon: Icon(Icons.more_vert_rounded, color: darkForest),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditVenueView(document: document)));
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, document);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(children: [Icon(Icons.edit_rounded, color: Colors.blue, size: 20), SizedBox(width: 10), Text('Chỉnh sửa')]),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(children: [Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20), SizedBox(width: 10), Text('Xóa sân')]),
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

  void _showDeleteDialog(BuildContext context, DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Xác nhận xóa?"),
        content: const Text("Hành động này sẽ xóa vĩnh viễn dữ liệu sân bãi."),
        actions: [
          TextButton(child: const Text("Hủy", style: TextStyle(color: Colors.grey)), onPressed: () => Navigator.pop(ctx)),
          TextButton(
            child: const Text("Xóa ngay", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('sport_fields').doc(document.id).delete();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa sân thành công!")));
            },
          ),
        ],
      ),
    );
  }
}