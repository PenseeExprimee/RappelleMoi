import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rappellemoi/enums/menu_action.dart';
import 'package:rappellemoi/services/bloc/auth_bloc.dart';
import 'dart:developer' as devtools show log;

import 'package:rappellemoi/services/bloc/auth_event.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  late final TextEditingController _email;
  late final TextEditingController _password;


  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();

    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  context.read<AuthBloc>().add(const AuthEventLoggedout());
                default:
                  devtools.log("I don't know");
              }
            },
            itemBuilder: (context) { //defines the actual menu
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout, //la valeur qui sera renvoyée et peut être utilisé dans une logique
                  child: Text("Logout")
                )
              ];
            },
          )
        ],
      ) ,
    );
  }
}