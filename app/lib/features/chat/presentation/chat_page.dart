import 'package:flutter/material.dart';

import '../../../shared/widgets/section_card.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SectionCard(title: 'Chat Modes', child: Text('自己理解・行動整理・検証モードを実装予定。')),
        ],
      ),
    );
  }
}
