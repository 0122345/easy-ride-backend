import 'package:eazyride_mobile/components/auth/otp_page.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_flags/country_flags.dart';
import 'package:eazyride_mobile/components/auth/signup.dart';
import 'package:eazyride_mobile/theme/hex_color.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Country? selectedCountry;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    selectedCountry = null; // Initialize with null or a default country.
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' first step Successful!')),
        );
        // Navigate to the next screen
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => OtpPage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
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
                 
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPhoneField(),
                
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
          "Sign In",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
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


  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor("#EDAE10"),
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
                'Log In',
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
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignUp()));
      },
      child: Center(
        child: Text.rich(
          TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            children: [
              TextSpan(
                text: "Sign Up",
                style: TextStyle(
                    color: HexColor("#FEC400"), fontWeight: FontWeight.bold),
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
