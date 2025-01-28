import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const FreightSearchApp());
}

class FreightSearchApp extends StatelessWidget {
  const FreightSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: Scaffold(
        appBar: AppBar(title: const Text('Freight Rate Search')),
        body: const FreightSearchForm(),
      ),
    );
  }
}

class FreightSearchForm extends StatefulWidget {
  const FreightSearchForm({super.key});

  @override
  State<FreightSearchForm> createState() => _FreightSearchFormState();
}

class _FreightSearchFormState extends State<FreightSearchForm> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  List<String> _originSuggestions = [];
  List<String> _destinationSuggestions = [];

  Future<List<String>> _fetchSuggestions(String query) async {
    if (query.isEmpty) return [];
    final response = await http.get(Uri.parse(
        'https://autocomplete.travelpayouts.com/places2?locale=en&types[]=country&term=$query'));

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);
      return results.map((item) => item['name'].toString()).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            width: 300,
            child: Autocomplete<String>(
              optionsBuilder: (textEditingValue) async {
                return await _fetchSuggestions(textEditingValue.text);
              },
              onSelected: (selection) {
                _originController.text = selection;
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Origin',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 300,
            child: Autocomplete<String>(
              optionsBuilder: (textEditingValue) async {
                return await _fetchSuggestions(textEditingValue.text);
              },
              onSelected: (selection) {
                _destinationController.text = selection;
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onEditingComplete) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
