import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isLoading = false;

  // Take picture from camera
  Future<void> _takePicture() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      
      if (cameraStatus.isGranted) {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          preferredCameraDevice: CameraDevice.rear,
        );

        if (photo != null) {
          setState(() {
            _image = File(photo.path);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
        setState(() {
          _isLoading = false;
        });
        _showPermissionDialog(
          'Camera Permission Required',
          'Please allow camera access to take photos.',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error opening camera: $e');
    }
  }

  // Pick image from gallery
  Future<void> _pickFromGallery() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Request storage/photos permission
      PermissionStatus storageStatus;
      
      if (Platform.isAndroid) {
        // For Android 13+ (API 33+)
        if (await Permission.photos.isGranted || 
            await Permission.storage.isGranted) {
          storageStatus = PermissionStatus.granted;
        } else {
          // Try photos permission first (Android 13+)
          storageStatus = await Permission.photos.request();
          
          // If photos not available, try storage (Android 12 and below)
          if (storageStatus.isDenied) {
            storageStatus = await Permission.storage.request();
          }
        }
      } else {
        // For iOS
        storageStatus = await Permission.photos.request();
      }
      
      if (storageStatus.isGranted || storageStatus.isLimited) {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );

        if (photo != null) {
          setState(() {
            _image = File(photo.path);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        _showPermissionDialog(
          'Gallery Permission Required',
          'Please allow gallery access to select photos.',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error opening gallery: $e');
    }
  }

  // Retake picture
  void _retakePicture() {
    setState(() {
      _image = null;
    });
  }

  // Show permission dialog
  void _showPermissionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Camera',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    
                    // Image preview or placeholder
                    _image != null
                        ? _buildImagePreview()
                        : _buildPlaceholder(),
                    
                    SizedBox(height: 40),
                    
                    // Action buttons
                    if (_image == null) _buildActionButtons(),
                    
                    if (_image != null) _buildImageActions(),
                  ],
                ),
              ),
            ),
    );
  }

  // Build image preview
  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          _image!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Build placeholder
  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'No Image Selected',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Take a photo or select from gallery',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Build action buttons
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Camera button
        _buildButton(
          icon: Icons.camera_alt,
          label: 'Take Photo',
          onPressed: _takePicture,
          color: Colors.blue,
        ),
        
        SizedBox(height: 16),
        
        // Gallery button
        _buildButton(
          icon: Icons.photo_library,
          label: 'Open Gallery',
          onPressed: _pickFromGallery,
          color: Colors.purple,
        ),
      ],
    );
  }

  // Build image actions
  Widget _buildImageActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildButton(
                icon: Icons.refresh,
                label: 'Retake',
                onPressed: _retakePicture,
                color: Colors.orange,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildButton(
                icon: Icons.check_circle,
                label: 'Use Image',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Image selected successfully!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build custom button
  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}