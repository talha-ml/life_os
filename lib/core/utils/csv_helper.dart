// lib/core/utils/csv_helper.dart
import 'dart:io';
import 'package:csv/csv.dart' as csv_pkg; // 🚀 ADDED ALIAS
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';

class CsvHelper {
  static Future<void> exportTasksToCsv(List<Task> tasks) async {
    try {
      // 1. Prepare Data
      List<List<dynamic>> rows = [];
      rows.add(["ID", "Title", "Category", "Status", "Date"]);

      for (var task in tasks) {
        rows.add([
          task.id ?? 0,
          task.title,
          task.categoryId,
          task.isCompleted ? "Done" : "Pending",
          DateFormat('yyyy-MM-dd').format(task.dueDate),
        ]);
      }

      // 🚀 THE FIX: Use the alias to access the converter
      // Agar 'ListToCsvConverter' direct nahi mil raha, toh hum 'csv_pkg' se mangwayenge
      String csvData = const csv_pkg.ListToCsvConverter().convert(rows);

      // 3. Save & Share (Mobile Only)
      final directory = await getTemporaryDirectory();
      final path = "${directory.path}/LifeOS_Report.csv";
      final file = File(path);

      await file.writeAsString(csvData);

      // Trigger Share Sheet
      await Share.shareXFiles([XFile(path)], text: 'Mission Report 🚀');

    } catch (e) {
      // Chrome/Web par path_provider error deta hai, isliye print hoga
      print("CSV Export Error: $e");
    }
  }
}