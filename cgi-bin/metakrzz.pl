#!/usr/bin/perl

use strict;
use warnings;
use lib 'lib';
use MeToo;

my $html = <<END;
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="/files/css/bootstrap.min.css">
<title>meta.krzz.de</title>
<script src="/files/js/app.dart.js"></script>
<!--[if lt IE 9]>
<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
<![endif]-->
</head>
<body>
<div class="container">
<h2>meta.krzz.de Meta URL Shortener</h2>
<form action="" method="post" class="well">
<input id=url name=url type=url placeholder="URL, e.g. http://example.com/" required autofocus class="input-medium" style="width: 100%">
<button id=btn class="btn btn-primary" type=submit>Shorten</button>
</form>
</body>
</html>
END

get '/' => sub {
	return $html;
};
