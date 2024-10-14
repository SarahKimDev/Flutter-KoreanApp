import 'package:flutter/material.dart';
import 'package:proverbs_app/services/database_service.dart';

import '../../main.dart';
import '../functionalities/words.dart';
import '../models/proverb.dart';


class FavoriteList extends StatefulWidget {
  const FavoriteList({super.key});

  @override
  _FavoriteListState createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  bool _isChecked = false; // State for the checkbox
  final DatabaseService _databaseService = DatabaseService.instance;




  bool _loaded = false;

  List<Proverb>? _favoriteProverbs;

  List<bool> _selectedIndexes = [];

  List<bool> _tappedIndexes=[];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await _fetchFavorites();

    });
    super.didChangeDependencies();
  }
  // Method to delete selected memos
  Future<void> _unfavoriteSelectedProverbs() async {
    List<int> proverbIdsToDelete = [];

    // Gather IDs of selected memos
    for (int i = 0; i < _selectedIndexes.length; i++) {
      if (_selectedIndexes[i]) {
        proverbIdsToDelete.add(_favoriteProverbs![i].id); // Assuming Memos model has an id field
      }
    }

    if (proverbIdsToDelete.isNotEmpty) {
      try {
        // Delete memos from the database
        for(var id in proverbIdsToDelete){
          _databaseService.unfavorite(id);
        }

        // Refresh the memo list
        await _fetchFavorites();

      } catch (e) {
        print('Error deleting memos: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("select proverbs")));
    }
  }

  Future<void> _fetchFavorites() async {
    List<Proverb> proverbs = [];
    List<Proverb> favoriteProverbs=[];
    try {

      proverbs=await _databaseService.getProverbs();
      for(var instance in proverbs){
        if(instance.favorite==1){
          favoriteProverbs.add(instance);
        }
      }

      setState(() {
        _favoriteProverbs = favoriteProverbs;
        // Initialize _selectedIndexes only after _memoAll is populated
        _selectedIndexes = List<bool>.filled(_favoriteProverbs?.length ?? 0, false);
        _tappedIndexes = List<bool>.filled(_favoriteProverbs?.length ?? 0, false);
        _loaded=true;
      });
    } catch (e) {
      print('Error fetching memos: $e');
    }
  }


  Future<bool> _onWillPop() async {
    if (true) {
      return true; // Allow back navigation if no changes were made
    }

  }




  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Words.app_background_color,
        appBar: AppBar(
          backgroundColor: Words.app_bar_color,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isChecked = !_isChecked;
                      // Update all list items based on the AppBar checkbox state
                      if (_favoriteProverbs != null) {
                        _selectedIndexes = List<bool>.filled(_favoriteProverbs!.length, _isChecked);
                      }
                    });
                  },
                ),
                SizedBox(width: 8),
                IconButton(
                    icon: Icon(Icons.delete_outline,color: Colors.white),
                    onPressed: (){
                      _unfavoriteSelectedProverbs();
                      setState(() {
                        _isChecked=false;
                      });
                    }),
              ],
            ),
          ],
        ),
        body: Container(
          color: Words.app_background_color, // Change the background color here
          child: _loaded ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehaviorSelection(),
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.all(Words.app_bar_color.withOpacity(0.5)), // Set scrollbar thumb color to yellow
                  thickness: MaterialStateProperty.all(8.0), // Set thickness of the scrollbar
                ),
                child: Scrollbar(
                  thumbVisibility: true, // Show scrollbar at all times
                  thickness: 8.0,
                  radius: Radius.circular(8.0),
                  child: _favoriteProverbs == null || _favoriteProverbs!.isEmpty
                      ? Center(
                    child: Text(
                      "No favorite proverbs existing",
                      style: TextStyle( color: Colors.black),
                    ),
                  )
                      : ListView.separated(
                    itemCount: _favoriteProverbs!.length,
                    itemBuilder: (context, index) {
                      final proverb = _favoriteProverbs![index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    proverb.eng,
                                    style: TextStyle(),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _selectedIndexes[index] ? Icons.check_box : Icons.check_box_outline_blank,
                                    color: Words.app_bar_color,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedIndexes[index] = !_selectedIndexes[index];
                                    });
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _tappedIndexes[index] = !_tappedIndexes[index];
                              });
                            },
                          ),
                          if (_tappedIndexes[index])
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                "${proverb.explain}",
                                style: TextStyle(),
                              ),
                            ),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) => Divider(
                      height: 1.0,
                      color: Words.app_bar_color.withOpacity(0.5)
                      ,
                    ),
                  ),
                ),
              ),
            ),
          ) : Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Words.app_bar_color),
            ),
          ),
        ),

      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}


class NoGlowScrollBehaviorSelection extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context,
      Widget child,
      AxisDirection axisDirection,
      ) {
    // Return the child directly to remove the glow effect
    return child;
  }
}
