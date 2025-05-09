import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ir_datetime_picker/src/helpers/date.dart';
import 'package:ir_datetime_picker/src/helpers/print.dart';
import 'package:ir_datetime_picker/src/helpers/responsive.dart';
import 'package:shamsi_date/shamsi_date.dart';

/// * [IRJalaliDatePickerOnSelected] is a callback function that will call when user change cupertino pickers.

typedef IRJalaliDatePickerOnSelected = void Function(Jalali jalaliDate);

/// * You can use [IRJalaliDatePicker] to design your own date pickers.

class IRJalaliDatePicker extends StatefulWidget {
  final Jalali? initialDate;
  final int? minYear;
  final int? maxYear;
  final bool visibleTodayButton;
  final bool? visibleDays;
  final String todayButtonText;
  final BoxConstraints? constraints;
  final IRJalaliDatePickerOnSelected onSelected;
  final TextStyle? textStyle;
  final double diameterRatio;
  final double magnification;
  final double offAxisFraction;
  final double squeeze;
  final Widget? selectionOverlay;

  const IRJalaliDatePicker({
    super.key,
    this.initialDate,
    this.minYear,
    this.maxYear,
    this.visibleDays,
    this.visibleTodayButton = true,
    required this.todayButtonText,
    this.constraints,
    required this.onSelected,
    this.textStyle,
    this.diameterRatio = 1.0,
    this.magnification = 1.3,
    this.offAxisFraction = 0.0,
    this.squeeze = 1.3,
    this.selectionOverlay,
  });

  @override
  State<IRJalaliDatePicker> createState() => _IRJalaliDatePickerState();
}

class _IRJalaliDatePickerState extends State<IRJalaliDatePicker> {
  late Jalali _initialDate;
  late bool _refreshCupertinoPickers;
  int _selectedYear = 1400;
  int _selectedMonth = 1;
  int _selectedDay = 1;
  List<int> _years = [];
  final List<String> _months = IRJalaliDateHelper.months;
  List<int> _days = [];

