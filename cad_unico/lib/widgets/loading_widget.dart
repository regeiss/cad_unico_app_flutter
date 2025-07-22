import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool overlay;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 40.0,
    this.color,
    this.overlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SpinKitFadingCircle(
          color: color ?? Theme.of(context).primaryColor,
          size: size,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (overlay) {
      return Container(
        color: Colors.black.withValues(alpha: (0.3),
        child: Center(child: widget),
      );
    }

    return Center(child: widget);
  }
}

class CompactLoadingWidget extends StatelessWidget {
  final double size;
  final Color? color;

  const CompactLoadingWidget({
    super.key,
    this.size = 20.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) => SpinKitThreeBounce(
      color: color ?? Theme.of(context).primaryColor,
      size: size,
    );
}

class ListLoadingWidget extends StatelessWidget {
  final int itemCount;

  const ListLoadingWidget({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) => ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const _SkeletonListItem(),
    );
}

class _SkeletonListItem extends StatefulWidget {
  const _SkeletonListItem();

  @override
  State<_SkeletonListItem> createState() => _SkeletonListItemState();
}

class _SkeletonListItemState extends State<_SkeletonListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300]!.withValues(alpha: (_animation.value),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 16,
                width: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  color: Colors.grey[300]!.withValues(alpha: (_animation.value),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 14,
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  color: Colors.grey[300]!.withValues(alpha: (_animation.value),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
    );
}