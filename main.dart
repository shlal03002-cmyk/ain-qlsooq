import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const AinAlsooqApp());

class Product {
  final int id;
  final String name, brand, category, barcode, description;
  final double rating;
  final List<Variant> variants;
  final List<Offer> offers;
  Product({
    required this.id, required this.name, required this.brand,
    required this.category, required this.barcode, required this.description,
    required this.rating, required this.variants, required this.offers,
  });
  factory Product.fromJson(Map<String,dynamic> j) => Product(
    id:j['id'], name:j['name'], brand:j['brand'], category:j['category'],
    barcode:j['barcode'], description:j['description'],
    rating:(j['rating'] as num).toDouble(),
    variants:(j['variants'] as List).map((x)=>Variant.fromJson(x)).toList(),
    offers:(j['offers'] as List).map((x)=>Offer.fromJson(x)).toList(),
  );
}
class Variant {
  final String id,label,barcode;
  Variant({required this.id,required this.label,required this.barcode});
  factory Variant.fromJson(Map<String,dynamic> j)=>Variant(id:j['id'],label:j['label'],barcode:j['barcode']);
}
class Offer {
  final String store,currency,updated;
  final double price;
  Offer({required this.store,required this.price,required this.currency,required this.updated});
  factory Offer.fromJson(Map<String,dynamic> j)=>Offer(store:j['store'],price:(j['price'] as num).toDouble(),currency:j['currency'],updated:j['updated']);
}

class AinAlsooqApp extends StatefulWidget {
  const AinAlsooqApp({super.key});
  @override State<AinAlsooqApp> createState()=>_AinState();
}
class _AinState extends State<AinAlsooqApp> {
  List<Product> all=[];
  bool loading=true;
  @override void initState(){super.initState(); load();}
  Future<void> load() async {
    final raw=await rootBundle.loadString('assets/products.json');
    final list=(jsonDecode(raw) as List).cast<Map<String,dynamic>>();
    setState(()=>all=list.map(Product.fromJson).toList()..sort((a,b)=>a.name.compareTo(b.name)));
  }
  @override Widget build(BuildContext context){
    return MaterialApp(debugShowCheckedModeBanner:false, theme:ThemeData(
      brightness:Brightness.dark, scaffoldBackgroundColor:const Color(0xFF06121F),
      fontFamily:'sans', colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xFFFFC533),brightness:Brightness.dark)
    ), home: loading ? const Splash() : Home(products:all));
  }
}

class Splash extends StatelessWidget {
  const Splash({super.key});
  @override Widget build(BuildContext c)=>const Scaffold(body:Center(child:CircularProgressIndicator()));
}

class Home extends StatefulWidget {
  final List<Product> products;
  const Home({super.key,required this.products});
  @override State<Home> createState()=>_HomeState();
}
class _HomeState extends State<Home>{
  final controller=TextEditingController();
  List<Product> results=[];
  bool searching=false;
  void search(String q){
    final x=q.trim().toLowerCase();
    setState((){
      searching=x.isNotEmpty;
      results=x.isEmpty ? [] : widget.products.where((p)=>
        p.name.toLowerCase().contains(x) || p.brand.toLowerCase().contains(x) ||
        p.barcode.contains(x) || p.variants.any((v)=>v.barcode.contains(x))
      ).take(50).toList();
    });
  }
  @override Widget build(BuildContext c)=>Scaffold(
    appBar:AppBar(title:const Text('عين السوق',style:TextStyle(fontWeight:FontWeight.bold)),actions:[
      IconButton(onPressed:(){},icon:const Icon(Icons.notifications_none)),
      const Padding(padding:EdgeInsets.only(right:12),child:CircleAvatar(child:Icon(Icons.person_outline)))
    ]),
    body:ListView(padding:const EdgeInsets.fromLTRB(16,8,16,30),children:[
      Text('أفضل الأسعار.. بكل ثقة',style:TextStyle(color:Colors.white70)),
      const SizedBox(height:14),
      TextField(controller:controller,onChanged:search,textDirection:TextDirection.rtl,
        decoration:InputDecoration(hintText:'ابحث عن منتج، علامة تجارية، أو باركود...',prefixIcon:const Icon(Icons.search),
        filled:true,fillColor:Colors.white, hintStyle:const TextStyle(color:Colors.black45),
        prefixIconColor:Colors.black87, border:OutlineInputBorder(borderRadius:BorderRadius.circular(30),borderSide:BorderSide.none))),
      const SizedBox(height:14),
      if(searching) ...[
        Text('نتائج البحث (${results.length})',textDirection:TextDirection.rtl,style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
        const SizedBox(height:8),
        ...results.map((p)=>ProductTile(p:p)),
      ] else ...[
        Row(children:[
          Expanded(child:ActionCard(icon:Icons.qr_code_scanner,title:'مسح الباركود',subtitle:'اكتشف السعر الآن')),
          const SizedBox(width:10),
          Expanded(child:ActionCard(icon:Icons.camera_alt_outlined,title:'ابحث بالصورة',subtitle:'التقط صورة المنتج')),
        ]),
        const SizedBox(height:24),
        const SectionTitle('الفئات'),
        SizedBox(height:95,child:ListView(scrollDirection:Axis.horizontal,children:[
          Cat('العطور',Icons.spa),Cat('الإلكترونيات',Icons.headphones),Cat('العناية',Icons.face),
          Cat('المواد الغذائية',Icons.shopping_basket),Cat('المنزل',Icons.home),
        ])),
        const SizedBox(height:18),
        const SectionTitle('منتجات شائعة'),
        ...widget.products.take(6).map((p)=>ProductTile(p:p)),
        const SizedBox(height:10),
        Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(
          borderRadius:BorderRadius.circular(20),gradient:const LinearGradient(colors:[Color(0xFF182A42),Color(0xFF0D1828)])),
          child:const Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
            Text('أفضل الأسعار',textDirection:TextDirection.rtl,style:TextStyle(color:Color(0xFFFFC533),fontSize:23,fontWeight:FontWeight.bold)),
            SizedBox(height:5),Text('قارن بين المتاجر واعثر على السعر الأنسب.',textDirection:TextDirection.rtl),
          ])),
      ]
    ])
  );
}

