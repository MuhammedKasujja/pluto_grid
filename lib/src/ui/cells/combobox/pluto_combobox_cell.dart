import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'combobox_cell.dart';

class PlutoComboboxCell extends StatefulWidget implements ComboboxCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoComboboxCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  PlutoComboboxCellState createState() => PlutoComboboxCellState();
}

class PlutoComboboxCellState extends State<PlutoComboboxCell>
    with ComboboxCellState<PlutoComboboxCell> {
  @override
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    items = widget.column.type.autocomplete.options;
  }
}
