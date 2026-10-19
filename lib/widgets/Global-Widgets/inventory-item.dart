// --- Reusable Text-Only Item Card (For Units, Tags, Variations) ---
import 'package:flutter/material.dart';
import 'package:va_bookats/app/modules/products/views/widgets/rounded_app_bar.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:va_bookats/utilities/translation_extention.dart';

class InventoryTextItemCard extends StatelessWidget {
  final String status;
  final String name;
  final String branch;
  final VoidCallback onDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InventoryTextItemCard({
    super.key,
    required this.status,
    required this.name,
    required this.branch,
    required this.onDetails,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'inventory.status'.trns(),
                style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w500, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE3D9), // Light orange bg
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.trns(),
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          
          // Name Row
          _buildInfoRow('inventory.name'.trns(), name),
          const SizedBox(height: 12),
          
          // Dashed Divider
          const DashedDivider(),
          const SizedBox(height: 12),
          
          // Branch Row
          _buildInfoRow('inventory.branch'.trns(), branch),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'inventory.details'.trns(),
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildIconButton(Icons.edit_outlined, onEdit),
              const SizedBox(width: 12),
              _buildIconButton(Icons.delete_outline, onDelete),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.grey, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
    );
  }
}