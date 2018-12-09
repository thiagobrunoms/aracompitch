import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import "../networking/http_requests.dart";
import "../persistence/my_database.dart";

class IdeiaListPage extends StatefulWidget {
  Map<String, dynamic> ideiasMap = {};
  List<String> ideiasKeys = [];
  List<Map> myIdeasList = [];
  var db;

  @override
  State<StatefulWidget> createState() {
    return IdeiaListPageState();
  }
}

class IdeiaListPageState extends State<IdeiaListPage> {
  final MyHTTPRequests httpRequests = MyHTTPRequests();

  @override
  void initState() {
    super.initState();

    var db = MyDatabase();
    Future<List<Map>> myIdeasFuture = db.getMyIdeas();
    myIdeasFuture.then((List<Map> myIdeas) {
      widget.myIdeasList = myIdeas;
    });

    Future<Map<String, dynamic>> response = httpRequests.listIdeias();
    response.then((Map<String, dynamic> ideiasMap) {
      if (ideiasMap.length != widget.ideiasMap.length) {
        setState(() {
          widget.ideiasKeys = ideiasMap.keys.toList();
          widget.ideiasMap = ideiasMap;

          widget.ideiasKeys.forEach((key) {
            widget.ideiasMap[key]["iwished"] = false;
            print(widget.ideiasMap[key]);
          });
        });
      }
    });
  }

  void makeWish(String key) {
    setState(() {
      widget.ideiasMap[key]["iwished"] = !widget.ideiasMap[key]["iwished"];
      print(widget.ideiasMap[key]);
    });

    if (!widget.ideiasMap[key]["iwished"]) {
      Future<bool> response = httpRequests.makeAWish(key);
      response.then((bool result) {
        if (result)
          print("Votação feita com sucesso!");
        else
          print("Algum problema na votação!");
      });
    } else
      print("Já votou essa");
  }

  bool checkIdea(String key) {
    for (int i = 0; i < widget.myIdeasList.length; i++) {
      Map anIdea = widget.myIdeasList[i]; //widget.myIdeasList[index]["ideaId"]
      if (anIdea["ideaId"] == key) return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // return localIdeiasMap.keys.length == 0 ? Text("Nada") : Text(id);
    return ListView.builder(
      itemCount: widget.ideiasKeys.length,
      itemBuilder: (BuildContext context, int index) {
        Map<String, dynamic> idea = widget.ideiasMap[widget.ideiasKeys[index]];

        return Card(
          child: Column(
            children: <Widget>[
              ListTile(
                key: Key(widget.ideiasKeys[index]),
                title: Text(idea["ideiaName"]),
                subtitle: Text(idea["ideiaDescription"] +
                    " - Votos: " +
                    idea["wishes"].toString()),
                leading: Icon(Icons.lightbulb_outline),
              ),
              ButtonTheme.bar(
                child: ButtonBar(
                  children: <Widget>[
                    IconButton(
                      icon: idea["iwished"]
                          ? Icon(Icons.favorite)
                          : Icon(Icons.favorite_border),
                      onPressed: () {
                        makeWish(widget.ideiasKeys[index]);
                      },
                    ),
                    IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: checkIdea(widget.ideiasKeys[index])
                            ? () {
                                print("deleting");
                                setState(() {
                                  widget.ideiasMap.remove(widget.ideiasKeys[
                                      index]); //= Map.from(newIdeiasMap);
                                  widget.ideiasKeys.remove(widget.ideiasKeys[
                                      index]); //= List.from(newIdeiasMap.keys);
                                });
                                // makeWish(widget.ideiasKeys[index]);
                              }
                            : null)
                  ],
                ),
              )
            ],
          ),
        );

        // ListTile(
        //     key: Key(widget.ideiasKeys[index]),
        //     title: Text(idea["ideiaName"]),
        //     subtitle: Text(idea["ideiaDescription"] +
        //         " - Votos: " +
        //         idea["wishes"].toString()),
        //     leading: Icon(Icons.lightbulb_outline),
        //     trailing: IconButton(
        //       icon: idea["iwished"]
        //           ? Icon(Icons.favorite)
        //           : Icon(Icons.favorite_border),
        //       onPressed: () {
        //         makeWish(widget.ideiasKeys[index]);
        //       },
        //     ));

        // return Dismissible(
        //   key: Key(widget.ideiasKeys[index]),
        //   onDismissed: (DismissDirection direction) {
        //     if (direction == DismissDirection.endToStart) {
        //       print("Deleting " + widget.ideiasKeys[index]);
        //       removeMyIdea(widget.ideiasKeys[index]);
        //     }
        //   },
        //   background: Container(
        //     color: Colors.red,
        //   ),
        //   child: ListTile(
        //       key: Key(widget.ideiasKeys[index]),
        //       title: Text(idea["ideiaName"]),
        //       subtitle: Text(idea["ideiaDescription"] +
        //           " - Votos: " +
        //           idea["wishes"].toString()),
        //       leading: Icon(Icons.lightbulb_outline),
        //       trailing: IconButton(
        //         icon: idea["iwished"]
        //             ? Icon(Icons.favorite)
        //             : Icon(Icons.favorite_border),
        //         onPressed: () {
        //           makeWish(widget.ideiasKeys[index]);
        //         },
        //       )),
        // );
      },
    );
  }
}
