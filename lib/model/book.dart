class Book {
  String url, title, image, description, publisher, authors;
  double rate;
  Book(this.url, this.title, this.image, this.description, this.publisher, this.rate, this.authors);
  Book.first(this.title, this.image, this.authors);

  /*String authorsString() {
    String s;
    for (int i = 0; i < this.authors.length; i++) {
      s += " " + authors[i];
    }
    return s;
  }*/
}