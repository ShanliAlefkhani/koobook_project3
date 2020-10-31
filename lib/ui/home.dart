import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:koobook_project3/model/book.dart';

class BookList extends StatefulWidget {
  @override
  _BookListState createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Search();
  }
}

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String s;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.amber.shade700,
        title: Text("Search Books"),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 80, left: 20, right: 20),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: Colors.blueGrey.shade100,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: TextField(
          keyboardType: TextInputType.name,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            //prefixText: "Search",
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
          onSubmitted: (String value) {
            try {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => Results(value),
                  ));
            } catch (exception) {}
          },
        ),
      ),
    );
  }
}

class Results extends StatefulWidget {
  String s;

  Results(this.s);

  @override
  _ResultsState createState() => _ResultsState(s);
}

class _ResultsState extends State<Results> {
  final String searchName;
  final _nextPageThreshold = 3;
  bool hasNextPage = true;
  int pageNum = 1;

  _ResultsState(this.searchName);

  List<Book> bookArr = new List();

  Future<List> getData() async {
    Dio dio = new Dio();
    final response =
        await dio.get("https://api.koobook.app/books/", queryParameters: {
      "search": searchName,
      "fields":
          "url,Title,ISBN,Image,Description,Publisher,Price,Edition,Hashtags,Rate,Authors",
      "page": pageNum,
    });
    //print(response.data['results']);
    if (response.data['next'] == null) {
      hasNextPage = false;
    } else {
      pageNum++;
    }
    if (response.statusCode == 200) {
      return response.data['results'];
    }
    return null;
  }

  Future<bool> starting() async {
    List response = await getData();
    for (int i = 0; i < response.length; i++) {
      String authorsName = "";
      for (int j = 0; j < response[i]['Authors'].length; j++) {
        authorsName += response[i]['Authors'][j]["Name"] + " ";
      }
      Book book = new Book(
          response[i]['url'],
          response[i]['Title'],
          response[i]['Image'],
          response[i]['Description'],
          response[i]['Publisher'],
          response[i]['Rate'],
          authorsName);
      bookArr.add(book);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Center(
        child: FutureBuilder(
          future: starting(),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container(
                child: Center(
                  child: Text(
                    "loading...",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                  //itemCount: bookArr.length + (hasNextPage ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == bookArr.length - _nextPageThreshold) {
                      starting();
                    }
                    if (index >= bookArr.length) {
                      return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                      ));
                    } else {
                      return Card(
                        elevation: 5,
                        color: Colors.white,
                        child: ListTile(
                          title: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text("${bookArr[index].title}",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.amber.shade700,
                                )),
                          ),
                          subtitle: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bookArr[index].authors,
                                    style:
                                        TextStyle(color: Colors.grey.shade700),
                                  ),
                                  Text(
                                    "${bookArr[index].publisher}",
                                    style:
                                        TextStyle(color: Colors.grey.shade700),
                                  ),
                                ]),
                          ),
                          trailing: CircleAvatar(
                            backgroundColor: Colors.blueGrey.shade900,
                            backgroundImage: NetworkImage(
                              bookArr[index].image,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) =>
                                      DetailPage(bookArr[index])),
                            );
                          },
                        ),
                      );
                    }
                  });
            }
          },
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Book book;

  DetailPage(this.book);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber.shade700,
        title: Text(
          book.title,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.all(20),
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(book.image),
                ),
              ),
            ),
          ),
          Text(
            book.authors,
            style: TextStyle(color: Colors.grey, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Text(
            book.publisher,
            style: TextStyle(color: Colors.grey, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                book.description,
                style: TextStyle(color: Colors.white, fontSize: 20),
              )),
          Text(
            "rate: ${book.rate}",
            style: TextStyle(color: Colors.amber.shade700, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          /*RaisedButton(
            //inja
            //onPressed: _launchURL(book),
            child: Text(
              book.url,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),*/
        ],
      ),
    );
  }

/*_launchURL(Book book) async {
    var url = book.url;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }*/
}
