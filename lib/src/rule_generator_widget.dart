import 'package:flutter/material.dart';
import 'package:rrule_generator/localizations/english.dart';
import 'package:rrule_generator/localizations/text_delegate.dart';
import 'package:rrule_generator/src/periods/period.dart';
import 'package:rrule_generator/src/pickers/exclude_dates.dart';
import 'package:rrule_generator/src/pickers/interval.dart';
import 'package:rrule_generator/src/periods/yearly.dart';
import 'package:rrule_generator/src/periods/monthly.dart';
import 'package:rrule_generator/src/periods/weekly.dart';
import 'package:rrule_generator/src/periods/daily.dart';
import 'package:rrule_generator/src/pickers/helpers.dart';
import 'package:intl/intl.dart';
import 'package:rrule_generator/src/rrule_generator_config.dart';

class RRuleGenerator extends StatefulWidget {
  final RRuleTextDelegate textDelegate;
  final void Function(String newValue)? onChange;
  final String initialRRule;
  final DateTime? initialDate;
  final bool withExcludeDates;
  final InputDecoration? overrideInputDecoration;
  final RRuleGeneratorConfig? config;
  RRuleGenerator({
    super.key,
    this.config,
    this.overrideInputDecoration,
    this.textDelegate = const EnglishRRuleTextDelegate(),
    this.onChange,
    this.initialRRule = '',
    this.withExcludeDates = false,
    this.initialDate,
  }) {}

  @override
  State<RRuleGenerator> createState() => _RRuleGeneratorState();
}

class _RRuleGeneratorState extends State<RRuleGenerator> {
  late final RRuleGeneratorConfig config;

  int frequencyType = 0;
  int countType = 0;
  DateTime pickedDateNotifier = DateTime.now();

  final instancesController = TextEditingController(text: '1');

  final List<Period> periodWidgets = [];

  late final ExcludeDates? _excludeDatesPicker;

  @override
  void initState() {
    super.initState();
    config = widget.config ?? RRuleGeneratorConfig();
    periodWidgets.addAll([
      Yearly(
        this.config,
        widget.textDelegate,
        valueChanged,
        widget.initialRRule,
        widget.initialDate ?? DateTime.now(),
        overrideInputDecoration: widget.overrideInputDecoration,
      ),
      Monthly(
        this.config,
        widget.textDelegate,
        valueChanged,
        widget.initialRRule,
        widget.initialDate ?? DateTime.now(),
        // overrideInputDecoration: overrideInputDecoration,
      ),
      Weekly(
        this.config,
        widget.textDelegate,
        valueChanged,
        widget.initialRRule,
        overrideInputDecoration: widget.overrideInputDecoration,
        widget.initialDate ?? DateTime.now(),
      ),
      Daily(
        this.config,
        widget.textDelegate,
        valueChanged,
        widget.initialRRule,
        widget.initialDate ?? DateTime.now(),
        overrideInputDecoration: widget.overrideInputDecoration,
      )
    ]);
    _excludeDatesPicker = widget.withExcludeDates
        ? ExcludeDates(
            this.config,
            widget.textDelegate,
            valueChanged,
            widget.initialRRule,
            widget.initialDate ?? DateTime.now(),
          )
        : null;
    handleInitialRRule();
  }

  void handleInitialRRule() {
    if (widget.initialRRule.contains('MONTHLY')) {
      frequencyType = 1;
    } else if (widget.initialRRule.contains('WEEKLY')) {
      frequencyType = 2;
    } else if (widget.initialRRule.contains('DAILY')) {
      frequencyType = 3;
    } else if (widget.initialRRule == '') {
      frequencyType = 4;
    }

    if (widget.initialRRule.contains('COUNT')) {
      countType = 1;
      final countIndex = widget.initialRRule.indexOf('COUNT=') + 6;
      int countEnd = widget.initialRRule.indexOf(';', countIndex);
      countEnd = countEnd == -1 ? widget.initialRRule.length : countEnd;
      instancesController.text =
          widget.initialRRule.substring(countIndex, countEnd);
    } else if (widget.initialRRule.contains('UNTIL')) {
      countType = 2;
      final dateIndex = widget.initialRRule.indexOf('UNTIL=') + 6;
      final dateEnd = widget.initialRRule.indexOf(';', dateIndex);
      pickedDateNotifier = DateTime.parse(
        widget.initialRRule.substring(
            dateIndex, dateEnd == -1 ? widget.initialRRule.length : dateEnd),
      );
    }
    setState(() {});
  }

