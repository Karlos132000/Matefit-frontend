import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/web_csv_utils.dart';

class UsersTable extends StatefulWidget {
  const UsersTable({super.key});

  @override
  State<UsersTable> createState() => _UsersTableState();
}

class _UsersTableState extends State<UsersTable> {
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  final String baseUrl = 'http://localhost:8080/api/admin';

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _searchController.addListener(() => filterUsers());
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
          filteredUsers = users;
        });
      }
    } catch (e) {
      print('❌ Error fetching users: $e');
    }
  }

  void filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users.where((user) {
        final email = user['email']?.toLowerCase() ?? '';
        return email.contains(query);
      }).toList();
    });
  }

  Future<void> deleteUser(String email) async {
    final response = await http.delete(Uri.parse('$baseUrl/users?email=$email'));
    if (response.statusCode == 200) {
      fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ User deleted")));
    }
  }

  Future<void> changeRole(String email, String role) async {
    await http.put(Uri.parse('$baseUrl/users/role?email=$email&role=$role'));
    fetchUsers();
  }

  Future<void> toggleStatus(String email, bool enabled) async {
    await http.put(Uri.parse('$baseUrl/users/toggle?email=$email&enable=$enabled'));
    fetchUsers();
  }

  void downloadCsv() {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("CSV download is only supported on Web.")));
      return;
    }

    final List<List<String>> csvData = [
      ['Name', 'Email', 'Phone'],
      ...filteredUsers.map((u) => [u['username'], u['email'], u['phoneNumber'] ?? '']),
    ];

    downloadCsvWeb(csvData);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔍 شريط البحث وزر التحميل
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by email...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: downloadCsv,
              icon: Icon(Icons.download),
              label: Text("Download Excel (CSV)"),
            ),
          ],
        ),
        SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1200),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("Email")),
                    DataColumn(label: Text("Phone")),
                    DataColumn(label: Text("Role")),
                    DataColumn(label: Text("Enabled")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: filteredUsers.map<DataRow>((user) {
                    return DataRow(cells: [
                      DataCell(Text(user['username'] ?? '')),
                      DataCell(Text(user['email'] ?? '')),
                      DataCell(Text(user['phoneNumber'] ?? '')),
                      DataCell(
                        DropdownButton<String>(
                          value: user['role'],
                          items: ['USER', 'ADMIN']
                              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (newRole) => changeRole(user['email'], newRole!),
                        ),
                      ),
                      DataCell(Switch(
                        value: user['enabled'] ?? false,
                        onChanged: (val) => toggleStatus(user['email'], val),
                      )),
                      DataCell(IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteUser(user['email']),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
