import 'package:flutter/material.dart';

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

class SocialConnections {
  final String attachments;
  final Map<String, List<Relationship>> relationships;
  final String attitudeToSociety;

  SocialConnections({
    required this.attachments,
    required this.relationships,
    required this.attitudeToSociety,
  });

  factory SocialConnections.fromMap(Map<dynamic, dynamic> map) {
    final relations = map['relationships'] as Map<dynamic, dynamic>? ?? {};

    return SocialConnections(
      attachments: map['attachments']?.toString() ?? '',
      relationships: {
        'family': _parseRelationships(relations['family']),
        'friends': _parseRelationships(relations['friends']),
        'enemies': _parseRelationships(relations['enemies']),
      },
      attitudeToSociety: map['attitudeToSociety']?.toString() ?? '',
    );
  }

  static List<Relationship> _parseRelationships(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => Relationship.fromMap(Map<dynamic, dynamic>.from(e))).toList();
    }
    if (data is Map) {
      return data.values
          .map((e) => Relationship.fromMap(Map<dynamic, dynamic>.from(e)))
          .toList();
    }
    return [];
  }
}

class Relationship {
  final String characterId;
  final String characterName;
  final String characterRelation;
  final String selectedCharacterRelation;

  Relationship({
    required this.characterId,
    required this.characterName,
    required this.characterRelation,
    required this.selectedCharacterRelation,
  });

  factory Relationship.fromMap(Map<dynamic, dynamic> map) {
    return Relationship(
      characterId: map['characterId']?.toString() ?? '',
      characterName: map['characterName']?.toString() ?? '',
      characterRelation: map['characterRelation']?.toString() ?? '',
      selectedCharacterRelation: map['selectedCharacterRelation']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'characterId': characterId,
      'characterName': characterName,
      'characterRelation': characterRelation,
      'selectedCharacterRelation': selectedCharacterRelation,
    };
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

  Map<String, dynamic> toMap() {
    return {
      if (mainImage != null) 'mainImage': mainImage!.toMap(),
      'appearance': appearance.map((e) => e.toMap()).toList(),
      'clothing': clothing.map((e) => e.toMap()).toList(),
      'moodboard': moodboard.map((e) => e.toMap()).toList(),
    };
  }
}

class ImageReference {
  final String url;
  final String caption;
  final DateTime? addedAt;
  final bool isLink;

  ImageReference({
    this.url = '',
    this.caption = '',
    this.addedAt,
    this.isLink = false,
  });

  factory ImageReference.fromMap(Map<dynamic, dynamic> map) {
    try {
      return ImageReference(
        url: map['url']?.toString() ?? '',
        caption: map['caption']?.toString() ?? '',
        addedAt: map['addedAt'] != null
            ? DateTime.parse(map['addedAt'].toString())
            : null,
        isLink: map['isLink'] as bool? ?? false,
      );
    } catch (e) {
      debugPrint('Error parsing ImageReference: $e');
      return ImageReference();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'caption': caption,
      if (addedAt != null) 'addedAt': addedAt!.toIso8601String(),
      'isLink': isLink,
    };
  }
}