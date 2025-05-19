import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../generated/l10n.dart';
import '../../../../models/book_character_model.dart';

class RelationshipFormWidget extends StatefulWidget {
  final String userId;
  final String bookId;
  final String characterId;

  const RelationshipFormWidget({
    super.key,
    required this.userId,
    required this.bookId,
    required this.characterId,
  });

  @override
  _RelationshipFormWidgetState createState() => _RelationshipFormWidgetState();
}

class _RelationshipFormWidgetState extends State<RelationshipFormWidget> {
  bool _isSaving = false;
  bool _isLoading = true;
  bool _isEditing = false;
  int _editingIndex = -1;

  late List<Character> _characters;
  late String _selectedFamilyCharacterId;
  late String _selectedFriendsCharacterId;
  late String _selectedEnemiesCharacterId;
  late String _selectedOthersCharacterId;

  late TextEditingController _familyDescriptionController;
  late TextEditingController _friendsDescriptionController;
  late TextEditingController _enemiesDescriptionController;
  late TextEditingController _othersDescriptionController;

  late TextEditingController _familyCharacterRelationController;
  late TextEditingController _friendsCharacterRelationController;
  late TextEditingController _enemiesCharacterRelationController;
  late TextEditingController _othersCharacterRelationController;

  late TextEditingController _familySelectedCharacterRelationController;
  late TextEditingController _friendsSelectedCharacterRelationController;
  late TextEditingController _enemiesSelectedCharacterRelationController;
  late TextEditingController _othersSelectedCharacterRelationController;

  late TextEditingController _attitudeToSocietyController;
  late TextEditingController _attachmentsController;

