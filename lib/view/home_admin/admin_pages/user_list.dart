import 'package:flutter/widgets.dart';
import 'package:fyp_wyc/model/user.dart';

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

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
