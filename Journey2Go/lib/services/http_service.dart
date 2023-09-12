import 'package:http/http.dart' as http;
const String baseUrl = 'https://www.holidify.com/places/kuala-lumpur/sightseeing-and-things-to-do.html';

class HttpService{
  static Future<String?> get()async{
    try{
      final response  = await http.get(Uri.parse(baseUrl));
      if(response.statusCode == 200) return response.body;
    }catch (e){
      print('HttpService $e');
    }
    return null;
  }
}