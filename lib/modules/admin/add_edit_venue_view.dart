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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();


  // Lưu ý: 'image' (icon) vẫn giữ để lưu vào Firebase cho đồng bộ với app User
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Futsal', 'image': 'assets/icons/soccer.png', 'realImage': 'assets/images/pringsewu_futsal.jpg'},
    {'name': 'Badminton', 'image': 'assets/icons/tennis.png', 'realImage': 'assets/images/wing_tennis.jpg'},
    {'name': 'Basketball', 'image': 'assets/icons/basketball.png', 'realImage': 'assets/images/vio_basketball.jpg'},
    {'name': 'Tennis', 'image': 'assets/icons/tennis.png', 'realImage': 'assets/images/dc_tennis_court.jpg'},
    {'name': 'Volley', 'image': 'assets/icons/volley.png', 'realImage': 'assets/images/voli_pantai.jpg'},
    {'name': 'Table Tennis', 'image': 'assets/icons/table_tennis.png', 'realImage': 'assets/images/tenis_meja_cortez.jpg'},
  ];

  // Danh sách ảnh mẫu cho bước nhập liệu
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

  String _selectedCategoryName = '';
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

      if (data['category'] != null) {
        _selectedCategoryName = data['category']['name'] ?? 'Futsal';
      } else {
        _selectedCategoryName = 'Futsal';
      }
      _isCategorySelected = true;
    }
  }

  String _getCategoryImage(String name) {
    var cat = _categories.firstWhere((element) => element['name'] == name, orElse: () => _categories[0]);
    return cat['image']!;
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Chọn ảnh bìa sân", style: titleTextStyle),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
                  ),
                  itemCount: _sampleImages.length,
                  itemBuilder: (context, index) {
                    final image = _sampleImages[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() { _selectedImageAsset = image; });
                        Navigator.pop(context);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            border: _selectedImageAsset == image ? Border.all(color: primaryColor500, width: 3) : null,
                          ),
                          child: Image.asset(image, fit: BoxFit.cover),
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

  Future<void> _saveVenue() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      try {
        Map<String, dynamic> dataToSave = {
          'name': _nameController.text,
          'address': _addressController.text,
          'price': int.tryParse(_priceController.text) ?? 0,
          'imageAsset': _selectedImageAsset,
          'imageUrl': '',
          'category': {
            'name': _selectedCategoryName,
            'image': _getCategoryImage(_selectedCategoryName)
          },
          'facilities': [],
          'openDay': 'All Day', 'openTime': '06:00', 'closeTime': '22:00',
          'phoneNumber': '0909 123 456',
          'author': 'Admin', 'authorUrl': '',
        };

        if (widget.document == null) {
          await FirebaseFirestore.instance.collection('sport_fields').add(dataToSave);
        } else {
          await widget.document!.reference.update(dataToSave);
        }

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lưu thành công!"), backgroundColor: Colors.green));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
      } finally {
        if(mounted) setState(() { _isLoading = false; });
      }
    }
  }

  // --- BƯỚC 1: GIAO DIỆN CHỌN LOẠI SÂN (ĐÃ SỬA: DÙNG ẢNH THẬT) ---
  Widget _buildCategorySelectionStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Đã sửa tiêu đề
          Text("Chọn loại hình thể thao", style: titleTextStyle.copyWith(fontSize: 22)),
          Text("Vui lòng chọn môn thể thao bạn muốn thêm sân.", style: descTextStyle),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3, // Điều chỉnh tỷ lệ khung hình cho đẹp hơn
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryName = cat['name'];
                      _isCategorySelected = true;
                    });
                  },
                  // Sử dụng Stack để chồng ảnh và chữ lên nhau
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand, // Ảnh tràn khung
                      children: [
                        // Lớp 1: Ảnh nền thật
                        Image.asset(
                          cat['realImage'],
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(color: Colors.grey), // Màu dự phòng nếu lỗi ảnh
                        ),
                        // Lớp 2: Lớp phủ đen mờ để dễ đọc chữ
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black87],
                            ),
                          ),
                        ),
                        // Lớp 3: Tên môn thể thao
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Text(
                            cat['name'],
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(1,1))]
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
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

  // --- BƯỚC 2: GIAO DIỆN NHẬP THÔNG TIN (GIỮ NGUYÊN) ---
  Widget _buildInputFormStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: primaryColor100,
            child: Row(
              children: [
                Text("Đang tạo sân: ", style: descTextStyle),
                Text(_selectedCategoryName, style: titleTextStyle.copyWith(fontSize: 16, color: primaryColor500)),
                Spacer(),
                if (widget.document == null)
                  TextButton.icon(
                      onPressed: () {
                        setState(() { _isCategorySelected = false; });
                      },
                      icon: Icon(Icons.edit, size: 16),
                      label: Text("Chọn lại")
                  )
              ],
            ),
          ),

          GestureDetector(
            onTap: _showImagePicker,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: double.infinity, height: 220,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    image: DecorationImage(image: AssetImage(_selectedImageAsset), fit: BoxFit.cover),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.camera_alt, color: Colors.white, size: 18), SizedBox(width: 8), Text("Đổi ảnh bìa", style: TextStyle(color: Colors.white))],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nhập thông tin chi tiết", style: titleTextStyle),
                  SizedBox(height: 24),

                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: "Tên sân", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: Icon(Icons.stadium)),
                    validator: (val) => val!.isEmpty ? "Cần nhập tên" : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: "Địa chỉ", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: Icon(Icons.location_on)),
                    validator: (val) => val!.isEmpty ? "Cần nhập địa chỉ" : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: "Giá / giờ (VND)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: Icon(Icons.attach_money)),
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? "Cần nhập giá" : null,
                  ),

                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor500, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _isLoading ? null : _saveVenue,
                      child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Lưu và Tạo sân", style: buttonTextStyle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.document == null ? "Thêm Sân Mới" : "Sửa Sân", style: titleTextStyle),
        backgroundColor: colorWhite,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkBlue500),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (_isCategorySelected && widget.document == null) {
              setState(() { _isCategorySelected = false; });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _isCategorySelected ? _buildInputFormStep() : _buildCategorySelectionStep(),
    );
  }
}