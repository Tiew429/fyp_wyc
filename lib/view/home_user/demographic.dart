import 'package:flutter/widgets.dart';
import 'package:fyp_wyc/model/user.dart';

class DemographicPage extends StatefulWidget {
  final User user;

  const DemographicPage({
    super.key,
    required this.user,
  });

  @override
  State<DemographicPage> createState() => _DemographicPageState();
}

class _DemographicPageState extends State<DemographicPage> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}