class ProductTile extends StatelessWidget {
  final Product p; const ProductTile({super.key,required this.p});
  @override Widget build(BuildContext c)=>Card(
    margin:const EdgeInsets.only(bottom:10),color:const Color(0xFF102237),
    child:ListTile(onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>ProductPage(p:p))),
      leading:Container(width:54,height:54,decoration:BoxDecoration(color:const Color(0xFF1B3550),borderRadius:BorderRadius.circular(12)),child:const Icon(Icons.inventory_2_outlined)),
      title:Text(p.name,textDirection:TextDirection.rtl,style:const TextStyle(fontWeight:FontWeight.bold)),
      subtitle:Text('${p.brand} • ${p.category}\n★ ${p.rating}',textDirection:TextDirection.rtl),
      trailing:const Icon(Icons.chevron_left)));
}
class ActionCard extends StatelessWidget {
  final IconData icon; final String title,subtitle;
  const ActionCard({super.key,required this.icon,required this.title,required this.subtitle});
  @override Widget build(BuildContext c)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(
    color:const Color(0xFF123153),borderRadius:BorderRadius.circular(18)),
    child:Column(children:[Icon(icon,size:34,color:const Color(0xFFFFC533)),const SizedBox(height:6),
      Text(title,textDirection:TextDirection.rtl,style:const TextStyle(fontWeight:FontWeight.bold)),
      Text(subtitle,textDirection:TextDirection.rtl,style:const TextStyle(fontSize:11,color:Colors.white60))]));
}
class Cat extends StatelessWidget {
  final String t; final IconData i; const Cat(this.t,this.i,{super.key});
  @override Widget build(BuildContext c)=>Padding(padding:const EdgeInsets.only(right:10),child:Container(width:92,
    padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:const Color(0xFF102237),borderRadius:BorderRadius.circular(16)),
    child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(i,color:const Color(0xFFFFC533)),const SizedBox(height:7),Text(t,textDirection:TextDirection.rtl,textAlign:TextAlign.center,style:const TextStyle(fontSize:12))])));
}
class SectionTitle extends StatelessWidget { final String t; const SectionTitle(this.t,{super.key});
  @override Widget build(BuildContext c)=>Align(alignment:Alignment.centerRight,child:Text(t,textDirection:TextDirection.rtl,style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)));
}

class ProductPage extends StatelessWidget {
  final Product p; const ProductPage({super.key,required this.p});
  @override Widget build(BuildContext c){
    final sorted=[...p.offers]..sort((a,b)=>a.price.compareTo(b.price));
    return Scaffold(appBar:AppBar(title:const Text('تفاصيل المنتج'),centerTitle:true),
      body:ListView(padding:const EdgeInsets.all(18),children:[
        Container(height:210,decoration:BoxDecoration(color:const Color(0xFF102237),borderRadius:BorderRadius.circular(24)),
          child:const Icon(Icons.inventory_2_outlined,size:90,color:Color(0xFFFFC533))),
        const SizedBox(height:18),
        Text(p.name,textDirection:TextDirection.rtl,style:const TextStyle(fontSize:25,fontWeight:FontWeight.bold)),
        Text('${p.brand} • ${p.category}',textDirection:TextDirection.rtl,style:const TextStyle(color:Colors.white70)),
        const SizedBox(height:8),Text('★ ${p.rating}   |   الباركود: ${p.barcode}',textDirection:TextDirection.rtl),
        const SizedBox(height:18),const Text('المتغيرات',textDirection:TextDirection.rtl,style:TextStyle(fontSize:19,fontWeight:FontWeight.bold)),
        Wrap(spacing:8,children:p.variants.map((v)=>Chip(label:Text('${v.label}  •  ${v.barcode}'))).toList()),
        const SizedBox(height:18),const Text('المتاجر والأسعار',textDirection:TextDirection.rtl,style:TextStyle(fontSize:19,fontWeight:FontWeight.bold)),
        ...sorted.map((o)=>Card(color:const Color(0xFF102237),child:ListTile(
          title:Text(o.store,textDirection:TextDirection.rtl),subtitle:Text('آخر تحديث: ${o.updated}',textDirection:TextDirection.rtl),
          trailing:Text('${o.price.toStringAsFixed(2)} ${o.currency}',style:const TextStyle(color:Color(0xFFFFC533),fontWeight:FontWeight.bold))))),
        const SizedBox(height:12),
        Text(p.description,textDirection:TextDirection.rtl,style:const TextStyle(color:Colors.white70)),
      ]));
  }
}
