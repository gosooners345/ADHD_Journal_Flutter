import 'package:envied/src/envied_base.dart';
import 'package:envied/envied.dart';
import 'package:envied_generator/envied_generator.dart';
part 'env.g.dart';
@Envied(path:"keys.env",allowOptionalFields: true)
abstract class Env{
  @EnviedField(varName:"IOS_API_KEY",obfuscate:true)
  static String IOS_API_KEY = _Env.IOS_API_KEY;
  @EnviedField(varName:"ANDROID_API_KEY",obfuscate:true)
  static String ANDROID_API_KEY = _Env.ANDROID_API_KEY;

}