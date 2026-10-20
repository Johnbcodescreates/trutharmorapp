# TruthArmor release-build rules (read automatically by Flutter's Android build).
#
# Google ML Kit text recognition references optional language packs
# (Chinese, Devanagari, Japanese, Korean) that TruthArmor does not include.
# Tell the code shrinker (R8) these missing classes are expected.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
