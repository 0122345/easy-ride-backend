// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:dio/dio.dart';
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:get/get.dart';

// class LocationService extends GetxService {
//   final dio = Dio(BaseOptions(
//     baseUrl: 'https://rwanda.p.rapidapi.com',
//     headers: {
//       'X-Rapidapi-Key': 'ac2265e187mshd163bb0862bbe12p197842jsn4766338cf8d3',
//       'X-Rapidapi-Host': 'rwanda.p.rapidapi.com',
//     },
//   ));

//   Future<List<String>> getProvinces() async {
//     try {
//       final response = await dio.get('/provinces');
//       return List<String>.from(response.data['provinces']);
//     } catch (e) {
//       return [];
//     }
//   }

//   Future<List<String>> getDistricts(String province) async {
//     try {
//       final response = await dio.get('/districts', queryParameters: {'province': province});
//       return List<String>.from(response.data['districts']);
//     } catch (e) {
//       return [];
//     }
//   }

//   Future<List<String>> getCities(String district) async {
//     try {
//       final response = await dio.get('/cities', queryParameters: {'district': district});
//       return List<String>.from(response.data['cities']);
//     } catch (e) {
//       return [];
//     }
//   }
// }

// class ImageService extends GetxService {
//   final ImagePicker _picker = ImagePicker();

//   Future<File?> pickImage(BuildContext context) async {
//     final result = await showModalBottomSheet<ImageSource>(
//       context: context,
//       builder: (BuildContext context) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.photo_camera),
//               title: const Text('Take a photo'),
//               onTap: () => Navigator.pop(context, ImageSource.camera),
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Choose from gallery'),
//               onTap: () => Navigator.pop(context, ImageSource.gallery),
//             ),
//           ],
//         ),
//       ),
//     );

//     if (result != null) {
//       final XFile? image = await _picker.pickImage(
//         source: result,
//         imageQuality: 80,
//         maxWidth: 1000,
//       );
//       return image != null ? File(image.path) : null;
//     }
//     return null;
//   }
// }

// class ProfileEditScreen extends StatefulWidget {
//   const ProfileEditScreen({Key? key}) : super(key: key);

//   @override
//   State<ProfileEditScreen> createState() => _ProfileEditScreenState();
// }

// class _ProfileEditScreenState extends State<ProfileEditScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _locationService = Get.put(LocationService());
//   final _imageService = Get.put(ImageService());
//   File? _imageFile;
//   bool _isLoading = false;
  
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _streetController = TextEditingController();
  
//   String? _selectedProvince;
//   String? _selectedDistrict;
//   String? _selectedCity;
  
//   List<String> _provinces = [];
//   List<String> _districts = [];
//   List<String> _cities = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//     _fetchProvinces();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _streetController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadUserData() async {
//     setState(() => _isLoading = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       setState(() {
//         _nameController.text = prefs.getString('userName') ?? '';
//         _phoneController.text = prefs.getString('userPhone') ?? '';
//         _selectedProvince = prefs.getString('userProvince');
//         _selectedDistrict = prefs.getString('userDistrict');
//         _selectedCity = prefs.getString('userCity');
//         _streetController.text = prefs.getString('userStreet') ?? '';
//       });
//       if (_selectedProvince != null) await _fetchDistricts(_selectedProvince!);
//       if (_selectedDistrict != null) await _fetchCities(_selectedDistrict!);
//     } catch (e) {
//       _showError('Error loading user data');
//     }
//     setState(() => _isLoading = false);
//   }

//   Future<void> _fetchProvinces() async {
//     try {
//       final provinces = await _locationService.getProvinces();
//       setState(() => _provinces = provinces);
//     } catch (e) {
//       _showError('Error fetching provinces');
//     }
//   }

//   Future<void> _fetchDistricts(String province) async {
//     try {
//       final districts = await _locationService.getDistricts(province);
//       setState(() {
//         _districts = districts;
//         _selectedDistrict = null;
//         _selectedCity = null;
//         _cities = [];
//       });
//     } catch (e) {
//       _showError('Error fetching districts');
//     }
//   }

//   Future<void> _fetchCities(String district) async {
//     try {
//       final cities = await _locationService.getCities(district);
//       setState(() {
//         _cities = cities;
//         _selectedCity = null;
//       });
//     } catch (e) {
//       _showError('Error fetching cities');
//     }
//   }

//   Future<void> _handleImageSelection() async {
//     final File? selectedImage = await _imageService.pickImage(context);
//     if (selectedImage != null) {
//       setState(() => _imageFile = selectedImage);
//     }
//   }

// Future<void> _saveProfile() async {
//   if (!_formKey.currentState!.validate()) return;

//   setState(() => _isLoading = true);

//   try {
//     final dio = Dio();
//     final formData = FormData.fromMap({
//       'name': _nameController.text,
//       'phone': _phoneController.text,
//       'province': _selectedProvince ?? '',
//       'district': _selectedDistrict ?? '',
//       'city': _selectedCity ?? '',
//       'street': _streetController.text,
//     });

 
//     if (_imageFile != null) {
//       formData.files.add(
//         MapEntry(
//           'profile_image',
//           await MultipartFile.fromFile(_imageFile!.path),
//         ),
//       );
//     }

