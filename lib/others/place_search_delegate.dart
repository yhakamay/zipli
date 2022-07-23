import 'package:flutter/material.dart';

import 'place_suggestion.dart';
import 'place_api.dart';

class PlaceSearchDelegate extends SearchDelegate<PlaceSuggestion> {
  late PlaceAPI placeApiProvider;

  PlaceSearchDelegate(this.sessionToken) {
    placeApiProvider = PlaceAPI(sessionToken: sessionToken);
  }

  final String sessionToken;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(
        context,
        PlaceSuggestion('', ''),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Do nothing
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query == ""
          ? null
          : placeApiProvider.fetchSuggestions(
              query, Localizations.localeOf(context).languageCode),
      builder: (context, AsyncSnapshot<List> snapshot) => query == ''
          ? Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text('Enter your address'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text(
                        (snapshot.data![index] as PlaceSuggestion).description),
                    onTap: () {
                      close(context, snapshot.data![index] as PlaceSuggestion);
                    },
                  ),
                  itemCount: snapshot.data!.length,
                )
              : const Text('Loading...'),
    );
  }
}
