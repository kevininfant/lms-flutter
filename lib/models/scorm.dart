class Scorm {
  final int id;
  final String scormName;
  final String? courseName;
  final String scormFileLink;
  final String description;

  Scorm({
    required this.id,
    required this.scormName,
    this.courseName,
    required this.scormFileLink,
    required this.description,
  });

  factory Scorm.fromJson(Map<String, dynamic> json) {
    return Scorm(
      id: json['id'],
      scormName: json['scormName'],
      courseName: json['courseName'],
      scormFileLink: json['scormFileLink'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scormName': scormName,
      'courseName': courseName,
      'scormFileLink': scormFileLink,
      'description': description,
    };
  }
}

class Video {
  final int id;
  final String videoName;
  final String videoUrl;
  final String type;
  final String description;

  Video({
    required this.id,
    required this.videoName,
    required this.videoUrl,
    required this.type,
    required this.description,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      videoName: json['videoName'],
      videoUrl: json['videoUrl'],
      type: json['type'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoName': videoName,
      'videoUrl': videoUrl,
      'type': type,
      'description': description,
    };
  }
}

class Music {
  final int id;
  final String musicName;
  final String musicUrl;
  final String type;
  final String description;

  Music({
    required this.id,
    required this.musicName,
    required this.musicUrl,
    required this.type,
    required this.description,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'],
      musicName: json['musicName'],
      musicUrl: json['musicUrl'],
      type: json['type'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'musicName': musicName,
      'musicUrl': musicUrl,
      'type': type,
      'description': description,
    };
  }
}

class H5P {
  final int id;
  final String h5pName;
  final String h5pFile;
  final String type;
  final String description;

  H5P({
    required this.id,
    required this.h5pName,
    required this.h5pFile,
    required this.type,
    required this.description,
  });

  factory H5P.fromJson(Map<String, dynamic> json) {
    return H5P(
      id: json['id'],
      h5pName: json['h5pName'],
      h5pFile: json['h5pFile'],
      type: json['type'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'h5pName': h5pName,
      'h5pFile': h5pFile,
      'type': type,
      'description': description,
    };
  }
}

class Document {
  final int id;
  final String docName;
  final String filePath;
  final String type;
  final String description;

  Document({
    required this.id,
    required this.docName,
    required this.filePath,
    required this.type,
    required this.description,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      docName: json['docName'],
      filePath: json['filePath'],
      type: json['type'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'docName': docName,
      'filePath': filePath,
      'type': type,
      'description': description,
    };
  }
}

class CourseData {
  final List<Scorm> scorms;
  final List<Video> videos;
  final List<Music> music;
  final List<H5P> h5p;
  final List<Document> docs;

  CourseData({
    required this.scorms,
    required this.videos,
    required this.music,
    required this.h5p,
    required this.docs,
  });

  factory CourseData.fromJson(Map<String, dynamic> json) {
    return CourseData(
      scorms: (json['scorm'] as List)
          .map((item) => Scorm.fromJson(item))
          .toList(),
      videos: (json['video'] as List)
          .map((item) => Video.fromJson(item))
          .toList(),
      music: (json['music'] as List)
          .map((item) => Music.fromJson(item))
          .toList(),
      h5p: (json['h5p'] as List)
          .map((item) => H5P.fromJson(item))
          .toList(),
      docs: (json['docs'] as List)
          .map((item) => Document.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scorm': scorms.map((item) => item.toJson()).toList(),
      'video': videos.map((item) => item.toJson()).toList(),
      'music': music.map((item) => item.toJson()).toList(),
      'h5p': h5p.map((item) => item.toJson()).toList(),
      'docs': docs.map((item) => item.toJson()).toList(),
    };
  }
}
