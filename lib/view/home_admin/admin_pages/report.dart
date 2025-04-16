import 'package:flutter/widgets.dart';
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
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}