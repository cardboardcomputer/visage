# Visage

This provides a basic and free capture tool for iPhone-based face mocap and headgear. 

It inclues a bare-bones iOS project/app that streams ARKit's `ARFaceAnchor` data, which includes face blendshapes and transforms, and broadcasts it through the [Open Sound Control](http://opensoundcontrol.org/) protocol.

Build and run it on your phone with Xcode, and implement an OSC receiver in your capture software to collect the data.

A Blender add-on is included as a functional example that receives the data from the iOS app.

The iOS project depends on the [SwiftOSC](https://github.com/ExistentialAudio/SwiftOSC) framework.

# OSC Broadcast

An OSC message is broadcast every time the AR session on the iPhone is updated. This usually happens at 60 fps, but may be halved to 30 fps depending on phone conditions, like charging or overheating.

The message that's broadcast is a list of 63 floats:

`/visage float[63]`

With the following sections in the array:

- indices `0`-`51` are the blendshapes
- indices `52`-`61` are eye/head transforms
- index `62` is the elapsed time (in seconds) phone-side

The full list of data indices are:

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

[52]  head position.x
[53]  head position.y
[54]  head position.z
[55]  head euler.x
[56]  head euler.y
[57]  head euler.z
[58]  eye (left) euler.x
[59]  eye (left) euler.y
[60]  eye (right) euler.x
[61]  eye (right) euler.y

// timestamp:

[62]  timestamp (seconds)
```
