import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/cell_tag.dart';
import '../../../../../shared/widgets/user_avatar.dart';
import '../../domain/entities/service_entity.dart';
import '../providers/marketplace_provider.dart';

class ServiceCard extends ConsumerWidget {
  final ServiceEntity service;
  final bool isMine;
  const ServiceCard({super.key, required this.service, this.isMine = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header vendeur
          Row(children: [
            UserAvatar(name: service.sellerName, avatarUrl: service.sellerAvatar, size: 32),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.sellerName,
                  style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white)),
                CellTag(cell: service.sellerCell, small: true),
              ],
            )),
            // Prix
            RichText(text: TextSpan(children: [
              TextSpan(text: '${service.priceDa} DA',
                style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.success)),
              TextSpan(text: '/${service.unit}',
                style: const TextStyle(fontSize: 11, color: AppColors.greyMuted)),
            ])),
          ]),

          const SizedBox(height: 10),

          // Titre + description
          Text(service.title,
            style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white)),
          const SizedBox(height: 4),
          Text(service.description,
            style: const TextStyle(fontSize: 12, color: AppColors.greyMuted, height: 1.5),
            maxLines: 2, overflow: TextOverflow.ellipsis),

          const SizedBox(height: 10),

          // Actions
          Row(children: [
            if (isMine) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (service.isActive ? AppColors.success : AppColors.greyLight).withOpacity(.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: (service.isActive ? AppColors.success : AppColors.greyLight).withOpacity(.3)),
                ),
                child: Text(service.isActive ? 'Actif' : 'Inactif',
                  style: GoogleFonts.syne(fontSize: 10, fontWeight: FontWeight.w700,
                    color: service.isActive ? AppColors.success : AppColors.greyLight)),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                onPressed: () => ref.read(marketplaceProvider.notifier).deleteService(service.id),
              ),
            ] else ...[
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(110, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Contacter', style: TextStyle(fontSize: 12)),
              ),
            ],
          ]),
        ]),
      ),
    );
  }
}