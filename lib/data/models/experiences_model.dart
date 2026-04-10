import 'dart:ui';

class Experiences {
  final String id;
  final String eventId;
  final String status;
  final DateTime? deletedAt;

  final Photo photo;
  final Shoutout shoutout;
  final Boomerang boomerang;
  final Gif gif;
  final SlowMotion slowMotion;

  final AiStyles aiStyles;

  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Experiences({
    required this.id,
    required this.eventId,
    required this.status,
    this.deletedAt,
    required this.photo,
    required this.shoutout,
    required this.boomerang,
    required this.gif,
    required this.slowMotion,
    required this.aiStyles,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Experiences.fromJson(Map<String, dynamic> json) {
    return Experiences(
      id: json['_id'] ?? '',
      eventId: json['eventId'] ?? '',
      status: json['status'] ?? '',
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      photo: Photo.fromJson(json['photo'] ?? {}),
      shoutout: Shoutout.fromJson(json['shoutout'] ?? {}),
      boomerang: Boomerang.fromJson(json['boomerang'] ?? {}),
      gif: Gif.fromJson(json['gif'] ?? {}),
      slowMotion: SlowMotion.fromJson(json['slowMotion'] ?? {}),
      aiStyles: AiStyles.fromJson(json['aiStyles'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'eventId': eventId,
      'status': status,
      'deletedAt': deletedAt?.toIso8601String(),
      'photo': photo.toJson(),
      'shoutout': shoutout.toJson(),
      'boomerang': boomerang.toJson(),
      'gif': gif.toJson(),
      'slowMotion': slowMotion.toJson(),
      'aiStyles': aiStyles.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class Photo {
  final bool enabled;
  final bool printOptionEnabled;

  Photo({required this.enabled, required this.printOptionEnabled});

  factory Photo.fromJson(Map<dynamic, dynamic> json) {
    return Photo(enabled: json['enabled'] ?? false, printOptionEnabled: json['printOptionEnabled'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'enabled': enabled, 'printOptionEnabled': printOptionEnabled};
  }
}

class Shoutout {
  final bool enabled;
  final int timeLimit;

  Shoutout({required this.enabled, required this.timeLimit});

  factory Shoutout.fromJson(Map<dynamic, dynamic> json) {
    return Shoutout(enabled: json['enabled'] ?? false, timeLimit: json['timeLimit'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'enabled': enabled, 'timeLimit': timeLimit};
  }
}

class Boomerang {
  final bool enabled;
  final int recordingLength;
  final double playbackSpeed;
  final String loopCount;
  final bool motionSmoothing;

  Boomerang({
    required this.enabled,
    required this.recordingLength,
    required this.playbackSpeed,
    required this.loopCount,
    required this.motionSmoothing,
  });

  factory Boomerang.fromJson(Map<dynamic, dynamic> json) {
    return Boomerang(
      enabled: json['enabled'] ?? false,
      recordingLength: json['recordingLength'] ?? 0,
      playbackSpeed: (json['playbackSpeed'] ?? 1).toDouble(),
      loopCount: json['loopCount'] ?? 'infinite',
      motionSmoothing: json['motionSmoothing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'recordingLength': recordingLength,
      'playbackSpeed': playbackSpeed,
      'loopCount': loopCount,
      'motionSmoothing': motionSmoothing,
    };
  }
}

class Gif {
  final bool enabled;
  final int frameCount;
  final double captureInterval;
  final double playbackSpeed;
  final String layout;

  Gif({
    required this.enabled,
    required this.frameCount,
    required this.captureInterval,
    required this.playbackSpeed,
    required this.layout,
  });

  factory Gif.fromJson(Map<dynamic, dynamic> json) {
    return Gif(
      enabled: json['enabled'] ?? false,
      frameCount: json['frameCount'] ?? 0,
      captureInterval: (json['captureInterval'] ?? 0.0).toDouble(),
      playbackSpeed: (json['playbackSpeed'] ?? 1).toDouble(),
      layout: json['layout'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'frameCount': frameCount,
      'captureInterval': captureInterval,
      'playbackSpeed': playbackSpeed,
      'layout': layout,
    };
  }
}

class SlowMotion {
  final bool enabled;
  final int recordingDuration;
  final double slowMotionSpeed;
  final int frameRate;

  SlowMotion({required this.enabled, required this.recordingDuration, required this.slowMotionSpeed, required this.frameRate});

  factory SlowMotion.fromJson(Map<dynamic, dynamic> json) {
    return SlowMotion(
      enabled: json['enabled'] ?? false,
      recordingDuration: json['recordingDuration'] ?? 0,
      slowMotionSpeed: (json['slowMotionSpeed'] ?? 1.0).toDouble(),
      frameRate: json['frameRate'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'recordingDuration': recordingDuration,
      'slowMotionSpeed': slowMotionSpeed,
      'frameRate': frameRate,
    };
  }
}

class AiStyles {
  final bool enabled;
  final bool overlayEnabled;
  final List<dynamic> styles;

  AiStyles({required this.enabled, required this.overlayEnabled, required this.styles});

  factory AiStyles.fromJson(Map<dynamic, dynamic> json) {
    return AiStyles(
      enabled: json['enabled'] ?? false,
      overlayEnabled: json['photoOverlay'] ?? false,
      styles: json['styles'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'enabled': enabled, 'photoOverlay': overlayEnabled, 'styles': styles};
  }
}

class ExperienceItem {
  final String key;
  final String label;
  final String icon;
  final VoidCallback onTap;

  ExperienceItem({required this.key, required this.label, required this.icon, required this.onTap});
}