//     // Make the POST request
//     final response = await dio.post(
//       'https://easy-ride-backend-xl8m.onrender.com/api/update-profile',
//       data: formData,
//     );

//     // Handle the response
//     if (response.statusCode == 200) {
//       final prefs = await SharedPreferences.getInstance();

//       // Save user profile data to shared preferences
//       await prefs.setString('userName', _nameController.text);
//       await prefs.setString('userPhone', _phoneController.text);
//       await prefs.setString('userProvince', _selectedProvince ?? '');
//       await prefs.setString('userDistrict', _selectedDistrict ?? '');
//       await prefs.setString('userCity', _selectedCity ?? '');
//       await prefs.setString('userStreet', _streetController.text);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile updated successfully')),
//         );
//       }
//     } else {
       
//       _showError('Failed to update profile: ${response.statusCode}');
//     }
//   } catch (e) {
     
//     print('Error during profile update: $e');
//     _showError('Error updating profile');
//   } finally {
//     if (mounted) {
//       setState(() => _isLoading = false);
//     }
//   }
// }

// void _showError(String message) {
//   if (!mounted) return;
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text(message)),
//   );
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('Profile'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     GestureDetector(
//                       onTap: _handleImageSelection,
//                       child: Stack(
//                         alignment: Alignment.bottomRight,
//                         children: [
//                           CircleAvatar(
//                             radius: 50,
//                             backgroundImage: _imageFile != null
//                                 ? FileImage(_imageFile!)
//                                 : null,
//                             child: _imageFile == null
//                                 ? const Icon(Icons.person, size: 50)
//                                 : null,
//                           ),
//                           Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: const BoxDecoration(
//                               color: Colors.amber,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(Icons.camera_alt, size: 20),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     TextFormField(
//                       controller: _nameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Full Name',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) =>
//                           value?.isEmpty ?? true ? 'Please enter your name' : null,
//                     ),
//                     const SizedBox(height: 16),

//                     TextFormField(
//                       controller: _phoneController,
//                       decoration: InputDecoration(
//                         labelText: 'Your mobile number',
//                         border: const OutlineInputBorder(),
//                         prefixIcon: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Image.asset('assets/flag.png', width: 24),
//                               const Text(' +250'),
//                             ],
//                           ),
//                         ),
//                       ),
//                       keyboardType: TextInputType.phone,
//                       validator: (value) =>
//                           value?.isEmpty ?? true ? 'Please enter your phone number' : null,
//                     ),
//                     const SizedBox(height: 16),

//                     DropdownButtonFormField<String>(
//                       value: _selectedProvince,
//                       decoration: const InputDecoration(
//                         labelText: 'Province',
//                         border: OutlineInputBorder(),
//                       ),
//                       items: _provinces.map((String province) {
//                         return DropdownMenuItem(
//                           value: province,
//                           child: Text(province),
//                         );
//                       }).toList(),
//                       onChanged: (String? value) {
//                         if (value != null) {
//                           setState(() => _selectedProvince = value);
//                           _fetchDistricts(value);
//                         }
//                       },
//                       validator: (value) =>
//                           value == null ? 'Please select a province' : null,
//                     ),
//                     const SizedBox(height: 16),

//                     DropdownButtonFormField<String>(
//                       value: _selectedDistrict,
//                       decoration: const InputDecoration(
//                         labelText: 'District',
//                         border: OutlineInputBorder(),
//                       ),
//                       items: _districts.map((String district) {
//                         return DropdownMenuItem(
//                           value: district,
//                           child: Text(district),
//                         );
//                       }).toList(),
//                       onChanged: (String? value) {
//                         if (value != null) {
//                           setState(() => _selectedDistrict = value);
//                           _fetchCities(value);
//                         }
//                       },
//                       validator: (value) =>
//                           value == null ? 'Please select a district' : null,
//                     ),
//                     const SizedBox(height: 16),

//                     DropdownButtonFormField<String>(
//                       value: _selectedCity,
//                       decoration: const InputDecoration(
//                         labelText: 'City',
//                         border: OutlineInputBorder(),
//                       ),
//                       items: _cities.map((String city) {
//                         return DropdownMenuItem(
//                           value: city,
//                           child: Text(city),
//                         );
//                       }).toList(),
//                       onChanged: (String? value) {
//                         setState(() => _selectedCity = value);
//                       },
//                       validator: (value) =>
//                           value == null ? 'Please select a city' : null,
//                     ),
//                     const SizedBox(height: 16),

//                     TextFormField(
//                       controller: _streetController,
//                       decoration: const InputDecoration(
//                         labelText: 'Street',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) =>
//                           value?.isEmpty ?? true ? 'Please enter your street' : null,
//                     ),
//                     const SizedBox(height: 24),

//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: const Text('Cancel'),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: _saveProfile,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.amber,
//                             ),
//                             child: const Text('Save'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }
