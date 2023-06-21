import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projeto_estagio_login/pages/events_page.dart';
import '../models/usermodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final String login;

  ProfilePage({required this.login});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User userProfile;

  bool isDataLoaded = false;
  String errorMessage = '';

  Future<User> getDataFromAPI() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final userId = sharedPreferences.getInt("user_id");
    final url = 'https://inideia.services/public/api/user/$userId';
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        userProfile = userFromJson(response.body);
        isDataLoaded = true;
      });
      return userProfile;
    } else {
      print('Erro ao buscar dados do perfil');
      errorMessage = '${response.statusCode}: ${response.body} ';
      return userProfile;
    }
  }

  fetchProfileData() async {
    userProfile = await getDataFromAPI();
  }

  void logout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // Realizar as ações necessárias para terminar a sessão do usuário
    // Exemplo: limpar os dados de autenticação
    // ...
    // Navegar para a tela de login
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Preferências'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.exit_to_app),
                          title: Text('Terminar sessão'),
                          onTap: () {
                            logout();
                            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: Text('Fechar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: isDataLoaded
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(userProfile.data?.avatar ?? ''),
            ),
            SizedBox(height: 16),
            Text(
              userProfile.data.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              userProfile.data.email,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text(userProfile.data.nTelemovel),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(userProfile.data.genero),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text(userProfile.data.dataNascimento.toString()),
            ),
          ],
        )
            : CircularProgressIndicator(),
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
              icon: Icon(Icons.home),
              color: Colors.white,
              onPressed: () {},
            ),
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
                  MaterialPageRoute(builder: (context) => ProfilePage(login: '')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
