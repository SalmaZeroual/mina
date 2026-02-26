import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/avatar_widget.dart';

class ServiceDetailScreen extends StatelessWidget {
  final ServiceModel service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(service.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                Text('\$${service.price.toInt()}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text('${service.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(' · ${service.reviewsCount} reviews', style: const TextStyle(color: AppTheme.textSecondary)),
            ]),
            const SizedBox(height: 16),
            const Text('About this service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(service.description, style: const TextStyle(fontSize: 14, height: 1.6, color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            const Text('Provider', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                AvatarWidget(initials: service.provider.initials, size: 48),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(service.provider.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(service.provider.title, style: const TextStyle(color: AppTheme.textSecondary)),
                  Text(service.cell, style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
                ]),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hire Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
