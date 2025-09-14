import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class viewallstdattendanceadmin extends StatefulWidget {
  viewallstdattendanceadmin({super.key});
  @override
  State<viewallstdattendanceadmin> createState() => _viewallstdattendanceadminState();
}

class _viewallstdattendanceadminState extends State<viewallstdattendanceadmin> {
  String _selectedFilter = 'All';
  DateTime? _singleDate;
  DateTimeRange? _selectedDateRange;

  /// Filtered Firestore query for real-time stream & PDF
  Query getAttendanceQuery() {
    Query query = FirebaseFirestore.instance
        .collection('attendance')
        .orderBy('markedAt', descending: true);

    if (_selectedFilter != 'All') {
      query = query.where('status', isEqualTo: _selectedFilter);
    }

    if (_singleDate != null) {
      DateTime start = DateTime(_singleDate!.year, _singleDate!.month, _singleDate!.day);
      DateTime end = start.add(Duration(days: 1));
      query = query
          .where('markedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('markedAt', isLessThan: Timestamp.fromDate(end));
    }

    if (_selectedDateRange != null) {
      DateTime start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
      DateTime end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day + 1);
      query = query
          .where('markedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('markedAt', isLessThan: Timestamp.fromDate(end));
    }

    return query;
  }

  Future<void> _selectSingleDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _singleDate ?? DateTime.now(),
      firstDate: DateTime(2023, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light()
              .copyWith(
            colorScheme:
            ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface:
              Colors.black,
            ),
            dialogBackgroundColor:
            Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _singleDate = picked;
        _selectedDateRange = null; // clear range if single date selected
      });
    }
  }

// Range picker
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023, 1),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(Duration(days: 7)),
            end: DateTime.now(),),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light()
              .copyWith(
            colorScheme:
            ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface:
              Colors.black,
            ),
            dialogBackgroundColor:
            Colors.white,
          ),
          child: child!,
        );
      },

    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _singleDate = null; // clear single date if range selected
      });
    }
  }



  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('hh:mm a').format(dateTime);
  }

  Future<String> getUserName(String userId) async {
    if (userId.isEmpty) return 'Unknown';
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['name'] ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<pw.Document> generatePDF(List<QueryDocumentSnapshot> docs) async {
    final pdf = pw.Document();
    List<List<String>> tableData = [];

    for (int i = 0; i < docs.length; i++) {
      final data = docs[i].data() as Map<String, dynamic>;
      final name = await getUserName(data['userId'] ?? '');
      final markedAt = data['markedAt'] as Timestamp?;
      final formattedTime = markedAt != null ? formatTimestamp(markedAt) : 'No time';

      tableData.add([
        '${i + 1}',
        name,
        data['status'] ?? 'Unknown',
        data['date'] ?? 'Unknown',
        formattedTime,
      ]);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Student Attendance Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Filter: $_selectedFilter'
                '${_singleDate != null ? " | Date: ${DateFormat('yyyy-MM-dd').format(_singleDate!)}" : ""}'
                '${_selectedDateRange != null ? " | Range: ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)} → ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)}" : ""}',
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['#', 'Name', 'Status', 'Date', 'Time'],
            data: tableData,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            border: pw.TableBorder.all(),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    return pdf;
  }

  void _previewPDF(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No attendance records to generate PDF')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFPreviewScreen(generatePDF: () => generatePDF(docs)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Attendance", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: () async {
              try {
                final snapshot = await getAttendanceQuery().get();
                _previewPDF(snapshot.docs);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("Filter by:", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16)),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFilter,
                        items: ['All', 'Present', 'Absent', 'Approved Leave']
                            .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedFilter = value!),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selectSingleDate(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: Text(
                          _singleDate == null ? "Select Date" : DateFormat('yyyy-MM-dd').format(_singleDate!),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selectDateRange(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: Text(
                          _selectedDateRange == null
                              ? "Calender"
                              : "${DateFormat('dd-MM-yyyy').format(_selectedDateRange!.start)} → ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.red),
                      onPressed: () => setState(() {
                        _singleDate = null;
                        _selectedDateRange = null;
                      }),
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getAttendanceQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => Shimmer.fromColors(
                      highlightColor: Colors.grey.shade100,
                      baseColor: Colors.grey.shade300,
                      child: ListTile(
                        leading: Container(height: 40, width: 40, color: Colors.white),
                        title: Container(height: 20, color: Colors.white),
                        subtitle: Container(height: 20, color: Colors.white),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text('No records found'));

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final markedAt = data['markedAt'] as Timestamp?;
                    final formattedTime = markedAt != null ? formatTimestamp(markedAt) : 'No time';
                    final date = markedAt != null ? DateFormat('yyyy-MM-dd').format(markedAt.toDate()) : 'Unknown date';

                    return FutureBuilder<String>(
                      future: getUserName(data['userId'] ?? ''),
                      builder: (context, nameSnapshot) {
                        final name = nameSnapshot.data ?? 'Loading...';
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text("${index + 1}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Status: ${data['status'] ?? 'Unknown'}"),
                                Text("Date: ${data['date'] ?? 'Unknown'}"),
                                Text("Time: $formattedTime"),
                              ],
                            ),
                            trailing: Icon(
                              data['status'] == "Present"
                                  ? Icons.check_circle
                                  : data['status'] == "Absent"
                                  ? Icons.cancel
                                  : Icons.access_time,
                              color: data['status'] == "Present"
                                  ? Colors.green
                                  : data['status'] == "Absent"
                                  ? Colors.red
                                  : Colors.orange,
                              size: 30,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PDFPreviewScreen extends StatelessWidget {
  final Future<pw.Document> Function() generatePDF;
  const PDFPreviewScreen({Key? key, required this.generatePDF}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Preview', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,

      ),
      body: PdfPreview(
        loadingWidget: CircularProgressIndicator(color: Colors.blue,),
        canChangeOrientation: false,
        canChangePageFormat: false,
        initialPageFormat: PdfPageFormat.a4,


        build: (format) async {
          try {
            final doc = await generatePDF();
            return await doc.save();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));

            return Uint8List(0);

          }
        },
      ),
    );
  }
}


