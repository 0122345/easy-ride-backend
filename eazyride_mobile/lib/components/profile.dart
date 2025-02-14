import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = false;
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  
  // Dropdown values
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedCity;
  
  // Dropdown items
  List<String> _provinces = [];
  List<String> _districts = [];
  List<String> _cities = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchProvinces();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  // Load existing user data
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _nameController.text = prefs.getString('userName') ?? '';
        _phoneController.text = prefs.getString('userPhone') ?? '';
        _selectedProvince = prefs.getString('userProvince');
        _selectedDistrict = prefs.getString('userDistrict');
        _selectedCity = prefs.getString('userCity');
        _streetController.text = prefs.getString('userStreet') ?? '';
      });
    } catch (e) {
      _showError('Error loading user data');
    }
    setState(() => _isLoading = false);
  }

  // Fetch provinces from API
  Future<void> _fetchProvinces() async {
    try {
       final response = await http.get(
      Uri.parse('https://rwanda.p.rapidapi.com/provinces'),
      headers: {
        'X-Rapidapi-Key': 'ac2265e187mshd163bb0862bbe12p197842jsn4766338cf8d3',
        'X-Rapidapi-Host': 'rwanda.p.rapidapi.com',
        'Host': 'rwanda.p.rapidapi.com',
      },
    );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _provinces = List<String>.from(data['provinces']);
        });
      }
    } catch (e) {
      _showError('Error fetching provinces');
    }
  }

  // Fetch districts based on selected province
  Future<void> _fetchDistricts(String province) async {
    try {
      final response = await http.get(
      Uri.parse('https://rwanda.p.rapidapi.com/districts?province=$province'),
      headers: {
        'X-Rapidapi-Key': 'ac2265e187mshd163bb0862bbe12p197842jsn4766338cf8d3',
        'X-Rapidapi-Host': 'rwanda.p.rapidapi.com',
        'Host': 'rwanda.p.rapidapi.com',
      },
    );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _districts = List<String>.from(data['districts']);
          _selectedDistrict = null;
          _selectedCity = null;
        });
      }
    } catch (e) {
      _showError('Error fetching districts');
    }
  }

  Future<void> _fetchCities(String district) async {
  try {
    final response = await http.get(
      Uri.parse('https://rwanda.p.rapidapi.com/cities?district=$district'),
      headers: {
        'X-Rapidapi-Key': 'ac2265e187mshd163bb0862bbe12p197842jsn4766338cf8d3',
        'X-Rapidapi-Host': 'rwanda.p.rapidapi.com',
        'Host': 'rwanda.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _cities = List<String>.from(data['cities']);
        _selectedCity = null;
      });
    } else {
      _showError('Error fetching cities: ${response.statusCode}');
    }
  } catch (e) {
    _showError('Error fetching cities: $e');
  }
}

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Error picking image');
    }
  }

  // Show image source selection dialog
  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Save profile data
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('YOUR_API_URL/update-profile'),
      );

      // Add image if selected
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            _imageFile!.path,
          ),
        );
      }

      // Add form fields
      request.fields.addAll({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'province': _selectedProvince ?? '',
        'district': _selectedDistrict ?? '',
        'city': _selectedCity ?? '',
        'street': _streetController.text,
      });

      // Send request
      final response = await request.send();
      if (response.statusCode == 200) {
        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', _nameController.text);
        await prefs.setString('userPhone', _phoneController.text);
        await prefs.setString('userProvince', _selectedProvince ?? '');
        await prefs.setString('userDistrict', _selectedDistrict ?? '');
        await prefs.setString('userCity', _selectedCity ?? '');
        await prefs.setString('userStreet', _streetController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      _showError('Error updating profile');
    }
    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Image
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : null,
                            child: _imageFile == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Your mobile number',
                        border: const OutlineInputBorder(),
                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/flag.png', width: 24),
                              const Text(' +250'),
                            ],
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Province Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedProvince,
                      decoration: const InputDecoration(
                        labelText: 'Province',
                        border: OutlineInputBorder(),
                      ),
                      items: _provinces.map((String province) {
                        return DropdownMenuItem(
                          value: province,
                          child: Text(province),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedProvince = value;
                        });
                        if (value != null) {
                          _fetchDistricts(value);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a province';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // District Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      decoration: const InputDecoration(
                        labelText: 'District',
                        border: OutlineInputBorder(),
                      ),
                      items: _districts.map((String district) {
                        return DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedDistrict = value;
                        });
                        if (value != null) {
                          _fetchCities(value);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a district';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // City Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      items: _cities.map((String city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Street Field
                    TextFormField(
                      controller: _streetController,
                      decoration: const InputDecoration(
                        labelText: 'Street',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your street';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                            ),
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}