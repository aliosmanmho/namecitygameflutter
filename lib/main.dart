import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:namecitygameflutter/GameScreen.dart';
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
  IO.Socket socket =
      IO.io('https://namecitygame.herokuapp.com', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });
  List<Game> games = [];
  bool isGameStart = false;
  @override
  void initState() {
    super.initState();
    initSocket();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isGameStart = false;
      });
    });
  }

  void initSocket() {
    try {
      isGameStart = false;
      // socket = IO.io('https://namecitygame.herokuapp.com', <String, dynamic>{
      //   'transports': ['websocket'],
      // });
      // socket = IO.io('http://192.168.1.105:5000', <String, dynamic>{
      //   'transports': ['websocket'],
      //   'autoConnect': false,
      // });
      // IO.io('http://192.168.1.105:5000/');
      //socket = IO.io('https://namecitygame.herokuapp.com/');
      socket.onConnect((_) {
        print('connect');
      });

      socket.on("GameList", (res) {
        setState(() {
          var list = json.decode(res) as List;
          games = list.map((i) => Game.fromJson(i)).toList();
          if (games.length > 0) {
            Game myGame = games.firstWhere(
                (element) => element.createSocetID == socket.id,
                orElse: () => null);
            if (myGame != null) {
              if (isGameStart != true) {
                _playerNameDialog(context, myGame).then((value) {
                  isGameStart = true;
                  createPlayer(value);
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => GameScreen(
                                data: myGame,
                                socket: socket,
                              )))
                      .then((value) => isGameStart = false);
                });
              }
            }
          }
        });
      });
      socket.connect();
    } catch (e) {
      print(e);
    }
  }

  Future<String> _playerNameDialog(BuildContext context, Game game) {
    final playerNameController = TextEditingController();
    return showDialog(
        builder: (context) {
          return AlertDialog(
            title: Text("Denem"),
            content: TextField(
              controller: playerNameController,
              // ...
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text("Gir"),
                onPressed: () {
                  Navigator.of(context)
                      .pop(playerNameController.text.toString());
                  // _askedToLead(sdasd, myGame2.id);
                },
              )
            ],
          );
        },
        context: context);
  }

  void createGame() {
    socket.emit("CreateGame", "");
  }

  void createPlayer(String playerName) {
    socket.emit("CreatePlayer", playerName);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          isGameStart = false;
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              return Card(
                  child: InkWell(
                onTap: () {
                  var dd = games[index];
                  _playerNameDialog(context, dd).then((value) {
                    isGameStart = true;
                    createPlayer(value);
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => GameScreen(
                                  data: dd,
                                  socket: socket,
                                )))
                        .then((value) => isGameStart = false);
                  });
                  print("inwell");
                },
                child: ListTile(
                  title: Text('${games[index].id}'),
                ),
              ));
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            createGame();
          },
          tooltip: 'Yeni oyun',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
