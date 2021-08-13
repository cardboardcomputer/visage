# Visage

Basic iPhone app to stream ARAnchorFace blendshape data via OpenSoundControl.

# OSC Broadcast

An OSC message is broadcast everytime the AR session on the iPhone is updated. This usually happens at 60fps, but maybe be halved to 30fps depending on tracking quality and other phone conditions (charging or overheating will reduce frame rate, for example).

The message that is broadcast is an array of 63 floats:

`/face float[63]`

With the following sections in the array:

- indices `0`-`51` are the blendshapes
- indices `52`-`61` are eye/head transforms
- index `62` is the elapsed time (in seconds) phone-side

The full list of data indicies are as follows:

```
// blendshapes:

[ 0]  browInnerUp
[ 1]  browDownLeft
[ 2]  browDownRight
[ 3]  browOuterUpLeft
[ 4]  browOuterUpRight
[ 5]  eyeLookUpLeft
[ 6]  eyeLookUpRight
[ 7]  eyeLookDownLeft
[ 8]  eyeLookDownRight
[ 9]  eyeLookInLeft
[10]  eyeLookInRight
[11]  eyeLookOutLeft
[12]  eyeLookOutRight
[13]  eyeBlinkLeft
[14]  eyeBlinkRight
[15]  eyeSquintLeft
[16]  eyeSquintRight
[17]  eyeWideLeft
[18]  eyeWideRight
[19]  cheekPuff
[20]  cheekSquintLeft
[21]  cheekSquintRight
[22]  noseSneerLeft
[23]  noseSneerRight
[24]  jawOpen
[25]  jawForward
[26]  jawLeft
[27]  jawRight
[28]  mouthFunnel
[29]  mouthPucker
[30]  mouthLeft
[31]  mouthRight
[32]  mouthRollUpper
[33]  mouthRollLower
[34]  mouthShrugUpper
[35]  mouthShrugLower
[36]  mouthClose
[37]  mouthSmileLeft
[38]  mouthSmileRight
[39]  mouthFrownLeft
[40]  mouthFrownRight
[41]  mouthDimpleLeft
[42]  mouthDimpleRight
[43]  mouthUpperUpLeft
[44]  mouthUpperUpRight
[45]  mouthLowerDownLeft
[46]  mouthLowerDownRight
[47]  mouthPressLeft
[48]  mouthPressRight
[49]  mouthStretchLeft
[50]  mouthStretchRight
[51]  tongueOut

// transforms:

[52]  eye (left) X
[53]  eye (left) Y
[54]  eye (right) X
[55]  eye (right) Y
[56]  head rotation X
[57]  head rotation Y
[58]  head rotation Z
[59]  head position X
[60]  head position Y
[61]  head position Z

// timestamp:

[62]  timestamp (seconds)
```