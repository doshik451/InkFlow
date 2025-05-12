import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../generated/l10n.dart';

class AdditionalInfoWidget extends StatefulWidget {
  final String userId;
  final String bookId;
  final String characterId;

  const AdditionalInfoWidget({
    Key? key,
    required this.userId,
    required this.bookId,
    required this.characterId,
  }) : super(key: key);

  @override
  _AdditionalInfoWidgetState createState() => _AdditionalInfoWidgetState();
}

class _AdditionalInfoWidgetState extends State<AdditionalInfoWidget> {
  bool _isSaving = false;

  late TextEditingController _quoteController;
  late TextEditingController _firstImpressionController;
  late TextEditingController _talentsController;
  late TextEditingController _artifactsController;

  @override
  void initState() {
    super.initState();

    _quoteController = TextEditingController();
    _firstImpressionController = TextEditingController();
    _talentsController = TextEditingController();
    _artifactsController = TextEditingController();

    _loadAdditionalInfo();
  }

  @override
  void dispose() {
    _quoteController.dispose();
    _firstImpressionController.dispose();
    _talentsController.dispose();
    _artifactsController.dispose();
    super.dispose();
  }

  Future<void> _loadAdditionalInfo() async {
    try{
      final dbRef = FirebaseDatabase.instance.ref(
          'books/${widget.userId}/${widget.bookId}/characters/${widget.characterId}/questionnaire/additionalInfo'
      );

      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);

        setState(() {
          _quoteController.text = data['quote'] ?? '';
          _firstImpressionController.text = data['firstImpression'] ?? '';
          _talentsController.text = data['talents']?.join(', ') ?? '';
          _artifactsController.text = data['artifacts']?.join(', ') ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading biography: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).an_error_occurred}: $e'))
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

  void _saveAdditionalInfo() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final additionalInfoData = {
        'talents': _talentsController.text.split(','),
        'artifacts': _artifactsController.text.split(','),
        'quote': _quoteController.text,
        'firstImpression': _firstImpressionController.text,
      };

      final dbRef = FirebaseDatabase.instance.ref(
          'books/${widget.userId}/${widget.bookId}/characters/${widget.characterId}/questionnaire/additionalInfo');
      await dbRef.update(additionalInfoData);
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
          color: Color.lerp(const Color(0xFFD3D3D3), Colors.white, 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFD3D3D3)),
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
                      S.of(context).additionalInfoTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    ),
                    children: [
                      const SizedBox(height: 10),
                      _buildTextField(_quoteController, S.of(context).quoteLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_firstImpressionController, S.of(context).firstImpressionLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_talentsController, S.of(context).talentsLabel),
                      const SizedBox(height: 16),
                      _buildTextField(_artifactsController, S.of(context).artifactsLabel),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveAdditionalInfo,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFD3D3D3)),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Color(0xFFD3D3D3))
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
      cursorColor: const Color(0xFFD3D3D3),
      onChanged: (value) {},
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 0.5, color: Color(0xFFD3D3D3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 1.5, color: Color(0xFFD3D3D3)),
        ),
      ),
    );
  }
}
