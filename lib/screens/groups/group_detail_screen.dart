import 'package:flutter/material.dart';
import '../../models/group_model.dart';
import '../../theme/app_theme.dart';

class GroupDetailScreen extends StatelessWidget {
  final GroupModel group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryLight]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(group.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            ),
            const SizedBox(height: 20),
            Text(group.description, style: const TextStyle(fontSize: 15, height: 1.5)),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.group_outlined, color: AppTheme.textSecondary, size: 18),
              const SizedBox(width: 6),
              Text('${group.membersCount} members', style: const TextStyle(color: AppTheme.textSecondary)),
            ]),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(group.requiresApproval ? 'Request to Join' : 'Join Group'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
