import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "../persistence/my_database.dart";

class MyHTTPRequests {
  final String url_create_idea =
      "https://aracomppitch.firebaseio.com/ideia.json";
  final String url_make_wish = "https://aracomppitch.firebaseio.com/wish.json";

  void sendIdeia(String name, String ideiaName, String ideiaDescription) {
    Map<String, dynamic> ideia = {
      "name": name,
      "ideiaName": ideiaName,
      "ideiaDescription": ideiaDescription,
      "wishes": 0
    };

    http
        .post(url_create_idea, body: json.encode(ideia))
        .then((http.Response response) {
      print(response.statusCode);
      print(response.body);

      Map<String, dynamic> newIdeaMap = json.decode(response.body);
      var db = MyDatabase();
      db.saveIdea(newIdeaMap["name"]);
    });
  }

  Future<Map<String, dynamic>> listIdeias() async {
    var response = await http.get(url_create_idea);

    Map<String, dynamic> ideiasMap = json.decode(response.body);

    return ideiasMap;
  }

  Future<bool> makeAWish(String key) async {
    Map<String, String> aWish = {"idea": key};
    var response = await http.post(url_make_wish, body: json.encode(aWish));

    if (response.statusCode == 200)
      return true;
    else
      return false;
  }

  void deleteIdea(String key) {
    print("Deleting from Firebase idea: " + key);
    http
        .delete("https://aracomppitch.firebaseio.com/ideia/${key}.json")
        .then((http.Response response) {
      print(response.statusCode);
    });
  }
}
