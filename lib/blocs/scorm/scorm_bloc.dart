import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/scorm_repository.dart';
import '../../models/scorm.dart';
import 'scorm_event.dart';
import 'scorm_state.dart';

class ScormBloc extends Bloc<ScormEvent, ScormState> {
  final ScormRepository scormRepository;

  ScormBloc(this.scormRepository) : super(ScormInitial()) {
    on<LoadScormData>((event, emit) async {
      emit(ScormLoading());
      try {
        final scorms = await scormRepository.loadScorms();
        emit(ScormLoaded(scorms));
      } catch (e) {
        emit(ScormError(e.toString()));
      }
    });

    on<LoadScormById>((event, emit) async {
      emit(ScormLoading());
      try {
        final scorm = await scormRepository.getScormById(event.scormId);
        if (scorm != null) {
          emit(ScormDetailLoaded(scorm));
        } else {
          emit(ScormError('SCORM not found'));
        }
      } catch (e) {
        emit(ScormError(e.toString()));
      }
    });

    on<LoadVideos>((event, emit) async {
      emit(VideoLoading());
      try {
        final videos = await scormRepository.loadVideos();
        emit(VideosLoaded(videos));
      } catch (e) {
        emit(ScormError(e.toString()));
      }
    });

    on<LoadMusic>((event, emit) async {
      emit(MusicLoading());
      try {
        final music = await scormRepository.loadMusic();
        emit(MusicLoaded(music));
      } catch (e) {
        emit(ScormError(e.toString()));
      }
    });

    on<LoadH5P>((event, emit) async {
      emit(H5PLoading());
      try {
        final h5p = await scormRepository.loadH5P();
        emit(H5PLoaded(h5p));
      } catch (e) {
        emit(ScormError(e.toString()));
      }
    });

    on<LoadDocuments>((event, emit) async {
      emit(DocumentsLoading());
      try {
        final documents = await scormRepository.loadDocuments();
        emit(DocumentsLoaded(documents));
      } catch (e) {
        emit(ScormError(e.toString()));
      }
    });

    on<LoadAllCourseData>((event, emit) async {
      emit(AllCourseDataLoading());
      try {
        final courseData = await scormRepository.loadCourseData();
        emit(AllCourseDataLoaded(courseData));
      } catch (e) {
        emit(ScormError(e.toString()));
      }
    });
  }
}
