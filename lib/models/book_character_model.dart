import 'package:flutter/material.dart';

import '../generated/l10n.dart';

class Character {
  final String id;
  final String name;
  final String age;
  final String role;
  final String race;
  final String occupation;
  final String appearanceDescription;
  final CharacterProfile? profile;
  final SocialConnections? social;
  final Biography? biography;
  final AdditionalInfo? additionalInfo;
  final CharacterImages? images;
  final String lastUpdate;

  Character({
    required this.id,
    required this.name,
    required this.age,
    required this.role,
    required this.race,
    required this.occupation,
    required this.appearanceDescription,
    this.profile,
    this.social,
    this.biography,
    this.additionalInfo,
    this.images,
    required this.lastUpdate
  });

  factory Character.fromMap(String id, Map<dynamic, dynamic> map) {
    return Character(
      id: id,
      name: map['name'] ?? '',
      age: map['age'] ?? '',
      role: map['role'] ?? '',
      race: map['race'] ?? '',
      occupation: map['occupation'] ?? '',
      appearanceDescription: map['appearanceDescription'] ?? '',
      profile: CharacterProfile.fromMap(Map<dynamic, dynamic>.from(map['profile'] ?? {})),
      social: SocialConnections.fromMap(Map<dynamic, dynamic>.from(map['social'] ?? {})),
      biography: Biography.fromMap(Map<dynamic, dynamic>.from(map['biography'] ?? {})),
      additionalInfo: AdditionalInfo.fromMap(Map<dynamic, dynamic>.from(map['additionalInfo'] ?? {})),
      images: CharacterImages.fromMap(Map<dynamic, dynamic>.from(map['images'] ?? {})),
      lastUpdate: map['lastUpdate'].toString(),
    );
  }
}

class CharacterProfile {
  final String personality;
  final String socialStatus;
  final String habits;
  final String strengths;
  final String weaknesses;
  final String beliefs;
  final String goal;
  final String motivation;
  final String admires;
  final String irritatesOrFears;
  final String inspires;
  final String temperament;
  final String stressBehavior;
  final String attitudeToLife;
  final String innerContradictions;

  CharacterProfile({
    required this.personality,
    required this.socialStatus,
    required this.habits,
    required this.strengths,
    required this.weaknesses,
    required this.beliefs,
    required this.goal,
    required this.motivation,
    required this.admires,
    required this.irritatesOrFears,
    required this.inspires,
    required this.temperament,
    required this.stressBehavior,
    required this.attitudeToLife,
    required this.innerContradictions,
  });

  factory CharacterProfile.fromMap(Map<dynamic, dynamic> map) {
    return CharacterProfile(
      personality: map['personality'] ?? '',
      socialStatus: map['socialStatus'] ?? '',
      habits: map['habits'] ?? '',
      strengths: map['strengths'] ?? '',
      weaknesses: map['weaknesses'] ?? '',
      beliefs: map['beliefs'] ?? '',
      goal: map['goal'] ?? '',
      motivation: map['motivation'] ?? '',
      admires: map['admires'] ?? '',
      irritatesOrFears: map['irritatesOrFears'] ?? '',
      inspires: map['inspires'] ?? '',
      temperament: map['temperament'] ?? '',
      stressBehavior: map['stressBehavior'] ?? '',
      attitudeToLife: map['attitudeToLife'] ?? '',
      innerContradictions: map['innerContradictions'] ?? '',
    );
  }
}

class SocialConnections {
  final String attachments;
  final List<Relationship> relationships;
  final String attitudeToSociety;

  SocialConnections({
    required this.attachments,
    required this.relationships,
    required this.attitudeToSociety,
  });

  factory SocialConnections.fromMap(Map<dynamic, dynamic> map) {
    return SocialConnections(
      attachments: map['attachments'] ?? '',
      relationships: (map['relationships'] as List? ?? [])
          .map((e) => Relationship.fromMap(Map<dynamic, dynamic>.from(e)))
          .toList(),
      attitudeToSociety: map['attitudeToSociety'] ?? '',
    );
  }
}

class Relationship {
  final String targetCharacterId;
  final String relationType;
  final String groupDescription;
  final RelationshipStatus currentStatus;
  final List<RelationshipEvent> history;
  final String characterPerspective;
  final String targetPerspective;

  Relationship({
    required this.targetCharacterId,
    required this.relationType,
    required this.groupDescription,
    required this.currentStatus,
    required this.history,
    required this.characterPerspective,
    required this.targetPerspective,
  });

  factory Relationship.fromMap(Map<dynamic, dynamic> map) {
    return Relationship(
      targetCharacterId: map['targetCharacterId'] ?? '',
      relationType: map['relationType'] ?? '',
      groupDescription: map['groupDescription'] ?? '',
      currentStatus: RelationshipStatus.fromString(map['currentStatus']?.toString()),
      history: (map['history'] as List? ?? [])
          .map((e) => RelationshipEvent.fromMap(Map<dynamic, dynamic>.from(e)))
          .toList(),
      characterPerspective: map['characterPerspective'] ?? '',
      targetPerspective: map['targetPerspective'] ?? '',
    );
  }
}

class RelationshipEvent {
  final String eventId;
  final String title;
  final String description;
  final DateTime date;
  final String previousStatus;
  final String newStatus;
  final bool isSecret;
  final String? chapterId;
  final RelationshipStatus mood;
  final List<String> involvedCharacters;

