import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'tree.dart';

final http.Client client = http.Client();
// better than http.get() if multiple requests to the same server

// If you connect the Android emulator to the webserver listening to localhost:8080
const String baseUrl = "https://a0c8-158-109-31-4.eu.ngrok.io";

// If instead you want to use a real phone, you need ngrok to redirect
// localhost:8080 to some temporal Url that ngrok.com provides for free: run
// "ngrok http 8080" and replace the address in the sentence below
//const String baseUrl = "http://59c1d5a02fa5.ngrok.io";
// in linux I've installed ngrok with "sudo npm install ngrok -g". On linux, windows,
// mac download it from https://ngrok.com/. More on this here
// https://medium.com/@vnbnews.vn/how-can-i-access-my-localhost-from-my-real-android-ios-device-d037fd192cdd

Future<Tree> getTree(int id, {String tag = 'null'}) async {
  if (tag != 'null') {
    return searchByTag(tag);
  } else {
    String uri = "$baseUrl/get_tree?$id";
    final response = await client.get(Uri.parse(uri)); // updated 16-dec-2022
    // response is NOT a Future because of await but since getTree() is async,
    // execution continues (leaves this function) until response is available,
    // and then we come back here
    if (response.statusCode == 200) {
      print("statusCode=$response.statusCode");
      print(response.body);
      // If the server did return a 200 OK response, then parse the JSON.
      Map<String, dynamic> decoded = convert.jsonDecode(response.body);
      return Tree(decoded);
    } else {
      // If the server did not return a 200 OK response, then throw an exception.
      print("statusCode=$response.statusCode");
      throw Exception('Failed to get children');
    }
  }
}

void manageResponse(response) {
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
  } else {
    print("statusCode=$response.statusCode");
    throw Exception('Failed to get children');
  }
}

Future<Tree> searchByTag(String tag) async {
  String uri = "$baseUrl/searchByTag?$tag";
  final response = await client.get(Uri.parse(uri));
  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
    Map<String, dynamic> decoded = convert.jsonDecode(response.body);
    return Tree(decoded);
  } else {
    print("statusCode=$response.statusCode");
    throw Exception('Failed to get children');
  }
}

Future<void> start(int id) async {
  String uri = "$baseUrl/start?$id";
  final response = await client.get(Uri.parse(uri));
  manageResponse(response);
}

Future<void> stop(int id) async {
  String uri = "$baseUrl/stop?$id";
  final response = await client.get(Uri.parse(uri));
  manageResponse(response);
}

Future<void> addActivity(Map<String, dynamic> newActivity) async {
  int id = newActivity['id'];
  String name = newActivity['name'];
  int father = newActivity['father'];
  String type = newActivity['class'];
  List<String> tags = newActivity['tags'];

  var uri = Uri.parse("$baseUrl/add?$name&$father&$type&$tags&$id");
  final response = await client.get(uri);

  if (response.statusCode == 200) {
    print("statusCode=$response.statusCode");
  } else {
    print("statusCode=$response.statusCode");
    throw Exception('Failed to get children');
  }
}
