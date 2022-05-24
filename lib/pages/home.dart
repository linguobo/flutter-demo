import 'package:flutter/material.dart';
import 'package:flutter_demo/server/request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_demo/utils/toast.dart';

class HomePage extends StatefulWidget {
  final title;
  const HomePage({
    Key? key,
    this.title,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textcontroller  = TextEditingController();
  Map formData = {
    'area':'852',
    'phoneNumber':'',
  };

  List areaOptions = [
    { 'value': '852', 'text': '+852'}
  ];

  List<String> _matchList = []; // 匹配列表
  List<String> _phoneHisttory = []; // 缓存列表

  @override
  void initState() {
    getAreaOptions();
    _readHistory();
    super.initState();
  }

  // 读取缓存
  void _readHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneHisttory = (prefs.getStringList('_phoneHisttory') ?? []);
    });
  }

  // 获取区号下拉项
  void getAreaOptions() async{
    var resData  = await HttpUtil().get('http://country.io/phone.json',data:{});
    Map bodyData = resData?? {};
    List options = areaOptions;
    var defaultVal = '';
    bodyData.forEach((key, value) {
      if(value=='852'){
        defaultVal='852'; // 设置默认值
      }else if(value.trim()!='') {
        options.add({ 'value': value, 'text': value.indexOf('+')>-1?value:'+$value'});
      }
    });
    if(defaultVal.isEmpty){
      defaultVal =  options[0]?.text;
    }
    setState(() {
      areaOptions = options;
      formData['area'] = defaultVal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.white,
              onPressed:(){
                Navigator.pop(context);
              }
          ),
          title: Text(widget.title),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top:50,left: 15,right:15),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 100.0,
                      width: 100.0,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/user.png"),
                          fit: BoxFit.contain,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Text('Please enter your phone number',
                        style: TextStyle(
                          fontSize: 20.0,
                        )
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF7B7E87),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width:150,
                              height: 40,
                              child: DropdownButton(
                                underline: Container(),
                                focusColor: Colors.pink,
                                items: areaOptions.map((item) => DropdownMenuItem(child: Text(item['text'],style: TextStyle(color: item['value']==formData['area']?Colors.blue:const Color(0xFF000000)),), value: item['value'])).toList(),
                                onChanged: (index) {
                                  setState(() {
                                    formData['area'] = index;
                                  });
                                },
                                // alignment: Alignment.centerRight,
                                value: formData['area'] ?? areaOptions[0]!.text,
                              ),
                            ),
                            Flexible(child:
                            Column(
                              children: [
                                TextFormField(
                                  controller: _textcontroller,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "手机号码",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                    hintMaxLines: 1,
                                    border: InputBorder.none,
                                  ),
                                  validator: (value) {
                                    RegExp reg =  RegExp(r'^\d{11}$');
                                    if (!reg.hasMatch(value!)) {
                                      return '请输入11位手机号码';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    if(value.trim()!=''){
                                      List<String>  matchList = [];
                                      for (var item in _phoneHisttory) {
                                        String matchVal = item.split(' ')[1];
                                        if(matchVal.contains(value.toString())){
                                          matchList.add(matchVal);
                                        }
                                      }
                                      setState(() {
                                        _matchList = matchList;
                                      });
                                    }
                                    if(_formKey.currentState!.validate()){
                                      setState(() {
                                        formData['phoneNumber'] = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            )
                            ),
                          ]),
                    ),
                    if(_matchList.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 250,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEEEE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                        margin: const EdgeInsets.only(top: 1),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: _matchList.map((item)=>InkWell(
                              onTap:(){
                                _textcontroller.text = item;
                                setState(() {
                                  _matchList = [];
                                  formData['phoneNumber'] = item;
                                  _formKey.currentState!.validate();
                                });
                              },
                              child: Text(item, style: const TextStyle(
                                height: 2,
                              )),
                            )).toList(),
                          ),
                        ),
                      ),
                    ),
                    Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(top: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: OutlinedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.blue),
                            ),
                            onPressed: () async {
                              if(_formKey.currentState!.validate()) {
                                final prefs = await SharedPreferences
                                    .getInstance();
                                var histtory = (prefs.getStringList(
                                    '_phoneHisttory') ?? []);
                                histtory.insertAll(0,["${formData['area']} ${formData['phoneNumber']}"]);
                                setState(() {
                                  _phoneHisttory = histtory;
                                  prefs.setStringList('_phoneHisttory', histtory);
                                  formData['phoneNumber'] = '';
                                  _textcontroller.clear();
                                });
                                AlertUtil.toast('存储成功');
                              }
                            },
                            child: const Text("Comfirm",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xFFFFFFFF),
                                )),
                          ),
                        )),
                    const SizedBox(height: 50,),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('缓存列表:',
                            style: TextStyle(
                              fontSize: 20,
                            ),),
                          InkWell(
                            onTap:()async{
                              final prefs = await SharedPreferences.getInstance();
                              prefs.remove('_phoneHisttory');
                              setState(() {
                                _phoneHisttory = [];
                              });
                            },
                            child: const Text("点击清除缓存",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xFF2A78FA),
                                )),
                          ),
                        ]
                    ),
                    if(_phoneHisttory.isNotEmpty)
                    Container(
                      width: double.infinity,
                      decoration:  BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: const Color(0xFFEEEEEE),
                      ),
                      padding: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom:10,),
                      child: Column(
                        children: _phoneHisttory.map((item)=>Text(item,
                          style: const TextStyle(
                              fontSize: 16,
                              height: 2
                          ),
                        )).toList(),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        )
    );
  }
}
