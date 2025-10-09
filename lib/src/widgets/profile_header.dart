import 'package:flutter/material.dart';
import 'package:your_turn/src/models/roommate.dart';
import 'package:your_turn/src/widgets/transaction_filters.dart'; // ⬅️ importa il widget dei filtri se non c’è

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.roommate,
  });

  final Roommate roommate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Foto profilo a sinistra
          _buildAvatar(),

          

          // 🔹 Box a destra (nome + filtri)
          
        ],
      ),
    );
  }

  // 🔹 Avatar con cerchio e ombra
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
}
