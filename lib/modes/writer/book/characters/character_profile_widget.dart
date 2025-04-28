import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../generated/l10n.dart';

class CharacterProfileWidget extends StatefulWidget {
  final String userId;
  final String bookId;
  final String characterId;

  const CharacterProfileWidget({
    Key? key,
    required this.userId,
    required this.bookId,
    required this.characterId,
  }) : super(key: key);

  @override
  _CharacterProfileWidgetState createState() => _CharacterProfileWidgetState();
}

class _CharacterProfileWidgetState extends State<CharacterProfileWidget> {
  bool _isSaving = false;

  late TextEditingController _personalityController;
  late TextEditingController _socialStatusController;
  late TextEditingController _habitsController;
  late TextEditingController _strengthsController;
  late TextEditingController _weaknessesController;
  late TextEditingController _beliefsController;
  late TextEditingController _goalController;
  late TextEditingController _motivationController;
  late TextEditingController _admiresController;
  late TextEditingController _irritatesOrFearsController;
  late TextEditingController _inspiresController;
  late TextEditingController _temperamentController;
  late TextEditingController _stressBehaviorController;
  late TextEditingController _attitudeToLifeController;
  late TextEditingController _innerContradictionsController;

  @override
  void initState() {
    super.initState();

    _personalityController = TextEditingController();
    _socialStatusController = TextEditingController();
    _habitsController = TextEditingController();
    _strengthsController = TextEditingController();
    _weaknessesController = TextEditingController();
    _beliefsController = TextEditingController();
    _goalController = TextEditingController();
    _motivationController = TextEditingController();
    _admiresController = TextEditingController();
    _irritatesOrFearsController = TextEditingController();
    _inspiresController = TextEditingController();
    _temperamentController = TextEditingController();
    _stressBehaviorController = TextEditingController();
    _attitudeToLifeController = TextEditingController();
    _innerContradictionsController = TextEditingController();

    _loadCharacterProfile();
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

  Future<void> _loadCharacterProfile() async {
    try {
      final dbRef = FirebaseDatabase.instance.ref(
          'books/${widget.userId}/${widget.bookId}/characters/${widget.characterId}/questionnaire/profile'
      );

      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);

        setState(() {
          _personalityController.text = data['personality'] ?? '';
          _socialStatusController.text = data['socialStatus'] ?? '';
          _habitsController.text = data['habits'] ?? '';
          _strengthsController.text = data['strengths'] ?? '';
          _weaknessesController.text = data['weaknesses'] ?? '';
          _beliefsController.text = data['beliefs'] ?? '';
          _goalController.text = data['goal'] ?? '';
          _motivationController.text = data['motivation'] ?? '';
          _admiresController.text = data['admires'] ?? '';
          _irritatesOrFearsController.text = data['irritatesOrFears'] ?? '';
          _inspiresController.text = data['inspires'] ?? '';
          _temperamentController.text = data['temperament'] ?? '';
          _stressBehaviorController.text = data['stressBehavior'] ?? '';
          _attitudeToLifeController.text = data['attitudeToLife'] ?? '';
          _innerContradictionsController.text = data['innerContradictions'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading character profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).an_error_occurred}: $e'))
      );
    }
  }

  @override
  void dispose() {
    _personalityController.dispose();
    _socialStatusController.dispose();
    _habitsController.dispose();
    _strengthsController.dispose();
    _weaknessesController.dispose();
    _beliefsController.dispose();
    _goalController.dispose();
    _motivationController.dispose();
    _admiresController.dispose();
    _irritatesOrFearsController.dispose();
    _inspiresController.dispose();
    _temperamentController.dispose();
    _stressBehaviorController.dispose();
    _attitudeToLifeController.dispose();
    _innerContradictionsController.dispose();
    super.dispose();
  }

  void _saveCharacterProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final profileData = {
        'personality': _personalityController.text,
        'socialStatus': _socialStatusController.text,
        'habits': _habitsController.text,
        'strengths': _strengthsController.text,
        'weaknesses': _weaknessesController.text,
        'beliefs': _beliefsController.text,
        'goal': _goalController.text,
        'motivation': _motivationController.text,
        'admires': _admiresController.text,
        'irritatesOrFears': _irritatesOrFearsController.text,
        'inspires': _inspiresController.text,
        'temperament': _temperamentController.text,
        'stressBehavior': _stressBehaviorController.text,
        'attitudeToLife': _attitudeToLifeController.text,
        'innerContradictions': _innerContradictionsController.text,
      };

      final dbRef = FirebaseDatabase.instance.ref(
          'books/${widget.userId}/${widget.bookId}/characters/${widget.characterId}/questionnaire/profile');
      await dbRef.update(profileData);
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
          color: Color.lerp(const Color(0xFFA5C6EA), Colors.white, 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFA5C6EA)),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                      S.of(context).characterProfileTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      const SizedBox(height: 10),
                      _buildTextField(_personalityController, S.of(context).personalityLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_socialStatusController, S.of(context).socialStatusLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_habitsController, S.of(context).habitsLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_strengthsController, S.of(context).strengthsLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_weaknessesController, S.of(context).weaknessesLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_beliefsController, S.of(context).beliefsLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_goalController, S.of(context).goalLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_motivationController, S.of(context).motivationLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_admiresController, S.of(context).admiresLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_irritatesOrFearsController, S.of(context).irritatesOrFearsLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_inspiresController, S.of(context).inspiresLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_temperamentController, S.of(context).temperamentLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_stressBehaviorController, S.of(context).stressBehaviorLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_attitudeToLifeController, S.of(context).attitudeToLifeLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_innerContradictionsController, S.of(context).innerContradictionsLabel),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveCharacterProfile,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFA5C6EA)),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Color(0xFFA5C6EA))
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
      cursorColor: const Color(0xFFA5C6EA),
      onChanged: (value) {},
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
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
    );
  }
}