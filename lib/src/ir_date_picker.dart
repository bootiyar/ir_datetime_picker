// Copyright (c) 2022, Ali Khajavi (alikhajavi74@gmail.com) All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ir_datetime_picker/src/utils/responsive.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'utils/utils.dart';

// --------------------------------------------------------------------------------------------------------------------

// IRDatePicker widget:

class IRDatePicker extends StatefulWidget {
  final Jalali? initialDate;
  final int? startYear;
  final int? endYear;

  const IRDatePicker({Key? key, this.initialDate, this.startYear, this.endYear}) : super(key: key);

  @override
  State<IRDatePicker> createState() => _IRDatePickerState();
}

class _IRDatePickerState extends State<IRDatePicker> {
  late Jalali _initialDate;

  int _selectedYear = 1400;
  int _selectedMonth = 1;
  late int _currentMonthLength;
  int _selectedDay = 1;

  List<int> _years = [];
  final List<String> _months = persianMonths;
  List<int> _days = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    _initialDate = widget.initialDate ?? Jalali.now();
    _selectedYear = _initialDate.year;
    _selectedMonth = _initialDate.month;
    _selectedDay = _initialDate.day;
    _years = generateYearsList(widget.startYear ?? (_initialDate.year - 50), widget.endYear ?? (_initialDate.year + 50));
    _currentMonthLength = getSelectedJalaliDate().monthLength;
    _days = generateDaysList(_currentMonthLength);
  }

  @override
  Widget build(BuildContext context) {
    Widget backButton = IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop<Jalali?>(context, null);
      },
    );
    Widget title = Text(
      "انتخاب تاریخ",
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.w700,
          ),
    );
    Widget datePicker = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        generateCupertinoPicker(
          context: context,
          list: _years,
          initialItem: _years.indexOf(_selectedYear),
          onSelectedItemChanged: (selectedIndex) {
            _selectedYear = _years[selectedIndex];
            int monthLength = getMonthLength(year: _selectedYear, month: _selectedMonth);
            if (monthLength != _currentMonthLength) {
              setState(() {
                _currentMonthLength = monthLength;
                mPrint("monthLength changed to $_currentMonthLength");
                _days = List<int>.generate(_currentMonthLength, (index) => index + 1);
              });
            } else {
              _days = List<int>.generate(_currentMonthLength, (index) => index + 1);
            }
          },
        ),
        generateCupertinoPicker(
          context: context,
          list: _months,
          initialItem: _months.indexOf(getMonthName(monthNumber: _selectedMonth)),
          onSelectedItemChanged: (selectedIndex) {
            _selectedMonth = getMonthNumber(monthName: _months[selectedIndex]);
            int monthLength = getMonthLength(year: _selectedYear, month: _selectedMonth);
            if (monthLength != _currentMonthLength) {
              setState(() {
                _currentMonthLength = monthLength;
                mPrint("monthLength changed to $_currentMonthLength");
                _days = List<int>.generate(_currentMonthLength, (index) => index + 1);
              });
            } else {
              _days = List<int>.generate(_currentMonthLength, (index) => index + 1);
            }
          },
        ),
        generateCupertinoPicker(
          context: context,
          list: _days,
          initialItem: _days.indexOf(_selectedDay),
          onSelectedItemChanged: (selectedIndex) {
            _selectedDay = _days[selectedIndex];
          },
        ),
      ],
    );
    Widget submitButton = ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: getPercentOfWidth(context, 50.0), height: getPercentOfHeight(context, 6.0)),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 6.0,
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        ),
        child: Text(
          "تایید",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: getResponsiveFontSize(context, 14.0), fontWeight: FontWeight.w600, color: Colors.white),
        ),
        onPressed: () {
          Navigator.pop<Jalali?>(context, getSelectedJalaliDate());
        },
      ),
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(width: double.infinity),
              Align(
                alignment: Alignment.topRight,
                child: backButton,
              ),
              SizedBox(height: getPercentOfHeight(context, 2.0)),
              title,
              SizedBox(height: getPercentOfHeight(context, 10.0)),
              datePicker,
              const Spacer(),
              submitButton,
              SizedBox(height: getPercentOfHeight(context, 6.0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget generateCupertinoPicker({required BuildContext context, required List list, required int initialItem, required ValueChanged<int> onSelectedItemChanged}) {
    return SizedBox(
      width: getPercentOfWidth(context, 30.0),
      height: getPercentOfHeight(context, 30.0),
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: initialItem),
        itemExtent: getPercentOfWidth(context, 8.5),
        diameterRatio: 1.0,
        selectionOverlay: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade400, width: 0.5),
              bottom: BorderSide(color: Colors.grey.shade400, width: 0.5),
            ),
          ),
        ),
        onSelectedItemChanged: onSelectedItemChanged,
        children: list.map<Widget>((element) {
          return Center(
            child: Text(element.toString(), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: getResponsiveFontSize(context, 18.0))),
          );
        }).toList(),
      ),
    );
  }

  List<int> generateYearsList(int startYear, int endYear) {
    List<int> years = [];
    for (int i = startYear; i <= endYear; i++) {
      years.add(i);
    }
    return years;
  }

  List<int> generateDaysList(int monthLength) {
    return List<int>.generate(monthLength, (index) => index + 1);
  }

  Jalali getSelectedJalaliDate() {
    return Jalali(_selectedYear, _selectedMonth, _selectedDay);
  }
}

// --------------------------------------------------------------------------------------------------------------------

// showIRDatePickerRoute top function:

Future<Jalali?> showIRDatePickerRoute(BuildContext context, {Jalali? initialDate, int? startYear, int? endYear}) async {
  Jalali? jalaliDate = await Navigator.of(context).push<Jalali?>(
    MaterialPageRoute(
      builder: (BuildContext buildContext) => IRDatePicker(
        initialDate: initialDate,
        startYear: startYear,
        endYear: endYear,
      ),
    ),
  );
  return jalaliDate;
}

// --------------------------------------------------------------------------------------------------------------------
