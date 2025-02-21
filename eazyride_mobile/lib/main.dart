import 'package:eazyride_mobile/auth/passenger/search_accept_ride.dart';
import 'package:eazyride_mobile/components/drawer.dart';
import 'package:eazyride_mobile/onboarding/entrance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: ".env");
  RendererBinding.instance.mouseTracker.dispose();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<RideState>(
          create: (_) => RideState(),
        ),
        Provider<MyDrawerController>(
          create: (_) => Get.put(MyDrawerController()),
        ),
      ],
      child: const MyApp(),
    ),
  );

  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ride Easy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const OnboardingSc(),
    );
  }
}
