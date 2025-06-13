// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:taskmanagementforgigworker/model/task.dart';
 // Import your Task model
import 'package:taskmanagementforgigworker/pages/add_task.dart';
 // For navigating to add task
import 'package:taskmanagementforgigworker/pages/edit_task.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// Instantiate Firestore Service

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(), // Custom AppBar
      body: _buildBody(), // Main task list body
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFloatingActionButton(), // Add Task FAB
      bottomNavigationBar: _buildBottomNavBar(), // Bottom Navigation Bar
    );
  }

  // --- Widget Builders ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false, // Prevents default back button
      backgroundColor: Theme.of(context).primaryColor, // Use theme color
      toolbarHeight: 120, // Height for the AppBar content
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamically show count of incomplete tasks
            StreamBuilder<List<Task>>(
              stream: getTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    "...",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    "Error",
                    style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
                  );
                }
                final activeTasksCount = snapshot.data?.where((task) => !task.isCompleted).length ?? 0;
                return Text(
                  "$activeTasksCount", // Show count of incomplete tasks
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            Text(
              "Today, ${DateFormat('d MMM').format(DateTime.now())}", // Dynamic date
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const Text(
              "My tasks",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  // TODO: Implement global search functionality
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                
                },
              ),
            ],
          ),
        )
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Search tasks...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
              // onChanged: (query) { /* TODO: Implement search filtering */ },
            ),
          ),
        ),
      ),
    );
  }

  // Builds the main body content with task sections, fetched from Firestore
  Widget _buildBody() {
    return StreamBuilder<List<Task>>(
      stream: _firestoreService.getTasks(), // Listen to real-time task updates
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading tasks: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            heightFactor: 5,
            child: Text('No tasks found. Click "+" to add one!'),
          );
        }

        final allTasks = snapshot.data!;

        // --- Categorize tasks based on due date ---
        final today = DateTime.now();
        final tomorrow = today.add(const Duration(days: 1));
        final endOfThisWeek = today.add(const Duration(days: 7)); // Simple week definition

        final List<Task> todayTasks = allTasks.where((task) =>
            task.dueDate.year == today.year &&
            task.dueDate.month == today.month &&
            task.dueDate.day == today.day
        ).toList()..sort((a,b) => a.dueDate.compareTo(b.dueDate));

        final List<Task> tomorrowTasks = allTasks.where((task) =>
            task.dueDate.year == tomorrow.year &&
            task.dueDate.month == tomorrow.month &&
            task.dueDate.day == tomorrow.day
        ).toList()..sort((a,b) => a.dueDate.compareTo(b.dueDate));

        final List<Task> thisWeekTasks = allTasks.where((task) =>
            (task.dueDate.isAfter(tomorrow) || task.dueDate.isAtSameMomentAs(tomorrow)) &&
            (task.dueDate.isBefore(endOfThisWeek) || task.dueDate.isAtSameMomentAs(endOfThisWeek))
        ).toList()..sort((a,b) => a.dueDate.compareTo(b.dueDate));

        // You could also add an "Overdue" section or "Later" section
        final List<Task> overdueTasks = allTasks.where((task) =>
            task.dueDate.isBefore(today) && !task.isCompleted
        ).toList()..sort((a,b) => a.dueDate.compareTo(b.dueDate));


        return ListView(
          children: [
            if (overdueTasks.isNotEmpty)
              _buildTaskSection(context, "Overdue", overdueTasks, titleColor: Colors.red),
            if (todayTasks.isNotEmpty)
              _buildTaskSection(context, "Today", todayTasks),
            if (tomorrowTasks.isNotEmpty)
              _buildTaskSection(context, "Tomorrow", tomorrowTasks),
            if (thisWeekTasks.isNotEmpty)
              _buildTaskSection(context, "This week", thisWeekTasks),
            const SizedBox(height: 80), // Space for FAB and BottomAppBar
          ],
        );
      },
    );
  }

  // Builds a section for tasks (e.g., "Today", "Tomorrow")
  Widget _buildTaskSection(BuildContext context, String title, List<Task> tasks, {Color titleColor = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true, // Important for nested list views
            physics: const NeverScrollableScrollPhysics(), // Prevents nested scrolling
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const Divider(height: 1), // Separator between tasks
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskListItem(task); // Delegates to a dedicated task item builder
            },
          ),
        ],
      ),
    );
  }

  // Builds an individual task list item, including complete/incomplete, edit, delete
  Widget _buildTaskListItem(Task task) {
    Color getPriorityColor(Priority priority) {
      switch (priority) {
        case Priority.high: return Colors.red;
        case Priority.medium: return Colors.orange; // Adjust as per your design
        case Priority.low: return Colors.green;
      }
    }

    return Dismissible( // Allows swipe-to-delete
      key: Key(task.id!), // Use task ID as the unique key for Dismissible
      direction: DismissDirection.endToStart, // Swipe from right to left
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) async {
        if (task.id != null) {
          try {
            await _firestoreService.deleteTask(task.id!);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${task.title} deleted")),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to delete ${task.title}: $e")),
            );
          }
        }
      },
      child: InkWell( // Makes the entire row tappable for editing
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(task: task), // Pass the task for editing
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              // Task Completion Indicator
              GestureDetector(
                onTap: () async {
                  if (task.id != null) {
                    try {
                      await _firestoreService.updateTask(
                        task.copyWith(isCompleted: !task.isCompleted), // Toggle completion status
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(task.isCompleted ? "${task.title} marked incomplete" : "${task.title} marked complete"),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to update task status: $e")),
                      );
                    }
                  }
                },
                child: Icon(
                  task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: task.isCompleted ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              // Task Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        color: task.isCompleted ? Colors.grey : Colors.black87,
                      ),
                    ),
                    if (task.description.isNotEmpty)
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      "Due: ${DateFormat('MMM d, yyyy').format(task.dueDate)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              // Priority Tag
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getPriorityColor(task.priority).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.priority.toString().split('.').last, // e.g., "High"
                  style: TextStyle(
                    color: getPriorityColor(task.priority),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Floating Action Button to add new tasks
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTaskScreen()),
        );
      },
      backgroundColor: Theme.of(context).colorScheme.secondary, // Use accent color
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      child: const Icon(Icons.add),
    );
  }

  // Bottom Navigation Bar (Placeholder functionality)
  Widget _buildBottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.list, color: Theme.of(context).colorScheme.secondary),
              onPressed: () {
                // TODO: Implement filter/view all tasks
              },
            ),
            const SizedBox(width: 48), // Space for the FAB
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () {
                // TODO: Implement view deleted/archived tasks
              },
            ),
          ],
        ),
      ),
    );
  }
}