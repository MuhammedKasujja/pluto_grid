import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'combobox_cell.dart';

class PlutoComboboxWidgetCell extends StatefulWidget implements ComboboxCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoComboboxWidgetCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  PlutoComboboxWidgetCellState createState() => PlutoComboboxWidgetCellState();
}

class PlutoComboboxWidgetCellState extends State<PlutoComboboxWidgetCell>
    with ComboboxCellState<PlutoComboboxWidgetCell> {
  @override
  List<ComboboxOption> items = [];

  @override
  void initState() {
    super.initState();
    items = widget.column.type.combobox.options as List<ComboboxOption>;
  }
}
