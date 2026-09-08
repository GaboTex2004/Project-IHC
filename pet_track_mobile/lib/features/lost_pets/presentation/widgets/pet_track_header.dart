import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/generated/figma_tokens.dart';

class PetTrackHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;

  const PetTrackHeader({
    super.key,
    this.title,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            )
          : null,
      titleSpacing: showBackButton ? 0 : SpacingToken.m,
      title: title != null
          ? Text(title!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pets_rounded, color: AppColors.primary, size: 25),
                SizedBox(width: SpacingToken.s),
                Text('Pet Track', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
      actions: actions,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }
}
