import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge_model.dart';
import '../services/challenge_service.dart';

class ChallengeCard extends StatefulWidget {
  final Challenge challenge;
  final VoidCallback? onDelete;

  const ChallengeCard({Key? key, required this.challenge, this.onDelete}) : super(key: key);

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard> {
  String? userEmail;
  bool isJoined = false;
  bool isLoadingJoin = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmailAndJoinedStatus();
  }

  Future<void> _loadUserEmailAndJoinedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email'); // صح من 'userEmail' لـ 'email'
    setState(() {
      userEmail = email;
    });

    if (email != null) {
      final joined = await ChallengeService.isChallengeJoined(widget.challenge.id!, email);
      setState(() {
        isJoined = joined;
      });
    }
  }

  Future<void> _joinOrUnjoinChallenge() async {
    if (userEmail == null) return;

    setState(() => isLoadingJoin = true);

    bool success;
    if (isJoined) {
      success = await ChallengeService.unjoinChallenge(widget.challenge.id!, userEmail!);
    } else {
      success = await ChallengeService.joinChallenge(widget.challenge.id!, userEmail!);
    }

    setState(() {
      isLoadingJoin = false;
      if (success) isJoined = !isJoined;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? (isJoined ? "✅ Joined challenge" : "✅ Unjoined challenge")
            : "❌ Failed, try again"),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteChallenge() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Challenge"),
        content: const Text("Are you sure you want to delete this challenge?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ChallengeService.deleteChallenge(widget.challenge.id!);
      if (success) {
        widget.onDelete?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Challenge deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to delete challenge")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final isOwner = userEmail != null && userEmail == challenge.creatorEmail;

    final imageUrl = (challenge.imageUrl != null && challenge.imageUrl!.isNotEmpty)
        ? "http://10.0.2.2:8080${challenge.imageUrl}"
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(2, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: imageUrl != null
                ? Image.network(imageUrl, width: double.infinity, height: 160, fit: BoxFit.cover)
                : _placeholderImage(),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  challenge.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(challenge.date, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Text("${challenge.kcal} kcal", style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoadingJoin ? null : _joinOrUnjoinChallenge,
                    icon: isLoadingJoin
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(isJoined ? Icons.check_circle : Icons.flag),
                    label: Text(isJoined ? "Joined" : "Join"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isJoined ? Colors.green : const Color(0xFF655CD1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                if (isOwner) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteChallenge,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
      ),
    );
  }
}
