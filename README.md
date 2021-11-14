# LearnedRubiks
Learned Rubiks will be a application that solves a rubiks cube in some regaurd. 
Currently it will vizualize a rubiks cube and listen to gestures to perform full cube rotations. 
A future project will contain a fully functioning virtual Rubik's Cube.

## Data Collection
To gather the data we gathered a dataset of \~4000 data points. 1000 was from Nick Larsen holding the phone in his right hand, 1000 from his left, and the same for Steven Larsen.
The notebook shows how accurate our models were on that dataset and the loaded model was trained on that dataset as well.

## Cube Definition Virtually (RubiksCube.swift)
### Properties
This class(es) will be what we use to analyze the state of the cube and perform turns. 
The RubiksCube class has a list of Cublets that each have the following properties:
* cameraNode: SCNNode! this is the camera for the scene
* bottomPositions, upPositions, rightPositions, leftPositions, frontPositions backPositions
  * These are lists containing the cublet positions for each of the layers coresponding to the face listed.
* ZRotationPositive, ZRotationNegative, YRotationPositive, YRotatationNegative, XRotationPositive, XRotationNegative
  * These are the new locations of each position (in order) if that rotation had occured. 
  i.e. XRotationPositive[3] is the new position for what ever cublet was at position 3, after a X Rotation.

### Cublet Class
This class is a private member of RubiksCube and is soly by RubiksCube class.
#### Properties
* node:SCNNode - the node that is in the SCNScene.
* pos - a position that repersents where the cublet is on the cube see [cuble position](#cublet-position)
* upDown, leftright, frontBack
  * These are the colors of the faces listed for that cublet. It is important to note that a cublet can only be on the right or left face at any given time, and the same can be said for the (up or down) and (front or back). Thus, we only need 3 colors to represent the colors for the cublet.
* pieceType - enum describing what type the piece is
  * corner - has 3 valid colors. Exists in positions: 1, 3, 17, 19, 21, 25, 27
  * wedge - has 2 valid colors. Exists in positions: 2, 4, 6, 8, 10, 12, 16, 18, 20, 22, 24, 26
  * center - has 1 valid color. Exists in positions: 5, 11, 13, 15, 17, 23
  * middlePiece - has 0 valid colors. Exists in position 14

## Index
### [Cublet Position](#cublet-position)
Each layer follow the same order and the pieces are numbered in the following manner:
* Down Right Front Corner: 1
* Down Right Wedge: 2
* Down Right Back Corner: 3
* Down Front Wedge: 4
* Down Center: 5
* Down Back Wedge: 6
* Down Front Left Corner: 7
* Down Left Wedge: 8
* Down Left Back Corner: 9

So for example the Front Up piece is 22. **There is a middle piece that will never be seen that is number 14**
### Rotation Table
Below is the table representing where each piece goes when the whole cube is rotated. If you only apply this table to one face then it will turn that face.
|Original Positon|1 |2 |3 |4 |5 |5 |6 |7 |8 |9 |10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|
|----------------|- |- |- |- |- |- |- |- |- |- |--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
| Z Rotation     |0 | 7| 8| 9|16|17|18|25|26|27|4 |5 | 6|13|14|15|22|23|24| 1| 2| 3|10|11|12|19|20|21|
| Y Rotation     |0 | 7| 4| 1| 8| 5| 2| 9| 6| 3|16|13|10|17|14|11|18|15|12|25|22|19|26|23|20|27|24|21|
| X Rotation     |0 |19|10| 1|22|13| 4|25|16| 7|20|11| 2|23|14| 5|26|17| 8|21|12| 3|24|15| 6|27|18| 9|


