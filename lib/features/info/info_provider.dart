import 'package:flutter/material.dart';
import 'package:welcome_port/features/info/info_service.dart';
import 'package:welcome_port/features/info/models/info_model.dart';
import 'package:welcome_port/features/info/utils/utils.dart';

class InfoProvider extends ChangeNotifier {
  final service = InfoService();

  InfoDetailsModel? info;
  bool isLoading = false;
  String error = '';
  String decodedHtml = '';

  void setInfo(InfoDetailsModel info) {
    this.info = info;
    notifyListeners();
  }

  void setError(String error) {
    this.error = error;
    notifyListeners();
  }

  void setIsLoading(bool isLoading) {
    this.isLoading = isLoading;
    notifyListeners();
  }

  void setDecodedHtml(String decodedHtml) {
    this.decodedHtml = decodedHtml;
    notifyListeners();
  }

  InfoProvider(String id) {
    getInfo(id);
  }

  Future<void> getInfo(String id) async {
    setIsLoading(true);
    final result = await service.getInfo(id);
    setIsLoading(false);
    result.fold((error) => setError(error), (info) {
      setDecodedHtml(decodeHtmlEntities(info.description));
      setInfo(info);
    });
  }
}
