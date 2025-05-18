import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../generated/l10n.dart';
import '../../../models/read_book_model.dart';

class ReviewScreen extends StatefulWidget {
  final FinishedBook book;
  final String userId;
  final BookCategory category;

  const ReviewScreen(
      {super.key,
      required this.book,
      required this.userId,
      required this.category});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late TextEditingController _criteriaScoreController;
  late final TextEditingController _reviewController;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final Map<String, TextEditingController> criteriaEntries = {};

  List<RatingCriterion> _defaultCriteria = [];
  List<RatingCriterion> _customCriteria = [];
  bool _isLoadingCriteria = true;

  bool _hasUnsavedData = false;

  late String _initialRating;
  late String _initialReview;

  @override
  void initState() {
    super.initState();
    _reviewController =
        TextEditingController(text: widget.book.personalReview ?? '');
    _criteriaScoreController =
        TextEditingController(text: widget.book.overallRating ?? '???');

    _initialRating = _criteriaScoreController.text;
    _initialReview = _reviewController.text;

    _loadCriteria();
  }

  Future<void> _loadCriteria() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final defaultSnapshot =
        await FirebaseDatabase.instance.ref('defaultCriteria').get();
    final customSnapshot =
        await FirebaseDatabase.instance.ref('customCriteria/$userId').get();

    List<RatingCriterion> defaultCriteriaList = [];
    if (defaultSnapshot.exists) {
      final rawList = defaultSnapshot.value as List<dynamic>;
      defaultCriteriaList = rawList.asMap().entries.map((entry) {
        return RatingCriterion.fromMap(entry.key.toString(), entry.value);
      }).toList();
    }

    List<RatingCriterion> customCriteriaList = [];
    if (customSnapshot.exists) {
      final rawMap = customSnapshot.value as Map<dynamic, dynamic>? ?? {};
      customCriteriaList = rawMap.entries.map((entry) {
        return RatingCriterion.fromMap(entry.key.toString(), entry.value);
      }).toList();
    }

    widget.book.criteria.forEach((criterionId, score) {
      criteriaEntries[criterionId] = TextEditingController(text: score);
    });

