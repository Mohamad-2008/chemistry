import 'package:flutter/material.dart';
import 'dart:math';

class Particle {
  Offset position;
  Offset velocity;
  double radius;
  Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.color,
  });
}

class ParticleAnimation extends StatefulWidget {
  const ParticleAnimation({Key? key}) : super(key: key);

  @override
  State<ParticleAnimation> createState() => _ParticleAnimationState();
}

class _ParticleAnimationState extends State<ParticleAnimation> with SingleTickerProviderStateMixin {
  late List<Particle> _particles;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _particles = List.generate(
      10000, // افزایش تعداد ذرات به 100
      (index) => Particle(
        position: Offset(
          Random().nextDouble() * MediaQuery.of(context).size.width,
          Random().nextDouble() * MediaQuery.of(context).size.height,
        ),
        velocity: Offset(
          (Random().nextDouble() - 0.5) * 0.5,
          (Random().nextDouble() - 0.5) * 0.5,
        ),
        radius: Random().nextDouble() * 4 + 1,
        color: Colors.white.withOpacity(Random().nextDouble() * 0.4 + 0.2),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _updateParticles();
        return CustomPaint(
          painter: ParticlePainter(_particles),
        );
      },
    );
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.position += particle.velocity;

      if (particle.position.dx < 0 || particle.position.dx > MediaQuery.of(context).size.width) {
        particle.velocity = Offset(-particle.velocity.dx, particle.velocity.dy);
      }
      if (particle.position.dy < 0 || particle.position.dy > MediaQuery.of(context).size.height) {
        particle.velocity = Offset(particle.velocity.dx, -particle.velocity.dy);
      }
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 