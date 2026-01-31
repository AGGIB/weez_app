
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

final _secret = SecretKey('my_secret_key_123'); // TODO: Move to env

String generateToken(int userId) {
  final jwt = JWT(
    {'user_id': userId},
    issuer: 'weez.server',
  );
  return jwt.sign(_secret, expiresIn: Duration(days: 30));
}

JWT? verifyToken(String token) {
  try {
    return JWT.verify(token, _secret);
  } catch (e) {
    return null;
  }
}
