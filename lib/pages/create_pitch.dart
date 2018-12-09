import "package:flutter/material.dart";
import "../networking/http_requests.dart";

class CreatePitchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CreatePitchPageState();
  }
}

class CreatePitchPageState extends State<CreatePitchPage> {
  String name;
  String ideiaName;
  String ideiaDescription;

  final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ideiaNameController = TextEditingController();
  final TextEditingController _ideiaDescriptionController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Form(
            key: _keyForm,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      labelText: "Nome Completo",
                      hintText: "Nome e Sobrenome",
                      icon: Icon(Icons.account_circle)),
                  validator: (String value) {
                    if (value.isEmpty)
                      return "Nome completo deve ser preenchido!";
                  },
                  onSaved: (String value) {
                    name = value;
                  },
                ),
                TextFormField(
                  controller: _ideiaNameController,
                  decoration: InputDecoration(
                      labelText: "Nome do Ideia",
                      icon: Icon(Icons.lightbulb_outline)),
                  validator: (String value) {
                    if (value.isEmpty) return "A ideia deve ter um nome";
                  },
                  onSaved: (String value) {
                    ideiaName = value;
                  },
                ),
                TextFormField(
                  controller: _ideiaDescriptionController,
                  decoration: InputDecoration(
                    labelText: "Descrição da Ideia",
                    icon: Icon(Icons.description),
                  ),
                  validator: (String value) {
                    if (value.isEmpty) return "A ideia deve ter uma descrição";
                  },
                  onSaved: (String value) {
                    ideiaDescription = value;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                RaisedButton(
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    child: Text("Enviar Ideia"),
                    onPressed: () {
                      if (!_keyForm.currentState.validate()) return;
                      _keyForm.currentState.save();

                      print(
                          "Enviando projeto: ${name}, nome da ideia: ${ideiaName}, descrição: ${ideiaDescription}");
                      MyHTTPRequests httpRequest = MyHTTPRequests();
                      httpRequest.sendIdeia(name, ideiaName, ideiaDescription);

                      _nameController.clear();
                      _ideiaNameController.clear();
                      _ideiaDescriptionController.clear();
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)))
              ],
            )));
  }
}
