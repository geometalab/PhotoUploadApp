class BackendService{

  Future<Iterable> getSuggestions(String pattern) {
    Future<Iterable> suggestions = {
      'Suggestion 1' : 'Subtitle 1', 'Suggestion 2' : 'Subtitle 2', 'Suggestion 3' : 'Subtitle 3', 'Suggestion 4' : 'Subtitle 4'
    } as Future<Iterable>;
    return suggestions;
  }

}
