import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:universal_viewer/universal_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universal Viewer Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  String? _currentUrl;
  PlatformFile? _currentFile;
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _currentFile = result.files.first;
          _currentUrl = null;
        });
      }
    } catch (e) {
      _showError('Failed to pick file: $e');
    }
  }

  void _loadUrl() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        _currentUrl = url;
        _currentFile = null;
      });
    }
  }

  void _loadExample(String url) {
    _urlController.text = url;
    _loadUrl();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universal Viewer Demo'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // URL Input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          labelText: 'Enter URL',
                          hintText: 'https://example.com',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                        ),
                        onSubmitted: (_) => _loadUrl(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _loadUrl,
                      child: const Text('Load'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quick Examples
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildExampleChip(
                      'DuckDuckGo',
                      'https://duckduckgo.com',
                      Icons.search,
                    ),
                    _buildExampleChip(
                      'PDF Sample',
                      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
                      Icons.picture_as_pdf,
                    ),
                    _buildExampleChip(
                      'YouTube',
                      'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                      Icons.play_circle,
                    ),
                    _buildExampleChip(
                      'Image',
                      'https://picsum.photos/800/600',
                      Icons.image,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // File Picker
                OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Pick File from Device'),
                ),
              ],
            ),
          ),

          // Viewer
          Expanded(
            child: _buildViewer(),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleChip(String label, String url, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () => _loadExample(url),
    );
  }

  Widget _buildViewer() {
    if (_currentUrl != null) {
      return UniversalViewer(
        url: _currentUrl,
        config: ViewerConfig(
          theme: const ViewerTheme(
            toolbarHeight: 60,
          ),
          onLoadStart: () => debugPrint('Loading...'),
          onLoadComplete: () => debugPrint('Loaded!'),
          onError: (error) => _showError(error),
        ),
      );
    }

    if (_currentFile != null) {
      return UniversalViewer.file(
        _currentFile!,
        config: ViewerConfig(
          theme: const ViewerTheme(
            primaryColor: Colors.green,
            toolbarHeight: 60,
          ),
          onLoadStart: () => debugPrint('Loading file...'),
          onLoadComplete: () => debugPrint('File loaded!'),
          onError: (error) => _showError(error),
        ),
      );
    }

    // Empty state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.visibility, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No content loaded',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a URL or pick a file to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
