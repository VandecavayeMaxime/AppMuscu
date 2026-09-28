import 'package:material_ui/material_ui.dart';

import '../../body/presentation/body_tab.dart';
import 'muscles_tab.dart';
import 'sessions_tab.dart';

/// Onglet « Stats » (SA-01) : trois sous-onglets, comme la fiche exercice.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stats'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Séances'),
              Tab(text: 'Muscles'),
              Tab(text: 'Corps'),
            ],
          ),
        ),
        // Pas de balayage entre sous-onglets : celui de « Muscles » sert déjà
        // à changer de semaine (SA-04), les deux gestes se gênaient.
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [SessionsTab(), MusclesTab(), BodyTab()],
        ),
      ),
    );
  }
}
