import 'package:flutter/material.dart';
import 'pdv_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();

  bool _isNameValid = true;
  bool _isCpfValid = true;

  String? _validateCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), ''); // Remove tudo que não é número
    if (cpf.length != 11) return "CPF inválido.";

    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return "CPF inválido.";

    List<int> numbers = cpf.split('').map((e) => int.parse(e)).toList();
    int sum = 0;
    for (int i = 0; i < 9; i++) {sum += numbers[i] * (10 - i);}
    int firstDigit = (sum * 10 % 11) % 10;

    sum = 0;
    for (int i = 0; i < 10; i++) {sum += numbers[i] * (11 - i);}
    int secondDigit = (sum * 10 % 11) % 10;

    return (numbers[9] == firstDigit && numbers[10] == secondDigit) ? null : "CPF inválido.";
  }

  void _onLoginPressed() async {
  String name = _nameController.text.trim();
  String cpf = _cpfController.text.trim();

  setState(() {
    _isNameValid = name.isNotEmpty;
    _isCpfValid = _validateCPF(cpf) == null;
  });

  if (!_isNameValid || !_isCpfValid) {
    _showErrorDialog(!_isNameValid
        ? "Informe seu nome."
        : "Informe um CPF válido.");
    return;
  }

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PDVScreen(clientName: name),
    ),
  );

  // Limpa os campos quando voltar à tela de login
  _nameController.clear();
  _cpfController.clear();
}


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Erro"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Supermercado Online',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 16.0),
              Icon(
                Icons.shopping_cart_rounded,
                size: 100.0,
                color: Colors.blue.shade300,
              ),
              const SizedBox(height: 30.0),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isNameValid ? Colors.grey : Colors.red,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  errorText: !_isNameValid ? "Campo obrigatório" : null,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _cpfController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'CPF',
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _isCpfValid ? Colors.grey : Colors.red,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.credit_card),
                  errorText: !_isCpfValid ? "CPF inválido" : null,
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _onLoginPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
