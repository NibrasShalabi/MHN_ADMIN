import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_text_styles.dart';
import '../../../../core/widgets/admin_button.dart';
import '../../../../core/widgets/admin_field.dart';
import '../../../../core/widgets/admin_text_input.dart';
import '../../../dashboard/presentation/pages/admin_home_page.dart';
import '../../data/repository/auth_repository.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(GetIt.instance<AuthRepository>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    context.read<AuthCubit>().login(_emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.canvas,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.success) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminHomePage()),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AdminConstants.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.storefront_outlined, size: 56, color: AdminColors.gold),
                  const SizedBox(height: AdminConstants.spacingMd),
                  Text(
                    'لوحة تحكم MHN',
                    textAlign: TextAlign.center,
                    style: AdminTextStyles.pageTitle.copyWith(color: AdminColors.gold),
                  ),
                  const SizedBox(height: AdminConstants.spacingXl),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AdminField(
                            label: 'البريد الإلكتروني',
                            isRequired: true,
                            child: AdminTextInput(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          AdminField(
                            label: 'كلمة المرور',
                            isRequired: true,
                            child: AdminTextInput(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: AdminColors.textSecondary,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          if (state.status == AuthStatus.failure) ...[
                            const SizedBox(height: AdminConstants.spacingSm),
                            Text(
                              state.errorMessage ?? '',
                              style: AdminTextStyles.caption.copyWith(color: AdminColors.danger),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: AdminConstants.spacingLg),
                          state.status == AuthStatus.loading
                              ? const Center(child: CircularProgressIndicator())
                              : AdminButton(
                            label: 'تسجيل الدخول',
                            onPressed: () => _submit(context),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}