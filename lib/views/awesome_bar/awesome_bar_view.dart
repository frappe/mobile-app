import 'package:flutter/material.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/form/controls/autocomplete.dart';
import 'package:frappe_app/model/doctype_response.dart';
import 'package:frappe_app/views/awesome_bar/awesome_bar_viewmodel.dart';
import 'package:frappe_app/views/new_doc/new_doc_view.dart';

import '../../model/offline_storage.dart';
import '../../utils/frappe_icon.dart';

import '../../config/frappe_icons.dart';

import '../../app/locator.dart';
import '../base_view.dart';
import '../list_view/list_view.dart';

class Awesombar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textEditingController = TextEditingController();
    var awesomeBarItems = [];
    var awesomeItems = OfflineStorage.getItem('awesomeItems');
    awesomeItems = awesomeItems["data"];

    // activeModules.keys.forEach((module) {
    //   awesomeBarItems.add(
    //     {
    //       "type": "Module",
    //       "value": module,
    //       "label": "Open $module",
    //     },
    //   );
    // });

    if (awesomeItems != null) {
      awesomeItems.values.forEach(
        (value) {
          (value as List).forEach(
            (v) {
              awesomeBarItems.add(
                {
                  "type": "Doctype",
                  "value": v,
                  "label": "$v List",
                },
              );
              awesomeBarItems.add(
                {
                  "type": "New Doc",
                  "value": v,
                  "label": "New $v",
                },
              );
            },
          );
        },
      );
    }

    return BaseView<AwesomBarViewModel>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          elevation: 0.8,
          toolbarHeight: 90,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 16,
              ),
              Text('Search'),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  Flexible(
                    flex: 5,
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        model.toggleFocus(hasFocus);
                      },
                      child: AutoComplete(
                        controller: textEditingController,
                        inputDecoration: InputDecoration(
                          filled: true,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(
                              6,
                            ),
                          ),
                          fillColor: FrappePalette.grey[100],
                          hintStyle: TextStyle(
                            fontSize: 18,
                            color: FrappePalette.grey[600],
                            fontWeight: FontWeight.normal,
                          ),
                          hintText: "Search",
                          suffixIcon: model.hasFocus
                              ? InkWell(
                                  onTap: () {
                                    textEditingController.clear();
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: FrappePalette.grey,
                                    child: FrappeIcon(
                                      FrappeIcons.close_alt,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : null,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FrappeIcon(
                              FrappeIcons.search,
                              color: FrappePalette.grey[700],
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minHeight: 42,
                            maxHeight: 42,
                          ),
                          suffixIconConstraints: BoxConstraints(
                            minHeight: 22,
                            maxHeight: 22,
                          ),
                        ),
                        itemBuilder: (context, item) {
                          return ListTile(
                            title: Text(
                              item["label"],
                            ),
                            onTap: () async {
                              var meta =
                                  await OfflineStorage.getMeta(item["value"]);
                              if (item["type"] == "Doctype") {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return CustomListView(
                                        meta: meta,
                                        module: meta.docs[0].module,
                                      );
                                    },
                                  ),
                                );
                              } else if (item["type"] == "New Doc") {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return NewDoc(meta: meta);
                                    },
                                  ),
                                );
                              } else if (item["type"] == "Module") {
                                // locator<NavigationService>().navigateTo(
                                //   Routes.home,
                                //   arguments: DoctypeViewArguments(
                                //     module: item["value"],
                                //   ),
                                // );
                                // TODO
                              }
                            },
                          );
                        },
                        suggestionsCallback: (query) {
                          var lowercaseQuery = query.toLowerCase();

                          return awesomeBarItems.where((option) {
                            return option["label"].toLowerCase().contains(
                                  lowercaseQuery,
                                );
                          }).toList();
                        },
                        doctypeField: DoctypeField(
                          label: "Search",
                          fieldname: "search",
                          options: awesomeBarItems,
                        ),
                      ),
                    ),
                  ),
                  if (model.hasFocus)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                        child: FlatButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: FrappePalette.blue[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          minWidth: 70,
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                        ),
                      ),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AwesomeSearch extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var awesomeBarItems = [];
    var awesomeItems = OfflineStorage.getItem('awesomeItems');
    awesomeItems = awesomeItems["data"];

    // activeModules.keys.forEach((module) {
    //   awesomeBarItems.add(
    //     {
    //       "type": "Module",
    //       "value": module,
    //       "label": "Open $module",
    //     },
    //   );
    // });

    if (awesomeItems != null) {
      awesomeItems.values.forEach(
        (value) {
          (value as List).forEach(
            (v) {
              awesomeBarItems.add(
                {
                  "type": "Doctype",
                  "value": v,
                  "label": "$v List",
                },
              );
              awesomeBarItems.add(
                {
                  "type": "New Doc",
                  "value": v,
                  "label": "New $v",
                },
              );
            },
          );
        },
      );
    }

    awesomeBarItems = awesomeBarItems.where((element) {
      var lowercaseQuery = query.toLowerCase();
      return (element["value"] as String)
          .toLowerCase()
          .contains(lowercaseQuery);
    }).toList();

    return ListView.builder(
      itemCount: awesomeBarItems.length,
      itemBuilder: (_, index) {
        var item = awesomeBarItems[index];
        return ListTile(
          title: Text(item["label"]),
        );
      },
    );
  }
}