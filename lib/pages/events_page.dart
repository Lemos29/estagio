import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import "package:projeto_estagio_login/models/eventmodel.dart";
import 'package:projeto_estagio_login/pages/Participate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Perfil.dart';

class EventsPage extends StatefulWidget {
  final List<int> userParticipatingEvents;

  const EventsPage({Key? key, required this.userParticipatingEvents}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late Events getevents;

  // for data is loaded flag
  bool isDataLoaded = false;

  String imageUrl = "https://inideia.services/public/";

  // error holding
  String errorMessage = '';

 late SharedPreferences sharedPreferences;

  // API Call
  Future<Events> getDataFromAPI() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Uri uri = Uri.parse('https://inideia.services/public/api/events');
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      // All ok
      Events getevents = geteventsFromJson(response.body);
      setState(() {
        isDataLoaded = true;
      });
      return getevents;
    } else {
      errorMessage = '${response.statusCode}: ${response.body} ';
      return Events(data: []);
    }
  }

  callAPIandAssignData() async {
    getevents = await getDataFromAPI();
  }

  @override
  void initState() {
    callAPIandAssignData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilhete digital'),
        centerTitle: true,
      ),
      body: isDataLoaded
          ? errorMessage.isNotEmpty
          ? Text(errorMessage)
          : getevents.data.isEmpty
          ? const Text('No Data')
          : ListView.builder(
        itemCount: getevents.data.length,
        itemBuilder: (context, index) => getRow(index),
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.event),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventsPage(userParticipatingEvents: []),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage(login: '',),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getRow(int index) {
    final evento = getevents.data[index];
    bool isParticipating = widget.userParticipatingEvents.contains(evento.id);

    return Card(
      child: Container(
        padding: const EdgeInsets.all(7.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  child: Image.network(
                    imageUrl + getevents.data[index].imagem,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getevents.data[index].nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('events: ${getevents.data[index].nome}'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        sharedPreferences.setInt("evento_id", evento.id);
                        if (isParticipating) {
                          Fluttertoast.showToast(msg: 'Já está a participar do evento');
                        } else {
                          setState(() {
                            widget.userParticipatingEvents.add(evento.id);
                          });
                          // Enviar a lista atualizada para o backend
                          updateUserParticipatingEvents(widget.userParticipatingEvents);
                          Fluttertoast.showToast(msg: 'Participando do evento');

                          // Navigating to the event page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParticipatePage(eventId: evento.id),
                            ),
                          );
                        }
                      },
                      child: Text('Participar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isParticipating ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isParticipating)
              Container(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Já está a participar do evento',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void updateUserParticipatingEvents(List<int> userParticipatingEvents) {}
}