    setState(() {
      _defaultCriteria = defaultCriteriaList;
      _customCriteria = customCriteriaList;
      _isLoadingCriteria = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _criteriaScoreController.dispose();
    _reviewController.dispose();
  }

  void _checkForChanges() {
    final hasRatingChanged = _criteriaScoreController.text != _initialRating;
    final hasReviewChanged = _reviewController.text != _initialReview;

    setState(() {
      _hasUnsavedData = hasRatingChanged || hasReviewChanged;
    });
  }

  void _saveReview() async {
    final Map<String, String> criteriaRatings = {};
    criteriaEntries.forEach((criterionId, controller) {
      final value = controller.text.trim();
      if (value.isNotEmpty) {
        criteriaRatings[criterionId] = value;
      }
    });

    await _databaseReference
        .child('finishedBooks/${widget.userId}/${widget.book.id}')
        .update({
      'personalReview': _reviewController.text,
      'overallRating': _criteriaScoreController.text,
      'criteriaRatings': criteriaRatings,
    });

    if (mounted) {
      setState(() {
        _initialReview = _reviewController.text;
        _initialRating = _criteriaScoreController.text;
        _hasUnsavedData = false;
      });
      Navigator.pop(context, {
        'reload': true,
        'book': FinishedBook.fromMap(widget.book.id, {
          ...widget.book.toMap(),
          'personalReview': _reviewController.text,
          'overallRating': _criteriaScoreController.text,
          'criteriaRatings': criteriaRatings,
        }),
      });
    }
  }

  void _addCriterion() async {
    final allCriteria = [..._defaultCriteria, ..._customCriteria];
    final List<RatingCriterion> available =
        allCriteria.where((c) => !criteriaEntries.containsKey(c.id)).toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).all_criteria_added,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.lerp(Theme.of(context).colorScheme.tertiary, Colors.white, 0.7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Color.lerp(
              Color(int.parse(widget.category.colorCode)), Colors.white, 0.7),
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Color(int.parse(widget.category.colorCode)),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    S.of(context).add_criteria,
                    style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.29,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: available
                            .map((criterion) => ListTile(
                                  title:
                                      Text(criterion.getLocalizedTitle(context),
                                          style: const TextStyle(
                                            color: Colors.black,
                                          )),
                                  trailing: criterion.isCustom
                                      ? IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _confirmDeleteCriterion(
                                                  context, criterion),
                                        )
                                      : null,
                                  onTap: () =>
                                      Navigator.pop(context, criterion),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(height: 1, color: Color(int.parse(widget.category.colorCode)), thickness: 2,),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: Text(S.of(context).add_criteria),
                      onTap: () async {
                        final newCriterionTitle =
                            await _showCreateCriterionDialog(context);
                        if (newCriterionTitle != null) {
                          Navigator.pop(context, newCriterionTitle);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      if (result is RatingCriterion) {
        _handleExistingCriterion(result);
      } else if (result is String) {
        await _handleNewCriterion(result);
      }
    }
  }

  Future<void> _confirmDeleteCriterion(
      BuildContext context, RatingCriterion criterion) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.lerp(
            Color(int.parse(widget.category.colorCode)), Colors.white, 0.7),
        shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Color(int.parse(widget.category.colorCode)),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16)),
        title: Text(S.of(context).delete),
        content: Text(S.of(context).are_you_sure),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              S.of(context).cancel,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.of(context).delete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteUserCriterion(criterion);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _deleteUserCriterion(RatingCriterion criterion) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseDatabase.instance
        .ref('customCriteria/$userId/${criterion.id}')
        .remove();
    final userBooksRef = FirebaseDatabase.instance.ref('finishedBooks/$userId');
    final userBooksSnapshot = await userBooksRef.get();

    if (userBooksSnapshot.exists) {
      final booksMap = userBooksSnapshot.value as Map<dynamic, dynamic>;

      for (final bookEntry in booksMap.entries) {
        final bookId = bookEntry.key.toString();
        final bookData = bookEntry.value as Map<dynamic, dynamic>;

        if (bookData['criteriaRatings'] != null) {
          final criteriaRatings = Map<String, dynamic>.from(
              bookData['criteriaRatings'] as Map<dynamic, dynamic>);
          if (criteriaRatings.containsKey(criterion.id)) {
            criteriaRatings.remove(criterion.id);

            await userBooksRef.child(bookId).update({
              'criteriaRatings': criteriaRatings,
            });
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _customCriteria.removeWhere((c) => c.id == criterion.id);
        criteriaEntries.remove(criterion.id);
      });
      _checkForChanges();
    }
  }

  Future<String?> _showCreateCriterionDialog(BuildContext context) async {
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.lerp(
              Color(int.parse(widget.category.colorCode)), Colors.white, 0.7),
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Color(int.parse(widget.category.colorCode)),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16)),
          title: Text(
            S.of(context).add_criteria,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          content: TextField(
            controller: controller,
            cursorColor: Color(int.parse(widget.category.colorCode)),
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: S.of(context).title,
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
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                S.of(context).cancel,
                style: const TextStyle(
                  color: Colors.black38,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: Text(
                S.of(context).save,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleExistingCriterion(RatingCriterion criterion) {
    if (!criteriaEntries.containsKey(criterion.id)) {
      setState(() {
        criteriaEntries[criterion.id] = TextEditingController();
      });
      _checkForChanges();
    }
  }

  Future<void> _handleNewCriterion(String title) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final newCriterionId = DateTime.now().millisecondsSinceEpoch.toString();

    final newCriterion = RatingCriterion(
      id: newCriterionId,
      title: title,
      isCustom: true,
    );

    await _databaseReference
        .child('customCriteria/$userId/$newCriterionId')
        .set(newCriterion.toMap());

    setState(() {
      _customCriteria.add(newCriterion);
      criteriaEntries[newCriterionId] = TextEditingController();
    });

    _checkForChanges();
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
              title: Text(
                  '${widget.book.title}: ${S.of(context).review_and_criteria}'),
              centerTitle: true,
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Color.lerp(Color(int.parse(widget.category.colorCode)),
                      Colors.white, 0.7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                          color: Color(int.parse(widget.category.colorCode)))),
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
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 65,
                              child: TextFormField(
                                controller: _criteriaScoreController,
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
                                cursorColor:
                                    Color(int.parse(widget.category.colorCode)),
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
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
                        const SizedBox(
                          height: 16,
                        ),
                        if (_isLoadingCriteria)
                          Center(
                            child: CircularProgressIndicator(
                              color:
                                  Color(int.parse(widget.category.colorCode)),
                            ),
                          )
                        else ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(S.of(context).criteria,
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.black)),
                                FloatingActionButton(
                                  mini: true,
                                  onPressed: _addCriterion,
                                  shape: const CircleBorder(),
                                  backgroundColor: Color(
                                      int.parse(widget.category.colorCode)),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...criteriaEntries.entries.map((entry) {
                            final allCriteria = [
                              ..._defaultCriteria,
                              ..._customCriteria
                            ];

                            final criterion = allCriteria.firstWhere(
                              (c) => c.id == entry.key,
                              orElse: () {
                                return RatingCriterion(
                                  id: entry.key,
                                  title: entry.key,
                                  isCustom: true,
                                );
                              },
                            );

                            return CriterionRatingField(
                              label: criterion.getLocalizedTitle(context),
                              controller: entry.value,
                              colorCode: widget.category.colorCode,
                              onChanged: _checkForChanges,
                              onDelete: () {
                                setState(
                                    () => criteriaEntries.remove(entry.key));
                                _checkForChanges();
                              },
                            );
                          }).toList(),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveReview,
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

class CriterionRatingField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String colorCode;
  final VoidCallback? onChanged;
  final VoidCallback? onDelete;

  const CriterionRatingField({
    super.key,
    required this.label,
    required this.controller,
    required this.colorCode,
    this.onChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$label:',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              TextFormField(
                controller: controller,
                onChanged: (_) => onChanged?.call(),
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(int.parse(colorCode))),
                  ),
                  contentPadding: const EdgeInsets.only(right: 30),
                  isDense: true,
                  counterText: '',
                ),
                cursorColor: Color(int.parse(colorCode)),
                style: const TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.end,
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.isEmpty) return newValue;
                    final value = int.tryParse(newValue.text);
                    if (value == null || value < 0 || value > 100) {
                      return oldValue;
                    }
                    return newValue;
                  }),
                ],
              ),
              const Positioned(
                right: 0,
                child: Text(
                  '/100',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
          tooltip: S.of(context).delete,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
