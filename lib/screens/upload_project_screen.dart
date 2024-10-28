import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore import
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication

class UploadProjectScreen extends StatefulWidget {
  @override
  _UploadProjectScreenState createState() => _UploadProjectScreenState();
}

class _UploadProjectScreenState extends State<UploadProjectScreen> {
  File? _selectedFile;
  String? _fileType;
  VideoPlayerController? _videoController;
  FirebaseStorage? storage; // Declare FirebaseStorage instance here

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isUploading = false;
  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    // Initialize Firebase Storage with the correct bucket
    storage = FirebaseStorage.instanceFor(bucket: 'skypi-8a884.appspot.com');
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('groups').get();
    setState(() {
      _categories = querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedFile = File(pickedFile.path);
        _fileType = 'Image';
      }
    });
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedFile = File(pickedFile.path);
        _fileType = 'Video';
        _videoController = VideoPlayerController.file(_selectedFile!)
          ..initialize().then((_) {
            setState(() {});
            _videoController!.play();
          });
      }
    });
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileType = 'Document';
      });
    }
  }

  Future<void> _deleteFile() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete File'),
          content: Text('Are you sure you want to delete this file?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedFile = null;
                  _fileType = null;
                  _videoController?.dispose();
                  _videoController = null;
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadTask() async {
    if (_titleController.text.isEmpty || _selectedFile == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a title and select a file, and choose a category.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Get current user details
      User? user = FirebaseAuth.instance.currentUser;
      String uploadedBy = user?.displayName ?? user?.email ?? 'Unknown';

      // Use the FirebaseStorage instance with the correct bucket
      String fileName = _selectedFile!.path.split('/').last;
      Reference storageRef = storage!.ref().child('tasks/$fileName');
      UploadTask uploadTask = storageRef.putFile(_selectedFile!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // Save the task details to Firestore
      await FirebaseFirestore.instance.collection('tasks').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'fileURL': downloadURL,
        'status': 'pending',
        'fileType': _fileType,
        'uploadedBy': uploadedBy,  // Save the username or email of the uploader
        'uploadedAt': Timestamp.now(), // Save the upload timestamp
        'category': _selectedCategory,

      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task uploaded successfully!')),
      );

      setState(() {
        _titleController.clear();
        _descriptionController.clear();
        _selectedFile = null;
        _fileType = null;
        _videoController?.dispose();
        _videoController = null;
        _selectedCategory = null;

      });
    } catch (e) {
      print('Error uploading task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload task. Please try again.')),
      );
    }

    setState(() {
      _isUploading = false;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildFilePreview() {
    if (_fileType == 'Image') {
      return Stack(
        children: [
          Image.file(_selectedFile!, fit: BoxFit.cover),
          Positioned(
            right: 0,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteFile,
            ),
          ),
        ],
      );
    } else if (_fileType == 'Video') {
      return Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _videoController!.value.isPlaying
                    ? _videoController!.pause()
                    : _videoController!.play();
              });
            },
            child: _videoController!.value.isInitialized
                ? AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            )
                : Center(child: CircularProgressIndicator()),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteFile,
            ),
          ),
        ],
      );
    } else if (_fileType == 'Document') {
      return Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DocumentPreviewScreen(file: _selectedFile!),
                ),
              );
            },
            child: Center(
              child: Icon(Icons.picture_as_pdf, size: 100, color: Colors.grey),
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteFile,
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_file, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text('Select File', style: TextStyle(fontSize: 16)),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Upload Your Answer', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold, color: Colors.green)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),

              // Title TextField
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Description TextField
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Select Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Select Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // File Preview
              GestureDetector(
                onTap: _pickDocument,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _buildFilePreview(),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image,color: Colors.green),
                    label: Text('Select Image', style: TextStyle(color: Colors.green)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: Icon(Icons.video_library,color: Colors.green,),
                    label: Text('Select Video', style: TextStyle(color: Colors.green)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadTask,
                child: _isUploading
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text(
                  'Upload Task',
                  selectionColor: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DocumentPreviewScreen extends StatelessWidget {
  final File file;

  DocumentPreviewScreen({required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document Preview'),
      ),
      body: PDFView(
        filePath: file.path,
      ),
    );
  }
}
