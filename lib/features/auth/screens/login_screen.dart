import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_validation.dart';
import '../../../core/utils/context_extension.dart';
import '../../../core/utils/responsiveness.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final pass = TextEditingController();
  final ValueNotifier<bool> _obscure = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    final w = screenWidth(context);
    final h = screenHeight(context);
    final pastelBlueDark = const Color(0xFF6CA9D9);

    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.02),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthSuccess) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/todos", (route) => false);
                } else if (state is AuthFailure) {
                  context.showSnackBar(state.message);
                }
              },
              builder: (context, state) {
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(w * 0.05),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Login",
                            style: TextStyle(
                              fontSize: w * 0.07,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontFamily: 'serif',
                            ),
                          ),
                          SizedBox(height: h * 0.03),

                          /// EMAIL FIELD
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: email,
                              style: TextStyle(color: Colors.black, fontSize: w * 0.045),
                              decoration: const InputDecoration(
                                labelText: "Email",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                              ),
                              validator: AppValidation.validateEmail,
                            ),
                          ),
                          SizedBox(height: h * 0.02),

                          /// PASSWORD FIELD
                          ValueListenableBuilder(
                            valueListenable: _obscure,
                            builder: (context, value, _) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: pass,
                                  obscureText: value,
                                  style: TextStyle(color: Colors.black, fontSize: w * 0.045),
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 15),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        value ? Icons.visibility_off : Icons.visibility,
                                      ),
                                      onPressed: () => _obscure.value = !value,
                                    ),
                                  ),
                                  validator: AppValidation.validatePassword,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: h * 0.03),

                          /// LOGIN BUTTON
                          state is AuthLoading
                              ? const CircularProgressIndicator()
                              : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pastelBlueDark,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: h * 0.02,
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthCubit>().login(
                                    email.text.trim(),
                                    pass.text.trim(),
                                  );
                                }
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(fontSize: w * 0.045),
                              ),
                            ),
                          ),
                          SizedBox(height: h * 0.015),

                          /// REGISTER LINK
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, "/register");
                            },
                            child: Text(
                              "Create account",
                              style: TextStyle(fontSize: w * 0.04),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}