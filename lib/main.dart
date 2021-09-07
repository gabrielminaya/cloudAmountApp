import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/app_widget.dart';
import 'core/di/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DependecyInjection.configure();
  await Firebase.initializeApp();

  runApp(AppWidget());
}
