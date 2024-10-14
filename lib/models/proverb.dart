class Proverb{
  final int id;
  final String eng;
  final String kor;
  final String explain;
  final int seen;
  late int favorite;
  Proverb({
    required this.id,
    required this.eng,
    required this.kor,
    required this.explain,
    required this.seen,
    required this.favorite
  });
}