import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import "../networking/http_requests.dart";
import "../persistence/my_database.dart";

class IdeiaListPage extends StatefulWidget {
  Map<String, dynamic> ideiasMap = {};
  List<String> ideiasKeys = [];
  List<Map> localIdeasList = [];
  List<Map> localWishesList = [];

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

    widget.db = MyDatabase();
    widget.db.getMyWishes().then((List<Map> myWishesFromDb) {
      //myWishesFromDB: {id: 1, wishId: -LTLQ3GABedNXNKyNwRL, ideaId: -LTGL-0rVGfT1IBUIyym}
      setState(() {
        widget.localWishesList = List.from(myWishesFromDb);
      });
      for (var i = 0; i < myWishesFromDb.length; i++) {
        print(myWishesFromDb[i]);
      }
    });

    Future<List<Map>> myIdeasFuture = widget.db.getMyIdeas();
    myIdeasFuture.then((List<Map> myIdeasFromDb) {
      widget.localIdeasList = myIdeasFromDb;
    });

    Future<Map<String, dynamic>> response = httpRequests.listIdeias();
    response.then((Map<String, dynamic> ideiasMap) {
      if (ideiasMap.length != widget.ideiasMap.length) {
        setState(() {
          widget.ideiasKeys = ideiasMap.keys.toList();
          widget.ideiasMap = ideiasMap;
          print("Ideas Keys and Ideas Map from Firebase: ");
          print(widget.ideiasKeys);
          print(widget.ideiasMap);
          widget.ideiasKeys.forEach((key) {
            widget.ideiasMap[key]["iwished"] = false; //primeiro cria o campo
            for (var i = 0; i < widget.localWishesList.length; i++) {
              Map aWish = widget.localWishesList[i];
              //depois atualiza o campo, pois não faz parte do firebase
              if (aWish["ideaId"] == key) {
                widget.ideiasMap[key]["iwished"] = true;
                break;
              } else
                widget.ideiasMap[key]["iwished"] = false;
            }

            print(widget.ideiasMap[key]);
          });
        });
      }
    });
  }

  void removeWish(String key) {
    print("Removendo like da ideia ${key}");

    setState(() {
      widget.ideiasMap[key]["iwished"] = false;
      print(widget.ideiasMap[key]);
    });

    for (int i = 0; i < widget.localWishesList.length; i++) {
      Map aWish = widget.localWishesList[i];
      if (aWish["ideaId"] == key) {
        widget.db.deleteAWish(aWish["wishId"]);
        httpRequests.deleteWish(aWish["wishId"]);
      }
    }
  }

  void makeWish(String key) {
    print("Realizando voto na ideia ${key}");
    setState(() {
      widget.ideiasMap[key]["iwished"] = true;
      print(widget.ideiasMap[key]);
    });

    bool found = false;
    for (int i = 0; i < widget.localWishesList.length; i++) {
      Map aWish = widget.localWishesList[i];
      if (aWish["ideaId"] == key) {
        found = true;
      }
    }

    if (!found) {
      print("Não encontrou voto para ideaId ${key}");
      Future<Map<String, dynamic>> response = httpRequests.makeAWish(key);
      response.then((Map<String, dynamic> theWish) {
        print("The wish confirmation from firabase: ");
        print(theWish);
        print("A wish para a key ${key}");
        Future newWishFuture = widget.db.saveAWish(theWish["name"], key);
        newWishFuture.then((var result) {
          print("Resultado do bd: ");
          print(result);

          Map<String, dynamic> newLocalWish = {
            "id": result,
            "wishId": theWish["name"],
            "ideaId": key
          };

          setState(() {
            widget.localWishesList.add(newLocalWish);
            print("nova lista de likes local");
            print(widget.localWishesList);
          });
        });

        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Voto contabilizado com sucesso!"),
        ));
      });
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Voto cancelado!"),
      ));
    }
  }

  bool checkIdea(String key) {
    for (int i = 0; i < widget.localIdeasList.length; i++) {
      Map anIdea =
          widget.localIdeasList[i]; //widget.myIdeasList[index]["ideaId"]
      if (anIdea["ideaId"] == key) return true;
    }

    return false;
  }

  void deleteIdea(String key) {
    widget.db.deleteIdea(key);

    httpRequests.deleteIdea(key);

    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text("Ideia removida com sucesso!")));
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
                        if (!idea["iwished"])
                          makeWish(widget.ideiasKeys[index]);
                        else
                          removeWish(widget.ideiasKeys[index]);
                      },
                    ),
                    IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: checkIdea(widget.ideiasKeys[index])
                            ? () {
                                print("deleting");
                                deleteIdea(widget.ideiasKeys[index]);
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
      },
    );
  }
}
