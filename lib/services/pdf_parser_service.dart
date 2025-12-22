import 'dart:io';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../core/constants.dart';

/// Service for parsing bank statement PDFs
class PdfParserService {
  PdfParserService._();

  static final PdfParserService _instance = PdfParserService._();
  factory PdfParserService() => _instance;

  /// Parse a bank statement PDF file and extract transactions
  /// 
  /// Returns a list of [Transaction] objects extracted from the PDF
  /// Throws an exception if the PDF cannot be parsed
  Future<List<Transaction>> parseBankStatement(String filePath) async {
    try {
      final Uint8List bytes = await File(filePath).readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      final String text = PdfTextExtractor(document).extractText();
      document.dispose();

      final lines = text.split('\n').map((e) => e.trim()).toList();
      final List<Transaction> transactions = [];

      for (int i = 0; i < lines.length - 3; i++) {
        final line = lines[i];

        // Check if the line is a DATE (dd-MM-yyyy)
        if (!RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(line)) {
          continue;
        }

        final dateStr = line;
        final desc = lines[i + 1];
        final amountStr = lines[i + 2];

        // Amount must be in numeric form "123.45" or "2,450.00"
        if (!RegExp(r'^\d[\d,]*\.\d{2}$').hasMatch(amountStr)) {
          continue; // skip malformed block
        }

        // Parse values
        final amount = double.parse(amountStr.replaceAll(',', ''));
        final date = DateFormat(AppConstants.dateFormatBankStatement)
            .parseStrict(dateStr);

        // Detect credit / debit using description
        final isDebit = desc.contains('/DR/') || desc.contains('DR');
        final finalAmount = isDebit ? -amount : amount;

        // Add transaction
        transactions.add(
          Transaction(
            title: desc,
            amount: finalAmount,
            date: date,
            category: _detectCategory(desc),
          ),
        );

        // Skip ahead (since we consumed 3 lines)
        i += 3;
      }

      return transactions;
    } catch (e) {
      throw Exception('Failed to parse PDF: $e');
    }
  }

  /// Detect category based on transaction description
  String _detectCategory(String desc) {
    final up = desc.toUpperCase();

    if (up.contains('AMAZON') || up.contains('FLIPKART')) {
      return 'Shopping';
    }
    if (up.contains('ZOMATO') || up.contains('SWIGGY')) {
      return 'Food';
    }
    if (up.contains('FUEL') || up.contains('HPCL') || up.contains('BPCL')) {
      return 'Fuel';
    }
    if (up.contains('UBER') || up.contains('OLA')) {
      return 'Transport';
    }
    if (up.contains('SALARY') ||
        up.contains('NEFT CR') ||
        up.contains('/CR/') ||
        up.contains('CREDIT')) {
      return 'Salary';
    }
    if (up.contains('ATM')) {
      return 'Cash Withdrawal';
    }
    if (up.contains('RENT')) {
      return 'Rent';
    }
    if (up.contains('IRCTC')) {
      return 'Transport';
    }
    if (up.contains('INFO EDGE') ||
        up.contains('NETFLIX') ||
        up.contains('OTT') ||
        up.contains('SPOTIFY')) {
      return 'Entertainment';
    }
    if (up.contains('JIO') || up.contains('AIRTEL')) {
      return 'Bills';
    }

    return 'Other';
  }
}

