import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/helper/platform_helper.dart';

abstract class AutoCompleteCell extends StatefulWidget {
  final PlutoGridStateManager stateManager;

  final PlutoCell cell;

  final PlutoColumn column;

  final PlutoRow row;

  const AutoCompleteCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });
}

abstract class AutoCompleteTextFieldProps {
  TextInputType get keyboardType;

  List<TextInputFormatter>? get inputFormatters;

  List<dynamic> get items;
}

mixin AutoCompleteCellState<T extends AutoCompleteCell> on State<T>
    implements AutoCompleteTextFieldProps {
  dynamic _initialCellValue;

  final _textController = TextEditingController();

  final PlutoDebounceByHashCode _debounce = PlutoDebounceByHashCode();

  late final FocusNode cellFocus;

  late _CellEditingStatus _cellEditingStatus;

  @override
  TextInputType get keyboardType => TextInputType.text;

  @override
  List<TextInputFormatter>? get inputFormatters => [];

  String get formattedValue =>
      widget.column.formattedValueForDisplayInEditing(widget.cell.value);

  @override
  void initState() {
    super.initState();

    cellFocus = FocusNode(onKeyEvent: _handleOnKey);

    widget.stateManager.setTextEditingController(_textController);

    _textController.text = formattedValue;

    _initialCellValue = _textController.text;

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

  void _restoreText() {
    if (_cellEditingStatus.isNotChanged) {
      return;
    }

    _textController.text = _initialCellValue.toString();

    widget.stateManager.changeCellValue(
      widget.stateManager.currentCell!,
      _initialCellValue,
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
    if (formattedValue == _textController.text) {
      return;
    }

    widget.stateManager.changeCellValue(widget.cell, _textController.text);

    _textController.text = formattedValue;

    _initialCellValue = _textController.text;

    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );

    _cellEditingStatus = _CellEditingStatus.updated;
  }

  void _handleOnChanged(String value) {
    _cellEditingStatus = formattedValue != value.toString()
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
    // print(items);
    if (widget.stateManager.keepFocus) {
      cellFocus.requestFocus();
    }

    return RawAutocomplete<String>(
      key: ValueKey('${widget.cell.column.hashCode}'),
      focusNode: cellFocus,
      textEditingController: _textController,
      optionsBuilder: (TextEditingValue textEditingValue) {
        final options =
            items.map((item) => item.toString()).toList().where((ele) {
          final filter = textEditingValue.text.toLowerCase();
          final productKey = ele.toLowerCase();

          return productKey.contains(filter);
        }).toList();

        return options;
      },
      displayStringForOption: (item) => item,
      onSelected: (ele) {
        handleSelected(ele);
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return TextField(
          key: ValueKey('${widget.cell.column.hashCode}'),
          focusNode: focusNode,
          controller: textEditingController,
          readOnly: widget.column.checkReadOnly(widget.row, widget.cell),
          onTap: _handleOnTap,
          style: widget.stateManager.configuration.style.cellTextStyle,
          decoration: InputDecoration(
            labelText: '',
            hintText: '',
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.clear,
                size: 15,
              ),
              onPressed: () {
                textEditingController.text = '';
                setState(() {
                  // _showClear = false;
                });
              },
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.zero,
          ),
          // autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: TextInputType.text,
          expands: false,
          autocorrect: false,
          maxLines: 1,
          textInputAction: TextInputAction.newline,
          onChanged: _handleOnChanged,
          onSubmitted: (value) {
            onFieldSubmitted();
          },
          enabled: true,
          textAlignVertical: TextAlignVertical.center,
          textAlign: widget.column.textAlign.value,
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        final highlightedIndex = AutocompleteHighlightedOption.of(context);
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: Container(
              color: Theme.of(context).cardColor,
              width: widget.column.width,
              height: 200,
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                itemCount: options.length,
                shrinkWrap: true,
                padding: const EdgeInsets.all(0),
                itemBuilder: (BuildContext context, int index) {
                  final entity = options.elementAt(index);
                  return Container(
                    color: highlightedIndex == index
                        ? Colors.blue.shade100
                        : Colors.transparent,
                    child: InkWell(
                      child: Text(entity),
                      onTap: () {
                        onSelected(entity);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void handleSelected(dynamic value) {
    // print("cell selected $value");
    widget.stateManager.changeCellValue(widget.cell, value);
    widget.stateManager.setKeepFocus(false);
    // cellFocus.unfocus();

    // _textController.text = widget.column.formattedValueForDisplayInEditing(
    //   widget.cell.value,
    // );

    // if (!widget.stateManager.configuration.enableMoveDownAfterSelecting) {
    //   cellFocus.requestFocus();
    // }
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
