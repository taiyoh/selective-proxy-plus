function FindProxyForURL(url, host) {
	var proxy = 'PROXY <?= $root_config->{domain} ?>:<?= $root_config->{port} ?>';

? for my $h (keys %{$hosts}) {
	if (dnsDomainIs(host, '<?= $h ?>')) {
<? my @p = map {
	   s{\.}{\\.}g;
	   s{\/}{\\/}g;
	   s{\?}{\\?}g;
	   $_
   } keys %{$hosts->{$h}};
?>
		if(/(<?= join( '|', @p) ?>)/.test(url)) {
			return proxy;
		}
	}
? }
	return 'DIRECT';
}
