import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class EntryForm extends StatelessWidget {
  final List<ColumnEntry> columns;

  EntryForm(this.columns);

  @override
  Widget build(BuildContext context) {
    
    return Row(children: columns);
  }
}


class ColumnEntry extends StatelessWidget {
  final String columnHeader;
  final List<RowEntry> rows;

  ColumnEntry(this.columnHeader, this.rows);

  @override
  Widget build(BuildContext context) {
    return Container (
      height: 150.0 * rows.length,
      width: 600,
      padding: EdgeInsets.all(10),
      child : Column(mainAxisSize: MainAxisSize.min, children: rows)
    );
  }

}


class RowEntry extends StatelessWidget {
  final String title, message, type;
  final bool needsValidation;
  final double height, width, padding;

  RowEntry(this.title, this.message, 
            this.type, this.needsValidation,
            this.height, this.width, this.padding);

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

  Container wrapper(Widget widget) {
    return Container (
      padding: EdgeInsets.only(top: padding, bottom: padding),
      height: height,
      width: width,
      child: Row (
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible (
            child: widget,
          )
        ],
      ),
    );
  }

  Container entry(String type) {
    if (type == 'textentry') {
      return wrapper ( 
              TextFormField (
                validator: (value) {
                  if (needsValidation && (value == null || value.isEmpty)) {
                    return 'Please add a value to $title';
                  } return null;
                },
                decoration: InputDecoration (
                  border: OutlineInputBorder(),
                  labelText: title
                ),
              )
      );
    }

    else if (type == 'number') {
      return wrapper (
              TextFormField (
              inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
              validator: (value) {
                if (needsValidation && (value == null || value.isEmpty)) {
                  return 'Please enter a number for $title';
                } return null;
              },
              decoration: InputDecoration (
                border: OutlineInputBorder(),
                labelText: title
              ),
            )
      );
    }
    else if (type == 'string') {
      return wrapper(Text(message));
    }
    else if (type == 'selectbox') {
      List<String> values = message.split(',');
      String dropdownValue = values.first;
      return wrapper(DropdownButton( 
        onChanged: (String? value) {
            dropdownValue = value!;
        },
        value: dropdownValue,
        items: values.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String> (
            value: value,
            child: Text(value),
          );
        }).toList(),
      ));
    }
    else if (type == 'button') {
      return wrapper(
        ElevatedButton (
          onPressed: null,
          child: Text(title)
          ));
    }
    else {
      return Container(child:Row());
    }
  }
}