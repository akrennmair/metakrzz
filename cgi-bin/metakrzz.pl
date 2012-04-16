#!/usr/bin/perl

use strict;
use warnings;
use lib 'lib';
use MeToo;
use LWP::UserAgent;
use URI::Escape;
use JSON;
use Cwd;
use Template;

sub read_config() {
	my %config;
	my $fh;
	if (open($fh, '<', 'config.txt')) {
		while (my $line = <$fh>) {
			chomp($line);
			my ($key, $value) = split(/ /, $line, 2);
			$config{$key} = $value;
		}
		close($fh);
	}
	return \%config;
}

my $t = Template->new({
		TAG_STYLE => 'asp',
		INCLUDE_PATH => getcwd . "/tmpl/",
		RELATIVE => 1,
});

sub _shorten_text {
	my ($ua, $urltmpl, $vars) = @_;
	my $shorten_url = $urltmpl;
	foreach my $k (keys %$vars) {
		my $v = $vars->{$k};
		$shorten_url =~ s/<$k>/$v/g;
	}
	#print STDERR "_shorten_text: requesting $shorten_url\n";
	my $resp = $ua->get($shorten_url);
	if ($resp->is_success) {
		my $content = $resp->decoded_content;
		chomp($content);
		$content =~ s/^\s*(.*)\s*$/\1/g;
		if ($content =~ /^http:\/\//) {
			return { "url" => $content };
		}
		return { "error" => $content };
	}
	return { "error" => $resp->status_line, "long_error" => $resp->decoded_content };
}

sub shorten_krzz {
	my ($ua, $url) = @_;
	return _shorten_text($ua, 'http://krzz.de/_api/save?url=<url>', { url => uri_escape($url) });
}

sub shorten_tinyurl {
	my ($ua, $url) = @_;
	return _shorten_text($ua, 'http://tinyurl.com/api-create.php?url=<url>', { url => uri_escape($url) });
}

sub shorten_isgd {
	my ($ua, $url) = @_;
	return _shorten_text($ua, 'http://is.gd/create.php?format=simple&url=<url>', { url => uri_escape($url) });
}

sub _shorten_bitly {
	my ($ua, $url, $domain) = @_;
	my $config = read_config();
	return _shorten_text($ua, 'http://api.bitly.com/v3/shorten?format=txt&longUrl=<url>&domain=<domain>&login=<login>&apiKey=<apikey>', 
		{ url => uri_escape($url), login => $config->{bitly_login}, apikey => $config->{bitly_apikey}, domain => $domain });
}

sub shorten_bitly {
	return _shorten_bitly(@_, 'bit.ly');
}

sub shorten_jmp {
	return _shorten_bitly(@_, 'j.mp');
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

sub shorten_cortas {
	my ($ua, $url) = @_;
	my $json = JSON->new;
	my $resp = $ua->get('http://cortas.elpais.com/encode.pl?u=' . uri_escape($url) . "&r=json");
	if ($resp->is_success) {
		my $result = $json->allow_singlequote->decode($resp->decoded_content);
		if ($result->{status} eq "ok") {
			return { "url" => $result->{urlCortas} };
		}
		return { "error" => $result->{errorLong} };
	}
	return { "error" => $resp->status_line };
}

sub shorten_b23ru {
	my ($ua, $url) = @_;
	my $config = read_config();

	$url =~ s/%/%25/g;
	$url =~ s/\?/%3F/g;
	$url =~ s/#/%23/g;
	$url =~ s/&/%26/g;

	my $complete_url = "http://$config->{b23ru_login}:$config->{b23ru_apikey}\@b23.ru/api/shorten/$url";

	my $resp = $ua->get($complete_url);

	if ($resp->is_success) {
		my $short_url = $resp->decoded_content;
		return { "url" => $short_url };
	}
	return { "error" => $resp->status_line };
}

sub shorten_kortanu {
	my ($ua, $url) = @_;
	return _shorten_text($ua, 'http://korta.nu/api/api.php?url=<url>', { url => uri_escape($url) });
}

sub shorten_redirec {
	my ($ua, $url) = @_;
	return _shorten_text($ua, 'http://redir.ec/_api/rest/redirec/create?url=<url>', { url => uri_escape($url) });
}

sub shorten_ipirat {
	my ($ua, $url) = @_;
	return _shorten_text($ua, 'http://ipir.at/yourls-api.php?action=shorturl&format=txt&url=<url>', { url => uri_escape($url) });
}

sub shorten_yepit {
	my ($ua, $url) = @_;
	return _shorten_text($ua, 'http://yep.it/api.php?url=<url>', { url => uri_escape($url) });
}

sub shorten_chilpit {
	my ($ua, $url) = @_;
	return _shorten_text($ua, 'http://chilp.it/api.php?url=<url>', { url => uri_escape($url) });
}

sub shorten_migreme {
	my ($ua, $url) = @_;
	return _shorten_text($ua, 'http://migre.me/api.txt?url=<url>', { url => uri_escape($url) });
}

sub shorten_qlnknet {
	my ($ua, $url) = @_;
	my $resp = $ua->get('http://qlnk.net/api.php?url=' . uri_escape($url));
	if ($resp->is_success) {
		my $content = $resp->decoded_content;
		chomp($content);
		$content =~ s/^\s*(.*)\s*$/\1/g;
		return { "url" => "http://$content/" };
	}
	return { "error" => $resp->status_line };
}

my %shortener = (
	'krzz.de' => \&shorten_krzz,
	'goo.gl' => \&shorten_googl,
	'tinyurl.com' => \&shorten_tinyurl,
	'is.gd' => \&shorten_isgd,
	'bit.ly' => \&shorten_bitly,
	'j.mp' => \&shorten_jmp,
	'b23.ru' => \&shorten_b23ru,
	'cort.as' => \&shorten_cortas,
	'korta.nu' => \&shorten_kortanu,
	'redir.ec' => \&shorten_redirec,
	'ipir.at' => \&shorten_ipirat,
	'yep.it' => \&shorten_yepit,
	'chilp.it' => \&shorten_chilpit,
	'migre.me' => \&shorten_migreme,
	'qlnk.net' => \&shorten_qlnknet,
);

get '/' => sub {
	my $html;
	$t->process("index.tt", { }, \$html) || return $t->error();
	return $html;
};

get '/contact' => sub {
	my $html;
	$t->process("contact.tt", { }, \$html) || return $t->error();
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

