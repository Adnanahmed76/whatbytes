import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Assuming you have an enum for Priority and a Task model as previously discussed.
// If not, you'll need to define them.
enum Priority { low, medium, high }

class Task {
  int? id;
  String title;
  String description;
  DateTime dueDate;
  Priority priority;
  bool isCompleted;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
  });

  // Convert a Task object into a Map for database operations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(), // Store DateTime as ISO 8601 string
      'priority': priority.index, // Store enum as integer index
      'isCompleted': isCompleted ? 1 : 0, // Store bool as 0 or 1
    };
  }

  // Create a Task object from a Map, typically read from the database.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      priority: Priority.values[map['priority'] as int],
      isCompleted: (map['isCompleted'] as int) == 1,
    );
  }

  // Helper for creating updated Task objects without modifying original
  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    Priority? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, description: $description, dueDate: $dueDate, priority: $priority, isCompleted: $isCompleted}';
  }
}


class DatabaseHelper {
  static final _databaseName = "task_manager.db"; // Your database file name
  static final _databaseVersion = 1; // Increment this for schema changes

  // Table name and column names
  static final String tableTasks = 'tasks';
  static final String columnId = 'id';
  static final String columnTitle = 'title';
  static final String columnDescription = 'description';
  static final String columnDueDate = 'dueDate';
  static final String columnPriority = 'priority';
  static final String columnIsCompleted = 'isCompleted';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Lazily instantiate the database if it's null
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database and create the table if it doesn't exist
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade); // Added onUpgrade for future schema changes
  }

  // SQL code to create the tasks table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableTasks (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnTitle TEXT NOT NULL,
            $columnDescription TEXT NOT NULL,
            $columnDueDate TEXT NOT NULL,
            $columnPriority INTEGER NOT NULL,
            $columnIsCompleted INTEGER NOT NULL
          )
          ''');
  }

  // Optional: Handle database upgrades (e.g., adding new columns)
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Example of handling an upgrade (e.g., if you add a new column in a future version)
    // if (oldVersion < 2) {
    //   await db.execute("ALTER TABLE $tableTasks ADD COLUMN newColumn TEXT");
    // }
  }

  // --- CRUD Operations ---

  // Insert a task
  Future<int> insertTask(Task task) async {
    Database db = await instance.database;
    return await db.insert(tableTasks, task.toMap());
  }

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableTasks);
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Get a single task by ID
  Future<Task?> getTaskById(int id) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableTasks,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }


  // Update a task
  Future<int> updateTask(Task task) async {
    Database db = await instance.database;
    return await db.update(
      tableTasks,
      task.toMap(),
      where: '$columnId = ?',
      whereArgs: [task.id],
    );
  }

  // Delete a task
  Future<int> deleteTask(int id) async {
    Database db = await instance.database;
    return await db.delete(
      tableTasks,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Get the number of tasks
  Future<int?> getTaskCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableTasks'));
  }

  // Close the database connection (optional, usually managed by the system)
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}