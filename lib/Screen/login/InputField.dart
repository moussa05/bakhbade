import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;

  const InputField({
    Key? key,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false, // Par défaut non masqué
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon),
          suffixIcon: Icon(Icons.clear),
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          floatingLabelStyle: const TextStyle(color: Colors.amber),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber, width: 2.0),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
      ),
    );
  }
}
