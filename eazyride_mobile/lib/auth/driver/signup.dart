import 'package:eazyride_mobile/auth/driver/login_rider.dart';
import 'package:eazyride_mobile/auth/driver/home_map.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_flags/country_flags.dart';
import 'package:dio/dio.dart';
import 'package:eazyride_mobile/theme/hex_color.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Country? selectedCountry;
  final dio = Dio();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _licenceController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  
  get token => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjM4YWU5ODM3LTFkMGYtNDAyNC1iMzczLWJjYTNjYTY0NzZhZSIsInVzZXJUeXBlIjoiRFJJVkVSIiwiaWF0IjoxNzM5NTE3Nzk5LCJleHAiOjE3NDIxMDk3OTl9.23rYk_ry_e_WIKhwSy4QW496sDJB_5wYe2Q_24iAfDQ";
  //final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCountry = null;
    dio.options.baseUrl =
        'https://easy-ride-backend-xl8m.onrender.com/api';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenceController.dispose();
    _genderController.dispose();
    super.dispose();
  }
 
 Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a country')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final driverData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': '${selectedCountry!.phoneCode}${_phoneController.text.trim()}',
        'gender': _genderController.text,
        'licenceNumber': _licenceController.text,
        'userType': 'DRIVER'
      };

          
         
          final response = await dio.post('/auth/driver/register', 
            data: {
              'name': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'phone': '${selectedCountry!.phoneCode}${_phoneController.text.trim()}',
              'gender': _genderController.text,
              'licenseNumber': _licenceController.text,   
              'password': 'securepassword123'   
            });

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeDriverWrapper(
                userId: response.data['userId'] as String,
                email: driverData['email'] as String,
                token: token,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildNameField(),
                const SizedBox(height: 16),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPhoneField(),
                const SizedBox(height: 16),
                _buildLicenceField(),
                const SizedBox(height: 16),
                _buildGenderField(),
                const SizedBox(height: 32),
                _buildSignUpButton(),
                const SizedBox(height: 20),
                _buildAgreementText(),
                const SizedBox(height: 16),
                _buildOrSeparator(),
                const SizedBox(height: 20),
                _buildSocialButtons(),
                const SizedBox(height: 20),
                _buildSignInOption(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
        const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Name is required';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
         }
        return null;
      },
     //TODO: _nameDecorator.clear();
    );
  }

   Widget  _buildLicenceField() {
    return TextFormField(
      controller: _licenceController,
      decoration: InputDecoration(
        labelText: 'Licence Plate number',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Licence is essential';
        }
        if (value.trim().length < 2) {
          return 'Licence number must be at least 2 characters';
        }
        return null;
      },
     //TODO: _nameDecorator.clear();
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email is required';
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return 'Enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return Row(
      children: [
        GestureDetector(
          onTap: _showCountryPicker,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                if (selectedCountry != null)
                  CountryFlag.fromCountryCode(
                    selectedCountry!.countryCode.toLowerCase(),
                    height: 24,
                    width: 32,
                  ),
                if (selectedCountry != null) const SizedBox(width: 8),
                Text('+${selectedCountry?.phoneCode ?? "Select"}'),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              if (value.trim().length < 9) {
                return 'Enter a valid phone number';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      value: _genderController.text.isNotEmpty ? _genderController.text : null,
      items: ["Male", "Female", "Other"].map((gender) {
        return DropdownMenuItem(value: gender, child: Text(gender));
      }).toList(),
      onChanged: (value) => setState(() => _genderController.text = value!),
      decoration: InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Gender is required';
        }
        return null;
      },
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor("#40D2B2"),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Sign Up',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildAgreementText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
            alignment: Alignment.topLeft,
            child:
                const Icon(Icons.check_circle, color: Colors.green, size: 20)),
        const SizedBox(width: 8),
        Flexible(
          child: Text.rich(
            TextSpan(
              text: "By signing up, you agree to the ",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              children: [
                TextSpan(
                  text: "Terms of service",
                  style: TextStyle(
                      color: HexColor("#FEC400"), fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: " and "),
                TextSpan(
                  text: "Privacy policy",
                  style: TextStyle(
                      color: HexColor("#FEC400"), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildOrSeparator() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.grey[300],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text("or",
              style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ),
        Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton("assets/images/google_icon.png", () {}),
        const SizedBox(width: 16),
        _buildSocialButton("assets/images/facebook_icon.png", () {}),
        const SizedBox(width: 16),
        _buildSocialButton("assets/images/apple_icon.png", () {}),
      ],
    );
  }

  Widget _buildSocialButton(String iconPath, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(iconPath, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildSignInOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //  Navigator.push(
        //      context, MaterialPageRoute(builder: (context) => LoginRiderPage()));
      },
      child: Center(
        child: Text.rich(
          TextSpan(
            text: "Already have an account? ",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            children: [
              TextSpan(
                text: "Sign in",
                style: TextStyle(
                    color: HexColor("#40D2B2"), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() => selectedCountry = country);
      },
    );
  }
}
