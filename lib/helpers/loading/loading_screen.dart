import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rappellemoi/helpers/loading/loading_screen_controller.dart';
import 'dart:developer' as devtools show log;


//This class handles the loading screen.
// When operations are happening in the background, we need to display a small message
//to the user so he knows that an operation is currently happening and he should wait.


class LoadingScreen {

  // create a singleton
  factory LoadingScreen() => _shared; //the private constructor always returns the _shared instance.
  static final LoadingScreen _shared = LoadingScreen._sharedInstance(); //since the _shared instance is a final, it iniatialized once and cannot be changed after that. static so it is attached to the class and not an instance of the class
  LoadingScreen._sharedInstance();  //private constructor that will create shared (doing nothing in particular but we could have added logic inside of this constructor)

  // loading screen controller
  LoadingScreenController? controller;

   void show({
     required BuildContext context,
     required String text,
    }){
    //we have to check if the controller has been initialized before or not, not only if it is null. If we can update the controller, it means it is existent
    if(controller?.update(text) ?? false ){
      return;
    } else { //there is no controller so we need one
      controller = showOverlay(
        context,
        text
      );
    }
   }
   void hide(){
    //close the controller (if it exists) and reinitialize it
    controller?.close();
    controller = null;
   }

  LoadingScreenController showOverlay(
     BuildContext context,
     String text,
    ){
      final _text = StreamController<String>(); //the stream controller will only take care of String values
      //add the text that should be displayed to the stream
      _text.add(text);
      
      final state = Overlay.of(context);
      
      // get the available size for the overlay
      final renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
   
      final overlay = OverlayEntry(
        builder: (context){
          return Material(
            color: Colors.black.withAlpha(150),
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: size.width*0.8,
                  maxHeight: size.width * 0.8,
                  minWidth: size.width * 0.5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StreamBuilder(
                        stream: _text.stream, //the stream builder is suscribded to the stream, it will update the UI when new info is passed to the stream
                        builder: (context, snapshot){
                          if(snapshot.hasData){
                            return Text(
                              snapshot.data as String,
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return Container();
                          }
                        }
                      )
                    ],
                  )
                )
              )
            )
          );
        }
        );
   
      // use the overlay
      state.insert(overlay);

      // return the loading screen controller

      return LoadingScreenController(
        close: (){
          //close the stream controller
          _text.close();
          //rmeove the overlay from the screen
          overlay.remove();
          // because of the type of the function, it has to return a boolean
          return true;

        }, 
        update: (text){
          // add the text to the stream
          _text.add(text);
          // because of the type of the function it has to return a boolean.
          return true;
        }
      );
   
   }

   
}
