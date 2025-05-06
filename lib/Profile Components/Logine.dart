import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vakansiya/Profile%20Components/ForgotPassword.dart';
import 'package:vakansiya/Profile%20Components/Helps.dart';
import 'package:vakansiya/Profile%20Components/ProfilePage.dart';
import 'package:vakansiya/Profile%20Components/signup.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../shared_pref_helper.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Вход', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 5,
        backgroundColor: Color.fromARGB(255, 6, 60, 74),
      ),
      backgroundColor: Color(0xFF121212),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              // Анимация Lottie для современного вида
              Container(
                height: 200,
                child: Lottie.asset('assets/animation_lm0js4z1.json'),
              ),
              SizedBox(height: 30),
              // Блок с формой для входа
              Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A3C52), Color(0xFF1AABBC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      // Поле для ввода email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFF212121),
                          prefixIcon: Icon(Icons.email, color: Colors.white),
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Неверный адрес электронной почты';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      // Поле для ввода пароля
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFF212121),

                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            child: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                          ),
                          labelText: 'Пароль',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty || value.length < 6) {
                            return 'Пароль должен содержать не менее 6 символов';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      // Кнопка входа
                      ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    try {
                                   var user=   await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                            email: _emailController.text,
                                            password: _passwordController.text,
                                          );
                                      final pref = SharedPrefHelper();

                                      await pref.saveString(user.user!.uid);
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => JobProfilePage(),
                                        ),
                                      );
                                    } catch (e) {
                                      String errorMessage =
                                          "Произошла ошибка. Пожалуйста, проверьте свои данные.";
                                      if (e is FirebaseAuthException) {
                                        if (e.code == 'user-not-found') {
                                          errorMessage =
                                              "Пользователь с таким email не найден.";
                                        } else if (e.code == 'wrong-password') {
                                          errorMessage =
                                              "Неверный пароль. Попробуйте снова.";
                                        }
                                      }
                                      _showErrorDialog(context, errorMessage);
                                    } finally {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1A3C52),
                          padding: EdgeInsets.symmetric(
                            vertical: 14.0,
                            horizontal: 30.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Войти',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Ссылки на забыл пароль и регистрацию
                      _buildFooterLinks(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ссылки внизу
  Widget _buildFooterLinks(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
            );
          },
          child: Text(
            'Забыли пароль?',
            style: TextStyle(
              color: Color(0xFF1AABBC),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignupPage()),
            );
          },
          child: Text(
            "Нет аккаунта? Зарегистрироваться",
            style: TextStyle(
              color: Color(0xFF1AABBC),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HelpPage()),
            );
          },
          child: Text(
            'Помощь',
            style: TextStyle(
              color: Color(0xFF1AABBC),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ошибка входа'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
