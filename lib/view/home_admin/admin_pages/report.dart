import 'package:flutter/material.dart';
import 'package:fyp_wyc/model/user.dart';

class ReportPage extends StatefulWidget {
  final List<User>? userList;

  const ReportPage({
    super.key,
    this.userList,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _dateController = TextEditingController();
  List<User> filteredUsers = [];
  bool hasSearched = false;
  String selectedMonth = '';
  String selectedYear = '';
  
  // Maps to store calculated statistics
  Map<String, int> ageGroups = {};
  Map<String, int> genderGroups = {};
  
  @override
  void initState() {
    super.initState();
    // Set default date to current month/year
    final now = DateTime.now();
    _dateController.text = '${now.month}/${now.year}';
  }
  
  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }
  
  void _search() {
    if (_dateController.text.isEmpty) return;
    
    // Parse the input date (MM/YYYY)
    final parts = _dateController.text.split('/');
    if (parts.length != 2) return;
    
    try {
      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]);
      
      if (month < 1 || month > 12 || year < 2000 || year > 2100) return;
      
      setState(() {
        selectedMonth = month.toString();
        selectedYear = year.toString();
        hasSearched = true;
        _filterUsersByDate(month, year);
        _calculateStatistics();
      });
    } catch (e) {
      // Handle parsing errors
    }
  }
  
  void _filterUsersByDate(int month, int year) {
    filteredUsers = widget.userList?.where((user) {
      try {
        // Parse the createdAt date from ISO string
        final createdAt = DateTime.parse(user.createdAt);
        return createdAt.month == month && createdAt.year == year;
      } catch (e) {
        return false;
      }
    }).toList() ?? [];
  }
  
  void _calculateStatistics() {
    // Reset maps with standardized format
    ageGroups = {
      'below12': 0,
      '12-17': 0,
      '18-25': 0,
      '26-35': 0,
      '36-above': 0,
    };
    
    genderGroups = {
      'Male': 0,
      'Female': 0,
      'Prefer not to say': 0,
    };
    
    // Count users by age group and gender
    for (final user in filteredUsers) {
      // Age groups - normalize the format (remove spaces)
      if (user.ageRange.isNotEmpty) {
        // Normalize the age range by removing spaces
        String normalizedAgeRange = _normalizeAgeRange(user.ageRange);
        
        // Try to map to standard keys
        if (ageGroups.containsKey(normalizedAgeRange)) {
          ageGroups[normalizedAgeRange] = (ageGroups[normalizedAgeRange] ?? 0) + 1;
        } else {
          // If it's not a standard key, add it to the map
          ageGroups[normalizedAgeRange] = (ageGroups[normalizedAgeRange] ?? 0) + 1;
        }
      }
      
      // Gender
      if (genderGroups.containsKey(user.gender)) {
        genderGroups[user.gender] = (genderGroups[user.gender] ?? 0) + 1;
      }
    }
  }
  
  // Helper to normalize age range formats
  String _normalizeAgeRange(String ageRange) {
    // Remove all spaces
    String normalized = ageRange.replaceAll(' ', '');
    
    // Replace multiple dashes with a single dash
    normalized = normalized.replaceAll('--', '-');
    
    // If it has a colon (e.g., "18-25: something"), remove everything after the colon
    if (normalized.contains(':')) {
      normalized = normalized.split(':')[0];
    }
    
    // Handle "below 12" variations
    if (normalized.toLowerCase().contains('below12') || 
        normalized.toLowerCase().contains('below-12') ||
        normalized.toLowerCase().contains('under12')) {
      return 'below12';
    }
    
    return normalized;
  }
  
  // Display the age groups in a consistent format
  List<String> _formatAgeGroups() {
    // Define the desired order of age groups
    final ageOrder = [
      'below12',
      '12-17',
      '18-25',
      '26-35',
      '36-above',
    ];
    
    // Filter to only include age groups that exist in our data
    List<String> orderedKeys = ageOrder.where((key) => 
      ageGroups.containsKey(key) && (ageGroups[key] ?? 0) > 0
    ).toList();
    
    // Add any additional age groups that might not be in our predefined order
    for (var key in ageGroups.keys) {
      if (!orderedKeys.contains(key) && (ageGroups[key] ?? 0) > 0) {
        orderedKeys.add(key);
      }
    }
    
    return orderedKeys.map((key) => 
      "$key: ${_calculatePercentage(ageGroups[key] ?? 0)}"
    ).toList();
  }
  
  String _calculatePercentage(int count) {
    if (filteredUsers.isEmpty) return '0%';
    return '${((count / filteredUsers.length) * 100).round()}%';
  }

  // Format gender groups for display
  List<String> _formatGenderGroups() {
    List<String> result = [];
    
    // Add entries in a specific order
    for (String key in ['Male', 'Female', 'Prefer not to say']) {
      if (genderGroups.containsKey(key)) {
        result.add("$key: ${_calculatePercentage(genderGroups[key] ?? 0)}");
      }
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "User Registration Report",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            
            // Date selection
            Text(
              "Select Date",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      hintText: 'MM/YYYY',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _search,
                ),
              ],
            ),
            
            if (hasSearched) ...[
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Result:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text("Date: $selectedMonth / $selectedYear"),
                    Text(
                      "Total Registered Users: ${filteredUsers.length}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    
                    // Age Groups
                    _buildStatisticCard(
                      "1. What is your age group?",
                      _formatAgeGroups(),
                    ),
                    SizedBox(height: 16),
                    
                    // Gender
                    _buildStatisticCard(
                      "2. What is your gender?",
                      _formatGenderGroups(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatisticCard(String title, List<String> items) {
    // Sort items if they represent age groups to ensure correct order
    if (title.contains("age group")) {
      // Items will already be sorted by _formatAgeGroups
    } else if (title.contains("gender")) {
      // Custom sort for gender to ensure a specific order
      items.sort((a, b) {
        // Define the order: Male, Female, Prefer not to say
        final order = {'Male': 0, 'Female': 1, 'Prefer not to say': 2};
        
        String getKey(String item) => item.split(':')[0].trim();
        int getOrder(String key) => order[key] ?? 999;
        
        return getOrder(getKey(a)).compareTo(getOrder(getKey(b)));
      });
    }
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(item),
          )),
        ],
      ),
    );
  }
}