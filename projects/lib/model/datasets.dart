const Map<String, String> languages = {
  'en': 'English',
  'de': 'German',
  'fr': 'French',
  'ru': 'Russian',
  'es': 'Spanish',
  'pt': 'Portuguese',
  'zh': 'Chinese',
  'ko': 'Korean',
  'ja': 'Japanese',
};

List<String> assetImages() {
  String path = "assets/media/backgrounds/";
  return [
    path + "aurora.jpg",
    path + "frogs.jpg",
    path + "national_park.jpg",
    path + "old_town.jpg",
    path + "roundhouse.jpg",
    path + "train.jpg",
    path + "waterfalls.jpg",
    ""
  ];
}
