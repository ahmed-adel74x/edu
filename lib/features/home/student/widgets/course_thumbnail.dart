import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Square course image used by the "continue learning" cards. The featured
/// card layers a play affordance on top of it.
///
/// [coverPath] is whatever the API sent, exactly as sent: only an absolute
/// `http(s)` URL is loaded over the network; anything else (a relative path the
/// app has no documented base for, or null) falls back to the neutral
/// placeholder built from the app's own surface/icon treatment.
class CourseThumbnail extends StatelessWidget {
  const CourseThumbnail({
    super.key,
    required this.coverPath,
    this.size = 88,
    this.radius,
    this.showPlayOverlay = false,
  });

  /// The cover path/URL as the API sent it, or null.
  final String? coverPath;

  /// Rendered as a square of `size.w`.
  final double size;

  /// Defaults to [AppRadius.md].
  final double? radius;

  final bool showPlayOverlay;

  bool get _isUrl {
    final path = coverPath;
    return path != null && path.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? AppRadius.md),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_isUrl)
              Image.network(
                coverPath!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _Placeholder(iconSize: size * 0.3),
              )
            else
              _Placeholder(iconSize: size * 0.3),
            if (showPlayOverlay)
              Center(
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: context.colors.scrim.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Neutral cover used when there is no renderable cover: the app's own tinted
/// surface with the brand's school glyph.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.surfaceTint,
      child: Center(
        child: Icon(
          Icons.school_rounded,
          color: context.colors.primary,
          size: iconSize.sp,
        ),
      ),
    );
  }
}
