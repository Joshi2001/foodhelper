import 'dart:convert';
import 'dart:io';

import 'package:e_commerce/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
final ImagePicker _picker = ImagePicker();
final TextEditingController _nameController = TextEditingController();
final TextEditingController _phoneController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _addressController = TextEditingController();
String? _profileImageUrl;
bool _isLoadingProfile = false;
@override
void initState() {
  super.initState();
  _fetchProfile();
}


Future<void> _pickImage(ImageSource source) async {
  final XFile? pickedFile = await _picker.pickImage(
    source: source,
    imageQuality: 80,
  );

  if (pickedFile != null) {
    setState(() {
      _profileImage = File(pickedFile.path);
    });
  }
}
void _showImagePickerOptions() {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    ),
  );
}
Future<void> _fetchProfile() async {
  setState(() {
    _isLoadingProfile = true;
  });

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      _showError('Token not found');
      return;
    }

    final response = await http.get(
      Uri.parse('https://grocerrybackend.onrender.com/api/user/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final user = data['user']; // ✅ FIXED

      setState(() {
        _nameController.text = user['name'] ?? '';
        _phoneController.text = user['phone'] ?? '';
        _emailController.text = user['email'] ?? '';
        _addressController.text = user['address'] ?? '';
        _profileImageUrl = user['profileImage']; // ✅ FIXED
      });
    } else {
      _showError(data['message'] ?? 'Failed to fetch profile');
    }
  } catch (e) {
    print("❌ ERROR: $e");
    _showError('Failed to load profile');
  } finally {
    setState(() {
      _isLoadingProfile = false;
    });
  }
}



Future<void> _updateProfile() async {
  if (!_formKey.currentState!.validate()) return;

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print(token);
    if (token == null) {
      _showError('User not logged in');
      return;
    }

    final uri = Uri.parse(
      'https://grocerrybackend.onrender.com/api/user/profile',
    );

    final request = http.MultipartRequest('POST', uri);

    // ✅ Headers
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // ✅ Text Fields
    request.fields.addAll({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
    });

    // ✅ Image (optional)
    if (_profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image', // 👈 must match backend key
          _profileImage!.path,
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final data = jsonDecode(responseBody);

    if (response.statusCode == 200 && data['success'] == true) {
      _showSuccess('Profile updated successfully');
    } else {
      print(response.statusCode);
      
      print("${data['message']}");
      _showError(data['message'] ?? 'Update failed');
    }
  } catch (e) {
    print(e);
    _showError('Something went wrong');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoadingProfile
    ? const Center(child: CircularProgressIndicator())
    : SingleChildScrollView(

   //   body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfileImage(),
              const SizedBox(height: 24),
              _buildFormCard(),
              const SizedBox(height: 30),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= PROFILE IMAGE =================
  Widget _buildProfileImage() {
  return Stack(
    alignment: Alignment.bottomRight,
    children: [
     CircleAvatar(
  radius: 55,
  backgroundColor: Colors.grey.shade300,
  backgroundImage: _profileImage != null
      ? FileImage(_profileImage!)
      : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
          ? NetworkImage(_profileImageUrl!)
          : const AssetImage(
              'Assets/face.png',
            ) as ImageProvider,
),

      GestureDetector(
        onTap: _showImagePickerOptions,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryOrangeColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.camera_alt,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    ],
  );
}

  // Widget _buildProfileImage() {
  //   return Stack(
  //     alignment: Alignment.bottomRight,
  //     children: [
  //       CircleAvatar(
  //         radius: 55,
  //         backgroundColor: Colors.grey.shade300,
  //         backgroundImage: const AssetImage(
  //           'assets/images/profile_placeholder.png', // optional
  //         ),
  //       ),
  //       Container(
  //         padding: const EdgeInsets.all(6),
  //         decoration: BoxDecoration(
  //           color: AppColors.primaryOrangeColor,
  //          // color: Theme.of(context).primaryColor,
  //           shape: BoxShape.circle,
  //         ),
  //         child: const Icon(
  //           Icons.camera_alt,
  //           size: 18,
  //           color: Colors.white,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // ================= FORM CARD =================

  Widget _buildFormCard() {
    return Card(
      color: AppColors.greyWhiteColor,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
  label: "Full Name",
  icon: Icons.person_outline,
  hint: "Enter your name",
  controller: _nameController,
),

_buildTextField(
  label: "Phone Number",
  icon: Icons.phone_outlined,
  hint: "Enter phone number",
  keyboardType: TextInputType.phone,
  controller: _phoneController,
),

_buildTextField(
  label: "Email",
  icon: Icons.email_outlined,
  hint: "Enter email address",
  keyboardType: TextInputType.emailAddress,
  controller: _emailController,
),

_buildTextField(
  label: "Address",
  icon: Icons.location_on_outlined,
  hint: "Enter your address",
  maxLines: 3,
  controller: _addressController,
),

          ],
        ),
      ),
    );
  }

  // ================= TEXT FIELD =================
Widget _buildTextField({
  required String label,
  required IconData icon,
  required String hint,
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(19),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    ),
  );
}

  // Widget _buildTextField({
  //   required String label,
  //   required IconData icon,
  //   required String hint,
  //   TextInputType keyboardType = TextInputType.text,
  //   int maxLines = 1,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           label,
  //           style: const TextStyle(
  //             fontSize: 13,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //         const SizedBox(height: 6),
  //         TextFormField(
  //           maxLines: maxLines,
  //           keyboardType: keyboardType,
  //           decoration: InputDecoration(
  //             hintText: hint,
  //             prefixIcon: Icon(icon),
  //             filled: true,
  //             fillColor: Colors.grey.shade100,
  //             contentPadding: const EdgeInsets.symmetric(
  //               vertical: 14,
  //               horizontal: 12,
  //             ),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(19),
  //               borderSide: BorderSide.none,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ================= SAVE BUTTON =================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          _updateProfile();

  if (_formKey.currentState!.validate()) {
    print("===== PROFILE DATA =====");
    print("Name: ${_nameController.text}");
    print("Phone: ${_phoneController.text}");
    print("Email: ${_emailController.text}");
    print("Address: ${_addressController.text}");
    print("Profile Image Path: ${_profileImage?.path ?? 'No image selected'}");  
    print("========================");
  }
},

        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrangeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Save Changes",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ),
    );
  }
  void _showSuccess(String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Success'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

void _showError(String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

}
