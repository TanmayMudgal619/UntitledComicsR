import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'explore.dart';
import 'mangapage.dart';
import 'status.dart';
import 'mangalistviews.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user.dart';
import 'newapilib.dart';
import 'globals.dart' as globals;

class LoadHome extends StatefulWidget {
  LoadHome();
  @override
  _LoadHomeState createState() => _LoadHomeState();
}

class _LoadHomeState extends State<LoadHome>
    with SingleTickerProviderStateMixin {
  int btindex = 0;
  bool isSearch = false;
  int off = 0;
  late Future<List<mangaBasic>> sedata;
  List<mangaBasic> medata = [];
  String sevalue = "";
  int cv = 2;
  TextEditingController seval = TextEditingController();

  Future<List<mangaBasic>> getdata(int off) async {
    return search_manga(sevalue, '100', off);
  }

  @override
  void initState() {
    getalls(globals.prefs.getString("session")!,
            globals.prefs.getString("refresh")!)
        .then((value) {
      value.forEach((key, value) {
        if (globals.als[value] != null) {
          globals.als[value]!.add(key);
        } else {
          globals.als[value] = [key];
        }
      });
      setState(() {});
    });
    super.initState();
  }

  void bindex(int index) {
    setState(() {
      btindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Set<String> a = globals.prefs.getStringList("hist")!.toSet();
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Center(
          child: Container(
            height: size.height,
            width: size.width,
            child: Image.asset(
              "assets/img/newbg.jpg",
              fit: BoxFit.cover,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: DefaultTabController(
            length: 6,
            child: Scaffold(
              key: globals.sk,
              backgroundColor: Colors.black26,
              appBar: CupertinoNavigationBar(
                brightness: Brightness.dark,
                border: Border.all(color: Colors.transparent),
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                trailing: (cv == 1)
                    ? (Material(
                        child: GestureDetector(
                          onTap: () {
                            if (isSearch) {
                              setState(() {
                                isSearch = false;
                                sevalue = "";
                                globals.secnt.clear();
                              });
                            }
                          },
                          child: (Icon(
                            (isSearch)
                                ? (CupertinoIcons.xmark)
                                : (CupertinoIcons.search),
                            size: 19,
                          )),
                        ),
                      ))
                    : (null),
                leading: (cv == 1)
                    ? GestureDetector(
                        child: Icon(
                          Icons.filter_alt_outlined,
                        ),
                        onTap: () {},
                      )
                    : (null),
                middle: (cv == 1)
                    ? Material(
                        child: (TextField(
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.blueGrey,
                          decoration: new InputDecoration(
                            hintText: ' Search...',
                            hintStyle: TextStyle(color: Colors.white),
                            border: InputBorder.none,
                          ),
                          controller: globals.secnt,
                          onSubmitted: (value) => setState(() {
                            sevalue = value;
                            isSearch = true;
                            a.add(value);
                            globals.prefs.setStringList("hist", a.toList());
                            sedata = search_manga(sevalue, 100, 0);
                          }),
                        )),
                      )
                    : Material(
                        child: (Image.asset("assets/img/logo.png")),
                      ),
              ),
              body: [
                Explore(globals.mdata),
                ((sevalue.isEmpty && !isSearch))
                    ? (a.isEmpty)
                        ? (Center(
                            child: Text("Search Your Favourite Manga!"),
                          ))
                        : (Container(
                            color: Colors.white10,
                            child: (ListView(
                              children: globals.prefs
                                  .getStringList("hist")!
                                  .map((e) => Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.white12,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        child: ListTile(
                                          onTap: () {
                                            setState(() {
                                              isSearch = true;
                                              sevalue = e;
                                              globals.secnt.text = e;
                                              sedata =
                                                  search_manga(sevalue, 100, 0);
                                            });
                                          },
                                          leading: Icon(
                                            Icons.arrow_right_rounded,
                                            color: Colors.white,
                                          ),
                                          title: Text(
                                            e,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          trailing: InkWell(
                                            onTap: () {
                                              // print("object");
                                              setState(() {
                                                a.remove(e);
                                                globals.prefs.setStringList(
                                                    "hist", a.toList());
                                              });
                                            },
                                            child: Icon(
                                              CupertinoIcons.xmark,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            )),
                          ))
                    : (FutureBuilder<List<mangaBasic>>(
                        future: sedata,
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.active:
                            case ConnectionState.waiting:
                              return Align(
                                child: LinearProgressIndicator(),
                                alignment: Alignment.topCenter,
                              );
                            default:
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(snapshot.error.toString()),
                                );
                              } else {
                                return SingleChildScrollView(
                                  child: GV(snapshot.data!),
                                );
                              }
                          }
                        },
                      )),
                SingleChildScrollView(
                  child: mangaPage(
                    globals.mdata[0],
                    globals.mdata[1],
                    globals.mdata[2],
                  ),
                ),
                (globals.als.isEmpty)
                    ? (Center(
                        child: CircularProgressIndicator(),
                      ))
                    : (Status()),
                Settings(),
              ].elementAt(cv),
              bottomNavigationBar: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.white24,
                    child: BottomNavigationBar(
                      selectedItemColor: Colors.black,
                      unselectedItemColor: Colors.black45,
                      showSelectedLabels: false,
                      elevation: 0,
                      currentIndex: cv,
                      onTap: (value) => setState(() {
                        if (cv != value) {
                          if (value != 1) {
                            sevalue = "";
                            isSearch = false;
                            globals.secnt.clear();
                          }
                          cv = value;
                        }
                      }),
                      items: [
                        BottomNavigationBarItem(
                          icon: (cv == 0)
                              ? (Chip(
                                  backgroundColor: Colors.white38,
                                  avatar: Icon(CupertinoIcons.compass),
                                  label: Text(
                                    "Explore",
                                  ),
                                ))
                              : (Icon(CupertinoIcons.compass)),
                          label: "Explore",
                          // backgroundColor: Colors.transparent,
                        ),
                        BottomNavigationBarItem(
                          icon: (cv == 1)
                              ? (Chip(
                                  backgroundColor: Colors.white38,
                                  avatar: Icon(CupertinoIcons.search),
                                  label: Text(
                                    "Search",
                                  ),
                                ))
                              : (Icon(CupertinoIcons.search)),
                          label: "Search",
                        ),
                        BottomNavigationBarItem(
                          icon: (cv == 2)
                              ? (Chip(
                                  backgroundColor: Colors.white38,
                                  avatar: Icon(CupertinoIcons.home),
                                  label: Text(
                                    "Home",
                                  ),
                                ))
                              : (Icon(CupertinoIcons.home)),
                          label: "Home",
                        ),
                        BottomNavigationBarItem(
                          icon: (cv == 3)
                              ? (Chip(
                                  backgroundColor: Colors.white38,
                                  avatar: Icon(CupertinoIcons.bookmark),
                                  label: Text(
                                    "Library",
                                  ),
                                ))
                              : (Icon(CupertinoIcons.bookmark)),
                          label: "Library",
                        ),
                        BottomNavigationBarItem(
                          icon: (cv == 4)
                              ? (Chip(
                                  backgroundColor: Colors.white38,
                                  avatar: Icon(CupertinoIcons.settings),
                                  label: Text(
                                    "Settings",
                                  ),
                                ))
                              : (Icon(CupertinoIcons.settings)),
                          label: "Settings",
                          backgroundColor: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // extendBody: true,
            ),
          ),
        ),
      ],
    );
  }
}
