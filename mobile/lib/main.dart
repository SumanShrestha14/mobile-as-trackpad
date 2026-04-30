import 'package:flutter/material.dart';

import 'presentation/app/mobile_as_trackpad_app.dart';
import 'injection/injection.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MobileAsTrackpadApp());
}
