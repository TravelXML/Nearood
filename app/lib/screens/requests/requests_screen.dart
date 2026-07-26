import 'package:flutter/material.dart';
import '../../widgets/placeholder_screen.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Requests',
      icon: Icons.mark_email_unread_rounded,
      description:
          'Join requests you\'ve sent, assistance matches, and their statuses will show up here.',
      upcoming: ['Pending', 'Accepted', 'Waiting list'],
    );
  }
}
