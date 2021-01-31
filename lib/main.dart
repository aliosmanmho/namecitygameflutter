import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'entities/Game.dart';

void main() {
  runApp(NameCityGameApp());
}

class NameCityGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İsim Şehir',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameListPage(title: 'Oyun Listesi'),
    );
  }
}

class GameListPage extends StatefulWidget {
  GameListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _GameListPageState createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  IO.Socket socket;
  List<Game> games = [];
  @override
  void initState() {
    initSocket();
    super.initState();
  }

  void initSocket() {
    try {
      socket = IO.io('https://namecitygame.herokuapp.com/');
      socket.onConnect((_) {
        print('connect');
      });

      socket.on("GameList", (res) {
        setState(() {
          var list = json.decode(res) as List;
          games = list.map((i) => Game.fromJson(i)).toList();
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${games[index].id}'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Yeni oyun',
        child: Icon(Icons.add),
      ),
    );
  }
}
