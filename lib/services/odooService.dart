import 'package:lotorb/utils/api.const.dart';
import 'package:odoo_api/odoo_api.dart';
import 'package:odoo_api/odoo_user_response.dart';
import 'package:odoo_api/odoo_api_connector.dart';

var myclient = OdooClient(ApiConst.baseUrl);
var myDB = ApiConst.ODOO_DATABASE;

// authenticate**
odooAuthenticate(String username,String password)async{

  AuthenticateCallback myDtat = await myclient.authenticate(username, password, myDB);

  return myDtat;

}

// Search Read**

odooSearchRead(String model, List domain, List<String> fields) async {
  var myData = await myclient.searchRead(model, domain, fields);

  return myData;
}

// Read**

odooRead(String model,List<int> ids,List<String> fields) async {
  var myData = await myclient.read(model, ids, fields);

  return myData;
}

// Create**

Future<OdooResponse> odooCreate(String model, Map values) async {
  var myData = await myclient.create(model, values);
  return myData;
}

// Write**

odooWrite(String model, List<int> ids, Map values) async {
  var myData = await myclient.write(model,ids,values);
  return myData.getResult();
}

// Unlink**

odooUnlink(String model, List<int> ids) async {
  var myData = await myclient.unlink(model, ids);

  return myData.getResult();
}