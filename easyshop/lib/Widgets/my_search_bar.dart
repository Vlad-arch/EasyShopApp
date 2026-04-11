import 'package:easyshop/utils/github_helper.dart';
import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions;
  final Function(String) onSearch;
  final Function(Map<String, dynamic>) onSuggestionSelected;

  const MySearchBar({
    super.key,
    required this.suggestions,
    required this.onSearch,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16.0)),
          onChanged: onSearch,
          onTap: () {
            controller.openView();
          },
          leading: const Icon(Icons.search),
          hintText: "Search for items here",
          backgroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
          elevation: const WidgetStatePropertyAll<double>(5.0),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        final String input = controller.value.text.toLowerCase();
        final List<Map<String, dynamic>> filteredSuggestions = suggestions
            .where((item) =>
                item['name'].toString().toLowerCase().contains(input))
            .toList();

        return filteredSuggestions.map((product) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                GithubHelper.convertUrl(product['image']),
              ),
            ),
            title: Text(product['name'] ?? "Unknown"),
            subtitle: Text("${product['price'] ?? '0.00'} - ${product['category'] ?? ''}"),
            onTap: () {
              controller.closeView(product['name']);
              onSuggestionSelected(product);
            },
          );
        });
      },
    );
  }
}