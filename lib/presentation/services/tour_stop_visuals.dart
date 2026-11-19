import 'package:material_ui/material_ui.dart';

import '../../domain/entities/tour_stop.dart';
import '../theme/app_palette.dart';

class TourStopVisualData {
  const TourStopVisualData({required this.icon, required this.iconBackground});

  final IconData icon;
  final Color iconBackground;
}

class TourStopVisuals {
  const TourStopVisuals();

  TourStopVisualData forStop(TourStop stop) {
    switch (stop.id) {
      case 'stazione':
        return const TourStopVisualData(
          icon: Icons.train_outlined,
          iconBackground: Color(0xFFFFECB3),
        );
      case 'arrigoni':
        return const TourStopVisualData(
          icon: Icons.factory_outlined,
          iconBackground: Color(0xFFB2EBF2),
        );
      case 'fantaguzzi':
        return const TourStopVisualData(
          icon: Icons.domain_outlined,
          iconBackground: Color(0xFFFFCDD2),
        );
      case 'rifugi_antiaerei':
        return const TourStopVisualData(
          icon: Icons.shield_outlined,
          iconBackground: Color(0xFFCFD8DC),
        );
      case 'abbazia_monte':
        return const TourStopVisualData(
          icon: Icons.terrain,
          iconBackground: Color(0xFFD7CCC8),
        );
      case 'osservanza':
        return const TourStopVisualData(
          icon: Icons.fort,
          iconBackground: Color(0xFFC5CAE9),
        );
    }
    switch (stop.type.toLowerCase()) {
      case 'shelter':
        return const TourStopVisualData(
          icon: Icons.security_outlined,
          iconBackground: Color(0xFFCFD8DC),
        );
      case 'church':
        return const TourStopVisualData(
          icon: Icons.church_outlined,
          iconBackground: Color(0xFFE1BEE7),
        );
      case 'monument':
        return const TourStopVisualData(
          icon: Icons.castle_outlined,
          iconBackground: Color(0xFFC8E6C9),
        );
      case 'square':
        return const TourStopVisualData(
          icon: Icons.account_balance_outlined,
          iconBackground: Color(0xFFBBDEFB),
        );
      case 'school':
        return const TourStopVisualData(
          icon: Icons.school_outlined,
          iconBackground: Color(0xFFFFECB3),
        );
      case 'bridge':
        return const TourStopVisualData(
          icon: Icons.architecture,
          iconBackground: Color(0xFFD7CCC8),
        );
      case 'library':
        return const TourStopVisualData(
          icon: Icons.local_library_outlined,
          iconBackground: Color(0xFFC5CAE9),
        );
      default:
        return _fallback;
    }
  }

  static const TourStopVisualData _fallback = TourStopVisualData(
    icon: Icons.place_outlined,
    iconBackground: AppPalette.tan,
  );
}
