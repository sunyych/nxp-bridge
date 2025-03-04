#include <jni.h>
#include "react-native-nxp-bridge.h"

extern "C"
JNIEXPORT jdouble JNICALL
Java_com_nxpbridge_NxpBridgeModule_nativeMultiply(JNIEnv *env, jclass type, jdouble a, jdouble b) {
    return nxpbridge::multiply(a, b);
}
