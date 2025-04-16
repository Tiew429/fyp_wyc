import 'package:flutter/material.dart';
import 'package:fyp_wyc/data/viewdata.dart';
import 'package:fyp_wyc/event/online_user_event.dart';
import 'package:fyp_wyc/functions/my_snackbar.dart';
import 'package:fyp_wyc/main.dart';
import 'package:fyp_wyc/model/user.dart';
import 'package:fyp_wyc/utils/my_avatar.dart';
import 'package:go_router/go_router.dart';

class UserListPage extends StatefulWidget {
  final List<User>? userList;

  const UserListPage({
    super.key,
    this.userList,
  });

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<User>? userList = [];

  @override
  void initState() {
    super.initState();
    userList = widget.userList;
  }

  Future<void> _onEditUser(User user) async {
    if (navigatorKey.currentContext != null && navigatorKey.currentContext!.mounted) {
      await navigatorKey.currentContext!.push(
        '/${ViewData.profileEdit.path}',
        extra: {
          'user': user,
        },
      );
    }
  }

  Future<void> _onLockUser(User user) async {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: Text(user.isBanned ? "Unban User" : "Ban User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.isBanned 
                    ? "Do you want to unban user '${user.username}'?" 
                    : "Do you want to ban user '${user.username}'?",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                user.isBanned
                    ? "This will allow the user to login and use the app again."
                    : "This will prevent the user from logging in to the app.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                showDialog(
                  context: navigatorKey.currentContext!,
                  barrierDismissible: false,
                  builder: (context) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00BFA6),
                      ),
                    );
                  },
                );
                
                // Toggle the user's ban status
                final result = await OnlineUserStore.toggleUserBanStatus(user.email, !user.isBanned);
                
                // Close loading indicator safely
                if (Navigator.canPop(navigatorKey.currentContext!)) {
                  Navigator.pop(navigatorKey.currentContext!);
                }
                
                // Display result message
                MySnackBar.showSnackBar(result['message']);
                
                // Refresh the list if successful
                if (result['success'] && mounted) {
                  setState(() {
                    // Update will happen via OnlineUserStore automatically
                  });
                }
              },
              child: Text(
                user.isBanned ? "Unban" : "Ban",
                style: TextStyle(color: user.isBanned ? Colors.green : Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("All Users",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text("Name",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.person),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(
              color: Colors.grey,
              thickness: 1,
            ),
          ),
          _buildUserList(),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return SizedBox(
      height: 500,
      child: ListView.builder(
        itemCount: userList!.length,
        itemBuilder: (context, index) {
          return _buildUserItem(userList![index]);
        },
      ),
    );
  }

  Widget _buildUserItem(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          MyAvatar(
            image: user.avatarUrl != '' ? Image.network(user.avatarUrl) : null,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.username,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (user.isBanned)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Banned',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  user.email,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _onEditUser(user),
              ),
              IconButton(
                icon: Icon(
                  user.isBanned ? Icons.lock_open : Icons.lock,
                  color: user.isBanned ? Colors.orange : null,
                ),
                onPressed: () => _onLockUser(user),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmationDialog(user),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(User user) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete User"),
          content: Text(
            "Are you sure you want to delete user '${user.username}'? This operation cannot be undone.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                
                // Show loading indicator
                showDialog(
                  context: navigatorKey.currentContext!,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00BFA6),
                      ),
                    );
                  },
                );
                
                // Delete the user
                final result = await OnlineUserStore.deleteUser(user.email);
                
                // Close loading indicator
                Navigator.of(navigatorKey.currentContext!).pop();
                
                // Display result message
                MySnackBar.showSnackBar(result['message']);
                
                // Refresh the list if successful
                if (result['success']) {
                  setState(() {
                    userList!.removeWhere((u) => u.email == user.email);
                  });
                }
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
