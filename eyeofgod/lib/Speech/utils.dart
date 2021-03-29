import 'package:flutter/material.dart';

class Command {
  // static final all = [email, browser1, browser2];

  static const place = 'to';
  // static const browser1 = 'open';
  // static const browser2 = 'go to';
}

class Utils {
  static String scanText(String rawText) {
    final text = rawText.toLowerCase();
    print(text);
    String loc;
    if (text.contains(Command.place)) {
      loc = _getTextAfterCommand(text: text, command: Command.place);
    }
    print(loc);
    return loc;
  }

  static String _getTextAfterCommand({
    @required String text,
    @required String command,
  }) {
    final indexCommand = text.indexOf(command);
    final indexAfter = indexCommand + command.length;

    if (indexCommand == -1) {
      return null;
    } else {
      return text.substring(indexAfter).trim();
    }
  }
}
