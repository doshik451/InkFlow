import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../generated/l10n.dart';
import '../../../models/read_book_model.dart';

class ReviewScreen extends StatefulWidget {
  final FinishedBook book;
  final String userId;
  final BookCategory category;

  const ReviewScreen({super.key, required this.book, required this.userId, required this.category});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late TextEditingController _overallRatingController;
  late final TextEditingController _reviewController;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  bool _isDownloading = false;
  bool _isLoadingFiles = false;
  bool _hasUnsavedData = false;

  late String _initialRating;
  late String _initialReview;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController(text: widget.book.personalReview ?? '');
    _overallRatingController =
        TextEditingController(text: widget.book.overallRating ?? '???');

    _initialRating = _overallRatingController.text;
    _initialReview = _reviewController.text;
  }

  @override
  void dispose() {
    super.dispose();
    _overallRatingController.dispose();
    _reviewController.dispose();
  }

  void _checkForChanges() {
    final hasRatingChanged = _overallRatingController.text != _initialRating;
    final hasReviewChanged = _reviewController.text != _initialReview;

    setState(() {
      _hasUnsavedData =
          hasRatingChanged ||
          hasReviewChanged;
    });
  }

  void _saveReview() async {

    await _databaseReference
        .child('finishedBooks/${widget.userId}/${widget.book.id}')
        .update({
      'personalReview': _reviewController.text,
      'overallRating': _overallRatingController.text
    });

    if (mounted) {
      setState(() {
        _initialReview = _reviewController.text;
        _initialRating = _overallRatingController.text;
        _hasUnsavedData = false;
      });
      Navigator.pop(context, {
        'reload': true,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !_hasUnsavedData,
        onPopInvoked: (bool didPop) async {
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
                    child: Text(
                      S.of(context).no,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      _saveReview();
                    },
                    child: Text(
                      S.of(context).save,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ),
                ],
              ),
            );
            if (shouldLeave == true && mounted) Navigator.of(context).pop(true);
          } else {
            Navigator.of(context).pop(true);
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              title: Text('${widget.book.title}: ${S.of(context).review_and_criteria}'),
              centerTitle: true,
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Color.lerp(
                      Color(int.parse(widget.category.colorCode)),
                      Colors.white,
                      0.7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                          color:
                              Color(int.parse(widget.category.colorCode)))),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        TextField(
                          controller: _reviewController,
                          cursorColor:
                              Color(int.parse(widget.category.colorCode)),
                          onChanged: (value) => _checkForChanges(),
                          style: const TextStyle(color: Colors.black),
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: S.of(context).review,
                            labelStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  width: 0.5,
                                  color: Color(
                                      int.parse(widget.category.colorCode))),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  width: 1.5,
                                  color: Color(
                                      int.parse(widget.category.colorCode))),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const SizedBox(width: 10),
                            Text(
                              '${S.of(context).general_impression}:',
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 65,
                              child: TextFormField(
                                controller: _overallRatingController,
                                onChanged: (value) => _checkForChanges(),
                                decoration: InputDecoration(
                                  border: const UnderlineInputBorder(),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(int.parse(
                                              widget.category.colorCode)))),
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                  suffix: const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Text(
                                      '/100',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  counterText: '',
                                ),
                                cursorColor: Color(
                                    int.parse(widget.category.colorCode)),
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                                textAlign: TextAlign.end,
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  TextInputFormatter.withFunction(
                                          (oldValue, newValue) {
                                        if (newValue.text.isEmpty) {
                                          return newValue;
                                        }
                                        final value = int.tryParse(newValue.text);
                                        if (value == null ||
                                            value < 0 ||
                                            value > 100) {
                                          return oldValue;
                                        }
                                        return newValue;
                                      }),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveReview,
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(Color(int.parse(widget.category.colorCode))),
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
        ));
  }
}
