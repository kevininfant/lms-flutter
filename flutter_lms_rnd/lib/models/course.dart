enum CourseType { video, scorm, url }

class Course {
  final String id;
  final String name;
  final String duration;
  final double rating;
  final String url; // URL for the course
  final String description; // Description of the course
  final String videoUrl; // New field for video URL
  final CourseType type; // Course type (video, scorm, url)
  final String? scormAssetPath; // Path to SCORM ZIP file in assets
  final String? thumbnailPath; // Path to course thumbnail
  final bool isOfflineAvailable; // Whether course is available offline

  Course({
    required this.id,
    required this.name,
    required this.duration,
    required this.rating,
    required this.url,
    required this.description,
    required this.videoUrl,
    this.type = CourseType.video,
    this.scormAssetPath,
    this.thumbnailPath,
    this.isOfflineAvailable = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id:
          json['id'] ??
          json['name'].toString().toLowerCase().replaceAll(' ', '_'),
      name: json['name'],
      duration: json['duration'],
      rating: json['rating'].toDouble(),
      url: json['url'],
      description: json['description'],
      videoUrl: json['videoUrl'] ?? json['url'],
      type: _parseCourseType(json['type']),
      scormAssetPath: json['scormAssetPath'],
      thumbnailPath: json['thumbnailPath'],
      isOfflineAvailable: json['isOfflineAvailable'] ?? false,
    );
  }

  static CourseType _parseCourseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'scorm':
        return CourseType.scorm;
      case 'url':
        return CourseType.url;
      default:
        return CourseType.video;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'rating': rating,
      'url': url,
      'description': description,
      'videoUrl': videoUrl,
      'type': type.name,
      'scormAssetPath': scormAssetPath,
      'thumbnailPath': thumbnailPath,
      'isOfflineAvailable': isOfflineAvailable,
    };
  }

  Course copyWith({
    String? id,
    String? name,
    String? duration,
    double? rating,
    String? url,
    String? description,
    String? videoUrl,
    CourseType? type,
    String? scormAssetPath,
    String? thumbnailPath,
    bool? isOfflineAvailable,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      rating: rating ?? this.rating,
      url: url ?? this.url,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      type: type ?? this.type,
      scormAssetPath: scormAssetPath ?? this.scormAssetPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isOfflineAvailable: isOfflineAvailable ?? this.isOfflineAvailable,
    );
  }
}
