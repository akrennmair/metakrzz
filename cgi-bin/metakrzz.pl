#!/usr/bin/perl

use strict;
use warnings;
use lib 'lib';
use MeToo;
use LWP::UserAgent;
use URI::Escape;
use JSON;

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
		<label id="recvmsg" style="display: none">
			<strong>Receiving results...</strong>
			<img src="/files/img/indicator.gif">
		</label>
		</form>
	</div>
</div>
<div class="row">
	<div id="errmsgbox" class="alert alert-error span4" style="display: none"></div>
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

sub shorten_krzz {
	my ($ua, $url) = @_;
	my $resp = $ua->get('http://krzz.de/_api/save?url=' . uri_escape($url));
	if ($resp->is_success) {
		my $content = $resp->decoded_content;
		chomp($content);
		if ($content =~ /^http:\/\/krzz\.de\//) {
			return { "url" => $content };
		}
		return { "error" => $content };
	}
	return { "error" => $resp->status_line };
}

sub shorten_tinyurl {
	my ($ua, $url) = @_;
	my $resp = $ua->get('http://tinyurl.com/api-create.php?url=' . uri_escape($url));
	if ($resp->is_success) {
		my $content = $resp->decoded_content;
		chomp($content);
		return { "url" => $content };
	}
	return { "error" => $resp->status_line };
}

sub shorten_googl {
	my ($ua, $url) = @_;
	my $json = JSON->new;
	my $resp = $ua->post('https://www.googleapis.com/urlshortener/v1/url', Content_Type => "application/json", Content => $json->encode({ longUrl => $url }));
	if ($resp->is_success) {
		my $result = $json->decode($resp->decoded_content);
		my $short_url = $result->{id};
		if ($short_url) {
			return { "url" => $short_url };
		}
		return { "error" => $result->{error}{message} };
	}
	return { "error" => $resp->status_line };
}

my %shortener = (
	'krzz' => \&shorten_krzz,
	'googl' => \&shorten_googl,
	'tinyurl' => \&shorten_tinyurl,
);

get '/' => sub {
	return $html;
};

get '/shorten/(.*)' => sub {
	my $id = shift;
	my $url = params->{url};
	content_type("application/json");
	my $shorten_func = $shortener{$id};
	if ($shorten_func) {
		my $ua = LWP::UserAgent->new;
		$ua->agent('meta.krzz.de Meta URL Shortener');
		$ua->timeout(10);
		my $result = &$shorten_func($ua, $url);
		my $json = JSON->new;
		return $json->encode($result);
	}
	return "{ \"error\": \"unsupported shortener\" }";
};

