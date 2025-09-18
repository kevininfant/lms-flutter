import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/scorm.dart';

class ScormRepository {
  Future<CourseData> loadCourseData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/course.json');
      final Map<String, dynamic> data = json.decode(response);
      return CourseData.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load course data: $e');
    }
  }

  Future<List<Scorm>> loadScorms() async {
    try {
      final courseData = await loadCourseData();
      return courseData.scorms;
    } catch (e) {
      throw Exception('Failed to load SCORM data: $e');
    }
  }

  Future<List<Video>> loadVideos() async {
    try {
      final courseData = await loadCourseData();
      return courseData.videos;
    } catch (e) {
      throw Exception('Failed to load video data: $e');
    }
  }

  Future<List<Music>> loadMusic() async {
    try {
      final courseData = await loadCourseData();
      return courseData.music;
    } catch (e) {
      throw Exception('Failed to load music data: $e');
    }
  }

  Future<List<H5P>> loadH5P() async {
    try {
      final courseData = await loadCourseData();
      return courseData.h5p;
    } catch (e) {
      throw Exception('Failed to load H5P data: $e');
    }
  }

  Future<List<Document>> loadDocuments() async {
    try {
      final courseData = await loadCourseData();
      return courseData.docs;
    } catch (e) {
      throw Exception('Failed to load document data: $e');
    }
  }

  Future<Scorm?> getScormById(int id) async {
    try {
      final scorms = await loadScorms();
      return scorms.firstWhere((scorm) => scorm.id == id);
    } catch (e) {
      return null;
    }
  }
}
