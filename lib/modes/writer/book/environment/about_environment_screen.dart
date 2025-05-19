import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/book_writer_model.dart';
import 'package:intl/intl.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/book_environment_model.dart';

class AboutEnvironmentScreen extends StatefulWidget {
  final BookEnvironmentModel? environment;
  final String bookId;
  final Status status;
  final String userId;

  const AboutEnvironmentScreen({
    super.key,
    this.environment,
    required this.bookId,
    required this.status,
    required this.userId
  });

  @override
  State<AboutEnvironmentScreen> createState() => _AboutEnvironmentScreenState();
}

class _AboutEnvironmentScreenState extends State<AboutEnvironmentScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _featuresController;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final List<File> _imageFiles = [];
  final _sliderKey = GlobalKey<_EnvironmentImageSliderState>();

  late String _initialTitle;
  late String _initialDescription;
  late String _initialFeatures;
  bool _hasUnsavedData = false;
  bool _isSaving = false;
  bool _showTitleError = false;
  bool _showDescriptionError = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.environment?.title ?? '');
    _descriptionController = TextEditingController(text: widget.environment?.description ?? '');
    _featuresController = TextEditingController(text: widget.environment?.features ?? '');

    _initialTitle = _titleController.text;
    _initialDescription = _descriptionController.text;
    _initialFeatures = _featuresController.text;
  }

  void _checkForChanges() {
    final hasTitleChanged = _titleController.text != _initialTitle;
    final hasDescriptionChanged = _descriptionController.text != _initialDescription;
    final hasFeaturesChanged = _featuresController.text != _initialFeatures;

    setState(() {
      _hasUnsavedData = hasTitleChanged || hasDescriptionChanged || hasFeaturesChanged;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  Future<void> _updateBook() async {
    final updateDate = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    final updates = {
      'lastUpdate': formatter.format(updateDate),
    };

    await FirebaseDatabase.instance
        .ref(
        'books/${widget.userId}/${widget.bookId}')
        .update(updates);
  }

  Future<void> _saveEnvironment() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final features = _featuresController.text.trim();

    if(title.isEmpty || description.isEmpty) {
      setState(() {
        _showDescriptionError = description.isEmpty;
        _showTitleError = title.isEmpty;
      });
      return;
    }

    try {
      setState(() => _isSaving = true);
      final updateDate = DateTime.now();
      final formatter = DateFormat('yyyy-MM-dd HH:mm');

      String? environmentId;
      DatabaseReference envRef;

      if (widget.environment != null) {
        environmentId = widget.environment!.id;
        envRef = _databaseReference.child('books/${widget.userId}/${widget.bookId}/environment/$environmentId');
      } else {
        envRef = _databaseReference.child('books/${widget.userId}/${widget.bookId}/environment').push();
        environmentId = envRef.key;
      }

      final slider = _sliderKey.currentState!;
      final imageUrls = await slider.uploadAllImages();

      final environmentData = {
        'title': title,
        'description': description,
        'features': features,
        'images': imageUrls,
        'lastUpdate': formatter.format(updateDate),
      };

      await envRef.set(environmentData);
      await _updateBook();

      if (mounted) {
        setState(() {
          _initialTitle = title;
          _initialDescription = description;
          _initialFeatures = features;
          _hasUnsavedData = false;
        });
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.current.an_error_occurred}: $e',
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: Color.lerp(widget.status.color, Colors.white, 0.7),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedData,
      onPopInvoked: (bool didPop) async {
        if(didPop) return;
        if(_hasUnsavedData){
          final shouldLeave = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(S.of(context).unsaved_data),
                content: Text(S.of(context).want_to_save),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(S.of(context).no,
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary)
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      _saveEnvironment();
                    },
                    child: Text(S.of(context).save,
                      style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ),
                ],
              )
          );
          if (shouldLeave == true && mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.environment != null ? widget.environment!.title : S.of(context).creating),
          centerTitle: true,
        ),
        body: Center(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
                minWidth: 300,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Color.lerp(widget.status.color, Colors.white, 0.7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: widget.status.color)
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        EnvironmentImageSlider(
                          key: _sliderKey,
                          userId: widget.userId,
                          bookId: widget.bookId,
                          environmentId: widget.environment?.id ?? 'temp',
                          initialImages: widget.environment?.images ?? [],
                          status: widget.status,
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: _titleController,
                          cursorColor: widget.status.color,
                          onChanged: (value) => _checkForChanges(),
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: S.of(context).title,
                            labelStyle: const TextStyle(color: Colors.black),
                            errorText: _showTitleError ? S.of(context).requiredField : null,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 0.5, color: widget.status.color),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 1.5, color: widget.status.color),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  width: 1.5, color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  width: 1.5, color: Colors.red),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: _descriptionController,
                          maxLines: null,
                          minLines: 3,
                          onChanged: (value) => _checkForChanges(),
                          keyboardType: TextInputType.multiline,
                          cursorColor: widget.status.color,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: S.of(context).description,
                            labelStyle: const TextStyle(color: Colors.black),
                            errorText: _showDescriptionError ? S.of(context).requiredField : null,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 0.5, color: widget.status.color),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 1.5, color: widget.status.color),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  width: 1.5, color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  width: 1.5, color: Colors.red),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16,),

                        TextField(
                          controller: _featuresController,
                          maxLines: null,
                          minLines: 3,
                          onChanged: (value) => _checkForChanges(),
                          keyboardType: TextInputType.multiline,
                          cursorColor: widget.status.color,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: S.of(context).features,
                            labelStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 0.5, color: widget.status.color),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 1.5, color: widget.status.color),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveEnvironment,
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(widget.status.color),
                            padding: WidgetStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                            ),
                          ),
                          child: _isSaving
                              ? CircularProgressIndicator( color: widget.status.color,)
                              : Text(
                            S.of(context).save,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EnvironmentImageSlider extends StatefulWidget {
  final String userId;
  final String bookId;
  final String environmentId;
  final List<String> initialImages;
  final Status status;

  const EnvironmentImageSlider({
    super.key,
    required this.userId,
    required this.bookId,
    required this.environmentId,
    required this.initialImages,
    required this.status,
  });

  @override
  State<EnvironmentImageSlider> createState() => _EnvironmentImageSliderState();
}

class _EnvironmentImageSliderState extends State<EnvironmentImageSlider> {
  final List<String> _imageUrls = [];
  final List<File> _newImages = [];
  final List<String> _linkUrls = [];
  final PageController _pageController = PageController();
  final TextEditingController _linkUrlController = TextEditingController();
  final TextEditingController _linkLabelController = TextEditingController();
  int _currentPage = 0;
  bool _isLoading = false;
  bool _showLinkInput = false;
  final _linkFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    for (final url in widget.initialImages) {
      if (url.startsWith('http') && !url.contains('firebasestorage')) {
        _linkUrls.add(url);
      } else {
        _imageUrls.add(url);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _linkUrlController.dispose();
    _linkLabelController.dispose();
    super.dispose();
  }

  List<String> get allItems => [..._imageUrls, ..._newImages.map((_) => 'local'), ..._linkUrls];
  bool get canAddMore => allItems.length < 5;

  bool _validateLink(String? value) {
    if (value == null || value.isEmpty) return false;
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Future<void> _openLink(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${S.of(context).an_error_occurred}: $e',
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(widget.status.color, Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _toggleLinkInput() {
    setState(() {
      _showLinkInput = !_showLinkInput;
      if (!_showLinkInput) {
        _linkUrlController.clear();
        _linkLabelController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: widget.status.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              if (allItems.isEmpty)
                const Center(child: Icon(Icons.image, size: 50, color: Colors.white))
              else
                PageView.builder(
                  controller: _pageController,
                  itemCount: allItems.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (ctx, index) {
                    final item = allItems[index];
                    return GestureDetector(
                      onTap: () {
                        if (item.startsWith('http') && !item.contains('firebasestorage')) {
                          _openLink(item);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Center(
                            child: _buildItemContent(item, index),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              if (allItems.length > 1)
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      allItems.length,
                          (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? widget.status.color
                              : Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        if (_showLinkInput) _buildLinkInputField(),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (canAddMore) ...[
              IconButton(
                icon: const Icon(Icons.add_photo_alternate, color: Colors.black),
                onPressed: _addImage,
              ),
              IconButton(
                icon: const Icon(Icons.link, color: Colors.black),
                onPressed: _toggleLinkInput,
              ),
            ],
            if (allItems.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.black),
                onPressed: _deleteCurrentItem,
              ),
          ],
        ),

        if (_isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(color: widget.status.color),
          ),
      ],
    );
  }

  Widget _buildItemContent(String item, int index) {
    if (item == 'local') {
      return Image.file(
        _newImages[index - _imageUrls.length],
        fit: BoxFit.cover,
      );
    } else if (item.startsWith('http') && !item.contains('firebasestorage')) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.link, size: 40, color: Colors.black),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(4),
              child: Text(
                S.of(context).tapToOpenLink,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    } else {
      return CachedNetworkImage(
        imageUrl: item,
        fit: BoxFit.cover,
        placeholder: (ctx, url) => Container(
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(color: widget.status.color),
          ),
        ),
        errorWidget: (ctx, url, err) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      );
    }
  }

  Widget _buildLinkInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Form(
        key: _linkFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: _linkUrlController,
              cursorColor: widget.status.color,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: S.of(context).imageLink,
                labelStyle: const TextStyle(color: Colors.black),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(width: 0.5, color: widget.status.color),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(width: 1.5, color: widget.status.color),
                ),
              ),
              validator: (value) =>
              _validateLink(value) ? null : S.of(context).enterValidUrl,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                if (_linkFormKey.currentState!.validate() &&
                    _linkUrls.length < 5) {
                  setState(() {
                    _linkUrls.add(_linkUrlController.text.trim());
                    _linkUrlController.clear();
                    _showLinkInput = false;
                    _currentPage = allItems.length;
                  });
                  _pageController.jumpToPage(_currentPage);
                }
              },
              icon: const Icon(Icons.check),
              label: Text(S.of(context).addLink),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(widget.status.color),
                padding: WidgetStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        _newImages.add(File(pickedFile.path));
        _currentPage = _imageUrls.length + _newImages.length - 1;
      });
      _pageController.jumpToPage(_currentPage);
    }
  }

  Future<void> _deleteCurrentItem() async {
    final isLink = _currentPage >= _imageUrls.length + _newImages.length;
    final isExistingImage = _currentPage < _imageUrls.length;

    if (isExistingImage) {
      setState(() => _isLoading = true);
      try {
        final url = _imageUrls[_currentPage];
        await FirebaseStorage.instance.refFromURL(url).delete();
        setState(() => _imageUrls.removeAt(_currentPage));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context).an_error_occurred}: $e',
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: Color.lerp(widget.status.color, Colors.white, 0.7),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else if (isLink) {
      setState(() {
        _linkUrls.removeAt(_currentPage - (_imageUrls.length + _newImages.length));
      });
    } else {
      setState(() {
        _newImages.removeAt(_currentPage - _imageUrls.length);
      });
    }

    if (mounted) {
      final newPage = (_currentPage > 0 && _currentPage >= allItems.length)
          ? allItems.length - 1
          : max(0, _currentPage - 1);

      setState(() => _currentPage = newPage);
      _pageController.jumpToPage(_currentPage);
    }
  }

  Future<List<String>> uploadAllImages() async {
    setState(() => _isLoading = true);
    final List<String> resultUrls = [..._imageUrls];

    try {
      for (final imageFile in _newImages) {
        final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref(
            'environment/${widget.userId}/${widget.bookId}/${widget.environmentId}/$fileName'
        );

        await ref.putFile(imageFile);
        final url = await ref.getDownloadURL();
        resultUrls.add(url);
      }

      resultUrls.addAll(_linkUrls);

      return resultUrls;
    } catch (e) {
      rethrow;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}