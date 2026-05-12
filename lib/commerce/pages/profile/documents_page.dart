import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api_service.dart';

class CommercantDocumentsData {
  static final CommercantDocumentsData _instance =
      CommercantDocumentsData._internal();
  factory CommercantDocumentsData() => _instance;
  CommercantDocumentsData._internal();

  File? extraitRc;
  File? cinOuPasseport;
}

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  static const Color backgroundColor = Color(0xFFFEFAE0);
  static const Color cardColor = Color(0xFFFAF8F5);
  static const Color iconBgColor = Color(0xFFCCD5AE);

  final _docs = CommercantDocumentsData();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  bool _isSupportedImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.pdf');
  }

  Future<File?> _pickReplacementImage() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFEFAE0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Choisir le type de fichier',
          style: TextStyle(fontSize: 16, color: Color(0xFF3E2723)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context, 'photo'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCD5AE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, color: Color(0xFF5D4E37)),
                    SizedBox(width: 8),
                    Text(
                      'Photo',
                      style: TextStyle(
                        color: Color(0xFF5D4E37),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.pop(context, 'pdf'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EED8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.picture_as_pdf_outlined,
                      color: Color(0xFF5D4E37),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'PDF',
                      style: TextStyle(
                        color: Color(0xFF5D4E37),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return null;

    if (choice == 'photo') {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2200,
        maxHeight: 2200,
        imageQuality: 92,
      );
      if (picked == null) return null;
      if (!_isSupportedImagePath(picked.path)) return null;
      return File(picked.path);
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.single.path == null) return null;
      return File(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF3E2723),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Documents',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 4, color: iconBgColor),
            if (_isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF5D4E37),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Chargement des documents...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildDocumentCard(
                        context: context,
                        icon: Icons.description_outlined,
                        title: 'Extrait Registre de Commerce',
                        subtitle: 'Expire 12 avril 2026',
                        onTap: () => _handleDocumentTap(context, 'rc'),
                        onLongPress: () => _handleReplaceFromList('rc'),
                      ),
                      const SizedBox(height: 16),
                      _buildDocumentCard(
                        context: context,
                        icon: Icons.credit_card_outlined,
                        title: 'CIN ou Passeport',
                        subtitle: 'Valide jusqu\'en 2029',
                        onTap: () => _handleDocumentTap(context, 'cin'),
                        onLongPress: () => _handleReplaceFromList('cin'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 80,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 36, color: const Color(0xFF5D6E3F)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  File? _fileForType(String docType) {
    switch (docType) {
      case 'rc':
        return _docs.extraitRc;
      case 'cin':
        return _docs.cinOuPasseport;
      default:
        return null;
    }
  }

  void _setFileForType(String docType, File file) {
    switch (docType) {
      case 'rc':
        _docs.extraitRc = file;
        return;
      case 'cin':
        _docs.cinOuPasseport = file;
        return;
    }
  }

  void _handleDocumentTap(BuildContext context, String docType) {
    final file = _fileForType(docType);
    Navigator.push<File?>(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentViewerPage(
          title: docType == 'rc'
              ? 'Extrait Registre de Commerce'
              : 'CIN ou Passeport',
          file: file,
          onPickReplacement: _pickReplacementImage,
        ),
      ),
    ).then((newFile) {
      if (newFile == null) return;
      setState(() => _setFileForType(docType, newFile));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document modifié'),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  Future<void> _handleReplaceFromList(String docType) async {
    final newFile = await _pickReplacementImage();
    if (newFile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisissez une image JPG/PNG ou PDF'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      String? uploadedUrl;

      if (docType == 'rc') {
        uploadedUrl = await ApiService.uploadRcFile(newFile);
      } else if (docType == 'cin') {
        uploadedUrl = await ApiService.uploadCinFile(newFile);
      }

      if (uploadedUrl != null) {
        setState(() {
          _setFileForType(docType, newFile);
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploadé avec succès!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Échec de l\'upload');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'upload: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class DocumentViewerPage extends StatefulWidget {
  const DocumentViewerPage({
    super.key,
    required this.title,
    required this.file,
    required this.onPickReplacement,
  });

  final String title;
  final File? file;
  final Future<File?> Function() onPickReplacement;

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  bool _isPdf(String path) => path.toLowerCase().endsWith('.pdf');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFAE0),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF3E2723),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final replacement = await widget.onPickReplacement();
                      if (replacement == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Choisissez une image JPG/PNG ou PDF',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                        return;
                      }
                      if (context.mounted) Navigator.pop(context, replacement);
                    },
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF5D4E37),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 4, color: const Color(0xFFCCD5AE)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: const Color(0xFFFAF8F5),
                    child: widget.file == null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 44,
                                    color: Color(0xFFBDB5A0),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Aucun document.\nAppuyez sur le crayon pour ajouter.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF9E9E9E),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _isPdf(widget.file!.path)
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9AE63),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  widget.file!.path.split('/').last,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3E2723),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Fichier PDF joint ✓',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : InteractiveViewer(
                            minScale: 1,
                            maxScale: 4,
                            child: Image.file(
                              widget.file!,
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
