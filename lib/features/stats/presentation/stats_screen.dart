import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/settings_button.dart';
import '../../activity/presentation/activity_tab.dart';
import '../../body/presentation/body_tab.dart';
import 'muscles_tab.dart';
import 'sessions_tab.dart';

/// Onglet « Stats » (SA-01) : quatre sous-onglets, comme la fiche exercice.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stats'),
          actions: const [SettingsButton()],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Séances'),
              Tab(text: 'Muscles'),
              Tab(text: 'Corps'),
              Tab(text: 'Activité'),
            ],
          ),
        ),
        // Pas de balayage entre sous-onglets : celui de « Muscles » sert déjà
        // à changer de semaine (SA-04), les deux gestes se gênaient.
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [SessionsTab(), MusclesTab(), BodyTab(), ActivityTab()],
        ),
      ),
    );
  }
}
