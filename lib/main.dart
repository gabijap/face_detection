import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(FacePage());

class FacePage extends StatefulWidget {
  @override
  _FacePageState createState() => new _FacePageState();
}

class _FacePageState extends State<FacePage> {
  File _imageFile;
  List<Face> _faces = <Face>[]; // list of detected faces

  Rect myRect;

  Future getImage() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    final image = FirebaseVisionImage.fromFile(imageFile);
    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector(
        FaceDetectorOptions(enableClassification: true,
            enableLandmarks: true,
            enableTracking: false, mode:FaceDetectorMode.accurate));
    final List<Face> faces = await faceDetector.processImage(image);
    if(mounted){
      setState(() {
        _imageFile = imageFile;
        _faces = faces;
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return new MaterialApp(
      home: new Scaffold(
        appBar: AppBar(
          title: new Text('Face Detector'),
        ),
        body: Column(children: <Widget>[
          Flexible(
            flex: 2,
            child: Container(
              constraints: BoxConstraints.expand(),
              child: _imageFile == null
                  ? Text('No image selected.')
                  : Image.file(
                      _imageFile,
                      fit: BoxFit.cover,
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: ListView(
                children: _faces.map<Widget>((f) => FaceCoordinates(f)).toList(),
          )),
        ],),/*Column(children: <Widget>[
          Flexible(
              flex: 2,
              child: Container(
                constraints: BoxConstraints.expand(),
                child: Image.file(
                  _imageFile,
                  fit: BoxFit.cover,
                ),
              )),
          Flexible(
              flex: 1,
              child: new Text('Image picked'),/*ListView(
          children: _faces.map<Widget>((f) => FaceCoordinates(f)).toList(),
        ),*/),
        ]),*/
        floatingActionButton: FloatingActionButton(
            onPressed: getImage,
            tooltip: 'Pick an image',
            child: Icon(Icons.add_a_photo)
        ),
      ),
    );
  }

}


class FaceCoordinates extends StatelessWidget {
  FaceCoordinates(this.face);
  final Face face;

  @override
  Widget build(BuildContext context) {
    final pos = face.boundingBox;
    return ListTile(
      title: Text('(${pos.top}, ${pos.left}), (${pos.bottom}, ${pos.right})'),
    );
  }
}