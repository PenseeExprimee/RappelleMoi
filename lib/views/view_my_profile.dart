import 'package:flutter/material.dart';
import 'package:rappellemoi/services/auth/auth_service.dart';

class MyProfileview extends StatelessWidget {
  const MyProfileview({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.firebase().currentUser!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ton profil :D"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 50),
          Container(
            height: 75.0,
            width: 75.0,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/profile.jpg'),
                    fit: BoxFit.contain)),
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 70.0, right: 70.0),
            child: Text("Email address: ${currentUser.email}"),
          ),
        ],
      ),
    );
  }
}