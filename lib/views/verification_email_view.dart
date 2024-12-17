import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rappellemoi/services/bloc/auth_bloc.dart';
import 'package:rappellemoi/services/bloc/auth_event.dart';

class VerifEmail extends StatelessWidget {
  const VerifEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Email verification"),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 50
          ),
          Container(
            height: 120.0,
            width: 120.0,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:  AssetImage('assets/images/email_open.jpg'),
                fit: BoxFit.contain
              )
            ),
          ),
          const SizedBox(
            height: 50
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(" We've sent you a verification email.Please click on the link in the email to verify your account.If you haven't received the email, click on the button below."),
          ),
          const SizedBox(
            height: 50
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor:  Colors.white,
              backgroundColor: Colors.blue,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular((100.0))),
                side: BorderSide(
                  color: Colors.blue,
                  width: 5,
                )
              ),
            ),
            onPressed:() {
              //send an event to signify that the user should verify his email
              context.read<AuthBloc>().add(const AuthEventShouldVerifyEmail());
            
            }, 
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mail),
              SizedBox(width: 10),
              Text('Re-send the verification email')
            ],
          )
          ),
          const SizedBox(
            height: 10
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor:  Colors.white,
              backgroundColor: Colors.cyan[400],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular((100.0))),
                
              ),
            ),
            onPressed:() {
              //send an event to signify that the user should verify his email
              context.read<AuthBloc>().add(const AuthEventLoggedout());
            
            }, 
            child:  const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home),
                SizedBox(width: 10),
                Text("Home page")
              ],
            )
          )
        ],
      ),
    );
  }
}