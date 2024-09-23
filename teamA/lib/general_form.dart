import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class EntryForm extends StatelessWidget {
  final List<ColumnEntry> columns;

  EntryForm(this.columns);

  @override
  Widget build(BuildContext context) {
    
    throw UnimplementedError();
  }
}


class ColumnEntry extends StatelessWidget {
  final String columnHeader;
  final List<RowEntry> rows;

  ColumnEntry(this.columnHeader, this.rows);

  @override
  Widget build(BuildContext context) {
    resizeChildren(rows, MediaQuery.sizeOf(context).height, MediaQuery.sizeOf(context).width);
    return Column (mainAxisSize: MainAxisSize.min, children: rows);
  }

  void resizeChildren(List<RowEntry> rows, double height, double width) {
    for (final row in rows) {
      row.height=100;
      row.width=10;
    }
  }
}


class RowEntry extends StatelessWidget {
  final String title, validationMessage, type;
  final bool needsValidation;
  double height=0, width=0, padding=0;

  RowEntry(this.title, this.validationMessage, this.type, this.needsValidation);

  @override
  Widget build(BuildContext context) {
    return Flexible (
            child: Row (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible (
                  child: entry(type)
                ),
              ],
            ),
          );
  }

  Container entry(String type) {
    if (type == 'string') {
      return Container (
        padding: EdgeInsets.only(top: padding, bottom: padding),
        height: height,
        width: width,
        child: Row (
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible (
            child: TextFormField (
              validator: (value) {
                if (needsValidation && (value == null || value.isEmpty)) {
                  return validationMessage;
                } return null;
              },
              decoration: InputDecoration (
                border: OutlineInputBorder(),
                labelText: title
              ),
            )
          )
        ]
      )
      );
    }

    else if (type == 'number') {
      return Container (
        padding: EdgeInsets.only(top: padding, bottom: padding),
        child: Row (
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible (
              child: TextFormField (
                inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                validator: (value) {
                  if (needsValidation && (value == null || value.isEmpty)) {
                    return 'Please enter a number';
                  } return null;
                },
                decoration: InputDecoration (
                  border: OutlineInputBorder(),
                  labelText: title
                ),
              )
            )
          ]
        )
      );
    }
    else {
      return Container(child:Row());
    }
  }
}