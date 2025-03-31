import 'package:flutter/material.dart';

void main() {
  runApp(VirtualAquariumApp());
}

class VirtualAquariumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Virtual Aquarium', home: AquariumScreen());
  }
}

class AquariumScreen extends StatefulWidget {
  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> {
  // State variables for speed and selected color.
  double _speed = 1.0;
  Color _selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Virtual Aquarium')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Aquarium container
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(children: [
                ],
              ),
            ),
            SizedBox(height: 20),
            //Add Fish & Save Settings buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {}, child: Text('Add Fish')),
                ElevatedButton(onPressed: () {}, child: Text('Save Settings')),
              ],
            ),
            SizedBox(height: 20),
            // Settings: Speed Slider and Color Dropdown
            Column(
              children: [
                // Speed Slider
                Row(
                  children: [
                    Text('Speed:'),
                    Expanded(
                      child: Slider(
                        value: _speed,
                        min: 0.5,
                        max: 5.0,
                        divisions: 9,
                        label: _speed.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            _speed = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                // Color Selection Dropdown
                Row(
                  children: [
                    Text('Fish Color:'),
                    SizedBox(width: 10),
                    DropdownButton<Color>(
                      value: _selectedColor,
                      items: [
                        DropdownMenuItem(
                          value: Colors.blue,
                          child: Text('Blue'),
                        ),
                        DropdownMenuItem(value: Colors.red, child: Text('Red')),
                        DropdownMenuItem(
                          value: Colors.green,
                          child: Text('Green'),
                        ),
                        DropdownMenuItem(
                          value: Colors.orange,
                          child: Text('Orange'),
                        ),
                      ],
                      onChanged: (Color? newColor) {
                        if (newColor != null) {
                          setState(() {
                            _selectedColor = newColor;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