  RelationshipEvent({
    required this.eventId,
    required this.title,
    required this.description,
    required this.date,
    required this.previousStatus,
    required this.newStatus,
    required this.mood,
    this.isSecret = false,
    this.chapterId,
    this.involvedCharacters = const [],
  });

  factory RelationshipEvent.fromMap(Map<dynamic, dynamic> map) {
    return RelationshipEvent(
      eventId: map['eventId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.parse(map['date'].toString()),
      previousStatus: map['previousStatus'] ?? '',
      newStatus: map['newStatus'] ?? '',
      isSecret: map['isSecret'] ?? false,
      chapterId: map['chapterId'],
      mood: RelationshipStatus.fromString(map['mood']?.toString()),
      involvedCharacters: List<String>.from(map['involvedCharacters'] ?? []),
    );
  }
}

class Biography {
  final String pastEvents;
  final String secrets;
  final String characterDevelopment;
  final String lossesAndGains;
  final String innerConflicts;
  final String worstMemory;
  final String happiestMemory;
  final String turningPoint;
  final String hiddenAspects;

  Biography({
    required this.pastEvents,
    required this.secrets,
    required this.characterDevelopment,
    required this.lossesAndGains,
    required this.innerConflicts,
    required this.worstMemory,
    required this.happiestMemory,
    required this.turningPoint,
    required this.hiddenAspects,
  });

  factory Biography.fromMap(Map<dynamic, dynamic> map) {
    return Biography(
      pastEvents: map['pastEvents'] ?? '',
      secrets: map['secrets'] ?? '',
      characterDevelopment: map['characterDevelopment'] ?? '',
      lossesAndGains: map['lossesAndGains'] ?? '',
      innerConflicts: map['innerConflicts'] ?? '',
      worstMemory: map['worstMemory'] ?? '',
      happiestMemory: map['happiestMemory'] ?? '',
      turningPoint: map['turningPoint'] ?? '',
      hiddenAspects: map['hiddenAspects'] ?? '',
    );
  }
}

class AdditionalInfo {
  final List<String> talents;
  final List<String> artifacts;
  final String quote;
  final String firstImpression;

  AdditionalInfo({
    required this.talents,
    required this.artifacts,
    required this.quote,
    required this.firstImpression,
  });

  factory AdditionalInfo.fromMap(Map<dynamic, dynamic> map) {
    return AdditionalInfo(
      talents: List<String>.from(map['talents'] ?? []),
      artifacts: List<String>.from(map['artifacts'] ?? []),
      quote: map['quote'] ?? '',
      firstImpression: map['firstImpression'] ?? '',
    );
  }
}

enum RelationshipStatus {
  allies(Color(0xFF8AC086)),
  friends(Color(0xFF89B0D9)),
  neutral(Color(0xFFD3D3D3)),
  rivals(Color(0xFFFFB347)),
  enemies(Color(0xFFE6A8A8)),
  other(Color(0xFFC9A6D4));

  final Color color;

  const RelationshipStatus(this.color);

  String title(BuildContext context) {
    switch (this) {
      case RelationshipStatus.allies:
        return S.of(context).allies;
      case RelationshipStatus.friends:
        return S.of(context).friends;
      case RelationshipStatus.neutral:
        return S.of(context).neutral;
      case RelationshipStatus.rivals:
        return S.of(context).rivals;
      case RelationshipStatus.enemies:
        return S.of(context).enemies;
      case RelationshipStatus.other:
        return S.of(context).other;
    }
  }

  static RelationshipStatus fromString(String? value) {
    return values.firstWhere(
          (e) => e.name == value,
      orElse: () => RelationshipStatus.neutral,
    );
  }
}

class CharacterImages {
  final ImageReference? mainImage;
  final List<ImageReference> appearance;
  final List<ImageReference> clothing;
  final List<ImageReference> moodboard;

  CharacterImages({
    this.mainImage,
    this.appearance = const [],
    this.clothing = const [],
    this.moodboard = const [],
  });

  factory CharacterImages.fromMap(Map<dynamic, dynamic>? map) {
    map ??= {};

    return CharacterImages(
      mainImage: map['mainImage'] != null
          ? ImageReference.fromMap(Map<dynamic, dynamic>.from(map['mainImage']))
          : null,
      appearance: _parseImageList(map['appearance']),
      clothing: _parseImageList(map['clothing']),
      moodboard: _parseImageList(map['moodboard']),
    );
  }

  static List<ImageReference> _parseImageList(dynamic data) {
    if (data == null) return [];
    try {
      return (data as List).map((e) =>
          ImageReference.fromMap(Map<dynamic, dynamic>.from(e))
      ).toList();
    } catch (_) {
      return [];
    }
  }
}

class ImageReference {
  final String url;
  final String caption;
  final DateTime? addedAt;

  ImageReference({
    this.url = '',
    this.caption = '',
    this.addedAt,
  });

  factory ImageReference.fromMap(Map<dynamic, dynamic> map) {
    try {
      return ImageReference(
        url: map['url']?.toString() ?? '',
        caption: map['caption']?.toString() ?? '',
        addedAt: map['addedAt'] != null
            ? DateTime.parse(map['addedAt'].toString())
            : null,
      );
    } catch (e) {
      return ImageReference();
    }
  }
}