  void valueChanged() {
    final void Function(String newValue)? fun = widget.onChange;
    if (fun != null) {
      fun(getRRule());
    }
    setState(() {});
  }

  String getRRule() {
    if (frequencyType == 4) {
      return '';
    }

    final String excludeDates = _excludeDatesPicker?.getRRule() ?? '';
    if (countType == 0) {
      return 'RRULE:${periodWidgets[frequencyType].getRRule()}$excludeDates';
    } else if (countType == 1) {
      final instances = int.tryParse(instancesController.text) ?? 0;
      return 'RRULE:${periodWidgets[frequencyType].getRRule()};COUNT=${instances > 0 ? instances : 1}$excludeDates';
    }
    final pickedDate = pickedDateNotifier;

    final day = pickedDate.day > 9 ? '${pickedDate.day}' : '0${pickedDate.day}';
    final month =
        pickedDate.month > 9 ? '${pickedDate.month}' : '0${pickedDate.month}';

    return 'RRULE:${periodWidgets[frequencyType].getRRule()};UNTIL=${pickedDate.year}$month$day$excludeDates';
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildContainer(
              child: buildElement(
                title: config.headerEnabled ? widget.textDelegate.repeat : null,
                style: config.headerTextStyle,
                child: buildDropdown(
                  context: context,
                  child: DropdownButton(
                    isExpanded: true,
                    value: frequencyType,
                    autofocus: true,
                    onChanged: (newPeriod) {
                      frequencyType = newPeriod!;
                      valueChanged();
                    },
                    items: List.generate(
                      5,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text(
                          widget.textDelegate.periods[index],
                          style: config.textStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (frequencyType != 4) ...[
              const Divider(),
              periodWidgets[frequencyType],
              const Divider(),
              buildContainer(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: buildElement(
                            title: widget.textDelegate.end,
                            style: config.textStyle,
                            child: buildDropdown(
                              context: context,
                              child: DropdownButton(
                                isExpanded: true,
                                value: countType,
                                onChanged: (newCountType) {
                                  countType = newCountType!;
                                  valueChanged();
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Text(
                                      widget.textDelegate.neverEnds,
                                      style: config.textStyle,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text(
                                      widget.textDelegate.endsAfter,
                                      style: config.textStyle,
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text(
                                      widget.textDelegate.endsOnDate,
                                      style: config.textStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: countType == 0 ? 0 : 8,
                        ),
                        buildEndsAt()
                      ],
                    ),
                  ],
                ),
              ),
            ],
            // if (child != null) const Divider(),
            // if (child != null) child,
          ],
        ),
        // child:  _excludeDatesPicker,
        // ),
      );

  Widget buildEndsAt() {
    switch (countType) {
      case 1:
        return Expanded(
          child: buildElement(
            title: widget.textDelegate.instances,
            style: config.textStyle,
            child: IntervalPicker(
              instancesController,
              valueChanged,
              config: config,
              overrideInputDecoration: widget.overrideInputDecoration,
            ),
          ),
        );
      case 2:
        return Expanded(
          child: buildElement(
            title: widget.textDelegate.date,
            style: config.textStyle,
            child: OutlinedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  locale: Locale(
                    widget.textDelegate.locale.split('-')[0],
                    widget.textDelegate.locale.contains('-')
                        ? widget.textDelegate.locale.split('-')[1]
                        : '',
                  ),
                  initialDate: pickedDateNotifier,
                  firstDate: DateTime.utc(2020, 10, 24),
                  lastDate: DateTime(2100),
                );

                if (picked != null && picked != pickedDateNotifier) {
                  pickedDateNotifier = picked;
                  valueChanged();
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                ),
              ),
              child: SizedBox(
                width: double.maxFinite,
                child: Text(
                  DateFormat.yMd(
                    widget.textDelegate.locale,
                  ).format(pickedDateNotifier),
                  style: config.textStyle.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      default:
        return Container();
    }
  }
}
