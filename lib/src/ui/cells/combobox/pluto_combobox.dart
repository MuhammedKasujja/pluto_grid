import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/helper/platform_helper.dart';

import 'combobox_cell.dart';

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

  dynamic selectedOption;
  String? selectedOptionLabel;

  @override
  List<ComboboxOption> items = [];

  @override
  TextInputType get keyboardType => TextInputType.text;

  @override
  List<TextInputFormatter>? get inputFormatters => [];

  ComboboxValue get formattedValue => _convertValue(widget.cell.value);
  // widget.column.formattedValueForDisplayInEditing(widget.cell.value);

  ComboboxValue displayString(dynamic item) {
    return widget.column.type.combobox.convertAndDisplay(item);
  }

  @override
  void initState() {
    super.initState();
    items = [
      ComboboxOption(label: '', value: null),
      ...widget.column.type.combobox.options as List<ComboboxOption>
    ];

    cellFocus = FocusNode(onKeyEvent: _handleOnKey);

    widget.stateManager.setTextEditingController(_textController);

    _textController.text = formattedValue.left ?? '';

    selectedOption = formattedValue.right;

    selectedOptionLabel = formattedValue.label;

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

  ComboboxValue comboboxValue() {
    return ComboboxValue(
      left: _textController.text,
      right: selectedOption,
      label: selectedOptionLabel,
    );
  }

  ComboboxValue _convertValue(dynamic value) {
    if (value == null || value == '') {
      return ComboboxValue.init();
    }
    try {
      final data = jsonDecode(
          widget.column.formattedValueForDisplayInEditing(jsonEncode(value)));
      return ComboboxValue(
        left: data['left'],
        right: data['right'],
        label: data['label'],
      );
    } catch (_) {
      return ComboboxValue.init();
    }
  }

  void _restoreText() {
    if (_cellEditingStatus.isNotChanged) {
      return;
    }

    _textController.text = _initialCellValue.toString();

    widget.stateManager.changeCellValue(
      widget.stateManager.currentCell!,
      comboboxValue().toJson(),
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
        formattedValue.right?.toString() == selectedOption?.toString()) {
      return;
    }

    final value = comboboxValue();
    print('Combobox value changed');
    widget.stateManager.changeCellValue(widget.cell, value.toJson());

    _textController.text = value.left ?? '';

    // setState(() {
    selectedOption = value.right;
    // });

    _textController.text = formattedValue.left ?? '';

    // setState(() {
    selectedOption = formattedValue.right;
    // });

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
      selectedOptionLabel = (items)
          .firstWhereOrNull((opt) => opt.value.toString() == option.toString())
          ?.label;
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
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
            inputDecorationTheme: const InputDecorationTheme(
              contentPadding: EdgeInsets.all(0),
              isDense: true,
            ),
            width: 110,
            dropdownMenuEntries: items
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
      ),
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
