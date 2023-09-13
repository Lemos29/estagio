import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'events_page.dart';

class PaymentsPage extends StatefulWidget {
  PaymentsPage();

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  String selectedMethod = 'MBWay';
  String paymentDetails = '';

  @override
  void initState() {
    super.initState();
  }

  Payment() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final userId = sharedPreferences.getInt('user_id');
    final eventId = sharedPreferences.getInt('event_id');
    final method = selectedMethod.toLowerCase();
    final amount = sharedPreferences.getString("event_price");

    if (method == 'mbway') {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pagamento MBWay'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Valor: $amount'),
                TextField(
                  onChanged: (value) {
                    paymentDetails = value;
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Confirmar'),
                onPressed: () {
                  Navigator.of(context).pop();
                  makePayment(userId!, eventId!, method, amount);
                },
              ),
            ],
          );
        },
      );
    } else if (method == 'paypal' || method == 'multibanco') {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pagamento'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Valor: $amount'),
                TextField(
                  onChanged: (value) {
                    paymentDetails = value;
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Confirmar'),
                onPressed: () {
                  Navigator.of(context).pop();
                  makePayment(userId!, eventId!, method, amount);
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> makePayment(int userId, int eventId, String method, String? amount) async {
    try {
      Uri url = Uri.parse('http://10.0.2.2:8000/api/payment/create');

      var body = jsonEncode({
        'eventId': eventId,
        'userId': userId,
        'metodo': method,
        'amount': amount,
      });

      var headers = {
        'Content-Type': 'application/json',
      };

      var response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // Payment successful, navigate to EventsPage
        navigateToEventsPage();
      } else {
        print('Request error: ${response.body}');
      }
    } catch (error) {
      print('Error fetching event data: $error');
    }
  }

  void navigateToEventsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: selectedMethod,
              onChanged: (String? newValue) {
                setState(() {
                  selectedMethod = newValue!;
                });
              },
              items: <String>['MBWay', 'PayPal', 'Multibanco'].map<DropdownMenuItem<String>>(
                    (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                },
              ).toList(),
            ),
            GestureDetector(
              onTap: Payment,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text('Pagamento'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
