import 'dart:typed_data';

import 'package:aurion_hotel/_logik/theme/theme_provider.dart';
import 'package:aurion_hotel/main_codes/asplash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
// Only for web
// ignore: undefined_prefixed_name
import 'dart:ui' as ui;
import 'dart:html' as html;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background notification handler
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  // if (kIsWeb) {
  //   // ignore: undefined_prefixed_name
  //   ui.platformViewRegistry.registerViewFactory('drop-zone', (int viewId) {
  //     final div = html.DivElement()
  //       ..style.width = '100%'
  //       ..style.height = '150px'
  //       ..style.border = '2px dashed #aaa'
  //       ..style.borderRadius = '12px'
  //       ..style.backgroundColor = 'rgba(255,255,0,0.05)'
  //       ..style.display = 'flex'
  //       ..style.alignItems = 'center'
  //       ..style.justifyContent = 'center'
  //       ..text = 'Drop document here (or click to choose)';

  //     // Prevent default browser behavior on drag/drop
  //     div.addEventListener('dragover', (event) {
  //       event.preventDefault();
  //       div.style.backgroundColor = 'rgba(255,255,0,0.15)';
  //     });

  //     div.addEventListener('dragleave', (event) {
  //       event.preventDefault();
  //       div.style.backgroundColor = 'rgba(255,255,0,0.05)';
  //     });

  //     div.addEventListener('drop', (event) async {
  //       event.preventDefault();
  //       final dataTransfer = (event as html.MouseEvent).dataTransfer;
  //       if (dataTransfer != null && dataTransfer.files!.isNotEmpty) {
  //         final file = dataTransfer.files!.first;
  //         final reader = html.FileReader();
  //         reader.readAsArrayBuffer(file);
  //         reader.onLoadEnd.listen((_) {
  //           final bytes = Uint8List.view((reader.result as ByteBuffer));
  //           // Use your existing handler
  //           // e.g., call a function to set droppedBytes & upload
  //         });
  //       }
  //       div.style.backgroundColor = 'rgba(255,255,0,0.05)';
  //     });

  //     return div;
  //   });
  // }

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Aurion Hotel',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,

      // LIGHT THEME
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 236, 236, 236),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0.5,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 236, 236, 236),
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),

      // DARK THEME
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 236, 236, 236),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          elevation: 0.5,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 236, 236, 236),
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),

      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        SystemChrome.setSystemUIOverlayStyle(
          brightness == Brightness.dark
              ? SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                )
              : SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                ),
        );
        return child!;
      },

      home: const SplashScreen(),
      // home: DeviceBlocker(
      //   mobileApp: const SplashScreen(),
      // ),
    );
  }
}
