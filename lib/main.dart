import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  WebSocketChannel? channel;
  Map<String, Map<String, int>> players = {};

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  void _connectToServer() {
    // Подключаемся к WebSocket серверу
    channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8000/ws'));
    
    // Слушаем сообщения от сервера
    channel!.stream.listen((data) {
      setState(() {
        players = jsonDecode(data);
      });
    });
  }

  void _sendCommand(String action) {
    // Отправляем команду серверу
    channel!.sink.add(jsonEncode({'action': action}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Сетевая игра на Flutter')),
        body: Stack(
          children: players.entries.map((entry) {
            String playerId = entry.key;
            Map<String, int> position = entry.value;
            return Positioned(
              left: position['x']!.toDouble() * 50,
              top: position['y']!.toDouble() * 50,
              child: Container(
                width: 40,
                height: 40,
                color: Colors.blue,
                child: Center(child: Text(playerId)),
              ),
            );
          }).toList(),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => _sendCommand('moveUp'),
              child: const Icon(Icons.arrow_upward),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () => _sendCommand('moveLeft'),
                  child: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () => _sendCommand('moveRight'),
                  child: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
            FloatingActionButton(
              onPressed: () => _sendCommand('moveDown'),
              child: const Icon(Icons.arrow_downward),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Закрываем соединение WebSocket при закрытии виджета
    channel!.sink.close();
    super.dispose();
  }
}
