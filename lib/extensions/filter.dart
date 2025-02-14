//Create an extension to filter the notes on the user
extension Filter<T> on Stream<List<T>> { //we are exgending any stream that has a value of T
  Stream <List<T>> filter(bool Function(T) where) =>
    map((items) => items.where(where).toList()); //the where inside the "()" is actually the close
  }