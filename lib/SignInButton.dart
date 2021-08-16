import 'package:flutter/material.dart';

class SignInButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function() onPressed;

  const SignInButton({Key? key, required this.icon, required this.text, required this.onPressed}): super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 44,
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18,),
              Padding(padding: const EdgeInsets.only(left: 4)),
              Text(text, style: TextStyle(fontSize: 18),)
            ],
          ),
        ),
      ),
    );
  }
}
