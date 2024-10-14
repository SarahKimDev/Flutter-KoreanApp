import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proverbs_app/pages/favorite_list.dart';
import 'package:proverbs_app/pages/wallpaper.dart';
import 'package:proverbs_app/services/database_service.dart';
import 'models/proverb.dart';
import 'package:share_plus/share_plus.dart';
import 'functionalities/words.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Proverb>? _proverbs; // List to store all proverbs
  int _currentPageIndex = 0; // Index of the currently displayed proverb
  late PageController _pageController; // PageController for PageView

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // Initialize PageController
    _fetchProverbs(); // Fetch the proverbs when the state is initialized
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose of PageController when the widget is removed
    super.dispose();
  }

  Future<void> _fetchProverbs() async {
    try {
      List<Proverb> proverbs = await _databaseService.getProverbs();
      print('Fetched proverbs: $proverbs');
      if (mounted) {
        setState(() {
          _proverbs = proverbs;
          if (_proverbs != null && _proverbs!.isNotEmpty) {
            _currentPageIndex = 0; // Set the initial page index
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _pageController.jumpToPage(_currentPageIndex);
            });
          }
        });
      }
    } catch (e) {
      print('Error fetching proverbs: $e');
    }
  }




  void _nextPage() {
    if (_proverbs != null && _currentPageIndex < _proverbs!.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_proverbs != null && _currentPageIndex > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleFavorite(Proverb proverb) async {
    try {
      if (proverb.favorite == 0) {
        await _databaseService.favorite(proverb.id);
        setState(() {
          proverb.favorite = 1;
        });
      } else {
        await _databaseService.unfavorite(proverb.id);
        setState(() {
          proverb.favorite = 0;
        });
      }
    } catch (e) {
      print('Error updating bookmark status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Words.app_bar_color,
        ),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Words.app_bar_color,
            title: Text(Words.app_name, style: TextStyle(color: Colors.white)),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          drawer: Drawer(
            child: Container(
              color: Words.app_background_color, // Set the background color of the Drawer to yellow

              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Center(
                      child: Text(
                        Words.app_name,
                        style: TextStyle(
                          fontSize: 24.0, // Adjust the font size as needed
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Adjust text color if needed
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Words.app_bar_color, // Keep header background color
                    ),
                  ),
                  ListTile(
                    title: Center(
                      // Center the text
                      child: Text(
                        "my favorites",
                        style: TextStyle(

                          color: Colors.black,
                        ),
                      ),
                    ),
                    onTap: () async{
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FavoriteList(),
                      ));
                      setState((){
                        _fetchProverbs();
                      });

                    },
                  ),

                ],
              ),
            ),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                flex: 1, // 1/3 of the available space
                child: _proverbs == null || _proverbs!.isEmpty
                    ? Center(child: Text('Loading proverbs...'))
                    : Stack(
                  children: [
                    PageView.builder(
                      itemCount: _proverbs?.length ?? 0,
                      controller: _pageController,
                      itemBuilder: (context, index) {
                        Proverb proverb = _proverbs![index];
                        return Center(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Words.app_background_color,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Spacer(),
                                Text(
                                  proverb.eng,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  '${proverb.kor}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 24.0),
                                Text(
                                  '${proverb.explain}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                                Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.arrow_back_ios, color: Colors.black54),
                                      onPressed: _previousPage,

                                    ),
                                    Spacer(),
                                    IconButton(onPressed: (){
                                      final String textToShare = '${proverb.eng}\n${proverb.kor}\n${proverb.explain}\n\nby '+Words.app_name;
                                      Share.share(textToShare);
                                    }, icon:Icon( Icons.share_outlined),padding: EdgeInsets.all(16),),
                                    IconButton(onPressed: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => WallPaper(eng: proverb.eng,kor: proverb.kor,explain: proverb.explain,)),
                                      );
                                    }, icon:Icon( Icons.screenshot),padding: EdgeInsets.all(16),),
                                    IconButton(onPressed: ()
                                        {
                                          _toggleFavorite(proverb);
                                        }, icon:Icon(
                                        proverb.favorite==0?Icons.favorite_outline:Icons.favorite),padding: EdgeInsets.all(16),),
                                    Spacer(),
                                    IconButton(
                                      icon: Icon(Icons.arrow_forward_ios, color: Colors.black54),
                                      onPressed: _nextPage,

                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      onPageChanged: (index) {
                        setState(() {
                          _currentPageIndex = index;
                        });
                      },
                    ),


                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }


}
