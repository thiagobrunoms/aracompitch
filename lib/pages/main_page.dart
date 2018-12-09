import 'package:flutter/material.dart';
import "./create_pitch.dart";
import "./list_ideias.dart";

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Aracomp - Pitch de Ideias"),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.create),
                  text: "Cadastrar",
                ),
                Tab(
                  icon: Icon(Icons.list),
                  text: "Listar Ideias",
                )
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[CreatePitchPage(), IdeiaListPage()],
          ),
        ));
  }
}
