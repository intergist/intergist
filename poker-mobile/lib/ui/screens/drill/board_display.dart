// Poker Sharp — Board Display (5 cards with flip animation)

import 'package:flutter/material.dart';

import '../../../core/poker.dart' as poker;
import '../../tokens/spacing_tokens.dart';
import '../../tokens/motion_tokens.dart';
import 'poker_card_widget.dart';

class BoardDisplay extends StatelessWidget {
  final List<poker.Card> board;
  final bool compact;

  const BoardDisplay({
    super.key,
    required this.board,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardW = compact ? 48.0 : 54.0;
    final cardH = compact ? 67.0 : 76.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(board.length, (i) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 3),
          child: _AnimatedBoardCard(
            card: board[i],
            index: i,
            width: cardW,
            height: cardH,
          ),
        );
      }),
    );
  }
}

class _AnimatedBoardCard extends StatefulWidget {
  final poker.Card card;
  final int index;
  final double width;
  final double height;

  const _AnimatedBoardCard({
    required this.card,
    required this.index,
    required this.width,
    required this.height,
  });

  @override
  State<_AnimatedBoardCard> createState() => _AnimatedBoardCardState();
}

class _AnimatedBoardCardState extends State<_AnimatedBoardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppMotion.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: AppMotion.entrance),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6),
      ),
    );

    // Stagger the animation by index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: PokerCardWidget(
        card: widget.card,
        width: widget.width,
        height: widget.height,
      ),
    );
  }
}
