import 'package:flutter/material.dart';
import 'project_page.dart';
import 'task_page.dart';
import 'home_page.dart';

class MyNavigationBar extends StatefulWidget {
  final int currentIndex;

  const MyNavigationBar({super.key, required this.currentIndex});

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => TaskPage()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ProjectPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _NavButton(
          icon: Icons.home,
          isActive: _selectedIndex == 0,
          onPressed: () => _onItemTapped(0),
        ),
        const SizedBox(width: 20),
        _NavButton(
          icon: Icons.edit,
          isActive: _selectedIndex == 1,
          onPressed: () => _onItemTapped(1),
        ),
        const SizedBox(width: 20),
        _NavButton(
          icon: Icons.work,
          isActive: _selectedIndex == 2,
          onPressed: () => _onItemTapped(2),
        ),
      ],
    );
  }
}

class _NavButton extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;

  const _NavButton({
    required this.icon,
    required this.isActive,
    required this.onPressed,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  Color get _buttonColor {
    if (widget.isActive) return const Color(0xFF164F94);
    if (_isPressed) return const Color(0xFFABABAB);
    if (_isHovered) return const Color(0xFFABABAB);
    return const Color(0xFFEBECF0);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _buttonColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            color: widget.isActive ? Colors.white : const Color(0xFFABABAB),
            size: 30,
          ),
        ),
      ),
    );
  }
}
