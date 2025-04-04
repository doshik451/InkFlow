import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:inkflow/models/idea_model.dart';

import '../../../../generated/l10n.dart';

class IdeaInfoScreen extends StatefulWidget {
  const IdeaInfoScreen({super.key});

  @override
  State<IdeaInfoScreen> createState() => _IdeaInfoScreenState();
}

class _IdeaInfoScreenState extends State<IdeaInfoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final ScrollController _scrollController = ScrollController();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  
  late List<IdeaStatus> _statuses;
  late IdeaStatus _selectedStatus;
  late String _selectedBookId;
  List<Map<String, dynamic>> _userBooks = [];

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();
    _statuses = IdeaStatus.values;
    _selectedStatus = IdeaStatus.inMind;
    _selectedBookId = '';
    _fetchUserBooks();
  }
  
  Future<void> _fetchUserBooks() async {
    //TODO заменить в бд структуру, пусть будет books->{userId}->{bookId} и тут
    // заменить тогда на _databaseReference.child('books').orderByChild('userId').equalTo(userId).get();
    final snapshot = await _databaseReference.child('books').get();
    if(snapshot.exists && snapshot.value is Map) {
      setState(() {
        _userBooks = (snapshot.value as Map).entries.where((entry) => entry.value['authorId'] == userId).map((entry) {
          return { 'id': entry.key, 'title': entry.value['title'].toString()};
        }).toList();
      });
    }
  }

  void _saveIdea() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    
    if(title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).requiredField)));
      return;
    }

    final DatabaseReference ref = FirebaseDatabase.instance.ref('ideas').push();
    final String newIdeaId = ref.key!;
    
    final newIdea = Idea(id: newIdeaId, authorId: userId, title: title, description: description, status: _selectedStatus, linkedBookId: _selectedBookId);
    await ref.set({
      'authorId': newIdea.authorId,
      'title': newIdea.title,
      'description': newIdea.description,
      'status': newIdea.status.name.toString(),
      'linkedBookId': newIdea.linkedBookId.toString()
    });
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.creating), centerTitle: true,),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: Color.lerp(_selectedStatus.color, Colors.white, 0.7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: _selectedStatus.color)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20,),
                  TextField(
                    controller: _titleController,
                    cursorColor: _selectedStatus.color,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(labelText: S.of(context).title, labelStyle: const TextStyle(color: Colors.black),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: 0.5, color: _selectedStatus.color),),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: 1.5, color: _selectedStatus.color),),
                    ),
                  ),
                  const SizedBox(height: 10,),
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
                        keyboardType: TextInputType.multiline,
                        cursorColor: _selectedStatus.color,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(labelText: S.of(context).description, labelStyle: const TextStyle(color: Colors.black),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: 0.5, color: _selectedStatus.color),),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(width: 1.5, color: _selectedStatus.color),),
                        ),
                      ),
                    )
                  ),
                  const SizedBox(height: 24,),
                  DropdownButtonFormField<IdeaStatus>(
                    value: _selectedStatus,
                    decoration: InputDecoration(labelText: S.of(context).status,labelStyle: const TextStyle(color: Colors.black),
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
                      if(value != null) setState(() => _selectedStatus = value);
                    },
                  ),
                  const SizedBox(height: 16,),
                  LayoutBuilder(
                    builder: (context, constraints) {
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
                  const SizedBox(height: 24,),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveIdea,
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(_selectedStatus.color), padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                      ),),
                      child: Text(
                        S.of(context).save,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
