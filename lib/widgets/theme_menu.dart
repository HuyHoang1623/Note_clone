import 'package:flutter/material.dart';
import '../main.dart';

void showThemePopupMenu(BuildContext context, Offset position) {
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

  showMenu(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(position, position),
      Offset.zero & overlay.size,
    ),
    items: [
      PopupMenuItem(
        child: const Text("Light"),
        onTap: () {
          Future.delayed(Duration.zero, () {
            MyApp.of(context)?.changeTheme(ThemeMode.light);
          });
        },
      ),
      PopupMenuItem(
        child: const Text("Dark"),
        onTap: () {
          Future.delayed(Duration.zero, () {
            MyApp.of(context)?.changeTheme(ThemeMode.dark);
          });
        },
      ),
    ],
  );
}
