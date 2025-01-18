import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rrule_generator/src/rrule_generator_config.dart';

class IntervalPicker extends StatefulWidget {
  const IntervalPicker(
    this.controller,
    this.onChange, {
    super.key,
    required this.config,
    this.overrideInputDecoration,
  });

  final RRuleGeneratorConfig config;

  final void Function() onChange;
  final TextEditingController controller;
  final InputDecoration? overrideInputDecoration;

  @override
  State<IntervalPicker> createState() => _IntervalPickerState();
}

class _IntervalPickerState extends State<IntervalPicker> {
  @override
  Widget build(BuildContext context) => TextField(
        controller: widget.controller,
        keyboardType: TextInputType.number,
        decoration: widget.overrideInputDecoration ??
            InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: widget.config.textFieldBorderColor),
                borderRadius: BorderRadius.all(
                  widget.config.textFieldBorderRadius,
                ),
              ),
            ),
        onTap: () {
          widget.controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: widget.controller.text.length,
          );
        },
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onSubmitted: (String _) {
          final currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        onChanged: (String text) {
          TextSelection previousSelection = widget.controller.selection;
          widget.controller.text = text;
          widget.controller.selection = previousSelection;
          widget.onChange();
        },
      );
}
