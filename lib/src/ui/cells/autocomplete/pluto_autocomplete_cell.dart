import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'autocomplete_cell.dart';

class PlutoAutoCompleteCell extends StatefulWidget implements AutoCompleteCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoAutoCompleteCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  PlutoAutoCompleteCellState createState() => PlutoAutoCompleteCellState();
}

class PlutoAutoCompleteCellState extends State<PlutoAutoCompleteCell>
    with AutoCompleteCellState<PlutoAutoCompleteCell> {
  @override
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    items = widget.column.type.autocomplete.options;
  }
}
