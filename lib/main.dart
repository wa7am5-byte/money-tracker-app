import 'package:flutter/material.dart';

void main() {
  runApp(const MoneyTrackerApp());
}

class MoneyTrackerApp extends StatelessWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money & Debt Tracker',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF030712),
        primaryColor: const Color(0xFF0F172A),
      ),
      home: const TrackerHomePage(),
    );
  }
}

class Transaction {
  final String id;
  final double amount;
  final String desc;
  final String type; // 'received', 'paid', 'loan'
  final String date;

  Transaction({
    required this.id,
    required this.amount,
    required this.desc,
    required this.type,
    required this.date,
  });
}

class TrackerHomePage extends StatefulWidget {
  const TrackerHomePage({super.key});

  @override
  State<TrackerHomePage> createState() => _TrackerHomePageState();
}

class _TrackerHomePageState extends State<TrackerHomePage> {
  String activeAccount = 'Main Account';
  Map<String, List<Transaction>> accounts = {
    'Main Account': [],
  };
  final String currency = '\$';

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  void _addTransaction(String type) {
    if (_amountController.text.isEmpty || _descController.text.isEmpty) return;

    final newTx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: double.tryParse(_amountController.text) ?? 0.0,
      desc: _descController.text,
      type: type,
      date: DateTime.now().toString().split(' ')[0],
    );

    setState(() {
      accounts[activeAccount]!.insert(0, newTx);
    });

    _amountController.clear();
    _descController.clear();
    Navigator.pop(context);
  }

  void _deleteTransaction(String id) {
    setState(() {
      accounts[activeAccount]!.removeWhere((tx) => tx.id == id);
    });
  }

  void _addNewAccount() {
    String name = _accountController.text.trim();
    if (name.isNotEmpty && !accounts.containsKey(name)) {
      setState(() {
        accounts[name] = [];
        activeAccount = name;
      });
      _accountController.clear();
      Navigator.pop(context);
    }
  }

  void _showTransactionModal(String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'New ${type.toUpperCase()}',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Amount',
                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Color(0xFF1E293B),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Description / Name',
                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Color(0xFF1E293B),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF334155)),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
                    onPressed: () => _addTransaction(type),
                    child: const Text('Save', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAccountModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Manage Accounts', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 150,
                child: ListView(
                  children: accounts.keys.map((acc) {
                    return ListTile(
                      title: Text(acc, style: const TextStyle(color: Colors.white)),
                      selected: activeAccount == acc,
                      selectedTileColor: const Color(0xFF1E293B),
                      onTap: () {
                        setState(() {
                          activeAccount = acc;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
              TextField(
                controller: _accountController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'New account name...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: Color(0xFF1E293B),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E)),
            onPressed: _addNewAccount,
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentList = accounts[activeAccount] ?? [];
    double totalRec = 0;
    double totalPaid = 0;
    double totalLoans = 0;

    for (var tx in currentList) {
      if (tx.type == 'received') totalRec += tx.amount;
      else if (tx.type == 'paid') totalPaid += tx.amount;
      else if (tx.type == 'loan') totalLoans += tx.amount;
    }

    double balance = totalRec - (totalPaid + totalLoans);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: GestureDetector(
          onTap: _showAccountModal,
          child: Text('👛 $activeAccount ▾', style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 16)),
        ),
        actions: const [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Money & Debt Tracker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF1E293B),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Name & Type', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                Text('Received', style: TextStyle(color: Color(0xFF4ADE80), fontSize: 12)),
                Text('Paid / Loan', style: TextStyle(color: Color(0xFFF87171), fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: currentList.isEmpty
                ? const Center(child: Text('No transactions recorded', style: TextStyle(color: Color(0xFF64748B))))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: currentList.length,
                    itemBuilder: (context, index) {
                      final item = currentList[index];
                      Color amountColor = const Color(0xFF4ADE80);
                      String sign = '+';
                      String typeText = 'Received';

                      if (item.type == 'paid') {
                        amountColor = const Color(0xFFF87171);
                        sign = '-';
                        typeText = 'Paid';
                      } else if (item.type == 'loan') {
                        amountColor = const Color(0xFFC084FC);
                        sign = '-';
                        typeText = '⚠️ Pending Loan';
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161E31),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.desc, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(typeText, style: TextStyle(color: item.type == 'loan' ? const Color(0xFFC084FC) : const Color(0xFF94A3B8), fontSize: 10)),
                              ],
                            ),
                            Row(
                              children: [
                                Text('$sign${item.amount} $currency', style: TextStyle(color: amountColor, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => _deleteTransaction(item.id),
                                  child: const Text('🗑️', style: TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            color: const Color(0xFF0F172A),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                        onPressed: () => _showTransactionModal('paid'),
                        child: const Text('Paid', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA855F7)),
                        onPressed: () => _showTransactionModal('loan'),
                        child: const Text('Loan', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E)),
                        onPressed: () => _showTransactionModal('received'),
                        child: const Text('Received', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(10),
                  color: const Color(0xFF020617),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Balance: $balance $currency', style: const TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.bold)),
                      Text('Loans: $totalLoans $currency', style: const TextStyle(color: Color(0xFFC084FC), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 
