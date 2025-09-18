abstract class ScormEvent {}

class LoadScormData extends ScormEvent {}

class LoadScormById extends ScormEvent {
  final int scormId;
  LoadScormById(this.scormId);
}

class LoadVideos extends ScormEvent {}

class LoadMusic extends ScormEvent {}

class LoadH5P extends ScormEvent {}

class LoadDocuments extends ScormEvent {}

class LoadAllCourseData extends ScormEvent {}
