import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quote App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 1, 12, 82),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quote App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Action for Button 1
              },
              child: const Text('House List'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Action for Button 2
              },
              child: const Text('On going Activities'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Action for Button 3
              },
              child: const Text('Product List'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Action for Button 4
              },
              child: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
