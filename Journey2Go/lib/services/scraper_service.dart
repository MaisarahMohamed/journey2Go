import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:journey2go/models/package_model.dart';

class ScraperService{
  static List<PackageModel> run(String html){
    try{
      final soup = BeautifulSoup(html);
      final items = soup.findAll('div', class_: 'card content-card');
      List<PackageModel> packages = [];
      for(var item in items){
        final dest = item.find('h3', class_: 'card-heading')?.text??'';
        final desc = item.find('p', class_: 'card-text')?.text??'';
        final img = item.find('img', class_: 'card-img-top lazy');

        PackageModel model = PackageModel(
          destination: dest.substring(4).trim(),
          description: desc,
          image: img!['data-original'],
        );
        packages.add(model);
      }
      return packages;

    } catch (e){
      print('ScraperService $e');
      return [];
    }
  }
}