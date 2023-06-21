import 'package:flutter/material.dart';
import 'package:projeto_estagio_login/pages/Payments.dart';
import 'package:projeto_estagio_login/pages/Perfil.dart';
import 'pages/Participate.dart';
import 'pages/login_page.dart';
import 'pages/events_page.dart';
import 'package:http/http.dart' as http;

void main() async {


  runApp(const MyApp());
}
Future<http.Response> fetchEvents() {
  return http.get(Uri.parse('http://127.0.0.1:8000/api/events'));


}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/Events",
      routes: {
        '/Login': (context) => LoginPage(),
        "/Events": (context) =>  EventsPage(userParticipatingEvents: [],),
        "/Participate": (context) => ParticipatePage(eventId: null,),
        "/Profile": (context) => ProfilePage(login: '',),
        "/Payments":(context) =>PaymentsPage(Paymentid: null,),
      },
    );
  }
}
