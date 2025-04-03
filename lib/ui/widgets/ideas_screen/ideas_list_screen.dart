import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

class IdeasListScreen extends StatelessWidget {
  const IdeasListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.ideas), centerTitle: true,),
      body: Center(

      ),
    );
  }
}
