import 'package:flutter/material.dart';

import '../models/bot_roster.dart';
import '../models/session_config.dart';

Color botProfileTone(BotProfile profile) {
  return switch (profile.persona) {
    _ when profile.name == 'Storm Crown' => const Color(0xFF8ED84E),
    _ when profile.name == 'Polly' => const Color(0xFFFF6B4A),
    Persona.coldMaster => const Color(0xFF63B8FF),
    Persona.coach => const Color(0xFF68D391),
    Persona.gentleman => const Color(0xFFFFC857),
    Persona.trashTalker => const Color(0xFFFF845E),
    Persona.trickster => const Color(0xFFD18CFF),
    Persona.speedDemon => const Color(0xFFFF4F7A),
    Persona.endgameGrinder => const Color(0xFFA9B4C2),
    Persona.royalVillain => const Color(0xFFE7B65C),
  };
}

IconData botProfileIcon(BotProfile profile) {
  return switch (profile.persona) {
    _ when profile.name == 'Polly' => Icons.flutter_dash_rounded,
    Persona.coldMaster => Icons.psychology_alt_rounded,
    Persona.coach => Icons.school_rounded,
    Persona.gentleman => Icons.workspace_premium_rounded,
    Persona.trashTalker => Icons.local_fire_department_rounded,
    Persona.trickster => Icons.auto_fix_high_rounded,
    Persona.speedDemon => Icons.bolt_rounded,
    Persona.endgameGrinder => Icons.hourglass_bottom_rounded,
    Persona.royalVillain => Icons.castle_rounded,
  };
}

class BotAvatarTile extends StatelessWidget {
  const BotAvatarTile({
    super.key,
    required this.profile,
    required this.size,
    this.borderRadius,
  });

  final BotProfile profile;
  final double size;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final tone = botProfileTone(profile);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(borderRadius ?? 18),
        border: Border.all(color: tone.withValues(alpha: 0.55)),
      ),
      child: Icon(botProfileIcon(profile), color: tone, size: size * 0.48),
    );
  }
}