  @override
  void initState() {
    super.initState();
    _initialDate = widget.initialDate ?? Jalali.now();
    _refreshCupertinoPickers = false;
    _selectedYear = _initialDate.year;
    _selectedMonth = _initialDate.month;
    _selectedDay = _initialDate.day;
    _years = _yearsList(widget.minYear ?? (_initialDate.year - 50),
        widget.maxYear ?? (_initialDate.year + 50));
    _days = _daysList(_getSelectedJalaliDate().monthLength);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCupertinoPickers = false;
    });
    BoxConstraints cupertinoPickersConstraints = BoxConstraints.loose(
      Size(100.0.percentOfWidth(context), 30.0.percentOfHeight(context)),
    );
    Widget cupertinoPickers = Directionality(
      textDirection: TextDirection.ltr,
      child: ConstrainedBox(
        constraints: widget.constraints ?? cupertinoPickersConstraints,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _cupertinoPicker(
              context: context,
              list: _years,
              initialItem: _years.indexOf(_selectedYear),
              onSelectedItemChanged: (selectedIndex) {
                setState(() {
                  _selectedYear = _years[selectedIndex];
                  int monthLength = IRJalaliDateHelper.getMonthLength(
                      year: _selectedYear, month: _selectedMonth);
                  _days = List<int>.generate(monthLength, (index) => index + 1);
                  if (_selectedDay > monthLength) {
                    _selectedDay = monthLength;
                  }
                });
                widget.onSelected(_getSelectedJalaliDate());
              },
            ),
            _cupertinoPicker(
              context: context,
              list: _months,
              initialItem: _months.indexOf(
                  IRJalaliDateHelper.getMonthName(monthNumber: _selectedMonth)),
              onSelectedItemChanged: (selectedIndex) {
                setState(() {
                  _selectedMonth = IRJalaliDateHelper.getMonthNumber(
                      monthName: _months[selectedIndex]);
                  int monthLength = IRJalaliDateHelper.getMonthLength(
                      year: _selectedYear, month: _selectedMonth);
                  _days = List<int>.generate(monthLength, (index) => index + 1);
                  if (_selectedDay > monthLength) {
                    _selectedDay = monthLength;
                  }
                });
                widget.onSelected(_getSelectedJalaliDate());
              },
            ),
           if(widget.visibleDays != false) _cupertinoPicker(
              context: context,
              list: _days,
              initialItem: _days.indexOf(_selectedDay),
              onSelectedItemChanged: (selectedIndex) {
                _selectedDay = _days[selectedIndex];
                widget.onSelected(_getSelectedJalaliDate());
              },
            ),
          ],
        ),
      ),
    );
    Widget todayButton = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 1.0.percentOfHeight(context)),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 10.0.percentOfWidth(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              TextButton.icon(
                icon: Icon(Icons.info,
                    size: 6.5.percentOfWidth(context),
                    color: widget.textStyle?.color ??
                        Theme.of(context).textTheme.titleMedium?.color),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(2.0.percentOfWidth(context)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                label: Text(widget.todayButtonText,
                    style: (widget.textStyle ??
                            Theme.of(context).textTheme.titleMedium)
                        ?.copyWith(
                            fontSize: 14.responsiveFont(context),
                            fontWeight: FontWeight.w600)),
                onPressed: () {
                  setState(() {
                    _refreshCupertinoPickers = true;
                    Jalali now = Jalali.now();
                    _selectedYear = now.year;
                    _selectedMonth = now.month;
                    _selectedDay = now.day;
                  });
                  widget.onSelected(_getSelectedJalaliDate());
                },
              ),
            ],
          ),
        ),
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        cupertinoPickers,
        Visibility(
          visible: widget.visibleTodayButton,
          child: todayButton,
        ),
      ],
    );
  }

  Widget _cupertinoPicker(
      {required BuildContext context,
      required List list,
      required int initialItem,
      required ValueChanged<int> onSelectedItemChanged}) {
    mPrint(initialItem);
    BoxConstraints cupertinoPickerConstraints = BoxConstraints.loose(
      Size(30.0.percentOfWidth(context), double.infinity),
    );
    return ConstrainedBox(
      constraints: cupertinoPickerConstraints,
      child: CupertinoPicker(
        key: _refreshCupertinoPickers ? UniqueKey() : null,
        scrollController: FixedExtentScrollController(initialItem: initialItem),
        itemExtent: 8.5.percentOfWidth(context),
        diameterRatio: widget.diameterRatio,
        magnification: widget.magnification,
        offAxisFraction: widget.offAxisFraction,
        squeeze: widget.squeeze,
        selectionOverlay: widget.selectionOverlay ?? Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  color: widget.textStyle?.color?.withOpacity(0.35) ??
                      Colors.grey.shade400,
                  width: 0.5),
              bottom: BorderSide(
                  color: widget.textStyle?.color?.withOpacity(0.35) ??
                      Colors.grey.shade400,
                  width: 0.5),
            ),
          ),
        ),
        onSelectedItemChanged: onSelectedItemChanged,
        children: list.map<Widget>(
          (element) {
            return Center(
              child: Text(
                element.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: widget.textStyle?.color,
                      fontSize: widget.textStyle?.fontSize ??
                          16.5.responsiveFont(context),
                      fontWeight: widget.textStyle?.fontWeight,
                    ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  List<int> _yearsList(int minYear, int maxYear) {
    List<int> years = [];
    for (int i = minYear; i <= maxYear; i++) {
      years.add(i);
    }
    return years;
  }

  List<int> _daysList(int monthLength) {
    return List<int>.generate(monthLength, (index) => index + 1);
  }

  Jalali _getSelectedJalaliDate() {
    return Jalali(_selectedYear, _selectedMonth, _selectedDay);
  }
}
