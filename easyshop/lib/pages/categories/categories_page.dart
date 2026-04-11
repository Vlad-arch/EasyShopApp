import 'package:easyshop/api/api_service.dart';
import 'package:easyshop/models/category_model.dart';
import 'package:easyshop/pages/categories/category_item_card_widget.dart';
import 'package:easyshop/utils/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<String> gridColors =[
    '#53B175',
    '#F8A44C',
    '#F7A593',
    '#D3B0E0',
    '#FDE598',
    '#B7DFF5',
    '#836AF6',
    '#D73B77'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            const Center(
              child: Text("All Categories",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _categoriesList(),
            ))
          ],
        ),
      ),
    );
  }

  Widget getStaggeredGrid(List<CategoryModel> data) {
    return StaggeredGrid.count(
      crossAxisCount: 4,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 1.0,
      children: data.asMap().entries.map<Widget>((e) {
        int index = e.key;
        CategoryModel categoryItem = e.value;
        return GestureDetector(
          onTap: () => {} ,
          child: Container(
            padding: EdgeInsets.all(10),
            child: CategoryItemCardWidget(
              item: categoryItem, 
              color: HexColor(
                gridColors[index % gridColors.length],
                ),
              ),
          ),
        );
      }).toList(),
    );
  }
  Widget _categoriesList() {
    return FutureBuilder(
      future: APIService.getCategories(),
       builder: (
        BuildContext context,
        AsyncSnapshot<List<CategoryModel>?> model,
      ) {
        if(model.hasData) {
          return getStaggeredGrid(model.data!);
        }

        return const Center(
          child: CircularProgressIndicator(),
          );
        },
      );
  }
}