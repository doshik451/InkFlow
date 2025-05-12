import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/book_environment_model.dart';

class AboutEnvironmentScreen extends StatefulWidget {
  final BookEnvironmentModel? environment;
  final String bookId;
  final String userId;

  const AboutEnvironmentScreen({
    super.key,
    this.environment,
    required this.bookId,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).requiredField)),
      );
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
          SnackBar(content: Text('${S.current.an_error_occurred}: $e')),
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
                  color: Color.lerp(const Color(0xFFA5C6EA), Colors.white, 0.7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFA5C6EA))
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
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: _titleController,
                          cursorColor: const Color(0xFFA5C6EA),
                          onChanged: (value) => _checkForChanges(),
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: S.of(context).title,
                            labelStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(width: 0.5, color: Color(0xFFA5C6EA)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(width: 1.5, color: Color(0xFFA5C6EA)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: _descriptionController,
                          maxLines: null,
                          minLines: 3,
                          onChanged: (value) => _checkForChanges(),
                          keyboardType: TextInputType.multiline,
                          cursorColor: const Color(0xFFA5C6EA),
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: S.of(context).description,
                            labelStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(width: 0.5, color: Color(0xFFA5C6EA)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(width: 1.5, color: Color(0xFFA5C6EA)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10,),

                        TextField(
                          controller: _featuresController,
                          maxLines: null,
                          minLines: 3,
                          onChanged: (value) => _checkForChanges(),
                          keyboardType: TextInputType.multiline,
                          cursorColor: const Color(0xFFA5C6EA),
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: S.of(context).features,
                            labelStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(width: 0.5, color: Color(0xFFA5C6EA)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(width: 1.5, color: Color(0xFFA5C6EA)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveEnvironment,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFA5C6EA)),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                            ),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator( color: Color(0xFFA5C6EA),)
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

  const EnvironmentImageSlider({
    super.key,
    required this.userId,
    required this.bookId,
    required this.environmentId,
    required this.initialImages,
  });

  @override
  State<EnvironmentImageSlider> createState() => _EnvironmentImageSliderState();
}

class _EnvironmentImageSliderState extends State<EnvironmentImageSlider> {
  final List<String> _imageUrls = [];
  final List<File> _newImages = [];
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrls.addAll(widget.initialImages);
  }

  @override
  Widget build(BuildContext context) {
    final allImages = [..._imageUrls, ..._newImages.map((_) => 'local')];
    final canAddMore = allImages.length < 5;

    return Column(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: const Color(0xFFA5C6EA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              if (allImages.isEmpty)
                const Center(child: Icon(Icons.image, size: 50, color: Colors.white))
              else
                PageView.builder(
                  controller: _pageController,
                  itemCount: allImages.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (ctx, index) {
                    final item = allImages[index];
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Center(
                          child: item == 'local'
                              ? Image.file(
                            _newImages[index - _imageUrls.length],
                            fit: BoxFit.cover,
                          ) : CachedNetworkImage(
                            imageUrl: item,
                            fit: BoxFit.cover,
                            placeholder: (ctx, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator( color: Color(0xFFA5C6EA),),
                              ),
                            ),
                            errorWidget: (ctx, url, err) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              if (allImages.length > 1)
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      allImages.length,
                          (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? const Color(0xFFA5C6EA)
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

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (canAddMore)
              IconButton(
                icon: const Icon(Icons.add_photo_alternate, color: Colors.black),
                onPressed: _addImage,
              ),

            if (allImages.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.black),
                onPressed: _deleteCurrentImage,
              ),
          ],
        ),

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator( color: Color(0xFFA5C6EA),),
          ),
      ],
    );
  }

  Future<void> _addImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        _newImages.add(File(pickedFile.path));
        _currentPage = _imageUrls.length + _newImages.length - 1;
        _pageController.jumpToPage(_currentPage);
      });
    }
  }

  Future<void> _deleteCurrentImage() async {
    if (_currentPage < _imageUrls.length) {
      setState(() => _isLoading = true);
      try {
        final url = _imageUrls[_currentPage];
        await FirebaseStorage.instance.refFromURL(url).delete();
        setState(() => _imageUrls.removeAt(_currentPage));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).an_error_occurred}: $e')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      setState(() {
        _newImages.removeAt(_currentPage - _imageUrls.length);
      });
    }

    if (_currentPage > 0 && _currentPage >= _imageUrls.length + _newImages.length) {
      _currentPage = _imageUrls.length + _newImages.length - 1;
    }
    _pageController.jumpToPage(_currentPage);
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

      return resultUrls;
    } catch (e) {
      rethrow;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}