import 'package:flutter/material.dart';



class CompanyProfileForm extends StatefulWidget {
  @override
  _CompanyProfileFormState createState() => _CompanyProfileFormState();
}

class _CompanyProfileFormState extends State<CompanyProfileForm> {
TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back navigation
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Name Field
            TextFormField(
           controller: nameController,
             keyboardType: TextInputType.text,
             maxLines: 1,
            decoration: InputDecoration(
              labelText: '',
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),

          ),



            ],
          ),
        ),
      ),
    );
  }
    }