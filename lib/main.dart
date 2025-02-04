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
  bool isChecked = false;
  bool isChecked1 = false;
  bool isChecked2 = false;
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<String> _originSuggestions = [];
  List<String> _destinationSuggestions = [];
  String? selectedCommodity;
  final List<String> commodities = [
    'Electronics',
    'Furniture',
    'Food',
    'Clothing',
    'Machinery'
  ];

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

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
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
                        prefixIcon: ImageIcon(
                          AssetImage('assets/location.png'),
                          size: 10,
                        ),
                        labelText: 'Origin',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
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
                        prefixIcon: ImageIcon(
                          AssetImage('assets/location.png'),
                          size: 10,
                        ),
                        labelText: 'Destination',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value!;
                    });
                  }),
              const Text("Data"),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedCommodity,
                  decoration: const InputDecoration(
                    labelText: 'Commodity',
                    border: OutlineInputBorder(),
                  ),
                  items: commodities.map((String commodity) {
                    return DropdownMenuItem<String>(
                      value: commodity,
                      child: Text(commodity),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedCommodity = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Cut Off Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: ImageIcon(
                        AssetImage('assets/calendar.png'),
                        size: 20,
                      ),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text('heading'),
          Row(
            children: [
              const Text("FCL"),
              Checkbox(
                  value: isChecked1,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked1 = value!;
                    });
                  }),
              const Text("LCL"),
              Checkbox(
                  value: isChecked2,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked2 = value!;
                    });
                  }),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Container Size',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    '20\' Standard',
                    '40\' Standard',
                    '40\' High Cube',
                    '45\' High Cube'
                  ]
                      .map((size) => DropdownMenuItem<String>(
                            value: size,
                            child: Text(size),
                          ))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      // Update selected container size (if needed)
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'No of Boxes',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Weight (Kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Container Internal Dimensions:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Length: 39.46 ft", style: TextStyle(fontSize: 14)),
                  Text("Width: 7.70 ft", style: TextStyle(fontSize: 14)),
                  Text("Height: 7.84 ft", style: TextStyle(fontSize: 14)),
                ],
              ),
              Image.asset('assets/container.png', width: 100),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
