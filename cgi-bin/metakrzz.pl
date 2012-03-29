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
<div class="row">
	<div class="span12">
		<form action="" method="post" class="well">
		<input id=url name=url type=url placeholder="URL, e.g. http://example.com/" required autofocus class="input-medium" style="width: 100%">
		<button id=btn class="btn btn-primary" type=submit>Shorten</button>
		</form>
	</div>
</div>
<div class="row">
	<div id="errmsgbox" class="alert alert-error span4" style="display: none"></div>
</div>
<div class="row" id="recvmsg" style="display: none">
	<div class="span12">
		Receiving results...
		<img src="/files/img/indicator.gif">
	</div>
</div>
<div class="row">
	<table class="table table-bordered table-striped table-condensed span12" id="urltbl" style="display: none">
		<tr><th>URL</th><th>Length</th></tr>
	</table>
</div>
</div>
</body>
</html>
END

get '/' => sub {
	return $html;
};

get '/shorten/(.*)' => sub {
	my $id = shift;
	content_type("application/json");
	sleep(rand(10));
	return "{ \"url\": \"http://foobar.com/$id\" }";
};

