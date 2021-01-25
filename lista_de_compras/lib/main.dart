import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:flutter.dev/docs/testing';

// https://pub.dev/packages/path_provider/install
void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();
  List _toDoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lasRemovedPos;

  @override // Control + Letra "O"
  void initState() {
    super.initState();

    _readData().then((data){
    setState(() {
      _toDoList = json.decode(data);
       });
    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoController.text;
      _toDoController.text = ""; // para resetar o texto após inserido
      newToDo["OK"] = false;
      _toDoList.add(newToDo);
      _saveData();
    });
  }

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDoList.sort((a, b){
        if(a["OK"] && !b["OK"]) return 1;
        else if(!a["OK"] && b["OK"]) return -1;
        else return 0;
      });
    _saveData();
    });
  return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lista de Compras"
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(7.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget> [
              Expanded(
                  child:  TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                        labelText: "Novo Item",
                        labelStyle: TextStyle(color: Colors.green, fontSize: 30.0)
                    ),
                  )
              ),
                RaisedButton(
                  color: Colors.green,
                  child: Text("+",
                  //textColor: Colors.white,
                  style: TextStyle(color: Colors.white, fontSize: 40.0)),
                  onPressed: _addToDo,
                )
              ],
            ),
          ),
          //---------------------------------------------Lista---------------------------------------------
          Expanded(
            child: RefreshIndicator(onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: _toDoList.length,
                  itemBuilder: buildItem),),
          )
        ],
      ),
    );
  }

 Widget buildItem(BuildContext context, int index){
   return Dismissible(
     key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
     background: Container(
       color: Colors.red,
       child: Align(
         alignment: Alignment(-0.9, 0.0),
         child: Icon(Icons.delete, color: Colors.white),
       ),
     ),
     direction: DismissDirection.startToEnd,
     child: CheckboxListTile(
       title: Text(_toDoList[index]["title"]),
       value: _toDoList[index]["OK"],
       secondary: CircleAvatar(
         child: Icon(_toDoList[index]["OK"] ?
         Icons.check: Icons.error),
         //  Icons.check, color: Colors.white: Icons.error, color: Colors.black),
       ),
       onChanged: (c){
         setState(() {
           _toDoList[index]["OK"] = c;
           _saveData();
         });
       },
     ),
     onDismissed: (direction){
       setState(() {
         _lastRemoved = Map.from(_toDoList[index]);
         _lasRemovedPos = index;
         _toDoList.removeAt(index);
         _saveData();
         final snack = SnackBar(
             content: Text("Tarefa ${_lastRemoved["title"]} Desfeita!"),
              action: SnackBarAction(label: "Desfazer",
              onPressed: (){
               setState(() {
                 _toDoList.insert(_lasRemovedPos, _lastRemoved);
                 _saveData();
               });
              }),
           duration: Duration(seconds: 10),
         );
         Scaffold.of(context).showSnackBar(snack);
       });
     },
   );
 }

/*
*/
// função para obter o arquivo
  Future<File> _getFile() async {
    // Control + Enter import Libraries io
    final directory =
        await getApplicationDocumentsDirectory(); // local onde serão armazenados arquivos
    return File(
        "${directory.path}/data.json"); // o nome data pode ser de livre escolha, comando para abrir arquivo
  }
//Função para salvar algum dado o arquivo
  Future<File> _saveData() async {
    String data = json.encode(
        _toDoList); // alt + enter import Library dart.convert, transformando a lista em Json e armazenando e uma string
    final file = await _getFile();
    return file.writeAsString(data);
  }
// função para ler os dados no arquivo.
  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
------------- // ------------------------
