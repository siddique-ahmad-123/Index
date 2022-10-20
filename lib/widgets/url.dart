import 'package:flutter/material.dart';

/// Returns a friendly readable URL, containing just
/// the hostname for a clean result.
Widget getReadableUrlWidget(BuildContext context, final String url) {
  // Build the readable URL, remove www.
  // subdomain and remove trailing slash
  final Uri temp = Uri.parse(url);
  final String parsedUrl = temp.host.replaceAll('www.', '');

  // Construct widget and set overflow behavior
  return Text(
    parsedUrl,
    style: Theme.of(context).textTheme.subtitle2,
    overflow: TextOverflow.ellipsis,
  );
}
