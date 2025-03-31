import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database before running the app.
  await DatabaseHelper.instance.database;
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

class _AquariumScreenState extends State<AquariumScreen>
    with SingleTickerProviderStateMixin {
  // List to hold all fish in the aquarium.
  List<Fish> fishList = [];
  // Default settings.
  double defaultSpeed = 1.0;
  Color defaultColor = Colors.blue;

  // Animation controller for updating fish positions.
  AnimationController? _controller;
  final Random random = Random();

  // Aquarium dimensions.
  final double aquariumWidth = 300;
  final double aquariumHeight = 300;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load settings from local storage.
    // Use a short duration to update the positions frequently (approx 60 FPS).
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 16))
          ..addListener(_updateFishPositions)
          ..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // Called on every tick of the AnimationController.
  void _updateFishPositions() {
    setState(() {
      for (var fish in fishList) {
        fish.updatePosition(aquariumWidth, aquariumHeight);
      }
    });
  }

  // Adds a new fish if there are less than 10.
  void _addFish() {
    if (fishList.length < 10) {
      // Set a random starting position inside the aquarium.
      Offset pos = Offset(
        random.nextDouble() * (aquariumWidth - 20),
        random.nextDouble() * (aquariumHeight - 20),
      );
      // Generate a random direction vector (normalized).
      double dx = random.nextDouble() * 2 - 1;
      double dy = random.nextDouble() * 2 - 1;
      double mag = sqrt(dx * dx + dy * dy);
      dx /= mag;
      dy /= mag;
      Fish newFish = Fish(
        position: pos,
        dx: dx,
        dy: dy,
        speed: defaultSpeed,
        color: defaultColor,
      );
      setState(() {
        fishList.add(newFish);
      });
    }
  }

  // Saves settings (fish count, default speed, and color) to SQLite.
  void _saveSettings() async {
    await DatabaseHelper.instance.saveSettings(
      fishCount: fishList.length,
      speed: defaultSpeed,
      color: defaultColor.value,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Settings saved!')));
  }

  // Loads saved settings from SQLite.
  void _loadSettings() async {
    var settings = await DatabaseHelper.instance.getSettings();
    if (settings != null) {
      setState(() {
        defaultSpeed = settings['speed'] ?? 1.0;
        int colorValue = settings['color'] ?? Colors.blue.value;
        defaultColor = Color(colorValue);
        // Optionally, recreate the fish based on the saved fish count.
        int savedFishCount = settings['fishCount'] ?? 0;
        fishList = List.generate(savedFishCount, (index) {
          Offset pos = Offset(
            random.nextDouble() * (aquariumWidth - 20),
            random.nextDouble() * (aquariumHeight - 20),
          );
          double dx = random.nextDouble() * 2 - 1;
          double dy = random.nextDouble() * 2 - 1;
          double mag = sqrt(dx * dx + dy * dy);
          dx /= mag;
          dy /= mag;
          return Fish(
            position: pos,
            dx: dx,
            dy: dy,
            speed: defaultSpeed,
            color: defaultColor,
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Virtual Aquarium')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Aquarium container that holds the animated fish.
            Container(
              width: aquariumWidth,
              height: aquariumHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children:
                    fishList.map((fish) {
                      return Positioned(
                        left: fish.position.dx,
                        top: fish.position.dy,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: fish.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _addFish, child: Text('Add Fish')),
                ElevatedButton(
                  onPressed: _saveSettings,
                  child: Text('Save Settings'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              children: [
                // Speed Slider
                Row(
                  children: [
                    Text('Speed:'),
                    Expanded(
                      child: Slider(
                        value: defaultSpeed,
                        min: 0.5,
                        max: 5.0,
                        divisions: 9,
                        label: defaultSpeed.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            defaultSpeed = value;
                            // Update the speed for all existing fish.
                            for (var fish in fishList) {
                              fish.speed = defaultSpeed;
                            }
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
                      value: defaultColor,
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
                            defaultColor = newColor;
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

class Fish {
  Offset position;
  double dx;
  double dy;
  double speed;
  Color color;

  Fish({
    required this.position,
    required this.dx,
    required this.dy,
    required this.speed,
    required this.color,
  });

  void updatePosition(double maxWidth, double maxHeight) {
    double newX = position.dx + dx * speed;
    double newY = position.dy + dy * speed;

    // Bounce off the left/right edges.
    if (newX <= 0 || newX >= maxWidth - 20) {
      dx = -dx;
      newX = position.dx + dx * speed;
    }
    // Bounce off the top/bottom edges.
    if (newY <= 0 || newY >= maxHeight - 20) {
      dy = -dy;
      newY = position.dy + dy * speed;
    }
    position = Offset(newX, newY);
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('settings.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Create a simple table to store settings.
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        fishCount INTEGER,
        speed REAL,
        color INTEGER
      )
    ''');
  }

  // Save settings with a fixed id (1) so that they are updated each time.
  Future<void> saveSettings({
    required int fishCount,
    required double speed,
    required int color,
  }) async {
    final db = await instance.database;
    await db.insert('settings', {
      'id': 1,
      'fishCount': fishCount,
      'speed': speed,
      'color': color,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Retrieve the saved settings.
  Future<Map<String, dynamic>?> getSettings() async {
    final db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }
}
