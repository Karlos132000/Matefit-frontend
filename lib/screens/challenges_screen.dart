import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/challenge_model.dart';
import '../services/challenge_service.dart';
import '../widgets/challenge_card.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  late Future<List<Challenge>> _challengesFuture;
  List<Challenge> _allChallenges = [];

  String _searchQuery = '';
  DateTime? _selectedDate;
  int _maxCalories = 0; // ملاحظة: 0 يعني "Any kcal"

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  void _loadChallenges() {
    _challengesFuture = ChallengeService.fetchChallenges().then((data) {
      setState(() {
        _allChallenges = data;
      });
      return data;
    });
  }

  void _refreshChallenges() {
    setState(() {
      _selectedDate = null;
      _searchQuery = '';
      _maxCalories = 0;
      _loadChallenges();
    });
  }

  List<Challenge> _filterChallenges() {
    return _allChallenges.where((challenge) {
      final matchesSearch = challenge.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDate = _selectedDate == null || challenge.date == DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final matchesCalories = (_maxCalories == 0) || challenge.kcal <= _maxCalories;
      return matchesSearch && matchesDate && matchesCalories;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add_challenge');
          _refreshChallenges();
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF655CD1),
      ),
      body: FutureBuilder<List<Challenge>>(
        future: _challengesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('❌ Error loading challenges'));
          }

          final filteredChallenges = _filterChallenges();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'Search challenges...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _selectedDate = null;
                              _maxCalories = 0;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: _maxCalories,
                      onChanged: (value) => setState(() => _maxCalories = value ?? 0),
                      items: [
                        DropdownMenuItem<int>(value: 0, child: Text("Any kcal")),
                        DropdownMenuItem<int>(value: 100, child: Text("≤ 100 kcal")),
                        DropdownMenuItem<int>(value: 200, child: Text("≤ 200 kcal")),
                        DropdownMenuItem<int>(value: 300, child: Text("≤ 300 kcal")),
                        DropdownMenuItem<int>(value: 500, child: Text("≤ 500 kcal")),
                        DropdownMenuItem<int>(value: 1000, child: Text("≤ 1000 kcal")),
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredChallenges.isEmpty
                    ? const Center(child: Text('No challenges found.'))
                    : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filteredChallenges.length,
                  itemBuilder: (context, index) {
                    final challenge = filteredChallenges[index];
                    return ChallengeCard(
                      challenge: challenge,
                      onDelete: _refreshChallenges,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
