import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'Payments.dart';

class ParticipatePage extends StatefulWidget {
  final int? eventId;


  ParticipatePage({required this.eventId});

  @override
  _ParticipatePageState createState() => _ParticipatePageState();
}

class _ParticipatePageState extends State<ParticipatePage> {
  String eventName = '';
  String eventLocation = '';
  String eventDescription = "";
  String eventImage = "";
  String imageUrl = "https://inideia.services/public/";


  @override
  void initState() {
    super.initState();
    fetchEventData();
  }

  Future<void> fetchEventData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final eventoid = sharedPreferences.getInt("evento_id");

    try {
      // Fazer a requisição HTTP para obter os detalhes do evento
      Uri url = Uri.parse(
          'https://inideia.services/public/api/events/$eventoid');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        // Decodificar a resposta JSON

        var eventData = jsonDecode(response.body);


        // Extrair os detalhes do evento
        eventName = eventData['data']['nome'];
        eventLocation = eventData['data']['localizacao'];
        eventDescription = eventData['data']['descricao'];
        eventImage = eventData['data']['imagem'];


        // Atualizar o estado para refletir os detalhes do evento
        setState(() {});
      } else {
        // Tratar o erro de requisição
        print('Erro na requisição: ${response.statusCode}');
      }
    } catch (error) {
      // Tratar erros de conexão ou outros erros
      print('Erro ao buscar dados do evento: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evento ${widget.eventId ?? ''}'),
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
              imageUrl+ eventImage ?? '',
              width: 300, // Defina a largura desejada para a imagem
              height: 250, // Defina a altura desejada para a imagem
              fit: BoxFit.contain, // Define como a imagem será ajustada ao espaço disponível
            ),
            SizedBox(height: 12),
            Text('Local: ${eventLocation ?? ''}'),
            SizedBox(height: 16),
            Text(
              'Descrição: ${eventDescription ?? ''}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentsPage(Paymentid: null,)),
                );
              },
              child: Text('Pagamento'),
            ),
          ],
        ),
      ),
    );
  }
}
