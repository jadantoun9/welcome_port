import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:welcome_port/core/helpers/error_helpers.dart';
import 'package:welcome_port/core/helpers/singletons.dart';
import 'package:mime/mime.dart';

class FileService {
  Future<Either<String, String>> uploadImage(File file) async {
    // Validate file exists and has content
    if (!await file.exists()) {
      return Left('File does not exist');
    }

    if (await file.length() == 0) {
      return Left('File is empty');
    }

    // Get image dimensions if it's an image file
    String? mimeType = lookupMimeType(file.path);
    FormData formData = FormData();

    // Get the original filename
    String originalFilename = file.path.split('/').last;

    // Ensure filename meets requirements (between 3 and 64 characters)
    String safeFilename = originalFilename;

    // If filename is too short, add a prefix
    if (safeFilename.length < 3) {
      safeFilename = "img_$safeFilename";
    }

    // If filename is too long, truncate it while preserving extension
    if (safeFilename.length > 64) {
      final extension =
          safeFilename.contains('.')
              ? safeFilename.substring(safeFilename.lastIndexOf('.'))
              : '';
      safeFilename =
          safeFilename.substring(0, 64 - extension.length) + extension;
    }

    // Make sure the filename has an extension
    if (!safeFilename.contains('.')) {
      safeFilename = "$safeFilename.jpg"; // Default to jpg if no extension
    }

    formData.files.add(
      MapEntry(
        'file',
        await MultipartFile.fromFile(
          file.path,
          filename: safeFilename,
          contentType: mimeType != null ? DioMediaType.parse(mimeType) : null,
        ),
      ),
    );

    try {
      final response = await Singletons.dio.post(
        '/upload',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.data['error'] != null &&
          response.data['error'].toString() != "[]") {
        return Left(response.data['error'].toString());
      }
      // Check success response structure based on your Postman example
      if (response.data['success'] != null) {
        return Right(response.data['data']['code'] ?? response.data['success']);
      }
      return Right(response.data['message']);
    } on DioException catch (e) {
      return Left(getMessageFromError(e));
    } catch (e) {
      debugPrint("Unexpected error: $e");
      return Left(getDefaultErrorMessage());
    }
  }
}
