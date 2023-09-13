import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import "package:projeto_estagio_login/models/eventmodel.dart";
import 'package:projeto_estagio_login/pages/Participate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Perfil.dart';

class EventsPage extends StatefulWidget {
  const EventsPage();

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late Events getevents;
  List<Datum> displayedEvents = [];
  bool isDataLoaded = false;
  String imageUrl = "http://10.0.2.2:8000";
  String errorMessage = '';
  late SharedPreferences sharedPreferences;
  TextEditingController searchController = TextEditingController();

  Future<Events> getDataFromAPI() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Uri uri = Uri.parse('http://10.0.2.2:8000/api/events');
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      Events getevents = geteventsFromJson(response.body);
      setState(() {
        isDataLoaded = true;
        getevents.data.shuffle();
        displayedEvents = getevents.data;
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

  void _showNotification() async {
    Uri uri = Uri.parse('http://10.0.2.2:8000/api/notifications');
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: response.body, gravity: ToastGravity.TOP_RIGHT);
    } else {
      Fluttertoast.showToast(msg: 'Failed to fetch notifications.');
    }
  }

  @override
  void initState() {
    callAPIandAssignData();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterEvents(String searchTerm) {
    if (searchTerm.isEmpty) {

      setState(() {
        displayedEvents = getevents.data;
      });
    } else {

      List<Datum> filteredEvents = getevents.data
          .where((event) => event.nome.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
      setState(() {
        displayedEvents = filteredEvents;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event World'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Abrir caixa de diálogo de pesquisa
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Search Events'),
                    content: TextField(
                      controller: searchController,
                      onChanged: filterEvents, // Chamar a função de filtro sempre que o texto mudar
                      decoration: InputDecoration(
                        hintText: 'Enter event name',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          filterEvents(searchController.text);
                        },
                        child: Text('Search'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: _showNotification,
          ),
        ],
      ),
      body: isDataLoaded
          ? errorMessage.isNotEmpty
          ? Text(errorMessage)
          : displayedEvents.isEmpty
          ? const Text('No Data')
          : ListView.builder(
        itemCount: displayedEvents.length,
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
                    builder: (context) => EventsPage(),
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
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      login: '',
                    ),
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
    return Card(
      child: InkWell(
        onTap: () {
          sharedPreferences.setInt("event_id", displayedEvents[index].id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParticipatePage(),
            ),
          );
        },
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
                      imageUrl + displayedEvents[index].imagem,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayedEvents[index].nome,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('events: ${displayedEvents[index].nome}'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
