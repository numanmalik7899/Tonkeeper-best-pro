import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const TonkeeperApp());
}

class TonkeeperApp extends StatelessWidget {
  const TonkeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tonkeeper',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        primaryColor: const Color(0xFF0284C7),
        cardColor: const Color(0xFF192338),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const WalletHomeScreen(),
    const TradeMarketScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF121A2D),
        selectedItemColor: const Color(0xFF38BDF8),
        unselectedItemColor: const Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: 'Trade',
          ),
        ],
      ),
    );
  }
}

class WalletHomeScreen extends StatelessWidget {
  const WalletHomeScreen({super.key});

  final String walletAddress = "EQCD39VS5jcpt9BR8vSJG5M0Ro2f54H45X6pYwO4L2f3S9A1";

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const SizedBox(height: 10),
        const Center(
          child: Text("Total Balance", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text("\$100.00", style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const SizedBox(height: 8),
        Center(
          child: InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: walletAddress));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Wallet Address Copied!")),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF192338),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF283756)),
              ),
              child: const Text("EQCD39...3S9A1 📋", style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12)),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _actionButton(context, Icons.arrow_upward, "Send", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SendTokenScreen()));
            }),
            _actionButton(context, Icons.arrow_downward, "Receive", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiveScreen(address: walletAddress, symbol: 'TON')));
            }),
            _actionButton(context, Icons.swap_horiz, "Trade", () {}),
          ],
        ),
        const SizedBox(height: 30),
        const Text("Your Assets", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _assetRow(context, "Toncoin", "10.00 TON", "\$50.00", Colors.blue, "TON"),
        _assetRow(context, "Bitcoin", "0.00065 BTC", "\$50.00", Colors.orange, "BTC"),
      ],
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF192338),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF283756)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _assetRow(BuildContext context, String name, String sub, String val, Color iconColor, String symbol) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF192338),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF283756)),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TokenDetailScreen(name: name, symbol: symbol, price: val)));
        },
        leading: CircleAvatar(
          backgroundColor: iconColor,
          child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        trailing: Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }
}

class SendTokenScreen extends StatefulWidget {
  const SendTokenScreen({super.key});

  @override
  State<SendTokenScreen> createState() => _SendTokenScreenState();
}

class _SendTokenScreenState extends State<SendTokenScreen> {
  final TextEditingController _addrController = TextEditingController();
  final TextEditingController _amtController = TextEditingController();
  String _selectedToken = 'TON';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send $_selectedToken"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF192338),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF283756)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addrController,
                      decoration: const InputDecoration(
                        hintText: "Paste address or name",
                        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      ClipboardData? data = await Clipboard.getData('text/plain');
                      if (data != null) {
                        _addrController.text = data.text ?? '';
                      }
                    },
                    child: const Text("Paste", style: TextStyle(color: Color(0xFF38BDF8))),
                  )
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF192338),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF283756)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amtController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "0",
                        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedToken,
                    dropdownColor: const Color(0xFF192338),
                    underline: const SizedBox(),
                    items: ['TON', 'GRAM', 'BTC', 'ETH', 'USDT'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedToken = val);
                    },
                  )
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  if (_addrController.text.isEmpty || _amtController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all details!")),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Sent ${_amtController.text} $_selectedToken Successfully!")),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ReceiveScreen extends StatelessWidget {
  final String address;
  final String symbol;

  const ReceiveScreen({super.key, required this.address, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Receive $symbol"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: QrImageView(
                data: address,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF192338),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF283756)),
              ),
              child: Text(
                address,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: address));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Address Copied!")),
                  );
                },
                child: const Text("Copy Address", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TradeMarketScreen extends StatelessWidget {
  const TradeMarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF192338),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF283756)),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Search by ticker or name",
                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text("Trending", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _gridItem("HAKKA", "-1.34%", Colors.red),
              _gridItem("BFC", "+2.18%", Colors.green),
              _gridItem("TANUKI", "-53.5%", Colors.red),
              _gridItem("DIVI", "-6.54%", Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gridItem(String sym, String change, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF192338),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF283756)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(sym, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(change, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}

class TokenDetailScreen extends StatelessWidget {
  final String name;
  final String symbol;
  final String price;

  const TokenDetailScreen({super.key, required this.name, required this.symbol, required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(price, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const Text("-1.28% Last day", style: TextStyle(color: Colors.red, fontSize: 12)),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5)
                      ],
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiveScreen(address: "EQCD39VS5jcpt9BR8vSJG5M0Ro2f54H45X6pYwO4L2f3S9A1", symbol: symbol)));
                },
                child: Text("Receive $symbol", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
