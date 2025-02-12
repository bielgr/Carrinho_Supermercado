//pdv_screen
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:carrinhodesupermercado/scanner/barcode_scanner_returning_image.dart';

Map<String, String> productImages = {
  "123456":
      "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png",
  "789012": "https://example.com/produto2.jpg",
  "345678": "https://example.com/produto3.jpg",
};

Future<String?> downloadAndSaveImage(String imageUrl, String fileName) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/$fileName';
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath; // Retorna o caminho salvo
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

class PDVScreen extends StatefulWidget {
  final String clientName;

  const PDVScreen({super.key, required this.clientName});

  @override
  State<PDVScreen> createState() => _PDVScreenState();
}

class _PDVScreenState extends State<PDVScreen> {
  final List<Map<String, dynamic>> _products = [];

  Future<bool> _onWillPop() async {
    bool? confirmExit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Encerrar Sessão"),
        content: const Text("Você deseja encerrar a sessão?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Não encerra
            child: const Text("Não"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true), // Encerra
            child: const Text("Sim"),
          ),
        ],
      ),
    );

    if (confirmExit == true) {
      // Limpa os dados antes de sair
      return true; // Permite sair
    }
    return false; // Bloqueia a ação de voltar
  }

  /*void _scanProduct() {
  showDialog(
    context: context,
    builder: (context) {
      final TextEditingController barcodeController = TextEditingController();
      return AlertDialog(
        title: const Text('Escanear Produto'),
        content: TextField(
          controller: barcodeController,
          decoration: const InputDecoration(
            labelText: 'Código de Barras',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o pop-up
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              String barcode = barcodeController.text;
              String imageUrl = "https://exemplo.com/imagem_$barcode.jpg"; // Troque para a API real
              String? localPath = await downloadAndSaveImage(imageUrl, "$barcode.jpg");

              setState(() {
                _products.add({
                  'description': 'Produto - Código $barcode',
                  'weight': '1.5 kg',
                  'quantity': 1,
                  'price': 12.99,
                  'imagePath': localPath, // Adiciona o caminho da imagem salva
                });
              });

              Navigator.of(context).pop();
            },
            child: const Text('Confirmar'),
          ),
        ],
      );
    },
  );
}*/

  //comeco scan_product()
  /*void _scanProduct(barcode) async {
    if (barcode != null && barcode.isNotEmpty) {
      _addProductToCart(barcode);
    }
  }

  void _addProductToCart(String barcode) async {
    var produtos = {
      "1234567891286": {
        "nome": "Arroz 5kg",
        "preco": 24.99,
        "imagem": "https://via.placeholder.com/150"
      },
      "789012": {
        "nome": "Feijão 1kg",
        "preco": 8.99,
        "imagem":
            "https://upload.wikimedia.org/wikipedia/commons/6/6a/JavaScript-logo.png"
      },
    };

    var produto = produtos[barcode];

    if (produto != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produto ${produto['nome']} adicionado!")),
      );
      setState(() {
        _products.add({
          'description': produto["nome"],
          'weight': '1.0 kg',
          'quantity': 1,
          'price': (produto["preco"] as num).toDouble(),
          'imageUrl': produto["imagem"], // Armazena a URL da imagem
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produto não encontrado")),
      );
    }
  }*/
  //fim scan_product()

  void _finalizePurchase() {
    // Verifica se há produtos no carrinho antes de finalizar
    if (_products.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro'),
          content: const Text('Primeiro escaneie algum produto.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Lógica para finalizar a compra
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compra Finalizada'),
        content: const Text('Agradecemos sua compra!'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _products.clear(); // Limpa os produtos após finalizar a compra
              });
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Bem-vindo ao Supermercado Online.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),
          ),
          backgroundColor: Colors.blue.shade700,
        ),
        body: Row(
          children: [
            Container(
              width: 250,
              color: Colors.blue.shade100,
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue.shade100),
                    child: Text(
                      'Boas compras, ${widget.clientName}!',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                  /*ListTile(
                      leading: const Icon(Icons.qr_code_scanner),
                      title: const Text('Escanear Produto'),
                      onTap:
                          _scanProduct /*() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  ScannerPage()),
                      );
                    },*/
                      ),*/
                  /*ListTile(
                    leading: const Icon(Icons.balance),
                    title: const Text('Pesar Produto'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BluetoothScreen()),
                      );
                    },
                  ),*/
                  /*ListTile(
                    leading: const Icon(Icons.assistant),
                    title: const Text('Assistente Inteligente'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatAssistant()),
                      );
                    },
                  ),*/
                  ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: const Text('Finalizar Compra'),
                    onTap: _finalizePurchase,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Produtos no Carrinho:',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5.0),
                    Expanded(
                      child: BarcodeScannerReturningImage(),
                    ),
                    if (_products.isNotEmpty) ...[
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R\$ ${_products.fold<double>(0.0, (total, product) => total + product['price']).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
