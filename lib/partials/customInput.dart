import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CustomInput extends StatelessWidget {
  final double width;
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final bool strengthTest;
  final TextInputFormatter? formatter;
  final TextInputType type;
  final double fontSize;
  final bool readOnly;

  const CustomInput(
      {super.key,
      required this.label,
      required this.icon,
      required this.controller,
      this.formatter,
      this.isPassword = false,
      this.strengthTest = false,
      this.width = 350,
      this.type = TextInputType.text,
      this.fontSize = 11,
      this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: TextFormField(
        decoration: InputDecoration(
            label: Text(label),
            labelStyle: TextStyle(fontSize: 20, height: 0.5, color: Colors.white),
            prefixIcon: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            // fillColor: Colors.lightBlue[400],
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide(width: 2)),
            filled: false,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            contentPadding: EdgeInsets.all(5)),
        controller: controller,
        obscureText: isPassword,
        cursorColor: Colors.white,
        inputFormatters: (formatter != null) ? [formatter!] : null,
        style: TextStyle(fontSize: clampDouble((width / label.length) * 0.6, 16, 24), color: Colors.white),
        keyboardType: type,
        readOnly: readOnly,
        validator: (value) {
          if (!(value != null && value.isNotEmpty)) {
            return "Campo Obrigatorio";
          } else if (strengthTest &&
              !RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)) {
            return "Senha fraca";
          } else {
            return null;
          }
        },
      ),
    );
  }
}
