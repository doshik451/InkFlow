import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../generated/l10n.dart';
import '../../../models/read_book_model.dart';
import '../../general/base/confirm_delete_base.dart';

class MomentsScreen extends StatefulWidget {
  final FinishedBook book;
  final String userId;
  final BookCategory category;

  const MomentsScreen({
    super.key,
    required this.book,
    required this.userId,
    required this.category,
  });

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends State<MomentsScreen> {
  bool _hasUnsavedData = false;
  final List<BookMoment> _moments = [];
  final Map<String, TextEditingController> _controllers = {};
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  bool _isTextExpanded = true;
  bool _isImageExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadMoments();
  }

  void _loadMoments() async {
    _moments.clear();
    _controllers.forEach((_, c) => c.dispose());
    _controllers.clear();

    final momentsRef = _databaseReference
        .child('finishedBooks/${widget.userId}/${widget.book.id}/moments');

    final snapshot = await momentsRef.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      data.forEach((id, value) {
        final moment = BookMoment.fromMap(id, Map<String, dynamic>.from(value));
        _moments.add(moment);

        if (moment.type == 'text') {
          _controllers[moment.id] = TextEditingController(text: moment.content);
        }
      });
      _moments.sort((a, b) => a.id.compareTo(b.id));
    }

    setState(() {});
  }

  String _generateMomentId() => DateTime.now().microsecondsSinceEpoch.toString();

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _saveMoments() async {
    for (var moment in _moments.where((m) => m.type == 'text')) {
      final controller = _controllers[moment.id];
      if (controller != null) {
        moment.content = controller.text;
      }
    }

    final bookData = widget.book.toMap();

    final updatedBook = {
      ...bookData,
      'moments': _moments.map((m) => m.toMap()).toList(),
    };

    try {
      final momentsRef = _databaseReference
          .child('finishedBooks/${widget.userId}/${widget.book.id}/moments');

      final snapshot = await momentsRef.get();
      final existingIds = <String>{};
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        existingIds.addAll(data.keys);
      }

      final currentIds = _moments.map((m) => m.id).toSet();
      final batchUpdate = <String, dynamic>{};
      for (var moment in _moments) {
        batchUpdate[moment.id] = moment.toMap();
      }

      for (var id in existingIds.difference(currentIds)) {
        batchUpdate[id] = null;
      }

      await momentsRef.update(batchUpdate);

      if (mounted) {
        Navigator.pop(context, {
          'reload': true,
          'book': FinishedBook.fromMap(widget.book.id, updatedBook),
        });
      }
    } catch (e) {
      print('Error saving moments: $e');
    }
  }

  void _removeMoment(BookMoment moment) {
    setState(() {
      _moments.remove(moment);
      _controllers.remove(moment.id)?.dispose();
      _hasUnsavedData = true;
    });
  }

  void _addTextMoment() {
    final newId = _generateMomentId();
    setState(() {
      _moments.add(BookMoment(
        id: newId,
        type: 'text',
        content: '',
      ));
      _controllers[newId] = TextEditingController();
      _hasUnsavedData = true;
    });
  }

  void _addImageMoment() async {
    final newMoment = BookMoment(
      id: const Uuid().v4(),
      type: 'image',
      content: '',
    );

    setState(() {
      _moments.add(newMoment);
      _hasUnsavedData = true;
    });

    await _pickAndUploadImage(newMoment);
  }

  Future<void> _pickAndUploadImage(BookMoment moment) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = path.basename(pickedFile.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('momentsImages/${widget.userId}/${moment.id}/$fileName');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      setState(() {
        moment.content = downloadUrl;
        _hasUnsavedData = true;
      });
    }
  }

  Widget _buildTextMomentCard(BookMoment moment) {
    final controller = _controllers[moment.id];
    if (controller == null) {
      return const SizedBox();
    }

    return Card(
      color: Color.lerp(
          Color(int.parse(widget.category.colorCode)), Colors.white, 0.5),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                cursorColor: Color(int.parse(widget.category.colorCode)),
                style: const TextStyle(color: Colors.black),
                maxLines: null,
                decoration: InputDecoration(
                  labelText: S.of(context).moment,
                  labelStyle: const TextStyle(color: Colors.black),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        width: 1,
                        color: Color.lerp(
                            Color(int.parse(widget.category.colorCode)),
                            Colors.black,
                            0.2)!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        width: 1.5,
                        color: Color.lerp(
                            Color(int.parse(widget.category.colorCode)),
                            Colors.black,
                            0.2)!),
                  ),
                ),
                onChanged: (val) {
                  moment.content = val;
                  _hasUnsavedData = true;
                },
              ),
            ),
            IconButton(
              alignment: Alignment.center,
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () async {
                final shouldDelete = await confirmDelete(context);
                if (shouldDelete ?? false) {
                  _controllers.remove(moment.id);
                  _removeMoment(moment);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMomentCard(BookMoment moment) {
    final hasImage = moment.content.isNotEmpty;

    return Card(
      color: Color.lerp(
          Color(int.parse(widget.category.colorCode)), Colors.white, 0.5),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          GestureDetector(
            onTap: hasImage
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageViewer(imageUrl: moment.content),
                ),
              );
            }
                : () async {
              await _pickAndUploadImage(moment);
            },
            child: Container(
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color.lerp(Color(int.parse(widget.category.colorCode)),
                    Colors.white, 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color.lerp(Color(int.parse(widget.category.colorCode)),
                      Colors.black, 0.2)!,
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: hasImage
                  ? Image.network(
                moment.content,
                fit: BoxFit.contain,
                width: double.infinity,
                height: 200,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(color: Color.lerp(Color(int.parse(widget.category.colorCode)),
                        Colors.black, 0.2)!,),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image)),
              )
                  : Text(
                S.of(context).add_image,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ),
          if (hasImage)
            Positioned(
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () async {
                  final shouldDelete = await confirmDelete(context);
                  if (shouldDelete ?? false) {
                    _removeMoment(moment);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  List<BookMoment> get _textMoments =>
      _moments.where((m) => m.type == 'text').toList();

  List<BookMoment> get _imageMoments =>
      _moments.where((m) => m.type == 'image').toList();

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color.lerp(
      Color(int.parse(widget.category.colorCode)),
      Colors.white,
      0.6,
    );

    return PopScope(
      canPop: !_hasUnsavedData,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (_hasUnsavedData) {
          final shouldLeave = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(S.of(context).unsaved_data),
              content: Text(S.of(context).want_to_save),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(S.of(context).no, style: TextStyle(color: Theme.of(context).colorScheme.tertiary),),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    _saveMoments();
                  },
                  child: Text(S.of(context).save, style: TextStyle(color: Theme.of(context).colorScheme.tertiary),),
                ),
              ],
            ),
          );
          if (shouldLeave == true && mounted) Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.book.title}: ${S.of(context).moments}'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: Color(int.parse(widget.category.colorCode))),
            ),
            elevation: 3,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                          color: Color(int.parse(widget.category.colorCode))),
                    ),
                    elevation: 3,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        title: Text(S.of(context).text_moments,
                          style: const TextStyle(color: Colors.black),),
                        trailing: Icon(
                          _isTextExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Colors.black,
                        ),
                        initiallyExpanded: _isTextExpanded,
                        onExpansionChanged: (val) =>
                            setState(() => _isTextExpanded = val),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ..._textMoments
                                    .map(_buildTextMomentCard)
                                    .toList(),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _addTextMoment,
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty
                                        .all<Color>(Color.lerp(
                                              Color(int.parse(
                                                  widget.category.colorCode)),
                                              Colors.white,
                                              0.2,
                                            ) ??
                                            Colors.white),
                                  ),
                                  label: Text(
                                    S.of(context).add_moment,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                          color: Color(int.parse(widget.category.colorCode))),
                    ),
                    elevation: 3,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        title: Text(S.of(context).image_moments,
                          style: const TextStyle(color: Colors.black),),
                        trailing: Icon(
                          _isImageExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Colors.black,
                        ),
                        initiallyExpanded: _isImageExpanded,
                        onExpansionChanged: (val) =>
                            setState(() => _isImageExpanded = val),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ..._imageMoments
                                    .map(_buildImageMomentCard)
                                    .toList(),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _addImageMoment,
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty
                                        .all<Color>(Color.lerp(
                                              Color(int.parse(
                                                  widget.category.colorCode)),
                                              Colors.white,
                                              0.2,
                                            ) ??
                                            Colors.white),
                                  ),
                                  label: Text(
                                    S.of(context).add_moment,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: _saveMoments,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            Color(int.parse(widget.category.colorCode))),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 6),
                        ),
                      ),
                      child: Text(
                        S.of(context).save,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
