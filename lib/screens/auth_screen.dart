// import 'package:flutter/material.dart';
// import 'package:cv_ganerator/config/theme.dart';
// import 'package:cv_ganerator/constants/dimensions.dart';
// import 'package:cv_ganerator/constants/strings.dart';
// import 'package:cv_ganerator/widgets/app_widgets.dart';
// import 'package:cv_ganerator/widgets/common_widgets.dart';

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> {
//   bool _isLogin = true;
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(gradient: AppTheme.gradientBackground),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(AppDimensions.paddingLarge),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   AppStrings.appName,
//                   style: theme.textTheme.displaySmall?.copyWith(
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: AppDimensions.paddingSmall),
//                 Text(
//                   _isLogin
//                       ? 'Welcome back. Let us build your next CV.'
//                       : 'Create your account to start building.',
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: Colors.white70,
//                   ),
//                 ),
//                 const SizedBox(height: AppDimensions.paddingLarge),
//                 CustomCard(
//                   borderRadius: AppDimensions.borderRadiusXLarge,
//                   child: Column(
//                     children: [
//                       _buildToggle(theme),
//                       const SizedBox(height: AppDimensions.paddingLarge),
//                       if (!_isLogin) ...[
//                         CustomTextField(
//                           label: AppStrings.fullName,
//                           hint: 'John Doe',
//                           controller: _nameController,
//                           prefixIcon: Icons.person_outline,
//                         ),
//                         const SizedBox(height: AppDimensions.paddingMedium),
//                       ],
//                       CustomTextField(
//                         label: AppStrings.email,
//                         hint: 'you@email.com',
//                         controller: _emailController,
//                         prefixIcon: Icons.email_outlined,
//                         keyboardType: TextInputType.emailAddress,
//                       ),
//                       const SizedBox(height: AppDimensions.paddingMedium),
//                       CustomTextField(
//                         label: 'Password',
//                         hint: 'At least 8 characters',
//                         controller: _passwordController,
//                         prefixIcon: Icons.lock_outline,
//                         obscureText: true,
//                       ),
//                       const SizedBox(height: AppDimensions.paddingLarge),
//                       PrimaryButton(
//                         label: _isLogin ? AppStrings.login : AppStrings.signUp,
//                         onPressed: _handleAuth,
//                         icon: Icons.arrow_forward,
//                       ),
//                       const SizedBox(height: AppDimensions.paddingMedium),
//                       SecondaryButton(
//                         label: AppStrings.continueAsGuest,
//                         onPressed: () {
//                           Navigator.pushReplacementNamed(context, '/root');
//                         },
//                         icon: Icons.person_outline,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: AppDimensions.paddingLarge),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       _isLogin
//                           ? 'New here?'
//                           : 'Already have an account?',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: Colors.white70,
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         setState(() => _isLogin = !_isLogin);
//                       },
//                       child: Text(
//                         _isLogin ? AppStrings.signUp : AppStrings.login,
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildToggle(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: AppTheme.backgroundColor,
//         borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: _buildToggleButton(
//               label: AppStrings.login,
//               active: _isLogin,
//               onTap: () => setState(() => _isLogin = true),
//             ),
//           ),
//           Expanded(
//             child: _buildToggleButton(
//               label: AppStrings.signUp,
//               active: !_isLogin,
//               onTap: () => setState(() => _isLogin = false),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToggleButton({
//     required String label,
//     required bool active,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: active ? AppTheme.primaryColor : Colors.transparent,
//           borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
//         ),
//         child: Text(
//           label,
//           textAlign: TextAlign.center,
//           style: Theme.of(context).textTheme.titleLarge?.copyWith(
//             color: active ? Colors.white : AppTheme.textDark,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleAuth() {
//     Navigator.pushReplacementNamed(context, '/root');
//   }
// }
