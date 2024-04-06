import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:flutter/material.dart';

class DropdownCountryBox extends StatefulWidget {
  final String country;
  ValueSetter<String> callBack;
  List<String> values = [];

  DropdownCountryBox(this.country,
      {Key? key, required this.callBack, required this.values})
      : super(key: key);

  @override
  _DropdownCountryBoxState createState() => _DropdownCountryBoxState();
}

class _DropdownCountryBoxState extends State<DropdownCountryBox> {
  GlobalKey? actionKey;
  double height = 0, width = 0, xPosition = 0, yPosition = 0;
  bool isDropdownOpened = false;
  OverlayEntry? floatingDropdown;

  @override
  void initState() {
    actionKey = LabeledGlobalKey(widget.country);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        key: actionKey,
        onTap: () {
          setState(() {
            if (isDropdownOpened) {
              floatingDropdown?.remove();
            } else {
              findDropdownPosition();
              floatingDropdown = _createFloatingDropdown();
              Overlay.of(context)?.insert(floatingDropdown!);
            }
            isDropdownOpened = !isDropdownOpened;
          });
        },
        child: _createHeader());
  }

  void findDropdownPosition() {
    RenderBox? renderBox =
        actionKey?.currentContext?.findRenderObject() as RenderBox?;
    height = renderBox?.size.height ?? 0;
    width = renderBox?.size.width ?? 0;
    Offset? offset = renderBox?.localToGlobal(Offset.zero);
    xPosition = (offset?.dx) ?? 0;
    yPosition = (offset?.dy) ?? 0;
  }

  OverlayEntry _createFloatingDropdown() {
    return OverlayEntry(builder: (context) {
      return Stack(
        children: [
          //For tap outside overlay to dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                floatingDropdown?.remove();
                isDropdownOpened = !isDropdownOpened;
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          //position of Overlay
          Positioned(
            width: MediaQuery.of(context).size.width,
            top: yPosition, //+ height,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: DropDown(
                itemHeight: height,
                selectedItem: widget.country,
                dropCountryData: widget.values,
                callBack: (value) => {hideDropdown(), widget.callBack(value)},
              ),
            ),
          ),
        ],
      );
    });
  }

  void hideDropdown() {
    floatingDropdown?.remove();
    isDropdownOpened = !isDropdownOpened;
  }

  Widget _createHeader() {
    return Container(
      decoration: BoxDecoration(
          color: context.theme.backgroundColor,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 0.1,
                offset: const Offset(0, 0.1)),
          ],
          borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Spacer(),
          Text(
            widget.country,
            style:  TextStyle(color: context.theme.textColor, fontSize: 16),
          ),
          const Spacer(),
          Icon(Icons.arrow_drop_down,color: context.theme.textColor,),
        ],
      ),
    );
  }
}

class DropDown extends StatelessWidget {
  final double itemHeight;
  final String selectedItem;
  ValueSetter<String> callBack;
  List<String> dropCountryData = <String>[];

  DropDown(
      {Key? key,
      required this.itemHeight,
      required this.selectedItem,
      required this.callBack,
      required this.dropCountryData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 5,
        ),
        Material(
          color: Colors.transparent,
          child: Container(
            height: dropCountryData.length * itemHeight + 5,
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: context.theme.backgroundColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 0.1,
                    offset: const Offset(0, 0.1)),
              ],
            ),
            // child: Column(
            //   children: <Widget>[

            //     DropDownItem(
            //         text: dropCountryData[0],
            //         isSelected: selectedItem == dropCountryData[0],
            //         callBack: callBack,
            //         isFirstItem: true),
            //     DropDownItem(
            //       text: dropCountryData[1],
            //       isSelected: selectedItem == dropCountryData[1],
            //       callBack: callBack,
            //     ),
            //   ],
            // ),
            child: ListView.builder(
                    itemCount: dropCountryData.length,
                    itemBuilder: (context, index) {
                      return DropDownItem(
                          text: dropCountryData[index],
                          isSelected: selectedItem == dropCountryData[index],
                          callBack: callBack,
                          isFirstItem: true);
                    }),
          ),
        ),
      ],
    );
  }
}

class DropDownItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isFirstItem;
  final bool isLastItem;
  ValueSetter<String> callBack;

  DropDownItem(
      {required this.text,
      this.isSelected = false,
      this.isFirstItem = false,
      this.isLastItem = false,
      required this.callBack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //return value
        callBack(text);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          gradient: isSelected
              ? context.theme.gradient
              : LinearGradient(colors: context.theme.themeMode==ThemeMode.light ? [Colors.white, Colors.white] : [AppColors.tundora,AppColors.tundora]),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
                color: isSelected ? Colors.white : context.theme.textColor,
                fontSize: 16),
          ),
        ),
      ),
    );
  }
}
