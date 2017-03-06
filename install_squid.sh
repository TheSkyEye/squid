#Interface
echo '# Interface de loopback
auto lo
iface lo inet loopback
# Interface du Proxy - Coté LAN – Eth0
allow-hotplug eth0
iface eth0 inet static
address 172.16.255.254
netmask 255.255.0.0
network 172.16.0.0
broadcast 172.16.255.255
dns-nameservers 8.8.8.8 # DNS Google

# Interface du Proxy - Coté Internet – Eth1
allow-hotplug eth1
iface eth1 inet static
address 10.30.20.250
netmask 255.255.255.0
gateway 10.30.20.254' >> /etc/network/interfaces

/etc/init.d/networking restart

#Squid
apt-get update
apt-get install -y squid3
service squid stop
echo '# Cette première ligne veut dire que Squid écoute sur le port 3128 et
# qu'il s'attendra à recevoir des requêtes redirigées sans que l'utilisateur 
# client en ait conscience
http_port 3128 

# Cette ligne affichera le nom de machine spécifié lors des messages 
# d'erreurs
visible_hostname squid.test.local

# Access List. Ici on crée un groupe qui sera utilisé pour gérer l'IP 
# source des clients qui utiliserons le proxy.
acl localnet src 10.30.20.0/24

# Squid fonctionne un peu comme Iptables. La première règle qui est 
# concordante avec le paquet qui arrive sera utilisée et n'ira pas plus 
# loin. Ainsi donc, dans notre cas, l'ACL qui regroupe les ip du lan 
#seront autorisées et toutes les autres refusées
http_access allow localnet
http_access deny all


# Spécifie le chemin vers les logs d’accès créé pour chaque page 
# visitée
access_log /var/log/squid3/access.log

# voir dans les logs d’accès squid les url complètes des pages visitées par les utilisateurs
strip_query_terms off

# Indique à Squid d'attendre 4 secondes avant de se couper quand on 
# essaye de le stoper ou de le redémarrer. Par défaut c'est 30 secondes
shutdown_lifetime 4 secondes' >> /etc/squid3/squid.conf

mkdir -p /home/precise/cache/
chmod 777 /home/precise/cache/
chown proxy:proxy /home/precise/cache/
cp /etc/squid3/squid.conf /etc/squid3/squid.conf.origin
chmod a-w /etc/squid3/squid.conf.origin
/etc/init.d/squid3 start

#SquidGuard
apt-get install -y squidguard
cp /etc/squidguard/squidGuard.conf /etc/squidguard/squidGuard.back
echo '#
# CONFIG FILE FOR SQUIDGUARD
#

dbhome /var/lib/squidguard/db
logdir /var/log/squidguard/squidGuard.log

#domaine bloqué
dest ads {
        domainlist      ads/domains
        urllist         ads/urls
}
dest porn {
        domainlist      porn/domains
        urllist         porn/urls
}
dest warez {
        domainlist      warez/domains
        urllist         warez/urls
}

acl {
        default {
                pass    !ads !porn !warez all
                redirect http://localhost/block.html
                }
}' >> /etc/squidguard/squidGuard.conf
 wget --no-check-certificate http://squidguard.mesd.k12.or.us/blacklists.tgz
tar xzf blacklists.tgz
cp -R blacklists/* /var/lib/squidguard/db/
chown -R proxy:proxy /usr/local/squidGuard/db/*
squidGuard -C all

#
#
#Pour mettre une demande de mot de passe pour passer le proxy à l'aide de compte utilisateur
#http://www.open2d.com/administration-systeme/installer-configurer-et-securiser-votre-serveur-proxy-squid3#.WLbrlNLhCig
#auth_param basic program /usr/lib/squid3/ncsa_auth /etc/squid3/users
auth_param basic children 5
auth_param basic realm Votre message d'authentification
auth_param basic credentialsttl 2 hours
auth_param basic casesensitive off
 
acl ncsa_users proxy_auth REQUIRED
 
http_access allow ncsa_users
http_access allow localhost
http_access deny all


Ouvrez votre terminal et tappez:


sudo touch /etc/squid3/users
1
sudo touch /etc/squid3/users
Puis ajouter y des utilisateur avec la commande :


sudo htpasswd -m /etc/squid3/users nom_utilisateur
1
sudo htpasswd -m /etc/squid3/users nom_utilisateur
Cette commande vous demandera alors un password, puis la confirmation de celui-ci pour l’utilisateur nom_utilisateur, puis ajoutera l’utilisateur en question dans le fichier users.


#http://www.ophyde.com/installer-serveur-proxy-squid-squidguard-clamav/
#https://www.vultr.com/docs/setup-squid3-proxy-server-on-debian
