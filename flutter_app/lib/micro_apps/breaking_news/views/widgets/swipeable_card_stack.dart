
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/breaking_news_article.dart';
import 'breaking_news_card.dart';

class SwipeableCardStack extends StatefulWidget {
  final List<BreakingNewsArticle> articles;
  final Function(BreakingNewsArticle) onSwipeLeft;
  final Function(BreakingNewsArticle) onSwipeRight;
  final Function(BreakingNewsArticle)? onCardFlip;
  final Function(BreakingNewsArticle)? onReadFinished;

  const SwipeableCardStack({
    super.key,
    required this.articles,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.onCardFlip,
    this.onReadFinished,
  });

  @override
  State<SwipeableCardStack> createState() => SwipeableCardStackState();
}

class SwipeableCardStackState extends State<SwipeableCardStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  
  Offset _dragOffset = Offset.zero;
  double _rotation = 0.0;
  bool _isDragging = false;
  
  BreakingNewsArticle? _animatingArticle;
  Offset _flyAwayEnd = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
        
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_animatingArticle != null) {
          if (_flyAwayEnd.dx > 0) {
            widget.onSwipeRight(_animatingArticle!);
          } else {
            widget.onSwipeLeft(_animatingArticle!);
          }
          
          setState(() {
            _dragOffset = Offset.zero;
            _rotation = 0.0;
            _animatingArticle = null;
          });
          _controller.reset();
        }
      }
    });

    _controller.addListener(() {
      setState(() {
        if (_controller.isAnimating && _animatingArticle == null) {
           _dragOffset = _animation.value;
           _rotation = _dragOffset.dx * 0.0005; 
        } else if (_controller.isAnimating) {
           _dragOffset = _animation.value;
        }
      });
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (_controller.isAnimating) return;
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_controller.isAnimating) return;
    setState(() {
      _dragOffset += details.delta;
      _rotation = (_dragOffset.dx / 300) * 0.3; 
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.35; 

    if (_dragOffset.dx.abs() > threshold) {
      _completeSwipe(screenWidth);
    } else {
      _springBack();
    }
  }

  void swipeLeft() {
    if (_isDragging || _animatingArticle != null || widget.articles.isEmpty) return;
    final screenWidth = MediaQuery.of(context).size.width;
    _completeSwipe(-screenWidth * 0.4); // Trigger with a small negative offset
  }

  void _completeSwipe(double initialDx) {
    if (widget.articles.isEmpty) return;
    
    _animatingArticle = widget.articles.first;
    final isRight = initialDx > 0;
    
    final screenWidth = MediaQuery.of(context).size.width;
    _flyAwayEnd = Offset(isRight ? screenWidth * 1.5 : -screenWidth * 1.5, 0);
    
    _animation = Tween<Offset>(begin: Offset(initialDx, 0), end: _flyAwayEnd)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
        
    _controller.reset();
    _controller.forward();
  }

  void _springBack() {
    _animation = Tween<Offset>(begin: _dragOffset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.articles.isEmpty) {
      return const Center(child: Text("No more news for now.", style: TextStyle(color: Colors.white70)));
    }

    // Determine how many cards to show (max 3 for visual depth)
    final totalCards = widget.articles.length;
    final visibleCount = totalCards > 3 ? 3 : totalCards;

    // We build the stack from bottom-up (last visible card first)
    // Index 0 = top (active), Index 1 = 2nd card, Index 2 = 3rd card
    final List<Widget> cardWidgets = [];
    
    for (int i = visibleCount - 1; i >= 0; i--) {
       final article = widget.articles[i];
       final bool isActive = (i == 0);
       
       if (isActive) {
          // Active Card (Top)
          cardWidgets.add(
            Positioned.fill(
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Transform.translate(
                  offset: _dragOffset,
                  child: Transform.rotate(
                    angle: _rotation,
                    child: BreakingNewsCard(
                      key: ValueKey(article.id),
                      article: article,
                      onFlip: () => widget.onCardFlip?.call(article),
                      onReadFinished: () => widget.onReadFinished?.call(article),
                      // No more onFlipChanged needed for idle control
                    ),
                  ),
                ),
              ),
            )
          );
       } else {
          // Background Cards (Depth Effect)
          // i=1 (2nd card): scale 0.95, top offset +15
          // i=2 (3rd card): scale 0.9, top offset +30
          final double scale = 1.0 - (i * 0.05);
          final double topOffset = i * 15.0;
          
          cardWidgets.add(
             Positioned.fill(
               top: topOffset, // Push down
               child: Transform.scale(
                 scale: scale,
                 alignment: Alignment.topCenter, // Scale from top to keep visual alignment
                 child: Container(
                   // To avoid touch interception on background cards
                   child: BreakingNewsCard(
                     key: ValueKey(article.id),
                     article: article,
                     // Background cards should not flip
                   ),
                 ),
               ),
             )
          );
       }
    }

    return Stack(
      children: cardWidgets,
    );
  }
}
