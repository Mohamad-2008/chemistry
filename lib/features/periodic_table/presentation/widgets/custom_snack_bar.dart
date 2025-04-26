import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show(BuildContext context, String message) {
    // ابتدا تمام پیام‌های قبلی را پاک می‌کنیم
    ScaffoldMessenger.of(context).clearSnackBars();
    
    // سپس پیام جدید را نمایش می‌دهیم
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _AnimatedSnackBarContent(message: message),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _AnimatedSnackBarContent extends StatefulWidget {
  final String message;

  const _AnimatedSnackBarContent({required this.message});

  @override
  _AnimatedSnackBarContentState createState() => _AnimatedSnackBarContentState();
}

class _AnimatedSnackBarContentState extends State<_AnimatedSnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          // onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1A237E), // آبی تیره
                  Color(0xFF4A148C), // بنفش تیره
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.blueAccent.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AnimatedIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedIcon extends StatefulWidget {
  @override
  _AnimatedIconState createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: const Icon(
        Icons.info_outline,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}