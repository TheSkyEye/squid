apt-get install squidguard
wget http://dsi.ut-capitole.fr/blacklists/download/blacklists.tar.gz
tar -xzf blacklists.tar.gz
cp -R blacklists/* /var/lib/squidguard/db/
cp /etc/squidguard/squidGuard.conf /etc/squidguard/squidGuard.backup
echo "#
# CONFIG FILE FOR SQUIDGUARD
#

dbhome /var/lib/squidguard/db
logdir /var/log/squid3

# les règles de filtrage
dest adult {
        domainlist adult/domains
        urllist adult/urls
        expressionlist adult/very_restrictive_expression
}
dest publicite {
        domainlist publicite/domains
        urllist publicite/urls
}
dest aggressive {
        domainlist aggressive/domains
        urllist aggressive/urls
}

###Forcer la réécriture de https vers http pour les moteurs de recherche et pouvoir analyser les mots
rew safesearch {
 s@(google..*/search?.*q=.*)@ &safe=active@i
  s@(google..*/images.*q=.*)@ &safe=active@i
 s@(google..*/groups.*q=.*)@ &safe=active@i
  s@(google..*/news.*q=.*)@ &safe=active@i
 s@(yandex..*/yandsearch?.*text=.*)@ &fyandex=1@i
  s@(search.yahoo..*/search.*p=.*)@ &vm=r&v=1@i
 s@(search.live..*/.*q=.*)@ &adlt=strict@i
  s@(search.msn..*/.*q=.*)@ &adlt=strict@i
 s@(.bing..*/.*q=.*)@ &adlt=strict@i
  log block.log
 }
#La règle avec les interdictions: !porn !adult !publicite !violence !agressif !aggressive
acl {
  default {
        pass !adult !publicite  !agressif  all
        redirect  http://google.fr ##tout ce qui est inderdit est rediriger vers google
  }
}
" >> /etc/squidguard/squidGuard.conf

ln -s /etc/squidguard/squidGuard.conf /etc/squid3/
chown -R proxy:proxy  /var/log/squid3 /var/lib/squidguard
squidGuard -b -C all
