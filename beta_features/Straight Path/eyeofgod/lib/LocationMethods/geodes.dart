import 'dart:math';

import 'package:geodesy/geodesy.dart';

Geodesy geodesy = Geodesy();
bool mid(double upd_start_lat, double upd_start_long, double upd_end_lat,
    double upd_end_long, double cur_lat, double cur_lng) {
  LatLng midpoint = geodesy.midPointBetweenTwoGeoPoints(
      new LatLng(upd_start_lat, upd_start_long),
      new LatLng(upd_end_lat, upd_end_long));
  num distance1 = geodesy.distanceBetweenTwoGeoPoints(
      new LatLng(upd_start_lat, upd_start_long),
      new LatLng(midpoint.latitude, midpoint.longitude));
  num distance2 = geodesy.distanceBetweenTwoGeoPoints(
      new LatLng(midpoint.latitude, midpoint.longitude),
      new LatLng(cur_lat, cur_lng));
  if (distance2 < distance1) {
    return true;
  }
}

int counter = 100;
bool pathMatching(double start_coord, double end_coord, double user_coord) {
  double averageAngle = 0;

  double x = 0;
  double y = 0;

  for (double a in [start_coord, end_coord]) {
    x += cos(a);
    y += sin(a);
  }

  averageAngle = atan2(y, x);

  counter--;
  if (((absabs(user_coord, start_coord) <= 0.0001) &
      (absabs(user_coord, start_coord) <= 0.0001))) {
    counter = 100;
    return true;
  }

  if (counter == 0) {
    counter = 100;
    return false;
  }

  if ((user_coord) <= averageAngle) {
    return pathMatching(start_coord, averageAngle, user_coord);
  }
  return pathMatching(averageAngle, end_coord, user_coord);
}

double absabs(double c1, double c2) {
  if ((c1 - c2) < 0) {
    return (c2 - c1);
  }
  return (c1 - c2);
}
