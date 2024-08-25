import 'package:banka/src/components/nav_bar/nav_banka_view.dart';
import 'package:flutter/material.dart';

class Banka extends StatelessWidget {
  const Banka({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Banka',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const NavigationBanka(),
      );   
  }
}
