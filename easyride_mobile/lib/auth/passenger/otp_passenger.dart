import 'package:dio/dio.dart';
import 'package:eazyride_mobile/theme/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:eazyride_mobile/transport/home_transport.dart';

class OtpPage extends StatefulWidget {
  final String userId;
  final String phone;
  
  const OtpPage({
    Key? key, 
    required this.userId,
    required this.phone,
  }) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final apiUrl = const String.fromEnvironment('API_URL',
    defaultValue: 'https://easy-ride-backend-xl8m.onrender.com/api');
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String currentText = "";
  late final Dio dio;
  int _resendAttempts = 0;
  bool _canResend = true;

  @override
  void initState() {
    super.initState();
    _initializeNetworking();
    _startResendTimer();
  }

  void _initializeNetworking() {
    dio = Dio();
    dio.options.baseUrl = apiUrl;
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.options.validateStatus = (status) => status! < 500;
    dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: _handleNetworkError,
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer ${widget.userId}';
          return handler.next(options);
        },
      ),
    );
  }

  void _handleNetworkError(DioError error, ErrorInterceptorHandler handler) {
    String message;
    switch (error.type) {
      case DioErrorType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioErrorType.receiveTimeout:
        message = 'Server not responding. Please try again.';
        break;
      case DioErrorType.connectionError:
        message = 'No internet connection.';
        break;
      default:
        message = 'Verification failed. Please try again.';
    }
    if (mounted) _showMessage(message);
    handler.next(error);
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() => _canResend = true);
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (!_validateOtp()) return;

    setState(() => _isLoading = true);
    try {
      final response = await _makeVerificationRequest();
      await _handleVerificationResponse(response);
    } catch (e) {
      _handleVerificationError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateOtp() {
    if (currentText.length != 5) {
      _showMessage('Please enter the complete 5-digit OTP');
      return false;
    }
    return true;
  }

  Future<Response> _makeVerificationRequest() async {
    return await dio.post(
      '/auth/verify-otp',
      data: {
        'userId': widget.userId,
        'otp': currentText,
        'phone': widget.phone,
      },
    );
  }

  Future<void> _handleVerificationResponse(Response response) async {
    if (!mounted) return;

    if (response.statusCode == 200) {
      await _processSuccessfulVerification(response.data);
    } else {
      _showMessage(response.data['message'] ?? 'Verification failed');
    }
  }

  Future<void> _processSuccessfulVerification(Map<String, dynamic> data) async {
    _showMessage('OTP Verified Successfully!');
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeTransp()),
      (route) => false,
    );
  }

  void _handleVerificationError(dynamic error) {
    if (!mounted) return;
    _showMessage('Verification failed. Please try again.');
  }

  Future<void> _resendOtp() async {
    if (!_canResend || _resendAttempts >= 3) {
      _showMessage('Maximum resend attempts reached. Please try again later.');
      return;
    }

    setState(() {
      _canResend = false;
      _resendAttempts++;
    });

    try {
      final response = await dio.post(
        '/auth/resend-otp',
        data: {
          'userId': widget.userId,
          'phone': widget.phone,
        },
      );

      if (response.statusCode == 200 && mounted) {
        _showMessage('New OTP sent successfully!');
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to resend OTP. Please try again later.');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#FFFFFF"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              _buildTitle(),
              const SizedBox(height: 8),
              _buildSubtitle(),
              const SizedBox(height: 40),
              _buildOtpInput(),
              const SizedBox(height: 32),
              _buildVerifyButton(),
              const SizedBox(height: 24),
              _buildResendOption(),
            ],
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
          "Back",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Center(
      child: const Text(
        "Phone Verification",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Center(
      child: Text(
        "Enter your Otp Code",
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildOtpInput() {
    return PinCodeTextField(
      appContext: context,
      length: 5,
      controller: _otpController,
      onChanged: (value) {
        setState(() => currentText = value);
      },
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(10),
        fieldHeight: 50,
        fieldWidth: 50,
        activeFillColor: Colors.white,
        selectedFillColor: Colors.white,
        inactiveFillColor: Colors.white,
        borderWidth: 1,
        activeColor: HexColor("#EDAE10"),
        selectedColor: HexColor("#EDAE10"),
        inactiveColor: Colors.black,
      ),
      cursorColor: Colors.black,
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor("#EDAE10"),
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
                'Verify',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildResendOption() {
    return Center(
      child: TextButton(
        onPressed: _resendOtp,
        child: Text.rich(
          TextSpan(
            text: "Didn't receive code? ",
            style: TextStyle(fontSize: 16, color: Colors.black),
            children: [
              TextSpan(
                text: "Resend",
                style: TextStyle(
                    color: HexColor("#FEC400"), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}