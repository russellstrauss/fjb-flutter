import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cart_service.dart';
import '../utils/image_loader.dart';

class AppHeader extends StatefulWidget {
  final bool hideLogo;

  const AppHeader({super.key, this.hideLogo = false});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  final CartService _cartService = CartService();
  bool _menuOpen = false;
  OverlayEntry? _overlayEntry;

  void _toggleMenu() {
    if (_menuOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    setState(() {
      _menuOpen = true;
    });
    
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    _overlayEntry = OverlayEntry(
      builder: (context) => _MenuOverlay(
        screenSize: screenSize,
        onClose: _closeMenu,
      ),
    );
    
    overlay.insert(_overlayEntry!);
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _menuOpen = false;
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1140),
        margin: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hamburger menu button with Squeeze animation
            IconButton(
              icon: _AnimatedHamburgerIcon(isActive: _menuOpen),
              onPressed: _toggleMenu,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              iconSize: 48,
            ),
                // Logo (hidden if hideLogo is true)
                if (!widget.hideLogo)
                  InkWell(
                    onTap: () {
                      _closeMenu();
                      context.go('/');
                    },
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: ImageLoader.loadImage(
                        '/assets/images/fjb-cotton-logo.svg',
                        fit: BoxFit.contain,
                        height: 60,
                        width: 60,
                        errorWidget: Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          child: const Center(
                            child: Text(
                              'FJB',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Cart icon with badge
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      iconSize: 48,
                      onPressed: () {
                        _closeMenu();
                        context.push('/cart');
                      },
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: FutureBuilder<int>(
                        future: Future.value(_cartService.getItemCount()),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          if (count == 0) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      );
  }
}

// Full-screen menu overlay widget
class _MenuOverlay extends StatefulWidget {
  final Size screenSize;
  final VoidCallback onClose;

  const _MenuOverlay({
    required this.screenSize,
    required this.onClose,
  });

  @override
  State<_MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<_MenuOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shopOpacityAnimation;
  late Animation<double> _shopSlideAnimation;
  late Animation<double> _aboutOpacityAnimation;
  late Animation<double> _aboutSlideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Shop animations - opacity slower (800ms), slide faster (400ms equivalent)
    _shopOpacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    );
    _shopSlideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic), // 50% of 800ms = 400ms
    );

    // About animations - opacity slower (800ms), slide faster (400ms equivalent)
    // Starts 150ms after Shop (150ms / 800ms = 0.1875)
    _aboutOpacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.1875, 1.0, curve: Curves.easeOut),
    );
    _aboutSlideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.1875, 0.6875, curve: Curves.easeOutCubic), // ~400ms duration starting at 150ms
    );

    // Start the animation when widget is built
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final headerHeight = 48.0; // Approximate header height
    
    return Stack(
      children: [
        // Full screen menu content starting below header
        Positioned(
          top: safeAreaTop + headerHeight,
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _MenuTextItem(
                      text: 'Shop',
                      opacityAnimation: _shopOpacityAnimation,
                      slideAnimation: _shopSlideAnimation,
                      onTap: () {
                        widget.onClose();
                        GoRouter.of(context).push('/shop');
                      },
                    ),
                    const SizedBox(height: 40),
                    _MenuTextItem(
                      text: 'About',
                      opacityAnimation: _aboutOpacityAnimation,
                      slideAnimation: _aboutSlideAnimation,
                      onTap: () {
                        widget.onClose();
                        GoRouter.of(context).push('/about');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Ignore pointer events in the header area so the original header button remains clickable
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: safeAreaTop + headerHeight,
          child: IgnorePointer(
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}

// Animated hamburger icon with Squeeze animation
class _AnimatedHamburgerIcon extends StatefulWidget {
  final bool isActive;

  const _AnimatedHamburgerIcon({required this.isActive});

  @override
  State<_AnimatedHamburgerIcon> createState() => _AnimatedHamburgerIconState();
}

class _AnimatedHamburgerIconState extends State<_AnimatedHamburgerIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Set initial state based on isActive
    if (widget.isActive) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedHamburgerIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Make icon 48x48 to match shopping cart icon (square)
    // Calculate bounding box for rotated content: diagonal of 45° rotation = size * sqrt(2)
    // Use clipBehavior: Clip.none to prevent clipping during rotation
    final baseSize = 48.0;
    final rotatedSize = baseSize * 1.414; // sqrt(2) for 45° rotation diagonal
    
    return Container(
      width: baseSize,
      height: baseSize,
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      // Use OverflowBox to allow content to extend when rotated, sized dynamically
      child: OverflowBox(
        maxWidth: rotatedSize,
        maxHeight: rotatedSize,
        alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Calculate positions for 3 lines: 5px height each with 10px spacing (even)
          // Total height: 5 + 10 + 5 + 10 + 5 = 35px
          // Center the 35px content in 48px container: starts at 6.5px
          // Center of 48px container: 24px
          // Top line top edge: 6.5px, moves to 21.5px (24 - 2.5) so center is at 24px
          // Middle line top edge: 21.5px (6.5 + 5 + 10) so center is at 24px
          // Bottom line top edge: 36.5px, moves to 21.5px so center is at 24px
          
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Top line - rotates down and moves to center, then forms X (45 degrees)
              Positioned(
                top: 6.5 + _animation.value * 15, // Move from 6.5px to 21.5px (top edge), center at 24px
                  left: 4,
                  right: 4,
                  child: Transform.rotate(
                    angle: _animation.value * 0.785398, // 45 degrees in radians
                    alignment: Alignment.center,
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
              // Middle line - fades out and scales down to 0
              Positioned(
                top: 21.5, // Top edge: 6.5 + 5 + 10 = 21.5px, center at 24px
                  left: 4,
                  right: 4,
                  child: Transform.scale(
                    scaleX: 1 - _animation.value,
                    child: Opacity(
                      opacity: 1 - _animation.value,
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ),
                ),
              // Bottom line - rotates up and moves to center, then forms X (-45 degrees)
              Positioned(
                top: 36.5 - _animation.value * 15, // Move from 36.5px to 21.5px (top edge), center at 24px
                  left: 4,
                  right: 4,
                  child: Transform.rotate(
                    angle: -_animation.value * 0.785398, // -45 degrees in radians
                    alignment: Alignment.center,
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


// Menu text item widget (large black text, no button)
class _MenuTextItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Animation<double> opacityAnimation;
  final Animation<double> slideAnimation;

  const _MenuTextItem({
    required this.text,
    required this.onTap,
    required this.opacityAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([opacityAnimation, slideAnimation]),
      builder: (context, child) {
        // Slide from left to right: start at -100px, end at 0px (using faster slide animation)
        final slideOffset = -100 * (1 - slideAnimation.value);
        // Fade in: start at opacity 0, end at opacity 1 (using slower opacity animation)
        final opacity = opacityAnimation.value;

        return Transform.translate(
          offset: Offset(slideOffset, 0),
          child: Opacity(
            opacity: opacity,
            child: SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: onTap,
                child: Text(
                  text.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}





