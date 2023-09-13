import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projeto_estagio_login/pages/events_page.dart';
import 'package:projeto_estagio_login/pages/pages/ResetPassword.dart';
import 'package:projeto_estagio_login/pages/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isBlocked = false;
  int loginAttempts = 0;

  login(String email, String password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    try {
      if (isBlocked) {
        // Sistema bloqueado
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Bloqueado'),
              content: Text('Você foi bloqueado. Tente novamente mais tarde.'),
              actions: <Widget>[
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
        return;
      }

      var url = Uri.parse('http://10.0.2.2:8000/api/login');

      var body = jsonEncode({
        'email': email,
        'password': password,
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
        var data = jsonDecode(response.body);
        var userId = data['user']['id'];
        print('Login successfully');
        sharedPreferences.setInt("user_id", userId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventsPage(),
          ),
        );
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        loginAttempts++;

        if (loginAttempts >= 3) {
          // Bloquear o sistema por 1 minuto
          setState(() {
            isBlocked = true;
          });
          Future.delayed(Duration(minutes: 1), () {
            setState(() {
              isBlocked = false;
              loginAttempts = 0;
            });
          });
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erro de login'),
              content: Text(
                  'Falha ao fazer login. Verifique seu email e senha.'),
              actions: <Widget>[
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
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event World'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
              ),
              SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  login(emailController.text.toString(),
                      passwordController.text.toString());
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text('Login'),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => ResetPasswordPage(),
                ),
                );
              },
                child: Text('Recuperar Senha'),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistrationPage(),
                    ),
                  );
                },
                child: Text('Ainda não tem conta?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
