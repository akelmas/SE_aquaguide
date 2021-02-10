import 'package:flutter/material.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/constants.dart';
import 'package:predixinote/types/parameter.dart';

class Editor extends StatefulWidget{
  final Parameter parameter;
  final void Function() onSubmit;

  const Editor({Key key,@required this.parameter, this.onSubmit, }) : super(key: key);

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  @override
  Widget build(BuildContext context) {




    bool hasOptions = widget.parameter.type ==
        "diameter";
    bool isNullValue=widget.parameter.value==null;

    Widget input = (hasOptions)
        ? DropdownButton<double>(
        value: (isNullValue)?null:widget.parameter.value*1.0,
        itemHeight: 60,
        isExpanded: true,
        hint: Text("${widget.parameter.name??"Listeden seçin"}"),
        items: List.generate(DN.length, (index) {
          return DropdownMenuItem(

            child: Text("DN${DN[index].floor()}",style: TextStyle(fontSize: 16),),
            value: DN[index],
          );
        }),

        onChanged: (selected) {
          setState(() {
            widget.parameter.value=selected;
          });
          widget.onSubmit();
        })
        : TextFormField(

        initialValue:(isNullValue)?null: widget.parameter.value
            .toString(),
        autofocus: true,
        keyboardType:
        TextInputType.numberWithOptions(signed: true, decimal: true),
        style: TextStyle(fontSize: 20),
        onChanged: (value) {
          widget.parameter.value = double.parse(value);
          setState(() {

          }
          );
        },
        onEditingComplete: widget.onSubmit,
        decoration: InputDecoration(
          suffix: Text("${units[widget.parameter.type]}"
            ,
            style: TextStyle(fontSize: 20),
          ),
          border: OutlineInputBorder(
              borderSide: BorderSide(
                  )),
          labelText: "${widget.parameter.name}",
          hintStyle: TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
          ),
        ),
        textAlign: TextAlign.end
    );



    return Container(
      padding: EdgeInsets.all(10),
      child:  SingleChildScrollView(
          child: input
      ),
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    DatabaseService().setParameter(widget.parameter);
  }
}