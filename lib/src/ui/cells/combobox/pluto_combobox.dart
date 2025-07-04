import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/helper/platform_helper.dart';

import 'combobox_cell.dart';

class ComboboxValue {
  final String? left;
  final dynamic right;

  ComboboxValue({required this.left, required this.right});

  Map<String, dynamic> toJson() {
    return {"left": left, "right": right};
  }

  factory ComboboxValue.fromJson(Map<String, dynamic> json) {
    return ComboboxValue(
      left: json['left'],
      right: json['right'],
    );
  }

  @override
  String toString(){
    return toString().toString();
  }
}

class PlutoComboboxCell<T extends Object> extends StatefulWidget {
  final PlutoGridStateManager stateManager;

  final PlutoCell cell;

  final PlutoColumn column;

  final PlutoRow row;

  const PlutoComboboxCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  State<PlutoComboboxCell<T>> createState() => _PlutoComboboxCellState();
}

class _PlutoComboboxCellState<T extends Object>
    extends State<PlutoComboboxCell<T>> implements ComboboxTextFieldProps<T> {
  dynamic _initialCellValue;

  final _textController = TextEditingController();

  final PlutoDebounceByHashCode _debounce = PlutoDebounceByHashCode();

  late final FocusNode cellFocus;

  late _CellEditingStatus _cellEditingStatus;

  String? selectedOption;

  @override
  List<T> items = [];

  @override
  TextInputType get keyboardType => TextInputType.text;

  @override
  List<TextInputFormatter>? get inputFormatters => [];

  ComboboxValue get formattedValue => _convertValue(widget.cell.value);
  // widget.column.formattedValueForDisplayInEditing(widget.cell.value);

  String displayString(T item) {
    return widget.column.type.combobox.convertAndDisplay(item as dynamic);
  }

  @override
  void initState() {
    super.initState();
    items = widget.column.type.combobox.options as List<T>;

    cellFocus = FocusNode(onKeyEvent: _handleOnKey);

    widget.stateManager.setTextEditingController(_textController);

    _textController.text = formattedValue.left ?? '';

    selectedOption = formattedValue.right;

    _initialCellValue = formattedValue.toJson();

    _cellEditingStatus = _CellEditingStatus.init;

    _textController.addListener(() {
      _handleOnChanged(_textController.text.toString());
    });
  }

  @override
  void dispose() {
    /**
     * Saves the changed value when moving a cell while text is being input.
     * if user do not press enter key, onEditingComplete is not called and the value is not saved.
     */
    if (_cellEditingStatus.isChanged) {
      _changeValue();
    }

    if (!widget.stateManager.isEditing ||
        widget.stateManager.currentColumn?.enableEditingMode != true) {
      widget.stateManager.setTextEditingController(null);
    }

    _debounce.dispose();

    _textController.dispose();

    cellFocus.dispose();

    super.dispose();
  }

  Map<String, dynamic> _getValue() {
    return {
      "left": _textController.value,
      "right": selectedOption,
    };
  }

  ComboboxValue comboboxValue() {
    return ComboboxValue(
      left: _textController.text,
      right: selectedOption,
    );
  }

  ComboboxValue _convertValue(dynamic value) {
    final data = jsonDecode(
        widget.column.formattedValueForDisplayInEditing(jsonEncode(value)));
    return ComboboxValue(left: data['left'], right: data['right']);
  }

  void _restoreText() {
    if (_cellEditingStatus.isNotChanged) {
      return;
    }

    _textController.text = _initialCellValue.toString();

    widget.stateManager.changeCellValue(
      widget.stateManager.currentCell!,
      _getValue(),
      notify: false,
    );
  }

  bool _moveHorizontal(PlutoKeyManagerEvent keyManager) {
    if (!keyManager.isHorizontal) {
      return false;
    }

    if (widget.column.readOnly == true) {
      return true;
    }

    final selection = _textController.selection;

    if (selection.baseOffset != selection.extentOffset) {
      return false;
    }

    if (selection.baseOffset == 0 && keyManager.isLeft) {
      return true;
    }

    final textLength = _textController.text.length;

    if (selection.baseOffset == textLength && keyManager.isRight) {
      return true;
    }

    return false;
  }

  void _changeValue() {
    if ((formattedValue.left ?? '') == _textController.text &&
        formattedValue.left == selectedOption) {
      return;
    }

    final value = comboboxValue();

    widget.stateManager.changeCellValue(widget.cell, value.toJson());

    _textController.text = value.left ?? '';

    setState(() {
      selectedOption = value.right;
    });

    _textController.text = formattedValue.left ?? '';

    setState(() {
      selectedOption = formattedValue.right;
    });

    _initialCellValue = formattedValue.toJson();

    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );

    _cellEditingStatus = _CellEditingStatus.updated;
  }

  void _handleOnChanged(String value) {
    _cellEditingStatus = formattedValue.left != value.toString()
        ? _CellEditingStatus.changed
        : _initialCellValue.toString() == value.toString()
            ? _CellEditingStatus.init
            : _CellEditingStatus.updated;
  }

  void _handleOnComplete() {
    final old = _textController.text;

    _changeValue();

    _handleOnChanged(old);

    PlatformHelper.onMobile(() {
      widget.stateManager.setKeepFocus(false);
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _onItemSelected(option) {
    setState(() {
      selectedOption = option;
    });
    _changeValue();
  }

  KeyEventResult _handleOnKey(FocusNode node, KeyEvent event) {
    var keyManager = PlutoKeyManagerEvent(
      focusNode: node,
      event: event,
    );

    if (keyManager.isKeyUpEvent) {
      return KeyEventResult.handled;
    }

    final skip = !(keyManager.isVertical ||
        _moveHorizontal(keyManager) ||
        keyManager.isEsc ||
        keyManager.isTab ||
        keyManager.isF3 ||
        keyManager.isEnter);

    if (skip) {
      return widget.stateManager.keyManager!.eventResult.skip(
        KeyEventResult.ignored,
      );
    }

    if (_debounce.isDebounced(
      hashCode: _textController.text.hashCode,
      ignore: !kIsWeb,
    )) {
      return KeyEventResult.handled;
    }

    if (keyManager.isEnter) {
      _handleOnComplete();
      return KeyEventResult.ignored;
    }

    if (keyManager.isEsc) {
      _restoreText();
    }

    widget.stateManager.keyManager!.subject.add(keyManager);

    return KeyEventResult.handled;
  }

  void _handleOnTap() {
    widget.stateManager.setKeepFocus(true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stateManager.keepFocus) {
      cellFocus.requestFocus();
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            focusNode: cellFocus,
            controller: _textController,
            readOnly: widget.column.checkReadOnly(widget.row, widget.cell),
            onChanged: _handleOnChanged,
            onEditingComplete: _handleOnComplete,
            onSubmitted: (_) => _handleOnComplete(),
            onTap: _handleOnTap,
            style: widget.stateManager.configuration.style.cellTextStyle,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            maxLines: 1,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textAlignVertical: TextAlignVertical.center,
            textAlign: widget.column.textAlign.value,
          ),
        ),
        DropdownMenu(
          initialSelection: selectedOption,
          enableSearch: false,
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.all(0),
            isDense: true,
          ),
          width: 110,
          dropdownMenuEntries: (items as List<ComboboxOption>)
              .map(
                (opt) => DropdownMenuEntry(
                  value: opt.value,
                  label: opt.label,
                ),
              )
              .toList(),
          onSelected: _onItemSelected,
        ),
      ],
    );
  }

  void handleSelected() {
    print(
        'selectedOption === ${widget.column.type.combobox.convertAndDisplay(selectedOption)}');
    widget.stateManager.changeCellValue(widget.cell, selectedOption);
    widget.stateManager.setKeepFocus(false);
    // cellFocus.unfocus();

    _textController.text = widget.column.formattedValueForDisplayInEditing(
      widget.cell.value,
    );

    if (!widget.stateManager.configuration.enableMoveDownAfterSelecting) {
      cellFocus.requestFocus();
    }
  }
}

enum _CellEditingStatus {
  init,
  changed,
  updated;

  bool get isNotChanged {
    return _CellEditingStatus.changed != this;
  }

  bool get isChanged {
    return _CellEditingStatus.changed == this;
  }

  bool get isUpdated {
    return _CellEditingStatus.updated == this;
  }
}
