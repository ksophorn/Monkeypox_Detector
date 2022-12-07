import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:tflite/tflite.dart';

class homeScreen extends StatefulWidget {
  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  var _image;
  List? _result;
  String _confidence = "";
  String _name = "";

  Future getImage(ImgSource source) async {
    try {
      var image = await ImagePickerGC.pickImage(
        context: context,
        source: source,
      );
      if (image == null) return;
      setState(() {
        _image = image;
        _image = File(_image!.path);
      });
      applyModelOnImage(_image!);
    }on PlatformException catch(e){
      print('Failed to pick image: $e');
    }
  }
  //End getImage

  //Dataset
  loadMyModel() async {
    var resultant = await Tflite.loadModel(
        labels: "assets/labels.txt",model: "assets/model.tflite"
    );
    print("Result after loading model:$resultant");
  }

  applyModelOnImage(File file) async {
    var res = await Tflite.runModelOnImage(
        path: file.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5
    );
    setState(() {
      _result = res;
      String str = _result![0]['label'];
      _name = str.substring(2);
      _confidence = _result != null ?
      (_result![0]['confidence'] * 100.0).toString().substring(0,5) + "%" : "";
    });
  }

  @override
  void initState() {
    super.initState();
    loadMyModel();
  }

  @override
  void dispose() {
    super.dispose();
  }
  //End Dataset

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monkeypox Detector'),
      ),
      body: Center(
          child: Column(
            children: [
              SizedBox(height: 30,),
              _image != null ? Image.file(_image!,width: 310,height: 310,fit: BoxFit.cover,) : Image.asset('assets/default_img.jpg'),
              SizedBox(height: 30,),
              CustomButton(title: 'Pick from Gallery',icon: Icons.image_outlined,onClick: () => getImage(ImgSource.Gallery)),
              CustomButton(title: 'Pick from Camera', icon: Icons.camera, onClick: () => getImage(ImgSource.Camera)),
              SizedBox(height: 20,),
              _image != null ?
                    _name == "Monkeypox" ?
                            Text("It might be monkeypox. You should visit \na dermatologist immediately! \nConfidence: $_confidence",style: TextStyle(fontSize: 16,),)
                          : Text("It's most probably not monkeypox, but \nvisiting a dermatologist always helps. \nConfidence: $_confidence",style: TextStyle(fontSize: 16,),)
                  : Text("Please pick image to detection!",style: TextStyle(fontSize: 16),)
            ],
          )
      ),
    );
  }
}

Widget CustomButton({
  required String title,
  required IconData icon,
  required VoidCallback onClick,
}){
  return Container(
    width: 280,
    child: ElevatedButton(
      onPressed: onClick,
      child: Row(children: [
        Icon(icon),
        SizedBox(
          width: 20,
        ),
        Text(title)
      ],),),
  );
}
