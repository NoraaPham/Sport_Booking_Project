import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_booking_project/theme.dart';

class AddEditVenueView extends StatefulWidget {
  final DocumentSnapshot? document;
  AddEditVenueView({this.document});

  @override
  _AddEditVenueViewState createState() => _AddEditVenueViewState();
}

class _AddEditVenueViewState extends State<AddEditVenueView> {
  // Bảng màu đồng bộ hệ thống Emerald & Mint
  final Color bgMint = const Color(0xFFF1F6F2);
  final Color primaryEmerald = const Color(0xFF4A9B7B);
  final Color darkForest = const Color(0xFF1B4332);
  final Color customBrown = const Color(0xFF8D6E63);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();

  // Danh mục môn thể thao kèm ảnh đại diện cho bước 1
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Bóng đá', 'image': 'assets/icons/soccer.png', 'realImage': 'assets/images/pringsewu_futsal.jpg'},
    {'name': 'Cầu lông', 'image': 'assets/icons/tennis.png', 'realImage': 'assets/images/wing_tennis.jpg'},
    {'name': 'Bóng rổ', 'image': 'assets/icons/basketball.png', 'realImage': 'assets/images/vio_basketball.jpg'},
    {'name': 'Tennis', 'image': 'assets/icons/tennis.png', 'realImage': 'assets/images/dc_tennis_court.jpg'},
    {'name': 'Bóng chuyền', 'image': 'assets/icons/volley.png', 'realImage': 'assets/images/voli_pantai.jpg'},
  ];

  // Danh sách ảnh mẫu để người dùng chọn làm ảnh bìa
  final List<String> _sampleImages = [
    'assets/images/vio_basketball.jpg',
    'assets/images/pringsewu_futsal.jpg',
    'assets/images/voli_pantai.jpg',
    'assets/images/tenis_meja_cortez.jpg',
    'assets/images/kali_basketball.jpg',
    'assets/images/lm_basketball.jpg',
    'assets/images/dc_tennis_court.jpg',
    'assets/images/tennis_coates.jpg',
    'assets/images/jaya_futsal.jpg',
    'assets/images/wing_tennis.jpg',
  ];

  String _selectedCategoryName = 'Bóng đá';
  bool _isCategorySelected = false;
  String _selectedImageAsset = 'assets/images/vio_basketball.jpg';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.document != null) {
      Map<String, dynamic> data = widget.document!.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _addressController.text = data['address'] ?? '';
      _priceController.text = (data['price'] ?? 0).toString();
      _selectedImageAsset = data['imageAsset'] ?? _sampleImages[0];

      // Map ngược từ dữ liệu cũ (nếu có)
      String type = data['type'] ?? (data['category'] != null ? data['category']['name'] : 'Bóng đá');
      _selectedCategoryName = _mapTypeToVietnamese(type);
      _isCategorySelected = true;
    }
  }

  String _mapTypeToVietnamese(String type) {
    switch (type.toLowerCase()) {
      case 'futsal': return "Bóng đá";
      case 'badminton': return "Cầu lông";
      case 'tennis': return "Tennis";
      case 'basketball': return "Bóng rổ";
      case 'volley': return "Bóng chuyền";
      default: return type;
    }
  }

  // --- LOGIC CHỌN ẢNH BÌA (FIXED) ---
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 450,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Chọn ảnh bìa sân", style: titleTextStyle.copyWith(color: darkForest)),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12,
                  ),
                  itemCount: _sampleImages.length,
                  itemBuilder: (context, index) {
                    final img = _sampleImages[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() { _selectedImageAsset = img; });
                        Navigator.pop(context);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            border: _selectedImageAsset == img ? Border.all(color: primaryEmerald, width: 3) : null,
                          ),
                          child: Image.asset(img, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      try {
        final data = {
          'name': _nameController.text,
          'address': _addressController.text,
          'price': int.tryParse(_priceController.text) ?? 0,
          'type': _selectedCategoryName,
          'imageAsset': _selectedImageAsset,
          'imageUrl': '',
          'category': {
            'name': _selectedCategoryName,
            'image': _categories.firstWhere((e) => e['name'] == _selectedCategoryName)['image']
          },
          'facilities': [],
          'openDay': 'Mỗi ngày', 'openTime': '06:00', 'closeTime': '22:00',
          'phoneNumber': '0909 123 456',
          'author': 'Admin',
        };

        if (widget.document == null) {
          await FirebaseFirestore.instance.collection('sport_fields').add(data);
        } else {
          await widget.document!.reference.update(data);
        }
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lưu thành công!"), backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
      } finally {
        if(mounted) setState(() { _isLoading = false; });
      }
    }
  }

  // --- BƯỚC 1: CHỌN MÔN THỂ THAO ---
  Widget _buildCategoryStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Thêm sân bãi mới", style: greetingTextStyle.copyWith(fontSize: 26)),
          const Text("Vui lòng chọn loại hình thể thao để tiếp tục.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 1.2, crossAxisSpacing: 16, mainAxisSpacing: 16,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategoryName = cat['name'];
                    _isCategorySelected = true;
                  }),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(cat['realImage'], fit: BoxFit.cover),
                        Container(color: Colors.black.withOpacity(0.3)),
                        Center(child: Text(cat['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- BƯỚC 2: NHẬP THÔNG TIN CHI TIẾT ---
  Widget _buildInputStep() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header hiển thị loại sân
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              color: bgMint,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Loại sân: $_selectedCategoryName", style: TextStyle(color: primaryEmerald, fontWeight: FontWeight.bold)),
                  if (widget.document == null)
                    TextButton(onPressed: () => setState(() => _isCategorySelected = false), child: Text("Đổi loại", style: TextStyle(color: customBrown))),
                ],
              ),
            ),

            // Ảnh bìa có thể thay đổi
            GestureDetector(
              onTap: _showImagePicker,
              child: Stack(
                children: [
                  Image.asset(_selectedImageAsset, width: double.infinity, height: 220, fit: BoxFit.cover),
                  Positioned(
                    bottom: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                      child: const Row(children: [Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16), SizedBox(width: 8), Text("Đổi ảnh bìa", style: TextStyle(color: Colors.white, fontSize: 12))]),
                    ),
                  )
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Thông tin chi tiết", style: titleTextStyle.copyWith(color: darkForest)),
                  const SizedBox(height: 20),
                  _buildInputField("Tên sân", Icons.stadium_rounded, _nameController),
                  const SizedBox(height: 16),
                  _buildInputField("Địa chỉ", Icons.location_on_rounded, _addressController),
                  const SizedBox(height: 16),
                  _buildInputField("Giá thuê / giờ (VND)", Icons.payments_rounded, _priceController, isNumber: true),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: customBrown, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 0),
                      onPressed: _isLoading ? null : _saveForm,
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(widget.document == null ? "Tạo sân ngay" : "Cập nhật", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, IconData icon, TextEditingController ctrl, {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryEmerald, size: 22),
        hintText: hint,
        filled: true, fillColor: bgMint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
      validator: (val) => val!.isEmpty ? "Không được để trống" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.document == null ? "Thêm Sân Mới" : "Chỉnh sửa", style: TextStyle(color: darkForest, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: darkForest, size: 20),
          onPressed: () {
            if (_isCategorySelected && widget.document == null) {
              setState(() => _isCategorySelected = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _isCategorySelected ? _buildInputStep() : _buildCategoryStep(),
    );
  }
}