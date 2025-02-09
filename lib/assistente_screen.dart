import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatAssistant extends StatefulWidget {
  @override
  _ChatAssistantState createState() => _ChatAssistantState();
}

class _ChatAssistantState extends State<ChatAssistant> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  // Adicione sua chave de API aqui

  Future<String> fetchResponse(String message) async {
    const String apiUrl =
        "https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.1";
    const String apiKey = ""; // Substitua pelo seu token válido

    int maxRetries = 3;
    int retryDelay = 2000; // 2 segundos

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "inputs": message,
            "parameters": {
              "max_length": 500, // Aumenta o tamanho da resposta
              "temperature": 0.7, // Deixa a resposta mais variada
              "top_p": 0.9 // Evita respostas muito repetitivas
            }
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data[0]["generated_text"] ?? "Erro na resposta.";
        } else if (response.statusCode == 503) {
          print("⚠️ API indisponível. Tentando novamente...");
          await Future.delayed(Duration(milliseconds: retryDelay));
        } else {
          return "Erro na API: ${response.statusCode} - ${response.body}";
        }
      } catch (e) {
        return "Erro na requisição: $e";
      }
    }
    return "Erro: API indisponível após várias tentativas.";
  }

  void _sendMessage() async {
    String message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({"sender": "Você", "message": message});
      _controller.clear();
    });

    String response = await fetchResponse(message);

    setState(() {
      _messages.add({
        "sender": "Assistente",
        "message": response.startsWith("Erro")
            ? "⚠️ Ocorreu um erro: $response"
            : response
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assistente Virtual")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ListTile(
                  title: Text(msg["sender"]!,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(msg["message"]!),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        InputDecoration(labelText: "Digite sua mensagem"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
