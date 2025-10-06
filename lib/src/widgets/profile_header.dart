import 'package:flutter/material.dart';

import 'package:your_turn/src/models/roommate.dart';

/// Widget per l'header del profilo con avatar e pulsanti azione
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.roommate,
    required this.onDownload,
    required this.onAddTransaction,
  });

  final Roommate roommate;
  final VoidCallback onDownload;
  final VoidCallback onAddTransaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildName(),
                const SizedBox(height: 8),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue.shade700, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: roommate.photoUrl != null && roommate.photoUrl!.isNotEmpty
            ? Image.network(
                roommate.photoUrl!,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
              )
            : _buildFallbackAvatar(),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: Colors.blue.shade700,
      child: Center(
        child: Text(
          roommate.name.isNotEmpty ? roommate.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildName() {
    return Text(
      roommate.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: Colors.grey.shade900,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: onDownload,
          icon: const Icon(Icons.download_rounded, size: 20),
          label: const Text('Download'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: onAddTransaction,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Aggiungi'),
        ),
      ],
    );
  }
}