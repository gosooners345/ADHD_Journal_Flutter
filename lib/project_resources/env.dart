import 'package:envied/envied.dart';
part 'env.g.dart';
@Envied(path:"keys.env")
abstract class Env{
  @EnviedField(varName:"IOS_API_KEY",obfuscate:true)
  static String IOS_API_KEY = _Env.IOS_API_KEY;
  @EnviedField(varName:"ANDROID_API_KEY",obfuscate:true)
  static String ANDROID_API_KEY = _Env.ANDROID_API_KEY;

}