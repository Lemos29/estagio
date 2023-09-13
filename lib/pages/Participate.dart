import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projeto_estagio_login/pages/Enter_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'Payments.dart';
import 'events_page.dart';

class ParticipatePage extends StatefulWidget {

  ParticipatePage();

  @override
  _ParticipatePageState createState() => _ParticipatePageState();
}

class _ParticipatePageState extends State<ParticipatePage> {
  String eventName = '';
  String eventLocation = '';
  String eventDescription = "";
  String eventImage = "";
  String eventdataInicio="";
  String eventdataFim="";
  int numerovagas=0;
  int vagasDisponiveis=0;
  String imageUrl = "http://10.0.2.2:8000";
  bool hasPurchasedTicket = false;

  @override
  void initState() {
    super.initState();
    fetchEventData();
  }

  Future<void> fetchEventData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final eventoid = sharedPreferences.getInt("event_id");
    final userid = sharedPreferences.getInt("user_id");

    Uri eventUrl = Uri.parse('http://10.0.2.2:8000/api/events/$eventoid');
    Uri paymentUrl = Uri.parse('http://10.0.2.2:8000/api/payment/$userid/$eventoid');

    try {
      var eventResponse = await http.get(eventUrl);

      if (eventResponse.statusCode == 200) {
        var eventData = jsonDecode(eventResponse.body);

        eventName = eventData['data']['nome'];
        eventLocation = eventData['data']['localizacao'];
        eventDescription = eventData['data']['descricao'];
        eventImage = eventData['data']['imagem'];
        eventdataFim=eventData['data']['data_fim'];
        eventdataInicio=eventData['data']['data_inicio'];
        numerovagas=eventData['data']['numero_vagas'];
        vagasDisponiveis=eventData['data']['vagas_disponiveis'];

        sharedPreferences.setString("event_price", eventData['data']['preco']);

        var paymentResponse = await http.get(paymentUrl);

        if (paymentResponse.statusCode == 200) {
          var paymentData = jsonDecode(paymentResponse.body);
          hasPurchasedTicket = paymentData['data'] != null;
        }

        setState(() {});
      } else {
        print('Erro na requisição do evento: ${eventResponse.statusCode}');
      }
    } catch (error) {
      print('Erro ao buscar dados do evento: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Image.network(
              imageUrl + eventImage ?? '',
              width: 300,
              height: 250,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            Text('Data de Inicio: ${eventdataInicio ?? ''}'),
            SizedBox(height: 10),
            Text('Data de Fim: ${eventdataFim?? ''}'),
            SizedBox(height: 10),
            Text('Local: ${eventLocation ?? ''}'),
            SizedBox(height: 10),
            Text(
              'Descrição: ${eventDescription ?? ''}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Text('Número de vagas: ${numerovagas ?? ''}'),
            SizedBox(height: 10),
            Text('Vagas disponíveis: ${vagasDisponiveis ?? ''}'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (hasPurchasedTicket) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRCodePage()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PaymentsPage()),
                  );
                }
              },
              child: Text(
                hasPurchasedTicket ? 'Entrar no Evento' : 'Participar no Evento',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

