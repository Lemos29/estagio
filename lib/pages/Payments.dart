import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentsPage extends StatefulWidget {
  final int? Paymentid;

  PaymentsPage({required this.Paymentid});

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  String eventId = '';
  String amount = '';
  String method = "";
  String reference = "";
  String qrcode = '';

  @override
  void initState() {
    super.initState();
    fetchEventData();
  }

  Future<void> fetchEventData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final paymentid = sharedPreferences.getInt("payment_id");

    try {
      // Make a POST request to retrieve the event details
      Uri url = Uri.parse('https://inideia.services/public/api/payment/1/$paymentid');
      var response = await http.post(url);

      if (response.statusCode == 200) {
        // Decode the JSON response
        var eventData = jsonDecode(response.body);

        // Extract the event details
        eventId = eventData['data']['event_id'];
        amount = eventData['data']['amount'];
        method = eventData['data']['method'];
        reference = eventData['data']['reference'];
        qrcode = eventData['data']['qrcode'];

        // Update the state to reflect the event details
        setState(() {});
      } else {
        // Handle the request error
        print('Request error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle connection or other errors
      print('Error fetching event data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment ${widget.Paymentid ?? ''}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventId,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Image.network(
              qrcode,
              width: 300,
              height: 250,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 12),
            Text('Amount: $amount'),
            SizedBox(height: 16),
            Text(
              'Method: $method',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Reference: $reference',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
