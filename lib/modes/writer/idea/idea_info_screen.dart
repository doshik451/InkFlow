import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../../models/idea_model.dart';
import 'package:intl/intl.dart';

import '../../../../generated/l10n.dart';

class IdeaInfoScreen extends StatefulWidget {
  final Idea? idea;
  const IdeaInfoScreen({super.key, this.idea});

  @override
  State<IdeaInfoScreen> createState() => _IdeaInfoScreenState();
}

class _IdeaInfoScreenState extends State<IdeaInfoScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final ScrollController _scrollController = ScrollController();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  bool _isLoadingBooks = true;

  late String _initialTitle;
  late String _initialDescription;
  late IdeaStatus _initialStatus;
  late String _initialBookId;

  late List<IdeaStatus> _statuses;
  late IdeaStatus _selectedStatus;
  late String _selectedBookId;
  List<Map<String, dynamic>> _userBooks = [];

  bool _hasUnsavedData = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.idea?.title ?? '');
    _descriptionController = TextEditingController(text: widget.idea?.description ?? '');

    _statuses = IdeaStatus.values;
    _selectedStatus = widget.idea?.status ?? IdeaStatus.inMind;
    _selectedBookId = widget.idea?.linkedBookId ?? '';

    _initialTitle = _titleController.text;
    _initialDescription = _descriptionController.text;
    _initialStatus = _selectedStatus;
    _initialBookId = _selectedBookId;

    _fetchUserBooks();
  }

  void _checkForChanges() {
    final hasTitleChanged = _titleController.text != _initialTitle;
    final hasDescriptionChanged = _descriptionController.text != _initialDescription;
    final hasStatusChanged = _selectedStatus != _initialStatus;
    final hasBookChanged = _selectedBookId != _initialBookId;

    setState(() {
      _hasUnsavedData = hasTitleChanged || hasDescriptionChanged || hasStatusChanged || hasBookChanged;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserBooks() async {
    setState(() {
      _isLoadingBooks = true;
    });

    final snapshot = await _databaseReference.child('books/$userId').get();
    if (snapshot.exists && snapshot.value is Map<dynamic, dynamic>) {
      final booksMap = snapshot.value as Map<dynamic, dynamic>;

      _userBooks = booksMap.entries
          .where((entry) => entry.value?['authorId'] == userId)
          .map((entry) {
        final value = entry.value as Map<dynamic, dynamic>;
        return {
          'id': entry.key.toString(),
          'title': value['title']?.toString() ?? S.current.unknown,
        };
      }).toList();
    }

    if (_userBooks.every((book) => book['id'] != _selectedBookId)) {
      _selectedBookId = '';
    }

    setState(() {
      _isLoadingBooks = false;
    });
  }

  void _saveIdea() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if(title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).requiredField,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(_selectedStatus.color, Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );;
      return;
    }

    try {
      final updateDate = DateTime.now();
      final formatter = DateFormat('yyyy-MM-dd HH:mm');

      if (widget.idea != null) {
        await _databaseReference.child('ideas/$userId/${widget.idea!.id}').update({
          'title': title,
          'description': description,
          'status': _selectedStatus.name,
          'linkedBookId': _selectedBookId,
          'lastUpdate': formatter.format(updateDate).toString(),
        });
      } else {
        await _databaseReference.child('ideas/$userId').push().set({
          'authorId': userId,
          'title': title,
          'description': description,
          'status': _selectedStatus.name,
          'linkedBookId': _selectedBookId,
          'lastUpdate': formatter.format(updateDate).toString(),
        });
      }

      if (mounted) {
        setState(() {
          _initialTitle = title;
          _initialDescription = description;
          _initialStatus = _selectedStatus;
          _initialBookId = _selectedBookId;
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
            backgroundColor: Color.lerp(_selectedStatus.color, Colors.white, 0.7),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
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
                TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(S.of(context).no, style: TextStyle(color: Theme.of(context).colorScheme.tertiary))),
                TextButton(onPressed: () { Navigator.of(context).pop(false); _saveIdea(); }, child: Text(S.of(context).save, style: TextStyle(color: Theme.of(context).colorScheme.tertiary),)),
              ],
            )
          );
          if (shouldLeave == true && mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.idea != null ? widget.idea!.title : S.of(context).creating),
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
                  color: Color.lerp(_selectedStatus.color, Colors.white, 0.7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: _selectedStatus.color)
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        TextField(
                          controller: _titleController,
                          cursorColor: _selectedStatus.color,
                          onChanged: (value) => _checkForChanges(),
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: S.of(context).title,
                            labelStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 0.5, color: _selectedStatus.color),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(width: 1.5, color: _selectedStatus.color),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              child: TextField(
                                controller: _descriptionController,
                                maxLines: null,
                                minLines: 3,
                                onChanged: (value) => _checkForChanges(),
                                keyboardType: TextInputType.multiline,
                                cursorColor: _selectedStatus.color,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: S.of(context).description,
                                  labelStyle: const TextStyle(color: Colors.black),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(width: 0.5, color: _selectedStatus.color),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(width: 1.5, color: _selectedStatus.color),
                                  ),
                                ),
                              ),
                            )
                        ),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<IdeaStatus>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: S.of(context).status,
                            labelStyle: const TextStyle(color: Colors.black),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: _selectedStatus.color, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: _selectedStatus.color, width: 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          dropdownColor: Color.lerp(_selectedStatus.color, Colors.white, 0.7),
                          style: const TextStyle(color: Colors.black),
                          items: _statuses.map((status) {
                            final isSelected = status == _selectedStatus;
                            return DropdownMenuItem(
                              value: status,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? _selectedStatus.color : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                                child: Text(
                                  status.title(context),
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedStatus = value;
                                _checkForChanges();
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (_isLoadingBooks) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      S.of(context).loading,
                                      style: const TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return DropdownButtonFormField<String>(
                              value: _selectedBookId,
                              decoration: InputDecoration(
                                labelText: S.of(context).relatedTo,
                                labelStyle: const TextStyle(color: Colors.black),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: _selectedStatus.color, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: _selectedStatus.color, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              dropdownColor: Color.lerp(_selectedStatus.color, Colors.white, 0.7),
                              style: const TextStyle(color: Colors.black),
                              borderRadius: BorderRadius.circular(14),
                              menuMaxHeight: 300,
                              items: [
                                DropdownMenuItem(
                                  value: '',
                                  child: Row(
                                    children: [
                                      if (_selectedBookId == '')
                                        const Icon(Icons.check, color: Colors.black54, size: 18),
                                      if (_selectedBookId == '') const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          S.of(context).general,
                                          style: TextStyle(
                                            fontWeight: _selectedBookId == '' ? FontWeight.bold : FontWeight.normal,
                                            color: Colors.black,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ..._userBooks.map((book) {
                                  final isSelected = _selectedBookId == book['id'];
                                  return DropdownMenuItem(
                                    value: book['id'],
                                    child: Row(
                                      children: [
                                        if (isSelected)
                                          const Icon(Icons.check, color: Colors.black54, size: 18),
                                        if (isSelected) const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            book['title'] ?? '',
                                            style: TextStyle(
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              color: Colors.black,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedBookId = value;
                                    _checkForChanges();
                                  });
                                }
                              },
                              selectedItemBuilder: (context) {
                                final allTitles = [
                                  S.of(context).general,
                                  ..._userBooks.map((book) => book['title'] ?? ''),
                                ];
                                return allTitles.map<Widget>((title) {
                                  return ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: constraints.maxWidth - 60),
                                    child: Text(
                                      title,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  );
                                }).toList();
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveIdea,
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(_selectedStatus.color),
                            padding: WidgetStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
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
