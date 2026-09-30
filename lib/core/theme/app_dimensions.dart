import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Consistent 4pt-based spacing scale, resolved through ScreenUtil so it
/// scales sensibly across phone sizes. Values are getters (not const)
/// because `.w` / `.r` need ScreenUtil to be initialized first.
abstract final class AppSpacing {
  static double get xxs => 4.w;
  static double get xs => 8.w;
  static double get sm => 12.w;
  static double get md => 16.w;
  static double get lg => 20.w;
  static double get xl => 24.w;
  static double get xxl => 32.w;
}

/// Consistent corner-radius scale.
abstract final class AppRadius {
  static double get xs => 8.r;
  static double get sm => 12.r;
  static double get md => 16.r;
  static double get lg => 20.r;
  static double get xl => 28.r;
  static double get pill => 999.r;
}

/// Small reusable gap widgets so spacing stays consistent without
/// sprinkling raw SizedBox(height: N.h) everywhere.
class VGap extends StatelessWidget {
  const VGap(this.size, {super.key});
  final double size;
  const VGap.xxs({super.key}) : size = 4;
  const VGap.xs({super.key}) : size = 8;
  const VGap.sm({super.key}) : size = 12;
  const VGap.md({super.key}) : size = 16;
  const VGap.lg({super.key}) : size = 20;
  const VGap.xl({super.key}) : size = 24;

  @override
  Widget build(BuildContext context) => SizedBox(height: size.h);
}

class HGap extends StatelessWidget {
  const HGap(this.size, {super.key});
  final double size;
  const HGap.xxs({super.key}) : size = 4;
  const HGap.xs({super.key}) : size = 8;
  const HGap.sm({super.key}) : size = 12;
  const HGap.md({super.key}) : size = 16;
  const HGap.lg({super.key}) : size = 20;
  const HGap.xl({super.key}) : size = 24;

  @override
  Widget build(BuildContext context) => SizedBox(width: size.w);
}