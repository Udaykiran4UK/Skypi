import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/task.dart';

class IndividualProjectScreen extends StatefulWidget {
  final String category;
  final ValueChanged<double> onProgressUpdated;

  const IndividualProjectScreen({
    super.key,
    required this.category,
    required this.onProgressUpdated,
  });

  @override
  _IndividualProjectScreenState createState() =>
      _IndividualProjectScreenState();
}

class _IndividualProjectScreenState extends State<IndividualProjectScreen> {
  List<Task> completedTasks = [];

  @override
  void initState() {
    super.initState();
    fetchCompletedTasks();
  }

  // Fetch tasks from Firestore collection 'completed_task'
  Future<void> fetchCompletedTasks() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('completed_task')
          .where('category', isEqualTo: widget.category) // Filter by category
          .get();

      if (snapshot.docs.isEmpty) {
        throw 'No tasks found in the completed_task collection.';
      }

      List<Task> fetchedTasks = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Debugging: Print fetched data to ensure fields exist
        print('Fetched data: $data');

        // Check the percentage field exists and handle conversion
        double percentage = 0.0;
        if (data['percentage'] != null) {
          if (data['percentage'] is num) {
            percentage = (data['percentage'] as num).toDouble();
          } else if (data['percentage'] is String) {
            // Handle percentage as string (e.g., '86.00%')
            String percentageStr = data['percentage'];
            percentageStr = percentageStr.replaceAll('%', '').trim();
            percentage = double.tryParse(percentageStr) ?? 0.0;
          } else {
            print('Error: percentage field is not a num or String');
          }
        } else {
          print('Warning: percentage field is missing in document ${doc.id}');
        }

        return Task(
          taskName: data['task_name'] ?? 'Unnamed Task',
          category: data['category'] ?? 'Uncategorized',
          feedback: data['feedback'] ?? 'No feedback',
          percentage: percentage,
        );
      }).toList();

      setState(() {
        completedTasks = fetchedTasks;
      });

      // Calculate the total progress and update the parent screen
      double totalPercentage = _calculateTotalPercentage(fetchedTasks);
      widget.onProgressUpdated(totalPercentage / 100);
    } catch (e) {
      print('Error fetching tasks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching completed tasks: $e')),
      );
    }
  }

  // Calculate the total percentage of all completed tasks
  double _calculateTotalPercentage(List<Task> completedTasks) {
    if (completedTasks.isEmpty) return 0.0;
    double totalCompletion =
    completedTasks.fold(0.0, (sum, task) => sum + task.percentage);
    return totalCompletion / completedTasks.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.category,
            style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold, color: Colors.green)        ),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: completedTasks.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          children: [
            const Text(
              'Your Tasks',
              style:
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...completedTasks.map((task) => _buildTaskCard(task)),
          ],
        ),
      ),
    );
  }

  // Build task card with category, task name, feedback, and percentage
  Widget _buildTaskCard(Task task) {
    return Card(
      child: ListTile(
        title: Text(
          task.taskName, // Display the task name
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${task.category}'), // Display the task category
            Text('Feedback: ${task.feedback}'), // Display feedback
          ],
        ),
        trailing: CircularPercentIndicator(
          radius: 25.0,
          lineWidth: 5.0,
          percent: task.percentage / 100.0, // Use percentage
          center: Text(
            '${task.percentage}%',
            style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
          ),
          progressColor: Colors.green,
        ),
      ),
    );
  }
}
