import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../generated/l10n.dart';
import '../../../../models/book_character_model.dart';
import '../../../../models/book_writer_model.dart';

class CharacterReferencesScreen extends StatefulWidget {
  final Character character;
  final String bookId;
  final String userId;
  final Status status;

  const CharacterReferencesScreen({
    super.key,
    required this.character,
    required this.bookId,
    required this.userId,
    required this.status
  });

  @override
  State<CharacterReferencesScreen> createState() =>
      _CharacterReferencesScreenState();
}

class _CharacterReferencesScreenState extends State<CharacterReferencesScreen> {
  late CharacterImages _characterImages;
  final GlobalKey<_CharacterReferenceCardState> _appearanceKey = GlobalKey();
  final GlobalKey<_CharacterReferenceCardState> _clothingKey = GlobalKey();
  final GlobalKey<_CharacterReferenceCardState> _moodboardKey = GlobalKey();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _characterImages = widget.character.images ?? CharacterImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.character.name),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                  minWidth: 300,
                ),
                child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CharacterReferenceCard(
                          key: _appearanceKey,
                          title: S.of(context).appearance,
                          initialImages: _characterImages.appearance,
                          characterId: widget.character.id,
                          userId: widget.userId,
                          bookId: widget.bookId,
                          category: 'appearance',
                          status: widget.status,
                        ),
                        CharacterReferenceCard(
                          key: _clothingKey,
                          title: S.of(context).clothing,
                          initialImages: _characterImages.clothing,
                          characterId: widget.character.id,
                          userId: widget.userId,
                          bookId: widget.bookId,
                          category: 'clothing',
                          status: widget.status,
                        ),
                        CharacterReferenceCard(
                          key: _moodboardKey,
                          title: S.of(context).moodboard,
                          initialImages: _characterImages.moodboard,
                          characterId: widget.character.id,
                          userId: widget.userId,
                          bookId: widget.bookId,
                          category: 'moodboard',
                          status: widget.status,
                        ),
                        const SizedBox(height: 8,),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveAllReferences,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all<Color>(widget.status.color),
                              padding: WidgetStateProperty.all<EdgeInsets>(
                                const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                              ),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator( color: widget.status.color,)
                                : Text(
                              S.of(context).save,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16,)
                      ],
                    ),
                  ),
              ),
            ),
          ),
    );
  }

  Future<void> _saveAllReferences() async {
    try {
      setState(() => _isLoading = true);

      final isAnyLoading = [
        _appearanceKey.currentState?._isLoading,
        _clothingKey.currentState?._isLoading,
        _moodboardKey.currentState?._isLoading,
      ].any((loading) => loading == true);

      if (isAnyLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context).waitForImageUpload,
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: Color.lerp(widget.status.color, Colors.white, 0.7),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      final CharacterImages updatedImages = CharacterImages(
        mainImage: _characterImages.mainImage,
        appearance: await _getUpdatedImages('appearance'),
        clothing: await _getUpdatedImages('clothing'),
        moodboard: await _getUpdatedImages('moodboard'),
      );

      await _updateCharacterImages(updatedImages);
      await _updateBook();
      await _reloadCharacter();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).allReferencesSaved,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(widget.status.color, Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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
  }

  Future<List<ImageReference>> _getUpdatedImages(String category) async {
    try {
      switch (category) {
        case 'appearance':
          return await _appearanceKey.currentState!.uploadImages();
        case 'clothing':
          return await _clothingKey.currentState!.uploadImages();
        case 'moodboard':
          return await _moodboardKey.currentState!.uploadImages();
        default:
          return [];
      }
    } catch (e) {
      debugPrint('${S.of(context).an_error_occurred} $category: $e');
      return [];
    }
  }

  Future<void> _updateCharacterImages(CharacterImages images) async {
    final updateDate = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    final updates = {
      'images': images.toMap(),
      'lastUpdate': formatter.format(updateDate),
    };

    await FirebaseDatabase.instance
        .ref(
            'books/${widget.userId}/${widget.bookId}/characters/${widget.character.id}')
        .update(updates);
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

  Future<void> _reloadCharacter() async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('books/${widget.userId}/${widget.bookId}/characters/${widget.character.id}')
          .get();

      if (snapshot.exists) {
        final characterData = snapshot.value as Map<dynamic, dynamic>;
        final updatedCharacter = Character.fromMap(widget.character.id, characterData);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CharacterReferencesScreen(
              character: updatedCharacter,
              userId: widget.userId,
              bookId: widget.bookId,
              status: widget.status,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error reloading character: $e');
    }
  }
}

class CharacterReferenceCard extends StatefulWidget {
  final String title;
  final List<ImageReference> initialImages;
  final String characterId;
  final String userId;
  final String bookId;
  final String category;
  final Status status;

  const CharacterReferenceCard({
    super.key,
    required this.title,
    required this.initialImages,
    required this.characterId,
    required this.userId,
    required this.bookId,
    required this.category,
    required this.status
  });

  @override
  State<CharacterReferenceCard> createState() => _CharacterReferenceCardState();
}

class _CharacterReferenceCardState extends State<CharacterReferenceCard> {
  final List<String> _imageUrls = [];
  final List<File> _newImages = [];
  final List<String> _linkUrls = [];
  final List<TextEditingController> _captionControllers = [];
  final List<TextEditingController> _linkCaptionControllers = [];
  final TextEditingController _linkUrlController = TextEditingController();
  final TextEditingController _linkLabelController = TextEditingController();
  late PageController _pageController;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _showLinkInput = false;
  final TextEditingController _linkInputController = TextEditingController();
  final _linkFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    final images = widget.initialImages.where((img) => !img.isLink).toList();
    final links = widget.initialImages.where((img) => img.isLink).toList();

    _imageUrls.addAll(images.map((img) => img.url));
    _linkUrls.addAll(links.map((img) => img.url));

    _captionControllers.addAll(widget.initialImages
        .map((img) => TextEditingController(text: img.caption)));

    _linkCaptionControllers
        .addAll(links.map((img) => TextEditingController(text: img.caption)));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _linkInputController.dispose();
    _linkUrlController.dispose();
    _linkLabelController.dispose();
    for (var controller in _captionControllers) {
      controller.dispose();
    }
    for (var controller in _linkCaptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _addImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        _newImages.add(File(pickedFile.path));
        _captionControllers.add(TextEditingController());
        _updateCurrentPage();
      });
      _jumpToCurrentPage();
    }
  }

  void _toggleLinkInput() {
    setState(() {
      _showLinkInput = !_showLinkInput;
      if (!_showLinkInput) {
        _linkInputController.clear();
      }
    });
  }

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

  Future<void> _updateBook() async {
    final updateDate = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    final updates = {
      'lastUpdate': formatter.format(updateDate),
    };

    await FirebaseDatabase.instance
        .ref(
        'books/${widget.userId}/${widget.bookId}/characters/${widget.characterId}')
        .update(updates);

    await FirebaseDatabase.instance
        .ref(
        'books/${widget.userId}/${widget.bookId}')
        .update(updates);
  }

  Future<void> _deleteCurrentItem() async {
    if (!_pageController.hasClients) return;

    final isLink = _currentPage >= _imageUrls.length + _newImages.length;
    final isExistingImage = _currentPage < _imageUrls.length;

    if (isExistingImage) {
      setState(() => _isLoading = true);
      try {
        final url = _imageUrls[_currentPage];
        await FirebaseStorage.instance.refFromURL(url).delete();
        await _updateBook();
        setState(() {
          _imageUrls.removeAt(_currentPage);
          _captionControllers.removeAt(_currentPage);
        });
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
        final linkIndex =
            _currentPage - (_imageUrls.length + _newImages.length);
        _linkUrls.removeAt(linkIndex);
        _linkCaptionControllers.removeAt(linkIndex);
      });
    } else {
      setState(() {
        _newImages.removeAt(_currentPage - _imageUrls.length);
        _captionControllers.removeAt(_currentPage);
      });
    }

    if (mounted) {
      final newPage = (_currentPage > 0 && _currentPage >= totalItems)
          ? totalItems - 1
          : max(0, _currentPage - 1);

      setState(() => _currentPage = newPage);
      _jumpToCurrentPage();
    }
  }

  Future<List<ImageReference>> uploadImages() async {
    setState(() => _isLoading = true);
    final List<ImageReference> result = [];

    try {
      for (int i = 0; i < _imageUrls.length; i++) {
        result.add(ImageReference(
          url: _imageUrls[i],
          caption: _captionControllers[i].text,
          addedAt: widget.initialImages[i].addedAt ?? DateTime.now(),
          isLink: false,
        ));
      }

      for (int i = 0; i < _newImages.length; i++) {
        final fileName =
            '${widget.category}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final ref = FirebaseStorage.instance.ref(
            'characterImages/${widget.bookId}/${widget.characterId}/${widget.category}/$fileName');

        final compressedImage = await _compressImage(_newImages[i]);
        if (compressedImage != null) {
          await ref.putData(compressedImage);
          await _updateBook();
          final url = await ref.getDownloadURL();
          result.add(ImageReference(
            url: url,
            caption: _captionControllers[_imageUrls.length + i].text,
            addedAt: DateTime.now(),
            isLink: false,
          ));
        }
      }

      for (int i = 0; i < _linkUrls.length; i++) {
        result.add(ImageReference(
          url: _linkUrls[i],
          caption: _linkCaptionControllers[i].text,
          addedAt: DateTime.now(),
          isLink: true,
        ));
      }

      return result;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Uint8List?> _compressImage(File file) async {
    try {
      return await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
        format: CompressFormat.jpeg,
      );
    } catch (e) {
      debugPrint('${S.of(context).an_error_occurred}: $e');
      return null;
    }
  }

  int get totalItems =>
      _imageUrls.length + _newImages.length + _linkUrls.length;

  bool get canAddMore => totalItems < 5;

  void _updateCurrentPage() {
    _currentPage = totalItems - 1;
  }

  void _jumpToCurrentPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allItems = [
      ..._imageUrls,
      ..._newImages.map((_) => 'local'),
      ..._linkUrls.map((_) => 'link'),
    ];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Color.lerp(widget.status.color, Colors.white, 0.7),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.black,
                  ),
            ),
            const SizedBox(height: 10),
            _buildImageSlider(allItems, widget.status),
            if (_showLinkInput) _buildLinkInputField(widget.status),
            if (_currentPage < _captionControllers.length) _buildCaptionField(widget.status),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider(List<String> allItems, Status status) {
    final canAddMore = allItems.length < 5;
    return Column(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: status.color,
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
                        if (item == 'link') {
                          final linkIndex = index - (_imageUrls.length + _newImages.length);
                          _openLink(_linkUrls[linkIndex]);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Center(
                            child: _buildItemContent(item, index, status),
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
                              ? status.color
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
            if (canAddMore) ...[
              IconButton(
                icon: const Icon(Icons.add_photo_alternate, color: Colors.black,),
                onPressed: _addImage,
              ),
              IconButton(
                icon: const Icon(Icons.link, color: Colors.black,),
                onPressed: _toggleLinkInput,
              ),
            ],
            if (allItems.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.black,),
                onPressed: _deleteCurrentItem,
              ),
          ],
        ),

        if (_isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(color: status.color),
          ),
      ],
    );
  }

  Widget _buildItemContent(String item, int index, Status status) {
    if (item == 'local') {
      return Image.file(
        _newImages[index - _imageUrls.length],
        fit: BoxFit.cover,
      );
    } else if (item == 'link') {
      final linkIndex = index - (_imageUrls.length + _newImages.length);
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: _linkUrls[linkIndex],
            fit: BoxFit.cover,
            placeholder: (ctx, url) => Container(
              color: Colors.grey[300],
              child: Center(
                child: CircularProgressIndicator(color: status.color),
              ),
            ),
            errorWidget: (ctx, url, err) => Container(
              color: Colors.grey[300],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.link, size: 40, color: Colors.black,),
                  Text(_linkUrls[linkIndex], style: const TextStyle(color: Colors.black),),
                ],
              ),
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
            child: CircularProgressIndicator(color: status.color),
          ),
        ),
        errorWidget: (ctx, url, err) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      );
    }
  }

  Widget _buildLinkInputField(Status status) {
    final TextEditingController linkUrlController = TextEditingController();
    final TextEditingController linkLabelController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Form(
        key: _linkFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: linkUrlController,
              cursorColor: status.color,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: S.of(context).imageLink,
                labelStyle: const TextStyle(color: Colors.black),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(width: 0.5, color: status.color),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(width: 1.5, color: status.color),
                ),
              ),
              validator: (value) =>
                  _validateLink(value) ? null : S.of(context).enterValidUrl,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: linkLabelController,
              cursorColor: status.color,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: S.of(context).linkCaptionOptional,
                labelStyle: const TextStyle(color: Colors.black),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(width: 0.5, color: status.color),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(width: 1.5, color: status.color),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                if (_linkFormKey.currentState!.validate() &&
                    _linkUrls.length < 5) {
                  setState(() {
                    _linkUrls.add(linkUrlController.text.trim());
                    _linkCaptionControllers.add(TextEditingController(
                        text: linkLabelController.text.trim()));
                    linkUrlController.clear();
                    linkLabelController.clear();
                    _showLinkInput = false;
                    _updateCurrentPage();
                  });
                  _jumpToCurrentPage();
                }
              },
              icon: const Icon(Icons.check),
              label: Text(S.of(context).addLink),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(status.color),
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

  Widget _buildCaptionField(Status status) {
    final isLink = _currentPage >= _imageUrls.length + _newImages.length;
    final controller = isLink
        ? _linkCaptionControllers[
            _currentPage - (_imageUrls.length + _newImages.length)]
        : _captionControllers[_currentPage];

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: controller,
        cursorColor: status.color,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: S.of(context).notes,
          labelStyle: const TextStyle(color: Colors.black),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(width: 0.5, color: status.color),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(width: 1.5, color: status.color),
          ),
        ),
        maxLength: 100,
        onChanged: (value) {
          if (isLink) {
            final linkIndex =
                _currentPage - (_imageUrls.length + _newImages.length);
            if (linkIndex < _linkCaptionControllers.length) {
              _linkCaptionControllers[linkIndex].text = value;
            }
          } else {
            if (_currentPage < _captionControllers.length) {
              _captionControllers[_currentPage].text = value;
            }
          }
        },
      ),
    );
  }
}
