import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:curve_vpn/pages/home_page.dart';
import 'package:curve_vpn/constants/constant.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());
  runApp(const GetMaterialApp(
    debugShowCheckedModeBanner: false,
    title: Constant.appName,
    home: HomePage(),
  ));
}
