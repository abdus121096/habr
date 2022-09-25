class Hab {
  String title;
  String hab_url;
  String body;

  Hab({required this.title, required this.hab_url, required this.body});

  Map<String, dynamic> toJson() => {
    'title': title,
    'hab_url': hab_url,
    'body': body,
  };

  Hab.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        hab_url = json['hab_url'],
        body = json['body'];
}