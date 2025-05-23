import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

MaskTextInputFormatter cpfFormatter = MaskTextInputFormatter(
  mask: "###.###.###-##",
  filter: {
    "#": RegExp(r'[0-9]'),
  },
);

MaskTextInputFormatter phoneFormatter = MaskTextInputFormatter(
  mask: "(##) #####-####",
  filter: {
    "#": RegExp(r'[0-9]'),
  },
);

final format = DateFormat("d/M/y").format;
final file_format = DateFormat("d_M_y").format;


extension Pallete on Color {
  static Color green = HexColor.fromHex("#279557");
  static Color blue = HexColor.fromHex("#064A6F");
  static Color gray = HexColor.fromHex("#0d0d0d");
  static Color black = HexColor.fromHex("#010101");
  static Color red = HexColor.fromHex("#EB5757");
  static Color white = HexColor.fromHex("#d8dee9");
  static Color orange = HexColor.fromHex("#d08770");
}

InputBorder border = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(15)),
  borderSide: BorderSide(
    color: Pallete.red,
    width: 2,
  ),
);

ThemeData themeData = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: Pallete.black,
  textTheme: GoogleFonts.aBeeZeeTextTheme(TextTheme()),
  appBarTheme: AppBarTheme(
    backgroundColor: Pallete.gray,
    centerTitle: true,
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: Pallete.gray,
    width: 300,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Pallete.red,
    backgroundColor: Pallete.gray,
    unselectedItemColor: Pallete.white,
    showUnselectedLabels: true,
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(Pallete.red),
    ),
  ),
  platform: TargetPlatform.windows,
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(Pallete.red),
      iconSize: WidgetStatePropertyAll(16)
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: border,
    enabledBorder: border,
    focusedBorder: border,
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Pallete.gray,
    shadowColor: Pallete.red,
  ),
  switchTheme: SwitchThemeData(
    trackColor: WidgetStatePropertyAll(Pallete.gray),
  ),
);

extension StringOPS on String {
  String ifEmpty(String replacement) => (isEmpty) ? replacement : this;
}