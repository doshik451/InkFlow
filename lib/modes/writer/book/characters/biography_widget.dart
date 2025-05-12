import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../generated/l10n.dart';

class BiographyWidget extends StatefulWidget {
  final String userId;
  final String bookId;
  final String characterId;

  const BiographyWidget({
    Key? key,
    required this.userId,
    required this.bookId,
    required this.characterId,
  }) : super(key: key);

  @override
  _BiographyWidgetState createState() => _BiographyWidgetState();
}

class _BiographyWidgetState extends State<BiographyWidget> {
  bool _isSaving = false;

  late TextEditingController _pastEventsController;
  late TextEditingController _secretsController;
  late TextEditingController _characterDevelopmentController;
  late TextEditingController _lossesAndGainsController;
  late TextEditingController _innerConflictsController;
  late TextEditingController _worstMemoryController;
  late TextEditingController _happiestMemoryController;
  late TextEditingController _turningPointController;
  late TextEditingController _hiddenAspectsController;

  @override
  void initState() {
    super.initState();

    _pastEventsController = TextEditingController();
    _secretsController = TextEditingController();
    _characterDevelopmentController = TextEditingController();
    _lossesAndGainsController = TextEditingController();
    _innerConflictsController = TextEditingController();
    _worstMemoryController = TextEditingController();
    _happiestMemoryController = TextEditingController();
    _turningPointController = TextEditingController();
    _hiddenAspectsController = TextEditingController();

    _loadBiography();
  }

  Future<void> _loadBiography() async {
    try {
      final dbRef = FirebaseDatabase.instance.ref(
          'books/${widget.userId}/${widget.bookId}/characters/${widget.characterId}/questionnaire/biography'
      );

      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);

        setState(() {
          _pastEventsController.text = data['pastEvents'] ?? '';
          _secretsController.text = data['secrets'] ?? '';
          _characterDevelopmentController.text = data['characterDevelopment'] ?? '';
          _lossesAndGainsController.text = data['lossesAndGains'] ?? '';
          _innerConflictsController.text = data['innerConflicts'] ?? '';
          _worstMemoryController.text = data['worstMemory'] ?? '';
          _happiestMemoryController.text = data['happiestMemory'] ?? '';
          _turningPointController.text = data['turningPoint'] ?? '';
          _hiddenAspectsController.text = data['hiddenAspects'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading biography: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).an_error_occurred}: $e'))
      );
    }
  }

  @override
  void dispose() {
    _pastEventsController.dispose();
    _secretsController.dispose();
    _characterDevelopmentController.dispose();
    _lossesAndGainsController.dispose();
    _innerConflictsController.dispose();
    _worstMemoryController.dispose();
    _happiestMemoryController.dispose();
    _turningPointController.dispose();
    _hiddenAspectsController.dispose();
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
        'books/${widget.userId}/${widget.bookId}/characters/${widget.characterId}')
        .update(updates);

    await FirebaseDatabase.instance
        .ref(
        'books/${widget.userId}/${widget.bookId}')
        .update(updates);
  }

  void _saveBiography() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final biographyData = {
        'pastEvents': _pastEventsController.text,
        'secrets': _secretsController.text,
        'characterDevelopment': _characterDevelopmentController.text,
        'lossesAndGains': _lossesAndGainsController.text,
        'innerConflicts': _innerConflictsController.text,
        'worstMemory': _worstMemoryController.text,
        'happiestMemory': _happiestMemoryController.text,
        'turningPoint': _turningPointController.text,
        'hiddenAspects': _hiddenAspectsController.text,
      };

      final dbRef = FirebaseDatabase.instance.ref(
          'books/${widget.userId}/${widget.bookId}/characters/${widget.characterId}/questionnaire/biography');
      await dbRef.update(biographyData);
      await _updateBook();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).create_success)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${S.of(context).an_error_occurred}: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Card(
          color: Color.lerp(const Color(0xFFC9A6D4), Colors.white, 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFC9A6D4)),
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
                      S.of(context).biographyTitle,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold, color: Colors.black
                      ),
                    ),
                    children: [
                      const SizedBox(height: 10),
                      _buildTextField(_pastEventsController, S.of(context).pastEventsLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_secretsController, S.of(context).secretsLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_characterDevelopmentController, S.of(context).characterDevelopmentLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_lossesAndGainsController, S.of(context).lossesAndGainsLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_innerConflictsController, S.of(context).innerConflictsLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_worstMemoryController, S.of(context).worstMemoryLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_happiestMemoryController, S.of(context).happiestMemoryLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_turningPointController, S.of(context).turningPointLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_hiddenAspectsController, S.of(context).hiddenAspectsLabel),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveBiography,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFC9A6D4)),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Color(0xFFC9A6D4))
                            : Text(
                          S.of(context).save,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      onChanged: (value) {},
      cursorColor: const Color(0xFFC9A6D4),
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 0.5, color: Color(0xFFC9A6D4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1.5, color: Color(0xFFC9A6D4)),
        ),
      ),
    );
  }
}