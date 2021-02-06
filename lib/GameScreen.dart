import 'package:flutter/material.dart';
import 'package:namecitygameflutter/entities/Game.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GameScreen extends StatefulWidget {
  final Game data;
  final IO.Socket socket;
  const GameScreen({this.data, this.socket});

  @override
  GameScreenState createState() => GameScreenState(data, socket);
}

class GameScreenState extends State<GameScreen> {
  GameScreenState(this.game, this.socket);
  final Game game;
  final IO.Socket socket;

  void joinGame(String gameId) {
    socket.emit("joinGame", gameId);
  }

  @override
  void initState() {
    joinGame(game.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          setState(() {
            socket.disconnect();
            socket.connect();
          });
          return true;
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(title: Text("Oyun" + game.id), elevation: 0.0),
            body: Center(child: Text('asdasd'))));
  }
}
