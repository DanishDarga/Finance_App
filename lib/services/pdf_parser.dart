import 'dart:io';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class PdfParserService {
  Future<List<Transaction>> parseBankStatement(String filePath) async {
    final Uint8List bytes = await File(filePath).readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    final String text = PdfTextExtractor(document).extractText();
    document.dispose();

    final lines = text.split("\n").map((e) => e.trim()).toList();

    List<Transaction> transactions = [];

    for (int i = 0; i < lines.length - 3; i++) {
      final line = lines[i];

      // 1️⃣ Check if the line is a DATE (dd-MM-yyyy)
      if (!RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(line)) {
        continue;
      }

      String dateStr = line;
      String desc = lines[i + 1];
      String amountStr = lines[i + 2];
      String balanceStr = lines[i + 3];

      // 2️⃣ Amount must be in numeric form "123.45" or "2,450.00"
      if (!RegExp(r'^\d[\d,]*\.\d{2}$').hasMatch(amountStr)) {
        continue; // skip malformed block
      }

      // 3️⃣ Parse values
      double amount = double.parse(amountStr.replaceAll(",", ""));
      DateTime date = DateFormat("dd-MM-yyyy").parseStrict(dateStr);

      // 4️⃣ Detect credit / debit using description
      bool isDebit = desc.contains("/DR/") || desc.contains("DR");
      if (isDebit) amount = -amount;

      // 5️⃣ Add final transaction
      transactions.add(
        Transaction(
          title: desc,
          amount: amount,
          date: date,
          category: _detectCategory(desc),
        ),
      );

      // 6️⃣ Skip ahead (since we consumed 4 lines)
      i += 3;
    }

    return transactions;
  }

  // -------------------------------------------------
  // Helpers
  // -------------------------------------------------
  String _detectCategory(String desc) {
    final up = desc.toUpperCase();

    if (up.contains("AMAZON") || up.contains("FLIPKART")) {
      return "Shopping";
    }
    if (up.contains("ZOMATO") || up.contains("SWIGGY")) {
      return "Food";
    }

    if (up.contains("FUEL") || up.contains("HPCL") || up.contains("BPCL")) {
      return "Fuel";
    }

    if (up.contains("UBER") || up.contains("OLA")) {
      return "Travel";
    }

    if (up.contains("SALARY") ||
        up.contains("NEFT CR") ||
        up.contains("/CR/") ||
        up.contains("CREDIT")) {
      return "Income";
    }

    if (up.contains("ATM")) {
      return "Cash Withdrawal";
    }

    if (up.contains("RENT")) {
      return "Rent";
    }

    if (up.contains("IRCTC")) {
      return "Travel";
    }

    if (up.contains("INFO EDGE") ||
        up.contains("NETFLIX") ||
        up.contains("OTT") ||
        up.contains("SPOTIFY")) {
      return "Subscription";
    }

    if (up.contains("JIO") || up.contains("AIRTEL")) {
      return "Recharge";
    }

    return "Others";
  }
}
