// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:dio/dio.dart';
// import 'package:equatable/equatable.dart';

// // States
// abstract class PasswordState extends Equatable {
//   @override
//   List<Object> get props => [];
// }

// class PasswordInitial extends PasswordState {}
// class PasswordLoading extends PasswordState {}
// class PasswordSuccess extends PasswordState {}
// class PasswordError extends PasswordState {
//   final String message;
//   PasswordError(this.message);

//   @override
//   List<Object> get props => [message];
// }

// // Cubit
// class PasswordCubit extends Cubit<PasswordState> {
//   final Dio _dio;

//   PasswordCubit() : 
//     _dio = Dio()..options.baseUrl = 'YOUR_ACTUAL_API_BASE_URL',  // Replace with actual URL
//     super(PasswordInitial());

//   Future<void> changePassword({
//     required String oldPassword,
//     required String newPassword,
//   }) async {
//     emit(PasswordLoading());

//     try {
//       // Verify old password
//       final verifyResponse = await _dio.post(
//         '/api/v1/auth/verify-password',
//         data: {'old_password': oldPassword},
//       );

//       if (verifyResponse.statusCode != 200) {
//         emit(PasswordError('Current password is incorrect'));
//         return;
//       }

//       // Update password
//       final updateResponse = await _dio.post(
//         '/api/v1/auth/update-password',
//         data: {'new_password': newPassword},
//       );

//       if (updateResponse.statusCode == 200) {
//         emit(PasswordSuccess());
//       } else {
//         emit(PasswordError('Failed to update password'));
//       }
//     } on DioException catch (e) {
//       emit(PasswordError(_mapDioErrorToMessage(e)));
//     } catch (e) {
//       emit(PasswordError('An unexpected error occurred'));
//     }
//   }

//   String _mapDioErrorToMessage(DioException error) {
//     switch (error.type) {
//       case DioExceptionType.connectionTimeout:
//       case DioExceptionType.sendTimeout:
//       case DioExceptionType.receiveTimeout:
//         return 'Connection timeout. Please check your internet connection.';
//       case DioExceptionType.badResponse:
//         return error.response?.data?['message'] ?? 'Server error occurred';
//       case DioExceptionType.cancel:
//         return 'Request was cancelled';
//       default:
//         return 'Network error occurred';
//     }
//   }
// }

// class ChangePasswordScreen extends StatefulWidget {
//   static const Key pageKey = Key('change_password_screen');
//   final VoidCallback? onSuccess;
  
//   const ChangePasswordScreen({
//     super.key = pageKey,
//     this.onSuccess,
//   });

//   @override
//   State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
// }

// class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _oldPasswordController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
  
//   bool _obscureOldPassword = true;
//   bool _obscureNewPassword = true;
//   bool _obscureConfirmPassword = true;

//   @override
//   void dispose() {
//     _oldPasswordController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }
//     if (value.length < 8) {
//       return 'Password must be at least 8 characters';
//     }
//     if (!RegExp(r'[A-Z]').hasMatch(value)) {
//       return 'Password must contain at least one uppercase letter';
//     }
//     if (!RegExp(r'[0-9]').hasMatch(value)) {
//       return 'Password must contain at least one number';
//     }
//     if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
//       return 'Password must contain at least one special character';
//     }
//     return null;
//   }

//   void _handleSubmit(BuildContext context) {
//     if (!_formKey.currentState!.validate()) return;

//     if (_newPasswordController.text != _confirmPasswordController.text) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Passwords do not match'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     context.read<PasswordCubit>().changePassword(
//           oldPassword: _oldPasswordController.text,
//           newPassword: _newPasswordController.text,
//         );
//   }

//   void _clearFields() {
//     _oldPasswordController.clear();
//     _newPasswordController.clear();
//     _confirmPasswordController.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => PasswordCubit(),
//       child: BlocListener<PasswordCubit, PasswordState>(
//         listener: (context, state) {
//           if (state is PasswordError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message))
//             );
//           }
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () => Navigator.pop(context),
//             ),
//             title: const Text('Change Password'),
//           ),
//           body: BlocConsumer<PasswordCubit, PasswordState>(
//             listener: (context, state) {
//               if (state is PasswordSuccess) {
//                 _clearFields();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Password updated successfully'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//                 widget.onSuccess?.call();
//               } else if (state is PasswordError) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(state.message),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             },
//             builder: (context, state) {
//               return SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       children: [
//                         TextFormField(
//                           controller: _oldPasswordController,
//                           decoration: InputDecoration(
//                             labelText: 'Old Password',
//                             suffixIcon: IconButton(
//                               icon: Icon(_obscureOldPassword 
//                                 ? Icons.visibility_off 
//                                 : Icons.visibility),
//                               onPressed: () => setState(() => 
//                                 _obscureOldPassword = !_obscureOldPassword),
//                             ),
//                           ),
//                           obscureText: _obscureOldPassword,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your current password';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _newPasswordController,
//                           decoration: InputDecoration(
//                             labelText: 'New Password',
//                             suffixIcon: IconButton(
//                               icon: Icon(_obscureNewPassword 
//                                 ? Icons.visibility_off 
//                                 : Icons.visibility),
//                               onPressed: () => setState(() => 
//                                 _obscureNewPassword = !_obscureNewPassword),
//                             ),
//                           ),
//                           obscureText: _obscureNewPassword,
//                           validator: _validatePassword,
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _confirmPasswordController,
//                           decoration: InputDecoration(
//                             labelText: 'Confirm Password',
//                             suffixIcon: IconButton(
//                               icon: Icon(_obscureConfirmPassword 
//                                 ? Icons.visibility_off 
//                                 : Icons.visibility),
//                               onPressed: () => setState(() => 
//                                 _obscureConfirmPassword = !_obscureConfirmPassword),
//                             ),
//                           ),
//                           obscureText: _obscureConfirmPassword,
//                           validator: _validatePassword,
//                         ),
//                         const SizedBox(height: 24),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: state is PasswordLoading 
//                               ? null 
//                               : () => _handleSubmit(context),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.orange,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: state is PasswordLoading
//                                 ? const CircularProgressIndicator(
//                                     color: Colors.white)
//                                 : const Text(
//                                     'Save',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }