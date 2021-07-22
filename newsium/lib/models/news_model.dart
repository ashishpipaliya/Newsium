import 'package:timeago/timeago.dart' as timeago;

class News {
  String? title;
  String? description;
  String? authorName;
  String? sourceName;
  String? sourceUrl;
  String? imageUrl;
  int? createdAt;
  String? inshortsUrl;

  News(
      {this.title,
      this.description,
      this.authorName,
      this.sourceName,
      this.sourceUrl,
      this.imageUrl,
      this.createdAt,
      this.inshortsUrl});

  String get createdAtAgo {
    final timeAgo = DateTime.fromMillisecondsSinceEpoch(createdAt!);
    return timeago.format(timeAgo);
  }

  News.fromJson(Map<String, dynamic>? json) {
    title = json!['title'];
    description = json['description'];
    authorName = json['author_name'];
    sourceName = json['source_name'];
    sourceUrl = json['source_url'];
    imageUrl = json['image_url'];
    createdAt = json['created_at'];
    inshortsUrl = json['inshorts_url'];
  }

  Map<String, dynamic>? toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['author_name'] = this.authorName;
    data['source_name'] = this.sourceName;
    data['source_url'] = this.sourceUrl;
    data['image_url'] = this.imageUrl;
    data['created_at'] = this.createdAt;
    data['inshorts_url'] = this.inshortsUrl;
    return data;
  }
}

enum NewsCategory {
  trending,
  top_stories,
  national,
  business,
  politics,
  sports,
  technology,
  startups,
  entertainment,
  hatke,
  education,
  world,
  automobile,
  science,
  travel,
  miscellaneous,
  fashion,
}

List<String> get categories => [
      'Trending',
      'National',
      'Business',
      'Politics',
      'Sports',
      'Technology',
      'Entertainment',
      'Hatke',
      'Education',
      'World',
      'Automobile',
      'Science',
      'Travel',
      'Miscellaneous',
      'Fashion'
    ];
