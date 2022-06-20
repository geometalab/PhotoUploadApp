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

const Map<String, String> licences = {
  'CC0': 'CC0',
  'cc-by-3.0': 'Attribution 3.0',
  'cc-by-sa-3.0': 'Attribution-ShareAlike 3.0',
  'cc-by-4.0': 'Attribution 4.0',
  'cc-by-sa-4.0': 'Attribution-ShareAlike 4.0'
};

List<String> assetImages() {
  String path = 'assets/media/backgrounds/';
  return [
    path + 'aurora.jpg',
    path + 'frogs.jpg',
    path + 'national_park.jpg',
    path + 'old_town.jpg',
    path + 'roundhouse.jpg',
    path + 'train.jpg',
    path + 'waterfalls.jpg',
    ''
  ];
}

enum SelectItemsFragmentUseCase { category, depicts }
