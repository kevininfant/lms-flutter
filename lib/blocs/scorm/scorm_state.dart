import '../../models/scorm.dart';

abstract class ScormState {}

class ScormInitial extends ScormState {}

class ScormLoading extends ScormState {}

class ScormLoaded extends ScormState {
  final List<Scorm> scorms;
  ScormLoaded(this.scorms);
}

class ScormError extends ScormState {
  final String message;
  ScormError(this.message);
}

class VideoLoading extends ScormState {}

class MusicLoading extends ScormState {}

class H5PLoading extends ScormState {}

class DocumentsLoading extends ScormState {}

class AllCourseDataLoading extends ScormState {}

class ScormDetailLoaded extends ScormState {
  final Scorm scorm;
  ScormDetailLoaded(this.scorm);
}

class VideosLoaded extends ScormState {
  final List<Video> videos;
  VideosLoaded(this.videos);
}

class MusicLoaded extends ScormState {
  final List<Music> music;
  MusicLoaded(this.music);
}

class H5PLoaded extends ScormState {
  final List<H5P> h5p;
  H5PLoaded(this.h5p);
}

class DocumentsLoaded extends ScormState {
  final List<Document> documents;
  DocumentsLoaded(this.documents);
}

class AllCourseDataLoaded extends ScormState {
  final CourseData courseData;
  AllCourseDataLoaded(this.courseData);
}
