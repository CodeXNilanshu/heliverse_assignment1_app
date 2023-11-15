import 'dart:convert';
import 'package:flutter/material.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String avatar;
  final String domain;
  final bool available;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.avatar,
    required this.domain,
    required this.available,
  });
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UsersListScreen(),
    );
  }
}

class UsersListScreen extends StatefulWidget {
  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  List<User>? allUsers;
  List<User> filteredUsers = [];
  String searchQuery = '';
  List<String> selectedDomains = [];
  List<String> selectedGenders = [];
  bool isAvailableSelected = false;

  @override
  void initState() {
    super.initState();
    loadMockData();
  }

  void loadMockData() async {
    String jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/heliverse_mock_data.json');
    List<dynamic> jsonList = json.decode(jsonString);

    allUsers = jsonList
        .map((json) => User(
              id: json['id'],
              firstName: json['first_name'],
              lastName: json['last_name'],
              email: json['email'],
              gender: json['gender'],
              avatar: json['avatar'],
              domain: json['domain'],
              available: json['available'],
            ))
        .toList();

    applyFilters();
  }

  void applyFilters() {
    filteredUsers = allUsers?.where((user) {
          final matchesSearch = '${user.firstName} ${user.lastName}'
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
          final matchesDomain =
              selectedDomains.isEmpty || selectedDomains.contains(user.domain);
          final matchesGender =
              selectedGenders.isEmpty || selectedGenders.contains(user.gender);
          final matchesAvailability = !isAvailableSelected || user.available;

          return matchesSearch &&
              matchesDomain &&
              matchesGender &&
              matchesAvailability;
        }).toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
              applyFilters();
            });
          },
          decoration: InputDecoration(
            hintText: 'Search by Name',
          ),
        ),
      ),
      body: Column(
        children: [
          FiltersBar(
            selectedDomains: selectedDomains,
            selectedGenders: selectedGenders,
            isAvailableSelected: isAvailableSelected,
            onDomainSelected: (domain) {
              setState(() {
                selectedDomains.contains(domain)
                    ? selectedDomains.remove(domain)
                    : selectedDomains.add(domain);
                applyFilters();
              });
            },
            onGenderSelected: (gender) {
              setState(() {
                selectedGenders.contains(gender)
                    ? selectedGenders.remove(gender)
                    : selectedGenders.add(gender);
                applyFilters();
              });
            },
            onAvailableSelected: (value) {
              setState(() {
                isAvailableSelected = value;
                applyFilters();
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                return UserCard(user: filteredUsers[index]);
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              List<User> selectedUsers =
                  filteredUsers.where((user) => user.available).toList();

              if (selectedUsers.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TeamDetailsScreen(selectedUsers: selectedUsers),
                  ),
                );
              } else {
                print('No available users selected.');
              }
            },
            child: Text('Add To Team'),
          ),
        ],
      ),
    );
  }
}

class FiltersBar extends StatelessWidget {
  final List<String> selectedDomains;
  final List<String> selectedGenders;
  final bool isAvailableSelected;
  final Function(String) onDomainSelected;
  final Function(String) onGenderSelected;
  final Function(bool) onAvailableSelected;

  FiltersBar({
    required this.selectedDomains,
    required this.selectedGenders,
    required this.isAvailableSelected,
    required this.onDomainSelected,
    required this.onGenderSelected,
    required this.onAvailableSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: EdgeInsets.all(16.0),
        color: Colors.grey[300],
        child: Row(
          children: [
            FilterDropdown(
              title: 'Domain',
              options: [
                'Sales',
                'Finance',
                'Marketing',
                'IT',
                'Management',
                'UI Designing',
                'Business Development'
              ],
              selectedOptions: selectedDomains,
              onOptionSelected: onDomainSelected,
            ),
            FilterDropdown(
              title: 'Gender',
              options: ['Male', 'Female'],
              selectedOptions: selectedGenders,
              onOptionSelected: onGenderSelected,
            ),
            FilterDropdown(
              title: 'Availability',
              options: ['Available', 'Not Available'],
              selectedOptions:
                  isAvailableSelected ? ['Available'] : ['Not Available'],
              onOptionSelected: (value) {
                onAvailableSelected(value == 'Available');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FilterDropdown extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<String> selectedOptions;
  final Function(String) onOptionSelected;

  FilterDropdown({
    required this.title,
    required this.options,
    required this.selectedOptions,
    required this.onOptionSelected,
  });

  @override
  _FilterDropdownState createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Row(
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              Icon(isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down),
            ],
          ),
        ),
        if (isExpanded)
          Wrap(
            spacing: 8.0,
            children: widget.options.map((option) {
              final isSelected = widget.selectedOptions.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  widget.onOptionSelected(option);
                },
                selectedColor: Colors.blue,
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
      ],
    );
  }
}

class UserCard extends StatelessWidget {
  final User user;

  UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.avatar),
        ),
        title: Text('${user.firstName} ${user.lastName}'),
        subtitle: Text(
            '${user.domain} - ${user.gender} - Available: ${user.available}'),
      ),
    );
  }
}

class TeamDetailsScreen extends StatelessWidget {
  final List<User> selectedUsers;

  TeamDetailsScreen({required this.selectedUsers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Details'),
      ),
      body: Column(
        children: [
          Text('Team Members:'),
          ListView.builder(
            itemCount: selectedUsers.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(selectedUsers[index].avatar),
                ),
                title: Text(
                    '${selectedUsers[index].firstName} ${selectedUsers[index].lastName}'),
                subtitle: Text(
                    '${selectedUsers[index].domain} - ${selectedUsers[index].gender}'),
              );
            },
          ),
        ],
      ),
    );
  }
}
