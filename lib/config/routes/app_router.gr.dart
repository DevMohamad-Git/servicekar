// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [CreateCustomerPage]
class CreateCustomerRoute extends PageRouteInfo<void> {
  const CreateCustomerRoute({List<PageRouteInfo>? children})
    : super(CreateCustomerRoute.name, initialChildren: children);

  static const String name = 'CreateCustomerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreateCustomerPage();
    },
  );
}

/// generated route for
/// [CustomerDetailsPage]
class CustomerDetailsRoute extends PageRouteInfo<CustomerDetailsRouteArgs> {
  CustomerDetailsRoute({
    Key? key,
    required String customerId,
    List<PageRouteInfo>? children,
  }) : super(
         CustomerDetailsRoute.name,
         args: CustomerDetailsRouteArgs(key: key, customerId: customerId),
         initialChildren: children,
       );

  static const String name = 'CustomerDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CustomerDetailsRouteArgs>();
      return CustomerDetailsPage(key: args.key, customerId: args.customerId);
    },
  );
}

class CustomerDetailsRouteArgs {
  const CustomerDetailsRouteArgs({this.key, required this.customerId});

  final Key? key;

  final String customerId;

  @override
  String toString() {
    return 'CustomerDetailsRouteArgs{key: $key, customerId: $customerId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomerDetailsRouteArgs) return false;
    return key == other.key && customerId == other.customerId;
  }

  @override
  int get hashCode => key.hashCode ^ customerId.hashCode;
}

/// generated route for
/// [CustomerListPage]
class CustomerListRoute extends PageRouteInfo<void> {
  const CustomerListRoute({List<PageRouteInfo>? children})
    : super(CustomerListRoute.name, initialChildren: children);

  static const String name = 'CustomerListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CustomerListPage();
    },
  );
}

/// generated route for
/// [EditCustomerPage]
class EditCustomerRoute extends PageRouteInfo<EditCustomerRouteArgs> {
  EditCustomerRoute({
    Key? key,
    required String customerId,
    List<PageRouteInfo>? children,
  }) : super(
         EditCustomerRoute.name,
         args: EditCustomerRouteArgs(key: key, customerId: customerId),
         initialChildren: children,
       );

  static const String name = 'EditCustomerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditCustomerRouteArgs>();
      return EditCustomerPage(key: args.key, customerId: args.customerId);
    },
  );
}

class EditCustomerRouteArgs {
  const EditCustomerRouteArgs({this.key, required this.customerId});

  final Key? key;

  final String customerId;

  @override
  String toString() {
    return 'EditCustomerRouteArgs{key: $key, customerId: $customerId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditCustomerRouteArgs) return false;
    return key == other.key && customerId == other.customerId;
  }

  @override
  int get hashCode => key.hashCode ^ customerId.hashCode;
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}
