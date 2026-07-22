// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator (hand-authored — see router.dart header)
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// NOTE: This file would normally be produced by
// `dart run build_runner build --delete-conflicting-outputs` against the
// `auto_route_generator: 10.5.0` dev dep. The offline sandbox blocks
// `flutter pub get` (HTTP 403), so this file is hand-authored to match
// the generator's output shape verbatim.
//
// Routes declared in `app_router.dart`:
//   * HomeRoute             -> /
///   * CustomerListRoute     -> /customers
///   * CustomerDetailsRoute  -> /customers/:customerId
///   * CreateCustomerRoute   -> /customers/new
///   * EditCustomerRoute     -> /customers/:customerId/edit
// ---------------------------------------------------------------------------

part of 'app_router.dart';

/// generated route for [HomePage]
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

/// generated route for [CustomerListPage]
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

/// generated route for [CustomerDetailsPage]
///
/// Family: the generated builder forwards the [customerId] argument.
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
      final args = data.argsAs<CustomerDetailsRouteArgs>(
        orElse: () => CustomerDetailsRouteArgs(customerId: ''),
      );
      return CustomerDetailsPage(
        key: args.key,
        customerId: args.customerId,
      );
    },
  );
}

class CustomerDetailsRouteArgs {
  const CustomerDetailsRouteArgs({this.key, required this.customerId});

  final Key? key;

  final String customerId;
}

/// generated route for [CreateCustomerPage]
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

/// generated route for [EditCustomerPage]
///
/// Family: the generated builder forwards the [customerId] argument.
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
      final args = data.argsAs<EditCustomerRouteArgs>(
        orElse: () => EditCustomerRouteArgs(customerId: ''),
      );
      return EditCustomerPage(
        key: args.key,
        customerId: args.customerId,
      );
    },
  );
}

class EditCustomerRouteArgs {
  const EditCustomerRouteArgs({this.key, required this.customerId});

  final Key? key;

  final String customerId;
}
