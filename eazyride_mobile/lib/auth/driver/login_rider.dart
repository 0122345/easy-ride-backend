import 'package:eazyride_mobile/auth/driver/otp_page.dart';
import 'package:eazyride_mobile/auth/homepage.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:country_flags/country_flags.dart';
import 'package:eazyride_mobile/auth/driver/signup.dart';
import 'package:eazyride_mobile/theme/hex_color.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final apiUrl = const String.fromEnvironment('API_URL',
    defaultValue: 'https://easy-ride-backend-xl8m.onrender.com/api/auth/driver/login');
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Country? selectedCountry;
  late final Dio dio;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCountry = null;
    _configureNetworking();
  }

  void _configureNetworking() {
    dio = Dio();
    dio.options.baseUrl = apiUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 5);
    dio.options.validateStatus = (status) => status! < 500;
    dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: _handleNetworkError,
        onRequest: (options, handler) => handler.next(options),
        onResponse: (response, handler) => handler.next(response),
      ),
    );
  }

  void _handleNetworkError(DioError error, ErrorInterceptorHandler handler) {
    String message = 'Network error occurred';
    switch (error.type) {
      case DioErrorType.connectionTimeout:
        message = 'Connection timed out';
        break;
      case DioErrorType.receiveTimeout:
        message = 'Server not responding';
        break;
      case DioErrorType.connectionError:
        message = 'No internet connection';
        break;
      default:
        message = 'Please try again';
    }
    if (mounted) _showError(message);
    handler.next(error);
  }

  Future<void> _handleLogin() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    try {
      final response = await _makeLoginRequest();
      await _processLoginResponse(response);
    } catch (e) {
      _handleLoginError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;
    if (selectedCountry == null) {
      _showError('Please select your country');
      return false;
    }
    return true;
  }

  Future<Response> _makeLoginRequest() async {
    return await dio.post(
      '/auth/login',
      data: {
        'phone': '${selectedCountry!.phoneCode}${_phoneController.text.trim()}',
        'name': _nameController.text.trim(),
      },
    );
  }

  Future<void> _processLoginResponse(Response response) async {
    if (response.statusCode == 200 && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpPage(
            userId: response.data['userId'],
            phone: '${selectedCountry!.phoneCode}${_phoneController.text.trim()}', token: null,
          ),
        ),
      );
    }
  }

  void _handleLoginError(dynamic error) {
    if (mounted) {
      _showError('Login failed. Please verify your details and try again.');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      final response = await dio.post(
        '/auth/google-login',
        data: {
          'idToken': googleAuth.idToken,
          'email': googleUser.email,
          'name': googleUser.displayName,
          'photoUrl': googleUser.photoUrl,
        },
      );

      if (response.statusCode == 200 && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
      }
    } catch (e) {
      if (mounted) _showError('Google Sign-In failed. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildNameField(),
                const SizedBox(height: 16),
                _buildPhoneField(),
                const SizedBox(height: 32),
                _buildLoginButton(),
                const SizedBox(height: 20),
                _buildAgreementText(),
                const SizedBox(height: 16),
                _buildOrSeparator(),
                const SizedBox(height: 20),
                _buildSocialButtons(),
                const SizedBox(height: 20),
                _buildSignUpOption(),
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

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        errorMaxLines: 2,
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
    );
  }

  Widget _buildPhoneField() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _showCountryPicker(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedCountry != null) ...[
                  CountryFlag.fromCountryCode(
                    selectedCountry!.countryCode.toLowerCase(),
                    height: 24,
                    width: 32,
                  ),
                  const SizedBox(width: 8),
                ],
                Text('+${selectedCountry?.phoneCode ?? ""}'),
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
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              errorMaxLines: 2,
            ),
            validator: _validatePhone,
            onFieldSubmitted: (_) => _handleLogin(),
          ),
        ),
      ],
    );
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleanPhone = value.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length < 9 || cleanPhone.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor:Color.fromARGB(255, 7, 255, 255),
          disabledBackgroundColor:Color.fromARGB(255, 7, 255, 255).withOpacity(0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        const Icon(Icons.check_circle, color: Colors.green, size: 20),
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
                    color: HexColor("#FEC400"),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: " and "),
                TextSpan(
                  text: "Privacy policy",
                  style: TextStyle(
                    color: HexColor("#FEC400"),
                    fontWeight: FontWeight.bold,
                  ),
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
          child: Divider(thickness: 1, color: Colors.grey[300]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text("or",
              style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ),
        Expanded(
          child: Divider(thickness: 1, color: Colors.grey[300]),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton("assets/images/google_icon.png", _handleGoogleSignIn),
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

  Widget _buildSignUpOption() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUp()),
        );
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
                  color: HexColor("#FEC400"),
                  fontWeight: FontWeight.bold,
                ),
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
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(10),
        inputDecoration: InputDecoration(
         // hintText: 'Search country',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() => selectedCountry = country);
      },
    );
  }
}
