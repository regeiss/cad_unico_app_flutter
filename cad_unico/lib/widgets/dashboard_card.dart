// lib/widgets/dashboard_card.dart

import 'package:flutter/material.dart';

class DashboardCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;
  final String? trend;
  final bool isCompact;
  final bool showTrend;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.isLoading = false,
    this.trend,
    this.isCompact = false,
    this.showTrend = false,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(widget.isCompact ? 12.0 : 16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isHovered 
                        ? widget.color.withValues(alpha: 0.3)
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? widget.color.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: _isHovered ? 8 : 4,
                      offset: Offset(0, _isHovered ? 4 : 2),
                    ),
                  ],
                ),
                child: widget.isLoading ? _buildLoadingState() : _buildContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: widget.isCompact ? 32 : 40,
              height: widget.isCompact ? 32 : 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Spacer(),
            if (!widget.isCompact)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
        SizedBox(height: widget.isCompact ? 8 : 12),
        Container(
          width: double.infinity,
          height: widget.isCompact ? 16 : 20,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: widget.isCompact ? 4 : 8),
        Container(
          width: widget.isCompact ? 60 : 80,
          height: widget.isCompact ? 12 : 14,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        if (widget.showTrend && !widget.isCompact) ...[
          const SizedBox(height: 8),
          Container(
            width: 100,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContent() {
    if (widget.isCompact) {
      return _buildCompactContent();
    } else {
      return _buildFullContent();
    }
  }

  Widget _buildCompactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ícone e valor
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                widget.icon,
                size: 20,
                color: widget.color,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // Título
        Text(
          widget.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        // Subtitle
        Text(
          widget.subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFullContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header com ícone e ação
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.icon,
                size: 24,
                color: widget.color,
              ),
            ),
            const Spacer(),
            if (widget.onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Valor principal
        Text(
          widget.value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: widget.color,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Título
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 2),
        
        // Subtitle
        Text(
          widget.subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        
        // Trend (se disponível)
        if (widget.showTrend && widget.trend != null) ...[
          const SizedBox(height: 8),
          _buildTrendIndicator(),
        ],
      ],
    );
  }

  Widget _buildTrendIndicator() {
    if (widget.trend == null) return const SizedBox.shrink();

    final isPositive = widget.trend!.startsWith('+');
    final isNegative = widget.trend!.startsWith('-');
    
    Color trendColor;
    IconData trendIcon;
    
    if (isPositive) {
      trendColor = Colors.green;
      trendIcon = Icons.trending_up;
    } else if (isNegative) {
      trendColor = Colors.red;
      trendIcon = Icons.trending_down;
    } else {
      trendColor = Colors.grey;
      trendIcon = Icons.trending_flat;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendIcon,
            size: 12,
            color: trendColor,
          ),
          const SizedBox(width: 4),
          Text(
            widget.trend!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para múltiplos cards
class DashboardCardGrid extends StatelessWidget {
  final List<DashboardCard> cards;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  const DashboardCardGrid({
    super.key,
    required this.cards,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.childAspectRatio = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: childAspectRatio,
      children: cards,
    );
  }
}

// Widget para cards em linha
class DashboardCardRow extends StatelessWidget {
  final List<DashboardCard> cards;
  final MainAxisAlignment mainAxisAlignment;

  const DashboardCardRow({
    super.key,
    required this.cards,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: cards
          .map((card) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: card,
                ),
              ))
          .toList(),
    );
  }
}