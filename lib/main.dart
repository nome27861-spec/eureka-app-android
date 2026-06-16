import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

void main() {
  runApp(const EurekaApp());
}

class EurekaApp extends StatelessWidget {
  const EurekaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eureka Core',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B14),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isNodeActive = false;
  bool _shareCPU = false;
  bool _meshPlus = false;
  String _statusText = "Desconectado";
  String _anonymousNodeId = "";

  @override
  void initState() {
    super.initState();
    _generateAnonymousIdentifier();
  }

  // CRITICAL PRIVACY: Gera uma identidade criptográfica anônima para o nó
  // Nem o dono do servidor sabe quem é o usuário real, apenas a hash hash gerada.
  void _generateAnonymousIdentifier() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    final bytes = utf8.encode(base64Url.encode(values));
    setState(() {
      _anonymousNodeId = sha256.convert(bytes).toString().substring(0, 16);
    });
  }

  // Comunicação com o Coração no Render
  Future<void> _syncNodeWithNetwork() async {
    final statusRede = _isNodeActive ? "Online" : "Offline";
    // Substitua pela URL do seu Render quando for testar nativamente
    final url = Uri.parse(
      'https://eureka-z34r.onrender.com/atualizar-no?status=$statusRede&cpu=$_shareCPU&mesh=$_meshPlus&nodeId=$_anonymousNodeId'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print("Nó anônimo sincronizado com a malha Mesh.");
      }
    } catch (e) {
      print("Erro ao conectar ao rastreador de nós: $e");
    }
  }

  void _togglePower() {
    setState(() {
      _isNodeActive = !_isNodeActive;
      _statusText = _isNodeActive ? "Proxy VPN Eureka Ativo" : "Desconectado";
    });
    _syncNodeWithNetwork();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Botão do Menu Lateral (Visual)
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menu de Ferramentas do Supercomputador (Aba Oculta)')),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu, color: Colors.white),
              ),
            ),
          ),
          
          // Interface Centralizada igual ao seu design web
          Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF131324),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF23233C)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'EUREKA',
                      style: TextStyle(color: Color(0xFF6C5CE7), fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 3),
                    ),
                    const Text(
                      'Protocolo de Rede Descentralizada',
                      style: TextStyle(color: Color(0xFF8F8FA8), fontSize: 12),
                    ),
                    const SizedBox(height: 30),
                    
                    // Botão Central de Força
                    GestureDetector(
                      onTap: _togglePower,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isNodeActive ? const Color(0xFF00B894) : const Color(0xFFFF7675),
                          boxShadow: [
                            BoxShadow(
                              color: _isNodeActive ? const Color(0xFF00B894).withOpacity(0.5) : const Color(0xFFFF7675).withOpacity(0.4),
                              blurRadius: 20,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _isNodeActive ? "LIGADO" : "LIGAR",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Box de Status
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: _isNodeActive ? const Color(0xFF00B894) : const Color(0xFFFF7675),
                            width: 4,
                          ),
                        ),
                      ),
                      width: double.infinity,
                      child: Text('Status: $_statusText', style: const TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(height: 20),
                    
                    // Informação de ID Anônimo
                    Text(
                      'ID do Nó: $_anonymousNodeId (Criptografado)',
                      style: const TextStyle(color: Color(0xFF636E72), fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
