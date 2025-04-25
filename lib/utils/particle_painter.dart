import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  double x;
  double y;
  double speedX;
  double speedY;
  double size;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.size,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double width;
  final double height;

  ParticlePainter({
    required this.particles,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      paint.color = particle.color;
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticleAnimation extends StatefulWidget {
  final int numberOfParticles;
  final Color particleColor;
  final double maxParticleSize;
  final double speed;

  const ParticleAnimation({
    Key? key,
    this.numberOfParticles = 20,
    this.particleColor = Colors.blue,
    this.maxParticleSize = 2,
    this.speed = 1,
  }) : super(key: key);

  @override
  _ParticleAnimationState createState() => _ParticleAnimationState();
}

class _ParticleAnimationState extends State<ParticleAnimation> with SingleTickerProviderStateMixin {
  List<Particle> particles = [];
  late AnimationController _controller;
  Size? _size;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _controller.addListener(() => setState(() {}));
  }

  void _initializeParticles() {
    if (_size == null) return;
    
    final random = Random();
    particles = List.generate(
      widget.numberOfParticles,
      (_) => Particle(
        x: random.nextDouble() * _size!.width,
        y: random.nextDouble() * _size!.height,
        speedX: (random.nextDouble() - 0.5) * widget.speed,
        speedY: (random.nextDouble() - 0.5) * widget.speed,
        size: random.nextDouble() * widget.maxParticleSize,
        color: widget.particleColor.withOpacity(0.5),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    
    if (particles.isEmpty) {
      _initializeParticles();
    }
    
    for (var particle in particles) {
      particle.x += particle.speedX;
      particle.y += particle.speedY;

      if (particle.x < 0 || particle.x > _size!.width) {
        particle.speedX *= -1;
      }
      if (particle.y < 0 || particle.y > _size!.height) {
        particle.speedY *= -1;
      }
    }

    return CustomPaint(
      painter: ParticlePainter(
        particles: particles,
        width: _size!.width,
        height: _size!.height,
      ),
    );
  }
} 