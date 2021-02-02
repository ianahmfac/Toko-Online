import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toko_online/shared/theme.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitFadingCircle(
              color: mainColor,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "Please Wait",
              style: productTitle.copyWith(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
