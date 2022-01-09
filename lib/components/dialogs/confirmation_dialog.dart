import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanji_memory_hint/components/buttons/icon_button.dart';
import 'package:kanji_memory_hint/icons.dart';
import 'package:kanji_memory_hint/theme.dart';

class ConfirmationDialog extends StatelessWidget {

  final  Function() onConfirm;
  final Function() onCancel;

  const ConfirmationDialog({Key? key, required this.onConfirm, required this.onCancel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
          shape: const BeveledRectangleBorder(
              side: BorderSide(color: Colors.black, width: 1)
          ),
          child: Container(
            height: size.height * 0.25,
            width: size.width * 0.45,
            padding: EdgeInsets.all(6),
            child: Container(
              height: size.height*0.40,
              width: size.width*0.40,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1
                )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(flex: 1, child: Text("Are you sure?"),),
                  Flexible(
                    flex: 2,
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    
                    children: [
                      Expanded(flex: 1, child: SizedBox()),
                      Flexible(
                        flex:2,
                        // child: TextButton(
                        //   style: TextButton.styleFrom(
                        //     backgroundColor: AppColors.wrong
                        //   ),
                        //   child: Image.asset(AppIcons.yes,),
                        //   onPressed: onConfirm,
                        // ),
                        child: AppIconButton(
                          onTap: onConfirm, 
                          iconPath: AppIcons.yes, 
                          height: 100, 
                          width: 100,
                          ratio: 4/3,
                          backgroundColor: AppColors.wrong
                        )
                      ),

                      Expanded(flex: 1, child: SizedBox()),

                      Flexible(
                        flex: 2,
                        child: AppIconButton(
                          onTap: onCancel, 
                          iconPath: AppIcons.no, 
                          height: 100, 
                          width: 100,
                          ratio: 4/3,
                          backgroundColor: AppColors.primary
                        )
                      ),
                      Expanded(flex: 1, child: SizedBox()),

                    ],
                  )
                  )
                  
                ],
              )
            )
          )
    );
  }

}