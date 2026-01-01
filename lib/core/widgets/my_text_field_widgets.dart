import 'package:flutter/material.dart';

class MyTextFieldWidgets extends StatefulWidget {
  const MyTextFieldWidgets({
    super.key,
    required this.controller,
    required this.hintText,
    required this.text,
    this.validator,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hintText;
  final String text;
  final String? Function(String?)? validator;
  final bool obscureText;

  @override
  State<MyTextFieldWidgets> createState() => _MyTextFieldWidgetsState();
}

class _MyTextFieldWidgetsState extends State<MyTextFieldWidgets> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.text,
        labelStyle: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey, width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              )
            : null,
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return ('Please enter ${widget.text}');
        }
        return null;
      },
    );
  }
}
