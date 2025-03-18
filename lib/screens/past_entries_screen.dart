import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PastEntriesScreen extends StatefulWidget {
  const PastEntriesScreen({Key? key}) : super(key: key);

  @override
  _PastEntriesScreenState createState() => _PastEntriesScreenState();
}

class _PastEntriesScreenState extends State<PastEntriesScreen> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Past Collections', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () {
              if (selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please select a date first!")),
                );
              } else {
                _exportToPDF(context);
              }
            },
          ),
        ],
      ),
      body: selectedDate == null
          ? Center(child: Text("Select a date to view records"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('milkDetails')
            .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate!))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No data available for selected date"));
          }

          var entries = snapshot.data!.docs;

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              var data = entries[index].data() as Map<String, dynamic>;
              String docId = entries[index].id;

              return GestureDetector(
                onLongPress: () => _confirmDeleteEntry(docId),
                child: Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("Name: ${data['name']}", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      "ID: ${data['id']} | Date: ${data['date']}\n"
                          "Time: ${data['time']} - ${data['animal']}\n"
                          "QTY: ${data['qty']} | FAT: ${data['fat']} | CLR: ${data['clr']}\n"
                          "SNF: ${data['snf']} | Rate: ${data['rate']} | Amount: ${data['amt']}",
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _confirmDeleteEntry(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Entry"),
          content: Text("Are you sure you want to delete this entry? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteEntry(docId);
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteEntry(String docId) {
    FirebaseFirestore.instance
        .collection('milkDetails')
        .doc(docId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Entry deleted successfully")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete entry: $error")),
      );
    });
  }

  void _exportToPDF(BuildContext context) async {
    if (selectedDate == null) return;

    final pdf = pw.Document();
    String selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);

    var snapshot = await FirebaseFirestore.instance
        .collection('milkDetails')
        .where('date', isEqualTo: selectedDateStr)
        .get();

    var entries = snapshot.docs;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: pw.EdgeInsets.only(top: 5),
            child: pw.Text(
              "Milky Cloud App | Developer | © Madhav Vedpathak 2025 | All Rights Reserved | Private License",
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                "Milk Collections Report - $selectedDateStr",
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
              ),
            ),
            pw.SizedBox(height: 10),
            ...entries.map((entry) {
              var data = entry.data() as Map<String, dynamic>;
              return pw.Container(
                margin: pw.EdgeInsets.only(bottom: 6),
                padding: pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.green800, width: 1.2),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildEntryRow("Name:", data['name']),
                          _buildEntryRow("ID:", data['id']),
                          _buildEntryRow("Date:", data['date']),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildEntryRow("Time:", "${data['time']} - ${data['animal']}"),
                          _buildEntryRow("QTY:", data['qty']?.toString()),
                          _buildEntryRow("FAT:", data['fat']?.toString()),
                          _buildEntryRow("CLR:", data['clr']?.toString()),
                          _buildEntryRow("SNF:", data['snf']?.toString()),
                          _buildEntryRow("Rate:", data['rate']?.toString()),
                          _buildEntryRow("Amount:", data['amt']?.toString()),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _buildEntryRow(String title, String? value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
          pw.SizedBox(width: 5),
          pw.Expanded(
            child: pw.Text(value ?? '', style: pw.TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