  List<Map<String, dynamic>> _familyRelations = [];
  List<Map<String, dynamic>> _friendsRelations = [];
  List<Map<String, dynamic>> _enemiesRelations = [];
  List<Map<String, dynamic>> _othersRelations = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _selectedFamilyCharacterId = '';
    _selectedFriendsCharacterId = '';
    _selectedEnemiesCharacterId = '';
    _selectedOthersCharacterId = '';
    _loadCharacters();
    _loadExistingRelations();
  }

  void _initControllers() {
    _familyDescriptionController = TextEditingController();
    _friendsDescriptionController = TextEditingController();
    _enemiesDescriptionController = TextEditingController();
    _othersDescriptionController = TextEditingController();

    _familyCharacterRelationController = TextEditingController();
    _friendsCharacterRelationController = TextEditingController();
    _enemiesCharacterRelationController = TextEditingController();
    _othersCharacterRelationController = TextEditingController();

    _familySelectedCharacterRelationController = TextEditingController();
    _friendsSelectedCharacterRelationController = TextEditingController();
    _enemiesSelectedCharacterRelationController = TextEditingController();
    _othersSelectedCharacterRelationController = TextEditingController();

    _attitudeToSocietyController = TextEditingController();
    _attachmentsController = TextEditingController();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _familyDescriptionController.dispose();
    _friendsDescriptionController.dispose();
    _enemiesDescriptionController.dispose();
    _othersDescriptionController.dispose();

    _familyCharacterRelationController.dispose();
    _friendsCharacterRelationController.dispose();
    _enemiesCharacterRelationController.dispose();
    _othersCharacterRelationController.dispose();

    _familySelectedCharacterRelationController.dispose();
    _friendsSelectedCharacterRelationController.dispose();
    _enemiesSelectedCharacterRelationController.dispose();
    _othersSelectedCharacterRelationController.dispose();

    _attitudeToSocietyController.dispose();
    _attachmentsController.dispose();
  }

  String _getSelectedCharacterId(String groupType) {
    switch (groupType) {
      case 'family':
        return _selectedFamilyCharacterId;
      case 'friends':
        return _selectedFriendsCharacterId;
      case 'enemies':
        return _selectedEnemiesCharacterId;
      case 'others':
        return _selectedOthersCharacterId;
      default:
        return '';
    }
  }

  void _setSelectedCharacterId(String groupType, String value) {
    setState(() {
      switch (groupType) {
        case 'family':
          _selectedFamilyCharacterId = value;
          break;
        case 'friends':
          _selectedFriendsCharacterId = value;
          break;
        case 'enemies':
          _selectedEnemiesCharacterId = value;
          break;
        case 'others':
          _selectedOthersCharacterId = value;
          break;
      }
    });
  }

  Future<void> _loadCharacters() async {
    try {
      final charactersRef = FirebaseDatabase.instance
          .ref('books/${widget.userId}/${widget.bookId}/characters');
      final snapshot = await charactersRef.get();

      if (snapshot.exists) {
        final charactersList =
            (snapshot.value as Map<dynamic, dynamic>).entries.map((entry) {
          return Character.fromMap(
              entry.key as String, Map<String, dynamic>.from(entry.value));
        }).toList();

        setState(() {
          _characters = charactersList;
        });
      }
    } catch (e) {
      debugPrint('Error loading characters: $e');
    }
  }

  Future<void> _loadExistingRelations() async {
    try {
      final relationsRef = FirebaseDatabase.instance.ref(
        'books/${widget.userId}/${widget.bookId}/characters/${widget.characterId}/questionnaire/relationships',
      );

      final snapshot = await relationsRef.get();

      if (snapshot.exists) {
        final relationsData =
            Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);

        setState(() {
          _familyRelations = _parseGroupData(relationsData['family']);
          _friendsRelations = _parseGroupData(relationsData['friends']);
          _enemiesRelations = _parseGroupData(relationsData['enemies']);
          _othersRelations = _parseGroupData(relationsData['others']);

          _attitudeToSocietyController.text =
              relationsData['attitudeToSociety']?.toString() ?? '';
          _attachmentsController.text =
              relationsData['attachments']?.toString() ?? '';

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading relations: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _parseGroupData(dynamic groupData) {
    if (groupData == null) return [];
    if (groupData is Map) {
      return groupData.values
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (groupData is List) {
      return groupData
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  List<Map<String, dynamic>> _getRelationsList(String groupType) {
    switch (groupType) {
      case 'family':
        return _familyRelations;
      case 'friends':
        return _friendsRelations;
      case 'enemies':
        return _enemiesRelations;
      case 'others':
        return _othersRelations;
      default:
        return [];
    }
  }

  TextEditingController _getCharacterRelationController(String groupType) {
    switch (groupType) {
      case 'family':
        return _familyCharacterRelationController;
      case 'friends':
        return _friendsCharacterRelationController;
      case 'enemies':
        return _enemiesCharacterRelationController;
      case 'others':
        return _othersCharacterRelationController;
      default:
        return _familyCharacterRelationController;
    }
  }

  TextEditingController _getSelectedCharacterRelationController(
      String groupType) {
    switch (groupType) {
      case 'family':
        return _familySelectedCharacterRelationController;
      case 'friends':
        return _friendsSelectedCharacterRelationController;
      case 'enemies':
        return _enemiesSelectedCharacterRelationController;
      case 'others':
        return _othersSelectedCharacterRelationController;
      default:
        return _familySelectedCharacterRelationController;
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

  Future<void> _saveGeneralInfo() async {
    setState(() => _isSaving = true);

    try {
      final relationsRef = FirebaseDatabase.instance.ref(
        'books/${widget.userId}/${widget.bookId}/characters/${widget.characterId}/questionnaire/relationships',
      );

      await relationsRef.update({
        'attitudeToSociety': _attitudeToSocietyController.text,
        'attachments': _attachmentsController.text,
      });

      await _updateBook();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).create_success,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Theme.of(context).colorScheme.tertiary, Colors.white, 0.7),
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
            '${S.of(context).an_error_occurred}: ${e.toString()}',
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Theme.of(context).colorScheme.tertiary, Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _addCharacterToGroup(String groupType) async {
    if (_getSelectedCharacterId(groupType).isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final character = _characters
          .firstWhere((c) => c.id == _getSelectedCharacterId(groupType));
      final currentCharacter =
      _characters.firstWhere((c) => c.id == widget.characterId);

      final relationId = DateTime.now().millisecondsSinceEpoch.toString();

      final newRelation = {
        'characterId': _getSelectedCharacterId(groupType),
        'characterName': character.name,
        'characterRelation': _getCharacterRelationController(groupType).text,
        'selectedCharacterRelation':
        _getSelectedCharacterRelationController(groupType).text,
        'relationId': relationId,
      };

      final groupRef = FirebaseDatabase.instance.ref(
          'books/${widget.userId}/${widget.bookId}/characters/${widget.characterId}/questionnaire/relationships/$groupType');
      await groupRef.push().set(newRelation);

      final reverseRelation = {
        'characterId': widget.characterId,
        'characterName': currentCharacter.name,
        'characterRelation':
        _getSelectedCharacterRelationController(groupType).text,
        'selectedCharacterRelation':
        _getCharacterRelationController(groupType).text,
        'relationId': relationId,
      };

      final targetGroupRef = FirebaseDatabase.instance.ref(
          'books/${widget.userId}/${widget.bookId}/characters/${_getSelectedCharacterId(groupType)}/questionnaire/relationships/$groupType');
      await targetGroupRef.push().set(reverseRelation);

      setState(() {
        _getRelationsList(groupType).add(newRelation);
      });

      await _updateBook();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).create_success,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Theme.of(context).colorScheme.tertiary, Colors.white, 0.7),
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
            '${S.of(context).an_error_occurred}: ${e.toString()}',
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Theme.of(context).colorScheme.tertiary, Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isSaving = false);
      _getCharacterRelationController(groupType).clear();
      _getSelectedCharacterRelationController(groupType).clear();
    }
  }

  void _startEditingRelation(String groupType, int index) {
    final relation = _getRelationsList(groupType)[index];

    setState(() {
      _setSelectedCharacterId(groupType, relation['characterId'] ?? '');
      _getCharacterRelationController(groupType).text =
          relation['characterRelation'] ?? '';
      _getSelectedCharacterRelationController(groupType).text =
          relation['selectedCharacterRelation'] ?? '';
      _editingIndex = index;
      _isEditing = true;
    });
  }

  Future<void> _saveEditedRelation(String groupType) async {
    final selectedCharacterId = _getSelectedCharacterId(groupType);
    if (selectedCharacterId.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final currentRelation = _getRelationsList(groupType)[_editingIndex];

      final updatedRelation = {
        'characterId': selectedCharacterId,
        'characterName':
        _characters.firstWhere((c) => c.id == selectedCharacterId).name,
        'characterRelation': _getCharacterRelationController(groupType).text,
        'selectedCharacterRelation':
        _getSelectedCharacterRelationController(groupType).text,
        'relationId': currentRelation['relationId'],
      };

      final groupRef = FirebaseDatabase.instance.ref(
          'books/${widget.userId}/${widget.bookId}/characters/${widget.characterId}/questionnaire/relationships/$groupType');

      final snapshot = await groupRef.get();
      if (snapshot.exists) {
        final relationsMap =
            Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
        final relationKey = relationsMap.keys.elementAt(_editingIndex);
        await groupRef.child(relationKey).update(updatedRelation);
      }

      final targetGroupRef = FirebaseDatabase.instance.ref(
          'books/${widget.userId}/${widget.bookId}/characters/$selectedCharacterId/questionnaire/relationships/$groupType');

      final targetSnapshot = await targetGroupRef.get();
      if (targetSnapshot.exists) {
        final targetRelations = Map<String, dynamic>.from(
            targetSnapshot.value as Map<dynamic, dynamic>);

        for (final entry in targetRelations.entries) {
          if (entry.value['characterId'] == widget.characterId) {
            await targetGroupRef.child(entry.key).update({
              'characterRelation': updatedRelation['selectedCharacterRelation'],
              'selectedCharacterRelation': updatedRelation['characterRelation'],
            });
            break;
          }
        }
      }

      setState(() {
        _getRelationsList(groupType)[_editingIndex] = updatedRelation;
        _isEditing = false;
        _editingIndex = -1;
        _setSelectedCharacterId(groupType, '');
      });

      await _updateBook();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).update_success,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Theme.of(context).colorScheme.tertiary, Colors.white, 0.7),
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
            '${S.of(context).an_error_occurred}: ${e.toString()}',
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Theme.of(context).colorScheme.tertiary, Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isSaving = false);
      _getCharacterRelationController(groupType).clear();
      _getSelectedCharacterRelationController(groupType).clear();
    }
  }

  Future<void> _deleteRelation(String groupType, int index) async {
    setState(() => _isSaving = true);

    try {
      final relationsRef = FirebaseDatabase.instance.ref(
          'books/${widget.userId}/${widget.bookId}/characters/${widget.characterId}/questionnaire/relationships/$groupType');

      final snapshot = await relationsRef.get();
      if (!snapshot.exists) return;

      final relationsMap =
      Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
      final relationKey = relationsMap.keys.elementAt(index);
      final relationToDelete = relationsMap[relationKey];
      final relationId = relationToDelete['relationId'];

      await relationsRef.child(relationKey).remove();

      final targetCharacterId = relationToDelete['characterId'];
      if (targetCharacterId != null) {
        final targetRef = FirebaseDatabase.instance.ref(
            'books/${widget.userId}/${widget.bookId}/characters/$targetCharacterId/questionnaire/relationships/$groupType');

        final targetSnapshot = await targetRef.get();
        if (targetSnapshot.exists) {
          final targetRelations = Map<String, dynamic>.from(
              targetSnapshot.value as Map<dynamic, dynamic>);

          for (final entry in targetRelations.entries) {
            if (entry.value['relationId'] == relationId) {
              await targetRef.child(entry.key).remove();
              break;
            }
          }
        }
      }

      await _updateBook();

      setState(() {
        _getRelationsList(groupType).removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).delete,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Theme.of(context).colorScheme.tertiary, Colors.white, 0.7),
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
            '${S.of(context).an_error_occurred}: ${e.toString()}',
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Theme.of(context).colorScheme.tertiary, Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editingIndex = -1;
      _selectedFamilyCharacterId = '';
      _selectedFriendsCharacterId = '';
      _selectedEnemiesCharacterId = '';
      _selectedOthersCharacterId = '';
      _familyCharacterRelationController.clear();
      _friendsCharacterRelationController.clear();
      _enemiesCharacterRelationController.clear();
      _othersCharacterRelationController.clear();
      _familySelectedCharacterRelationController.clear();
      _friendsSelectedCharacterRelationController.clear();
      _enemiesSelectedCharacterRelationController.clear();
      _othersSelectedCharacterRelationController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      child: Card(
        color: Color.lerp(const Color(0xFFFED1BD), Colors.white, 0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFED1BD)),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  title: Text(
                    s.characterRelationshipsTitle,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  children: [
                    Column(
                      children: [
                        Card(
                          color: Color.lerp(const Color(0xFFFED1BD), Colors.white, 0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFFED1BD)),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.generalInformationTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18, color: Colors.black
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _attitudeToSocietyController,
                                  cursorColor: const Color(0xFFCD9983),
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    labelText: s.attitudeToSocietyLabel,
                                    labelStyle: const TextStyle(color: Colors.black),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          width: 0.5, color: Color(0xFFCD9983)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          width: 1.5, color: Color(0xFFCD9983)),
                                    ),
                                  ),
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _attachmentsController,
                                  cursorColor: const Color(0xFFFED1BD),
                                  style: const TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    labelText: s.attachmentsLabel,
                                    labelStyle: const TextStyle(color: Colors.black),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          width: 0.5, color: Color(0xFFCD9983)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          width: 1.5, color: Color(0xFFCD9983)),
                                    ),
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: _isSaving ? null : _saveGeneralInfo,
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all<Color>(
                                          const Color(0xFFFED1BD)),
                                      padding: WidgetStateProperty.all<EdgeInsets>(
                                        const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 6),
                                      ),
                                    ),
                                    child: _isSaving
                                        ? const CircularProgressIndicator()
                                        : Text(
                                      s.saveButton,
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
                        const SizedBox(height: 16),
                        _buildExpandableCard(s.familyRelationsTitle, 'family'),
                        const SizedBox(height: 16),
                        _buildExpandableCard(s.friendsRelationsTitle, 'friends'),
                        const SizedBox(height: 16),
                        _buildExpandableCard(s.enemiesRelationsTitle, 'enemies'),
                        const SizedBox(height: 16),
                        _buildExpandableCard(s.otherRelationsTitle, 'others'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableCard(String title, String groupType) {
    final s = S.of(context);
    final relationsList = _getRelationsList(groupType);

    return Card(
      color: Color.lerp(const Color(0xFFFED1BD), Colors.white, 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFCD9983)),
      ),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _getSelectedCharacterId(groupType).isEmpty ? null : _getSelectedCharacterId(groupType),
                    decoration: InputDecoration(
                      labelText: s.selectCharacterLabel,
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            width: 1.5,
                            color: Color(0xFFCD9983)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            width: 2.0,
                            color: Color(0xFFCD9983)),
                      ),
                      filled: true,
                      fillColor: Color.lerp(
                          const Color(0xFFFED1BD), Colors.white, 0.7),
                    ),
                    dropdownColor: Color.lerp(
                        const Color(0xFFFED1BD), Colors.white, 0.7),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                    iconSize: 28,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    items: _characters
                        .where((character) => character.id != widget.characterId)
                        .map((character) => DropdownMenuItem<String>(
                      value: character.id,
                      child: Text(
                        character.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                        .toList(),
                    onChanged: (value) => _setSelectedCharacterId(groupType, value ?? ''),
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    menuMaxHeight: 300,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _getCharacterRelationController(groupType),
                    cursorColor: const Color(0xFFCD9983),
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: s.firstToSecondRelationLabel,
                      labelStyle: const TextStyle(color: Colors.black),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            width: 0.5, color: Color(0xFFCD9983)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            width: 1.5, color: Color(0xFFCD9983)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _getSelectedCharacterRelationController(groupType),
                    cursorColor: const Color(0xFFCD9983),
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: s.secondToFirstRelationLabel,
                      labelStyle: const TextStyle(color: Colors.black),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            width: 0.5, color: Color(0xFFCD9983)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            width: 1.5, color: Color(0xFFCD9983)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_isEditing) ...[
                        TextButton(
                          onPressed: _cancelEditing,
                          child: Text(
                            s.cancelButton,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () {
                          if (_isEditing) {
                            _saveEditedRelation(groupType);
                          } else {
                            _addCharacterToGroup(groupType);
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              const Color(0xFFFED1BD)),
                          padding: WidgetStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 6),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator()
                            : Text(
                          _isEditing ? s.saveButton : s.addButton,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (relationsList.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            s.currentRelationsLabel,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 8),
                        ...relationsList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final relation = entry.value;
                          return Card(
                            color: Color.lerp(
                                const Color(0xFFFED1BD), Colors.white, 0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xFFFED1BD)),
                            ),
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(relation['characterName'] ?? '', style: const TextStyle(color: Colors.black),),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${s.firstToSecondRelationLabel}: ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: relation['characterRelation'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${s.secondToFirstRelationLabel}: ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: relation['selectedCharacterRelation'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.black),
                                    onPressed: () => _startEditingRelation(groupType, index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.black),
                                    onPressed: () => _deleteRelation(groupType, index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
