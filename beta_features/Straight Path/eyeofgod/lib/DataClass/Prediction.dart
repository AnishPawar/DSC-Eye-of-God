class Prediction {
  String mainText;
  String placeId;
  String secondaryText;

  Prediction({
    this.mainText,
    this.placeId,
    this.secondaryText,
  });

  Prediction.fromJson(Map<String, dynamic> json) {
    placeId = json['place_id'];
    mainText = json['structured_formatting']['main_text'];
    secondaryText = json['structured_formatting']['secondary_text'];
  }
}