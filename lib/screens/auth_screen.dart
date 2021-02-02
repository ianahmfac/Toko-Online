import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:toko_online/providers/auth.dart';
import 'package:toko_online/shared/theme.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [mainColor, mainColor.withOpacity(0.2)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 80, left: 32, right: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "🛒 Toko Online",
                  style: TextStyle(
                    fontFamily: "Anton",
                    fontSize: 32,
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              AuthForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  var _isSecure = true;
  var _isConfirmationSecure = true;
  var _isLoginPage = true;
  var _isLoading = false;
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Map<String, String> _formData = {
    "email": "",
    "password": "",
    "name": "",
  };

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorMessage(String errorMessage) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Pesan Kesalahan"),
        content: Text(errorMessage),
        actions: [
          CupertinoButton(
            child: Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    final isValid = _formKey.currentState.validate();
    if (!isValid) return;

    _formKey.currentState.save();

    setState(() {
      _isLoading = true;
    });
    try {
      if (_isLoginPage) {
        //* Sign In Method
        await Provider.of<Auth>(context, listen: false)
            .signInWithEmailAndPassword(
                _formData["email"], _formData["password"]);
      } else {
        //* Sign Up Method
        final auth = Provider.of<Auth>(context, listen: false);
        await auth.signUp(
            _formData["email"], _formData["password"], _formData["name"]);
      }
    } catch (e) {
      var errorMessage = "Terjadi kesalahan. Coba secara berkala.";
      if (e.toString().contains("EMAIL_EXISTS"))
        errorMessage = "Alamat email sudah digunakan oleh akun lain";
      else if (e.toString().contains("OPERATION_NOT_ALLOWED"))
        errorMessage = "Password Sign In dinonaktifkan untuk aplikasi ini";
      else if (e.toString().contains("TOO_MANY_ATTEMPTS_TRY_LATER"))
        errorMessage =
            "Kami telah memblokir semua permintaan dari perangkat ini karena aktivitas yang tidak biasa. Coba lagi nanti.";
      else if (e.toString().contains("EMAIL_NOT_FOUND"))
        errorMessage =
            "Tidak ada catatan pengguna yang sesuai dengan pengenal ini. Pengguna tersebut mungkin telah dihapus.";
      else if (e.toString().contains("INVALID_PASSWORD"))
        errorMessage =
            "Password tidak valid atau pengguna tidak memiliki password.";
      else if (e.toString().contains("USER_DISABLED"))
        errorMessage = "Akun pengguna telah dinonaktifkan oleh administrator.";

      _showErrorMessage(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isLoginPage ? "Sign In" : "Sign Up",
          style: productTitle.copyWith(fontSize: 28),
        ),
        SizedBox(
          height: 30,
        ),
        Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //* Email Form
                Text(
                  "Email Address",
                  style: productTitle,
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white70,
                  ),
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      hintText: "Email Address",
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value.isEmpty) return "Field tidak boleh kosong";
                      if (!EmailValidator.validate(value))
                        return "Alamat email tidak valid";
                      else
                        return null;
                    },
                    onSaved: (newValue) {
                      _formData["email"] = newValue;
                    },
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                //* Password Form
                Text(
                  "Password",
                  style: productTitle,
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white70,
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    textInputAction: TextInputAction.next,
                    obscureText: _isSecure,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                          icon: Icon(
                            _isSecure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isSecure = !_isSecure;
                            });
                          }),
                    ),
                    validator: (value) {
                      if (value.isEmpty) return "Field tidak boleh kosong";
                      if (value.length < 8)
                        return "Password setidaknya memiliki 8 karakter";
                      else
                        return null;
                    },
                    onSaved: (newValue) {
                      _formData["password"] = newValue;
                    },
                  ),
                ),
                //* Confirm Password Form
                if (!_isLoginPage)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      //* Password Form
                      Text(
                        "Re-type Password",
                        style: productTitle,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white70,
                        ),
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          obscureText: _isConfirmationSecure,
                          decoration: InputDecoration(
                            hintText: "Re-type Password",
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmationSecure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmationSecure =
                                        !_isConfirmationSecure;
                                  });
                                }),
                          ),
                          validator: (value) {
                            if (value.isEmpty)
                              return "Field tidak boleh kosong";
                            if (value != _passwordController.text)
                              return "Password tidak sesuai";
                            else
                              return null;
                          },
                        ),
                      ),
                      //* Name
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Name",
                        style: productTitle,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white70,
                        ),
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: "Name",
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value.isEmpty)
                              return "Field tidak boleh kosong";
                            else
                              return null;
                          },
                          onSaved: (newValue) {
                            _formData["name"] = newValue;
                          },
                        ),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 32,
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        primary: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? SpinKitFadingCircle(
                              color: Colors.black,
                              size: 35,
                            )
                          : Text(
                              _isLoginPage ? "SIGN IN" : "SIGN UP",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Center(
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isLoginPage = !_isLoginPage;
                        });
                      },
                      child: Text(
                        _isLoginPage
                            ? "Don\'t have an account? Sign Up first"
                            : "Already have an account? Sign In here",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      )),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
