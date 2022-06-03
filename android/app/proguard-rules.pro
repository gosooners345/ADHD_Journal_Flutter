-ignorewarnings
-keep class * {
    public private *;
}
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }