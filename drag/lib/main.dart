import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DragAndDrop(),
    debugShowCheckedModeBanner: false,
  ));
}

List<Item> _items = [
  Item(
      name: "Pizza Vietnam",
      totalPriceCents: 10000,
      uid: '1',
      imageProvider: NetworkImage(
          'https://cdn.huongnghiepaau.com/wp-content/uploads/2019/04/banh-pizza-thom-ngon.jpg')),
  Item(
      name: "Bun bo hue",
      totalPriceCents: 39000,
      uid: '1',
      imageProvider: NetworkImage(
          'https://media.cooky.vn/images/blog-2016/bi-quyet-lam-noi-nuoc-leo-bun-bo-hue-dam-da-chuan-vi-hue-ma-cac-me-nen-luu-lai-4.jpg')),
  Item(
      name: "Banh mi",
      totalPriceCents: 15000,
      uid: '1',
      imageProvider: NetworkImage(
          'https://banhmipho.vn/wp-content/uploads/2021/03/ca-ngu.png')),
];

class DragAndDrop extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DragAndDropState();
}

class _DragAndDropState extends State<DragAndDrop>
    with TickerProviderStateMixin {
  List<Customer> _people = [
    Customer(
        name: "Vang Thao",
        imageProvider: NetworkImage(
            'https://www.xda-developers.com/files/2018/02/Flutter-Framework-Feature-Image-Background-Colour.png'),
        items: []),
    Customer(
        name: "Que Mim'gh",
        imageProvider: NetworkImage(
            'https://miro.medium.com/max/480/1*oNM0JVqivoi3lVPF6ygp9Q.png'),
        items: []),
    Customer(
        name: "Mobile",
        imageProvider: NetworkImage(
            'https://media.kasperskydaily.com/wp-content/uploads/sites/92/2019/12/09084248/android-device-identifiers-featured.jpg'),
        items: [])
  ];

  final GlobalKey _draggableKey = GlobalKey();

  void _itemDroppedOnCustomerCart(
      {required Item item, required Customer customer}) {
    setState(() {
      customer.items.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: _buildAppBar(),
        body: _buildContent());
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.green),
      title: Text(
        'Order app',
        style: Theme.of(context).textTheme.headline4?.copyWith(
            fontSize: 36, color: Colors.red, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.blue,
      elevation: 0,
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        SafeArea(
            child: Column(
          children: [Expanded(child: _buildMenuList()), _buildPeopleRow()],
        ))
      ],
    );
  }

  Widget _buildPeopleRow() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
        child: Row(
          children: _people.map(_buildPersonWithDropZone).toList(),
        ));
  }

  Widget _buildMenuList() {
    return ListView.separated(
        itemBuilder: (content, index) {
          final item = _items[index];
          return _buildItemMenu(item: item);
        },
        separatorBuilder: (content, index) {
          return const SizedBox(
            height: 12.0,
          );
        },
        itemCount: _items.length);
  }

  Widget _buildItemMenu({required Item item}) {
    return LongPressDraggable<Item>(
        child: MenuListItem(
            name: item.name,
            price: item.formattedTotalItemPrice,
            photoProvider: item.imageProvider),
        feedback: DraggingListItem(
            dragKey: _draggableKey, photoProvider: item.imageProvider));
  }

  Widget _buildPersonWithDropZone(Customer customer) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.0),
            child: DragTarget<Item>(
              builder: (context, candidateItems, rejectItems) {
                return CustomerCart(
                  hasItems: customer.items.isNotEmpty,
                  highlighted: candidateItems.isNotEmpty,
                  customer: customer,
                );
              },
            )));
  }
}

class CustomerCart extends StatelessWidget {
  final Customer customer;
  final bool highlighted;
  final bool hasItems;

  CustomerCart(
      {required this.customer,
      this.highlighted = false,
      this.hasItems = false});

  @override
  Widget build(BuildContext context) {
    final textColor = highlighted ? Colors.white : Colors.black;
    return Transform.scale(
        scale: highlighted ? 1.075 : 1.0,
        child: Material(
            elevation: highlighted ? 8.0 : 4.0,
            borderRadius: BorderRadius.circular(22.0),
            color: highlighted ? Color(0xFFF64209) : Colors.white,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipOval(
                        child: SizedBox(
                            width: 46,
                            height: 46,
                            child: Image(
                                image: customer.imageProvider,
                                fit: BoxFit.cover))),
                    SizedBox(height: 8.0),
                    Text(customer.name,
                        style: Theme.of(context).textTheme.subtitle1?.copyWith(
                            color: textColor,
                            fontWeight: hasItems
                                ? FontWeight.normal
                                : FontWeight.bold)),
                    Visibility(
                        visible: hasItems,
                        maintainState: true,
                        maintainAnimation: true,
                        maintainSize: true,
                        child: Column(
                          children: [
                            SizedBox(height: 4.0),
                            Text(customer.formattedTotalItemPrice,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                        color: textColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold)),
                            SizedBox(height: 4.0),
                            Text(
                                '${customer.items.length} item${customer.items.length != 1 ? 's' : ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                        color: textColor, fontSize: 12.0)),
                          ],
                        ))
                  ],
                ))));
  }
}

class MenuListItem extends StatelessWidget {
  final String name;
  final String price;
  final ImageProvider photoProvider;
  final bool isDepressed;

  MenuListItem(
      {this.name = '',
      this.price = '',
      required this.photoProvider,
      this.isDepressed = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: SizedBox(
                width: 120,
                height: 120,
                child: Center(
                  child: AnimatedContainer(
                    duration: Duration(microseconds: 100),
                    curve: Curves.easeInOut,
                    height: isDepressed ? 115 : 120,
                    width: isDepressed ? 115 : 120,
                    child: Image(image: photoProvider, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 30.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18.0),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DraggingListItem extends StatelessWidget {
  final GlobalKey dragKey;
  final ImageProvider photoProvider;

  DraggingListItem({required this.dragKey, required this.photoProvider});

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: ClipRRect(
          key: dragKey,
          borderRadius: BorderRadius.circular(12.0),
          child: SizedBox(
              height: 150,
              width: 150,
              child: Opacity(
                  opacity: 0.85,
                  child: Image(image: photoProvider, fit: BoxFit.cover)))),
    );
  }
}

@immutable
class Item {
  final int totalPriceCents;
  final String name;
  final String uid;
  final ImageProvider imageProvider;

  Item(
      {required this.totalPriceCents,
      required this.name,
      required this.uid,
      required this.imageProvider});

  String get formattedTotalItemPrice =>
      '\$${(totalPriceCents / 100.0).toStringAsFixed(2)}';
}

class Customer {
  final String name;
  final ImageProvider imageProvider;
  final List<Item> items;

  Customer(
      {required this.name, required this.imageProvider, required this.items});

  String get formattedTotalItemPrice {
    final totalPriceCents = items.fold<int>(
        0, (previousValue, element) => previousValue + element.totalPriceCents);
    return '\$${(totalPriceCents / 100.0).toStringAsFixed(2)}';
  }
}
