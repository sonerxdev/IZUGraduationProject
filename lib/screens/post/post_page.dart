import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicamp/model/user.dart';
import 'package:unicamp/model/widgets.dart';
import 'package:unicamp/services/database.dart';
import 'package:unicamp/shared/constants.dart';
import 'package:unicamp/shared/context_extension.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ImD;

class PostPage extends StatefulWidget {
  final User1 gCurrentUser;

  PostPage({this.gCurrentUser});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage>
    with AutomaticKeepAliveClientMixin<PostPage> {
  bool uploading = false;
  String postId = Uuid().v4();

  TextEditingController descriptionTextEditingController =
      new TextEditingController();
  TextEditingController locationTextEditingController =
      new TextEditingController();
  File file;

  captureImageWithCamera() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 680, maxWidth: 970);
    setState(() {
      this.file = imageFile;
    });
  }

  pickImageFromGallery() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      this.file = imageFile;
    });
  }

  takeImage(xContext) {
    return showDialog(
      context: xContext,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.black,
          title: Text(
            "Yeni Gönderi",
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                "Kamera",
                style:
                    TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
              ),
              onPressed: captureImageWithCamera,
            ),
            SimpleDialogOption(
              child: Text(
                "Galeri",
                style:
                    TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
              ),
              onPressed: pickImageFromGallery,
            ),
            SimpleDialogOption(
              child: Text(
                "İptal",
                style:
                    TextStyle(fontWeight: FontWeight.w300, color: Colors.blue),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  uploadScreen() {
    return Container(
      color: mainColor2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            color: Colors.grey,
            size: 200.0,
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 20.0,
            ),
            child: RaisedButton(
              onPressed: () => takeImage(context),
              color: mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.0),
              ),
              child: Text(
                "Gönderi Paylaş",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  clearPostInfo() {
    descriptionTextEditingController.clear();
    setState(() {
      file = null;
    });
  }

  compressPhoto() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 60));
    setState(() {
      file = compressedImageFile;
    });
  }

  uploadAndSave() async {
    setState(() {
      uploading = true;
    });

    await compressPhoto();

    String downloadUrl = await uploadPhoto(file);
    savePostFirestore(
        url: downloadUrl, description: descriptionTextEditingController.text);
    descriptionTextEditingController.clear();
    setState(() {
      file = null;
      uploading = false;
      postId = Uuid().v4();
    });

    SnackBar snackBar = SnackBar(
      content: Text(
        "Gönderi Paylaşıldı!",
        style: TextStyle(
            color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.w300),
      ),
      backgroundColor: secondColor,
      duration: Duration(milliseconds: 2000),
      elevation: 20.0,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  savePostFirestore({String url, String description}) {
    postReference
        .doc(widget.gCurrentUser.uid)
        .collection("usersPosts")
        .doc(postId)
        .set({
      "postId": postId,
      "ownerId": widget.gCurrentUser.uid,
      "timestamp": DateTime.now(),
      "likes": {},
      "username": widget.gCurrentUser.username,
      "description": description,
      "url": url,
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    UploadTask mStorageUploadTask =
        storageReference.child("post_$postId.jpg").putFile(mImageFile);
    String downloadUrl = await (await mStorageUploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  displayUploadFormScreen() {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          color: mainColor,
          child: Column(
            children: [
              uploading ? linearProgressWidget() : Text(""),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: clearPostInfo,
                  ),
                  Text(
                    "Yeni Gönderi",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                  FlatButton(
                    onPressed: () => uploading ? null : uploadAndSave(),
                    child: Text(
                      "Paylaş",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w300,
                          color: Colors.white),
                    ),
                  )
                ],
              ),
              Expanded(
                flex: 5,
                child: Container(
                  color: mainColor,
                  height: context.dynamicHeight(0.45),
                  width: context.dynamicWidth(2.0),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: FileImage(file),
                          fit: BoxFit.cover,
                        )),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  tileColor: mainColor,
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                        widget.gCurrentUser.photoLink),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: descriptionTextEditingController,
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              hintText: 'Bir şeyler yazın.',
                              hintStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300),
                              filled: true,
                              fillColor: mainColor2,
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return file == null ? uploadScreen() : displayUploadFormScreen();
  }
}
