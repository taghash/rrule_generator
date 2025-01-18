import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Container buildDropdown({
  required Widget child,
  required BuildContext context,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: Theme.of(context).dividerColor,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    width: double.maxFinite,
    padding: const EdgeInsets.all(8),
    child: DropdownButtonHideUnderline(
      child: child,
    ),
  );
}

Column buildElement({
  String? title,
  required Widget child,
  required TextStyle style,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // if (title != null)
      //   Text(
      //     title,
      //     style: style,
      //   )
      // else
      Container(),
      child,
    ],
  );
}

Padding buildContainer({required Widget child}) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: child,
  );
}

Widget buildToggleItem({
  required Widget child,
  required void Function(bool) onChanged,
  required String title,
  required bool value,
  required TextStyle style,
}) {
  return AnimatedSize(
      duration: Durations.medium1,
      child: buildContainer(
        child: Column(
          children: [
            SwitchListTile.adaptive(
              value: value,
              onChanged: onChanged,
              title: Text(
                title,
                style: style.copyWith(fontSize: 16),
              ),
            ),
            if (value == true) child
          ],
        ),
      ));
}
