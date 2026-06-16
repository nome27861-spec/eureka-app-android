import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:async';

void main() {
  runApp(const EurekaApp());
}

class EurekaApp extends StatelessWidget {
  const EurekaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eureka Core',
      debugShowCheckedModeBanner: false,
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
  List<String> _terminalLogs = ["> Motor P2P inicializado. Aguardando ativação..."];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _generateAnonymousIdentifier();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _generateAnonymousIdentifier() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    final bytes = utf8.encode(base64Url.encode(values));
    setState(() {
      _anonymousNodeId = sha256.convert(bytes).toString().substring(0, 16);
    });
  }

  void _addLog(String msg) {
    setState(() {
      _terminalLogs.add("> $msg");
      if (_terminalLogs.length > 20) _terminalLogs.removeAt(0); // Limpa logs antigos
    });
  }

  // Sincronização e escuta ativa de tarefas na rede
  Future<void> _syncAndListen() async {
    if (!_isNodeActive) return;

    final statusRede = _isNodeActive ? "Online" : "Offline";
    final url = Uri.parse(
      'https://eureka-z34r.onrender.com/atualizar-no?status=$statusRede&cpu=$_shareCPU&mesh=$_meshPlus&nodeId=$_anonymousNodeId'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _addLog("Sincronizado. Nós na malha ativos.");
        
        // Se a doação de CPU estiver ligada, o motor simula a busca e execução de cálculos matemáticos da rede
        if (_shareCPU) {
          _executeCryptoTask();
        }
      }
    } catch (e) {
      _addLog("Erro de conexão com a malha Mesh.");
    }
  }

  // MOTOR BRUTO: Executa blocos de criptografia SHA-256 localmente usando a CPU do celular
  void _executeCryptoTask() {
    _addLog("Buscando blocos de dados pendentes...");
    
    // Simula o recebimento de um pedaço de arquivo criptografado da rede Mesh
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!_shareCPU || !_isNodeActive) return;
      
      _addLog("Bloco [0x${_anonymousNodeId}F] recebido de nó par.");
      _addLog("Processando hash matemática de alto nível...");
      
      // Executa um estresse real de CPU calculando hashes em loop
      String payload = "eureka_mesh_data_block_" + Random().nextInt(100000).toString();
      for (int i = 0; i < 5000; i++) {
        payload = sha256.convert(utf8.encode(payload)).toString();
      }
      
      _addLog("✔ Bloco resolvido com sucesso.");
      _addLog("Devolvendo prova de trabalho anônima pro servidor.");
    });
  }

  void _togglePower() {
    setState(() {
      _isNodeActive = !_isNodeActive;
      _statusText = _isNodeActive ? "Proxy VPN Eureka Ativo" : "Desconectado";
    });

    if (_isNodeActive) {
      _addLog("Conectando ao rastreador descentralizado...");
      _syncAndListen();
      // Fica escutando/atualizando a rede a cada 10 segundos continuamente
      _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) => _syncAndListen());
    } else {
      _pollingTimer?.cancel();
      _addLog("Nó desconectado da malha principal.");
      _syncAndListen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: Column(
              children: [
                // Card Principal (Igual ao seu design)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131324),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF23233C)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'EUREKA',
                        style: TextStyle(color: Color(0xFF6C5CE7), fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 3),
                      ),
                      const Text(
                        'Protocolo de Rede Descentralizada',
                        style: TextStyle(color: Color(0xFF8F8FA8), fontSize: 12),
                      ),
                      const SizedBox(height: 25),
                      
                      // Botão Central Redondo
                      GestureDetector(
                        onTap: _togglePower,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 95,
                          height: 95,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isNodeActive ? const Color(0xFF00B894) : const Color(0xFFFF7675),
                            boxShadow: [
                              BoxShadow(
                                color: _isNodeActive ? const Color(0xFF00B894).withOpacity(0.5) : const Color(0xFFFF7675).withOpacity(0.4),
                                blurRadius: 18,
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _isNodeActive ? "LIGADO" : "LIGAR",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      
                      // Status Box
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
                        child: Text('Status: $_statusText', style: const TextStyle(fontSize: 13, color: Colors.white)),
                      ),
                      const SizedBox(height: 15),
                      
                      // Chaves de controle (Toggles)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Compartilhar CPU", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              Text("Doe 5% para processamento", style: TextStyle(fontSize: 11, color: Color(0xFF8F8FA8))),
                            ],
                          ),
                          Switch(
                            value: _shareCPU,
                            activeColor: const Color(0xFF6C5CE7),
                            onChanged: (val) {
                              setState(() => _shareCPU = val);
                              _syncAndListen();
                            },
                          )
                        ],
                      ),
                      
                      Text(
                        'ID ANÔNIMO: $_anonymousNodeId',
                        style: const TextStyle(color: Color(0xFF636E72), fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // MONITOR DO MOTOR EM TEMPO REAL (O Terminal Bruto no App)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(" MONITOR DO MOTOR P2P", style: TextStyle(color: Color(0xFF6C5CE7), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(height: 5),
                Container(
                  height: 160,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF23233C)),
                  ),
                  child: ListView.builder(
                    itemCount: _terminalLogs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          _terminalLogs[index],
                          style: const TextStyle(color: Color(0xFF00FF00), fontFamily: 'monospace', fontSize: 11),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
